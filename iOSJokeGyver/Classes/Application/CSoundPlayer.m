/* Copyright (c) 1996-2014 Clickteam
 *
 * This source code is part of the iOS exporter for Clickteam Multimedia Fusion 2
 * and Clickteam Fusion 2.5.
 *
 * Permission is hereby granted to any person obtaining a legal copy
 * of Clickteam Multimedia Fusion 2 or Clickteam Fusion 2.5 to use or modify this source
 * code for debugging, optimizing, or customizing applications created with
 * Clickteam Multimedia Fusion 2 and/or Clickteam Fusion 2.5.
 * Any other use of this source code is prohibited.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */
//----------------------------------------------------------------------------------
//
// CSOUNDPLAYER : synthetiseur MIDI
//
//----------------------------------------------------------------------------------
#import "CSoundPlayer.h"
#import "CRunApp.h"
#import "CRun.h"
#import "CSound.h"
#import "CSoundBank.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CALPlayer.h"
#import <AVFoundation/AVFoundation.h>

@implementation CSoundPlayer

-(void)audioSessionInterrupted:(NSNotification*)notification
{
    NSDictionary* interruptionDictionary = [notification userInfo];
    NSNumber* interruptionType = (NSNumber *)[interruptionDictionary valueForKey:AVAudioSessionInterruptionTypeKey];

    switch (interruptionType.unsignedIntegerValue)
    {
        case AVAudioSessionInterruptionTypeBegan:
        {
            NSLog(@"Interruption Began ...");
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//            [self pause:2];
            [self->runApp->run pause2];
            [runApp->ALPlayer beginInterruption];
        }
            break;
        case AVAudioSessionInterruptionTypeEnded:
        {
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                NSLog(@"Audio interruption ended, resuming sounds ...");
                [runApp->ALPlayer requestAudioSession];
                [runApp->ALPlayer endInterruption];
                [runApp->ALPlayer resetSources];
//                [self resume:2];
                [self->runApp->run resume2];
            }
            else
                NSLog(@"Interruption Ended but not active...");
            [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
            break;
        default:
            break;
    }
}

-(id)initWithApp:(CRunApp*)app
{
    if(self = [super init])
    {
        runApp=app;
        parentPlayer=nil;
        channels = (CSound**)calloc(NCHANNELS, sizeof(CSound*));
        volumes=(int*)calloc(NCHANNELS, sizeof(int));
        frequencies = (int*)calloc(NCHANNELS, sizeof(int));
        panes = (float*)calloc(NCHANNELS, sizeof(float));
        bLocked=(BOOL*)calloc(NCHANNELS, sizeof(BOOL));
        
        bOn=YES;
        bMultipleSounds=YES;
        pausedBy = -1;
        
        int n;
        for (n=0; n<NCHANNELS; n++)
        {
            volumes[n]=100;
            panes[n] = 0.0f;
            bLocked[n]=NO;
        }
        mainVolume=100;
        
        NSError* error = nil;
        AVAudioSession* audioSession = [AVAudioSession sharedInstance];
        [audioSession setPreferredSampleRate:44100 error:&error];
        if (error != nil)
            NSLog(@"Audio session change with error: %@", [error localizedDescription]);

        if(!runApp->enable_ext_sounds) 
        {
            [audioSession setCategory:AVAudioSessionCategorySoloAmbient withOptions:0 error:&error];
        }
        else 
        {
           [audioSession setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioSessionInterrupted:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:nil];
        
        [audioSession setActive:YES error:&error];
        if (error != nil)
            NSLog(@"Audio session change with error: %@", [error localizedDescription]);
        
    }
    return self;
}

-(id)initWithApp:(CRunApp*)app andSoundPlayer:(CSoundPlayer*)player
{
    if(self = [super init])
    {
        runApp=app;
        parentPlayer = player;
        channels = (CSound**)calloc(NCHANNELS, sizeof(CSound*));
        volumes=(int*)calloc(NCHANNELS, sizeof(int));
        frequencies = (int*)calloc(NCHANNELS, sizeof(int));
		panes = (float*)calloc(NCHANNELS, sizeof(float));
        bLocked=(BOOL*)calloc(NCHANNELS, sizeof(BOOL));
        
        bOn=YES;
        bMultipleSounds=YES;
        pausedBy = -1;
        
        int n;
        for (n=0; n<NCHANNELS; n++)
        {
            volumes[n]=100;
            panes[n] = 0.0f;
            bLocked[n]=NO;
        }
        mainVolume=100;
    }
    return self;
}

-(void)dealloc
{
    free(channels);
    free(volumes);
    free(frequencies);
    free(panes);
    free(bLocked);
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    [super dealloc];
}

-(void)reset
{
    int n;
    for (n=0; n<NCHANNELS; n++)
    {
        //		volumes[n]=100;
        bLocked[n]=NO;
    }
    //	mainVolume=100;
}

-(void)play:(short)handle withNLoops:(int)nLoops andChannel:(int)channel andPrio:(BOOL)bPrio andVolume:(int)_volume andPan:(int)_pan andFreq:(int)_freq
{
	// Note: _volume, _pan and _freq are valid if _volume != -1
    int n;
    
    if (bOn == NO)
    {
        return;
    }
    
    CSound* handleSound = [runApp->soundBank getSoundFromHandle:handle];
    if (handleSound == nil)
    {
        return;
    }
    //Read handle Sound, after verify that is not been asigned to a channels
    // make it as sound in case have been asigned make a clone of it, max time 0.015 millisecs
    CSound* sound;
    if(!handleSound->bAsigned)
        sound = handleSound;
    else
        sound = [handleSound mutableCopy];
    
    if (bMultipleSounds == NO)
    {
        channel = 0;
    }
    
    /* UNINTERRUPTABLE - This option means that the sound cannot be interrupted by a sound that hasn't this option.
     * A sound can be interrupted by another one in 2 cases:
     *         (1) when you play the sound on a specific channel and another one is already playing on this channel, or
     *         (2) when you play a sound without specifying a channel and there is no free channel available.
     *             (a) If the playing sound has the option and the new sound hasn't the option, the new sound won't be played.
     *             (b) The sound will be played on the first channel whose sound hasn't this option.
     */
    
	@synchronized (sound) {
		// Channel == -1 => find free channel
        if (channel < 0)
        {
            for (n = 0; n < NCHANNELS; n++)
            {
                if (channels[n] == nil && bLocked[n]==NO)
                {
                    break;
                }
            }
            if (n == NCHANNELS)
            {
                // Stoppe le son sur un canal deja en route
                for (n = 0; n < NCHANNELS; n++)
                {
                    if (bLocked[n]==NO)
                    {
                        if (channels[n] != nil)
                        {
                            if (channels[n]->bUninterruptible == NO)
                            {
                                [channels[n] stop];
                                channels[n]=nil;
                            }
                        }
                    }
                }
            }
            channel = n;
            if (channel>=0 && channel< NCHANNELS)
            {
				// Reset channel settings if unspecified in parameters
				if (_volume == -1)
				{
					volumes[channel] = mainVolume;
					panes[channel] = 0.0f;
					frequencies[channel] = 0;
				}
			}
        }

        if (channel < 0 || channel >= NCHANNELS)
        {
            return;
        }
        
		// Set channel volume and frequency if specified
		if (_volume != -1)
		{
			volumes[channel] = _volume;
			panes[channel] = (float)_pan / 100.0f;
			frequencies[channel] = _freq;
		}
		
        if (channels[channel] != nil)
        {
			if (channels[channel]->bUninterruptible && !bPrio)
				return;

            [channels[channel] stop];
            channels[channel] = nil;
        }
        sound->bAsigned = YES;
        channels[channel] = sound;
        channels[channel]->bUninterruptible=bPrio;
        [channels[channel] play:nLoops channel:channel];
        [channels[channel] setVolume:volumes[channel]];
        if(frequencies[channel] > 0)
            [channels[channel] setPitch:frequencies[channel]];
        if(panes[channel] != 0)
            [channels[channel] setPan:panes[channel]];

    }
}

-(void)setMultipleSounds:(BOOL)bMultiple
{
    bMultipleSounds = bMultiple;
}

-(void)keepCurrentSounds
{
    for (int n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            if (channels[n]->bPlaying)
            {
                [runApp->soundBank setToLoad:channels[n]->handle];
            }
        }
    }
}

-(void)setOnOff:(BOOL)bState
{
    if (bState != bOn)
    {
        bOn = bState;
        if (bOn == NO)
        {
            [self stopAllSounds];
        }
    }
}

-(BOOL)getOnOff
{
    return bOn;
}

-(void)stopAllSounds
{
    for (int n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            [channels[n] stop];
            channels[n]->bUninterruptible=NO;
            channels[n]=nil;
        }
    }
}

-(void)stopSample:(short)handle
{
    for (int c = 0; c < NCHANNELS; c++)
    {
        if (channels[c] != nil)
        {
            if (channels[c]->handle == handle)
            {
                [channels[c] stop];
                channels[c]->bUninterruptible=NO;
                channels[c] = nil;
            }
        }
    }
}
-(BOOL)isSamplePaused:(short)handle
{
    for (int c = 0; c < NCHANNELS; c++)
    {
        if (channels[c] != nil)
        {
            if (channels[c]->handle == handle)
            {
                return [channels[c] isPaused];
            }
        }
    }
    return NO;
}

-(BOOL)isSoundPlaying
{
    for (int n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            if (channels[n]->bPlaying)
            {
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL)isSamplePlaying:(short)handle
{
    for (int n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            if (channels[n]->handle == handle)
            {
                if (channels[n]->bPlaying)
                {
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(BOOL)isChannelPlaying:(int)channel
{
    if (channel >= 0 && channel < NCHANNELS)
    {
        if (channels[channel] != nil)
        {
            if (channels[channel]->bPlaying)
            {
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL)isChannelPaused:(int)channel
{
    if (channel >= 0 && channel < NCHANNELS)
    {
        if (channels[channel] != nil)
        {
            return [channels[channel] isPaused];
        }
    }
    return NO;
}

-(void)setPositionSample:(short)handle withPosition:(int)pos
{
    for (int n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            if (channels[n]->handle == handle)
            {
                [channels[n] setPosition:pos];
            }
        }
    }
}

-(int)getPositionSample:(short)handle
{
    for (int n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            if (channels[n]->handle == handle)
            {
                return [channels[n] getPosition];
            }
        }
    }
    return 0;
}

-(void)pauseSample:(short)handle
{
    for (int n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            if (channels[n]->handle == handle)
            {
                [channels[n] pause:0];
            }
        }
    }
}

-(void)resumeSample:(short)handle
{
    for (int n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            if (channels[n]->handle == handle)
            {
                [channels[n] resume:0];
            }
        }
    }
}

-(void)pause:(int)pausemode
{
    for (int n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            [channels[n] pause:pausemode];
        }
    }
    pausedBy = pausemode;
}

-(void)resume:(int)pausemode
{
    for (int n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            [channels[n] resume:pausemode];
        }
    }
    pausedBy = -1;
}

-(void)pauseChannel:(int)channel
{
    if (channel >= 0 && channel < NCHANNELS)
    {
        if (channels[channel] != nil)
        {
            [channels[channel] pause:0];
        }
    }
}

-(void)stopChannel:(int)channel
{
    if (channel >= 0 && channel < NCHANNELS)
    {
        if (channels[channel] != nil)
        {
            [channels[channel] stop];
            channels[channel]->bUninterruptible=NO;
            channels[channel] = nil;
        }
    }
}

-(void)resumeChannel:(int)channel
{
    if (channel >= 0 && channel < NCHANNELS)
    {
        if (channels[channel] != nil)
        {
            [channels[channel] resume:0];
        }
    }
}

-(void)setPositionChannel:(int)channel withPosition:(int)pos
{
    if (channel >= 0 && channel < NCHANNELS)
    {
        if (channels[channel] != nil)
        {
            [channels[channel] setPosition:pos];
        }
    }
}

-(int)getPositionChannel:(int)channel
{
    if (channel >= 0 && channel < NCHANNELS)
    {
        if (channels[channel] != nil)
        {
            //NSLog(@"Channel:%d and object channels:%@", channel, channels[channel] );
            return [channels[channel] getPosition];
        }
    }
    return 0;
}

-(void)setVolumeSample:(short)handle withVolume:(int)v
{
    if (v<0) v=0;
    if (v>100) v=100;
    int n;
    for (n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            if (channels[n]->handle == handle)
            {
                volumes[n]=v;
                [channels[n] setVolume:v];
            }
        }
    }
}

-(void)setFreqSample:(short)handle withFreq:(int)v
{
    if (v<0) v=0;
    if (v>100000) v=100000;
    if (v==0)
    {
        v=42000;
    }
    
    int n;
    for (n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            if (channels[n]->handle == handle)
            {
                frequencies[n]=v;
                //[channels[n] setPitch:v/42000.0f];
                [channels[n] setPitch:v*1.0f];
            }
        }
    }
}

-(void)setVolumeChannel:(int)channel withVolume:(int)v
{
    if (v<0) v=0;
    if (v>100) v=100;
    
    if (channel >= 0 && channel < NCHANNELS)
    {
        volumes[channel]=v;
        if (channels[channel] != nil)
        {
            [channels[channel] setVolume:v];
        }
    }
}

-(void)setFreqChannel:(int)channel withFreq:(int)v
{
    if (v<0) v=0;
    if (v>100000) v=100000;
    if (v==0)
    {
        v=42000;
    }
    
    if (channel >= 0 && channel < NCHANNELS)
    {
        volumes[channel]=v;
        if (channels[channel] != nil)
        {
            frequencies[channel]=v;
            [channels[channel] setPitch:v];
        }
    }
}
-(int)getSampleFrequency:(NSString*)name
{
    int c=[self getChannel:name];
    if (c>=0)
    {
        return frequencies[c];
    }
    return 0;
}

-(int)getFrequencyChannel:(int)channel
{
    if (channel >= 0 && channel < NCHANNELS)
    {
        if (channels[channel] != nil)
        {
            int f = [channels[channel] getPitch];
            if(f < 0)
                return frequencies[channel];
            else
                return f;
        }
    }
    return 0;
}


-(int)getVolumeChannel:(int)channel
{
    if (channel >= 0 && channel < NCHANNELS)
    {
        if (channels[channel] != nil)
        {
            return volumes[channel];
        }
    }
    return 0;
}

-(int)getDurationChannel:(int)channel
{
    if (channel >= 0 && channel < NCHANNELS)
    {
        if (channels[channel] != nil)
        {
            return [channels[channel] getDuration];
        }
    }
    return 0;
}
-(void)setMainVolume:(int)v
{
    if (v<0) v=0;
    if (v>100) v=100;
    
    mainVolume=v;
    int n;
    for (n=0; n<NCHANNELS; n++)
    {
        volumes[n]=v;
        if (channels[n]!=nil)
        {
            [channels[n] setVolume:v];
        }
    }
}
-(int)getMainVolume
{
    return mainVolume;
}

-(void)setPan:(float)pan
{
    if (pan >  1.0f) pan =  1.0f;
    if (pan < -1.0f) pan = -1.0f;
    
    mainPan = pan;
    int n;
    for (n=0; n<NCHANNELS; n++)
    {
        if (channels[n]!=nil)
        {
            [channels[n] setPan:pan];
        }
    }
}

-(float)getPan
{
    return mainPan;
}

-(void)setPanChannel:(int)n withPan:(float)pan
{
    if (pan >  1.0f) pan =  1.0f;
    if (pan < -1.0f) pan = -1.0f;
    
    if (channels[n]!=nil)
    {
        panes[n] = pan;
        [channels[n] setPan:pan];
    }

}
-(float)getPanChannel:(int)n
{
    float pan = 0;
    
    if (channels[n]!=nil)
    {
        pan = panes[n];
    }
    return pan;
}

-(void)setPanSample:(short)handle withPan:(float)pan
{
    if (pan >  1.0f) pan =  1.0f;
    if (pan < -1.0f) pan = -1.0f;
    int n;
    for (n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            if (channels[n]->handle == handle)
            {
                panes[n]=pan;
                [channels[n] setPan:pan];
            }
        }
    }
}

-(float)getSamplePan:(NSString*)name
{
    float pan = 0;
    int c=[self getChannel:name];
    
    if (c>=0)
    {
        pan = panes[c];
    }
    return pan;
}

-(void)removeSound:(CSound*)s
{
    int n;
    for (n=0; n<NCHANNELS; n++)
    {
        if (channels[n]==s)
        {
            channels[n]->bUninterruptible=NO;
            frequencies[n]=0;
            [channels[n] stop];
            channels[n]=nil;
        }
    }
}
-(void)checkPlaying
{
    int n;
    for (n = 0; n < NCHANNELS; n++)
    {
        if (channels[n] != nil)
        {
            [channels[n] checkPlaying];
        }
    }
}

-(void)lockChannel:(int)channel
{
    if (channel >= 0 && channel < NCHANNELS)
    {
        bLocked[channel]=YES;
    }
}

-(void)unLockChannel:(int)channel
{
    if (channel >= 0 && channel < NCHANNELS)
    {
        bLocked[channel]=NO;
    }
}

-(int)getChannel:(NSString*)name
{
    int c;
    for (c = 0; c < NCHANNELS; c++)
    {
        if (channels[c] != nil)
        {
            if ([channels[c]->name compare:name]==0)
            {
                return c;
            }
        }
    }
    return -1;
}
-(int)getSamplePosition:(NSString*)name
{
    int c=[self getChannel:name];
    if (c>=0)
    {
        return [channels[c] getPosition];
    }
    return 0;
}
-(int)getSampleVolume:(NSString*)name
{
    int c=[self getChannel:name];
    if (c>=0)
    {
        return [channels[c] getVolume];
    }
    return 0;
}
-(int)getSampleDuration:(NSString*)name
{
    int c=[self getChannel:name];
    if (c>=0)
    {
        return [channels[c] getDuration];
    }
    return 0;
}
-(NSString*)getSoundNameChannel:(int)channel
{
	if (channel>=0 && channel<NCHANNELS && channels[channel] != nil)
	{
		return channels[channel]->name;
	}
	return @"";
}


-(void)setAudioSessionMode:(BOOL)bflag andMode:(int)mode
{
    NSError* error = nil;
    
    runApp->enable_ext_sounds = bflag;
    
    [runApp->ALPlayer setAllowOtherAppSounds:runApp->enable_ext_sounds];
    
    if(mode ==1){
        [self pause:2];
        [runApp->ALPlayer beginInterruption];
    }
    
    if (mode == 0)
    {
        [[AVAudioSession sharedInstance] setActive:NO error:&error];
        
        if (runApp->enable_ext_sounds)
        {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
        }
        else
        {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient withOptions:0 error:&error];
        }
        
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        
        if (error != nil)
            NSLog(@"Audio session change with error: %@", [error localizedDescription]);
        
    }
    
    if(mode ==1){
        [runApp->ALPlayer endInterruption];
        [self resume:2];
    }
}
@end
