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
//
//  CALPlayer.m
//  RuntimeIPhone
//
//  Created by Francois Lionet on 24/03/11.
//  Copyright 2011 Clickteam. All rights reserved.
//

#import "CALPlayer.h"
#import "CSound.h"

#import <AVFoundation/AVFoundation.h>

OSStatus read_Proc (void *inClientData, SInt64 inPosition, UInt32 requestCount, void *buffer, UInt32 *actualCount)
{
    NSData* data=(NSData*)inClientData;
    
    NSRange range;
    NSUInteger length=requestCount;
    if (length+inPosition>[data length])
    {
        length=[data length]-(unsigned int)inPosition;
    }        
    range.location=(unsigned int)inPosition;
    range.length=length;
    [data getBytes:buffer range:range];
    *actualCount=(UInt32)length;
    return noErr;
}
OSStatus write_Proc (void *inClientData, SInt64 inPosition, UInt32 requestCount, const void *buffer, UInt32  *actualCount)
{
    *actualCount=0;
    return noErr;
}
SInt64 getSize_Proc (void *inClientData)
{
    NSData* data=(NSData*)inClientData;
    return [data length];
}
OSStatus setSize_Proc (void *inClientData, SInt64 size)
{
    return noErr;
}

void* GetOpenALAudioData(NSData* data, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei* outSampleRate)
{
	OSStatus err = noErr;
	SInt64 theFileLengthInFrames = 0;
	AudioStreamBasicDescription theFileFormat;
	UInt32 thePropertySize = sizeof(theFileFormat);
	ExtAudioFileRef extRef = NULL;
	void* theData = NULL;
	AudioStreamBasicDescription theOutputFormat;
    BOOL isStereo=false, isPCM = false, is16Bits = false;
    
	// Open a file with ExtAudioFileOpen()
    AudioFileID fid = 0;
    err=AudioFileOpenWithCallbacks(data, read_Proc, write_Proc, getSize_Proc, setSize_Proc, 0, &fid);
    if (err)
		return ExitFunction(extRef, fid, theData);
    err=ExtAudioFileWrapAudioFileID(fid, false, &extRef);
	if(err)
		return ExitFunction(extRef, fid, theData);
    
	// Get the audio data format
	err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileDataFormat, &thePropertySize, &theFileFormat);
	if(err)
		return ExitFunction(extRef, fid, theData);
	if (theFileFormat.mChannelsPerFrame > 2)
		return ExitFunction(extRef, fid, theData);
    
	// Set the client format to 16 bit signed integer (native-endian) data
	// Maintain the channel count and sample rate of the original source format
	theOutputFormat.mSampleRate = theFileFormat.mSampleRate;
	theOutputFormat.mChannelsPerFrame = theFileFormat.mChannelsPerFrame;
    
	theOutputFormat.mFormatID = kAudioFormatLinearPCM;
	theOutputFormat.mBytesPerPacket = 2 * theOutputFormat.mChannelsPerFrame;
	theOutputFormat.mFramesPerPacket = 1;
	theOutputFormat.mBytesPerFrame = 2 * theOutputFormat.mChannelsPerFrame;
	theOutputFormat.mBitsPerChannel = 16;
	theOutputFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    
    is16Bits = theFileFormat.mBitsPerChannel > 8;
    isPCM = theFileFormat.mFormatID == kAudioFormatLinearPCM;
    isStereo = theOutputFormat.mChannelsPerFrame > 1;
	// Set the desired client (output) data format
	err = ExtAudioFileSetProperty(extRef, kExtAudioFileProperty_ClientDataFormat, sizeof(theOutputFormat), &theOutputFormat);
	if(err)
		return ExitFunction(extRef, fid, theData);
    
    //Use Methods according format
    UInt32 bytesRead = 0;
    if(isPCM)
    {
        UInt64 audioDataByteCount = 0;
        UInt32 sizePropertySize = sizeof(audioDataByteCount);
        err = AudioFileGetProperty(fid, kAudioFilePropertyAudioDataByteCount, &sizePropertySize, &audioDataByteCount);
        
        bytesRead = (UInt32)audioDataByteCount;
        theData = calloc(bytesRead, sizeof(char));
    }
    else
    {
        // Get the total frame count
        thePropertySize = sizeof(theFileLengthInFrames);
        err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileLengthFrames, &thePropertySize, &theFileLengthInFrames);
        if(err)
            return ExitFunction(extRef, fid, theData);
        
        // Read all the data into memory
        bytesRead = (UInt32)(theFileLengthInFrames * theOutputFormat.mBytesPerFrame);
        theData = calloc(bytesRead, sizeof(SInt16));
    }
    if (theData)
    {
        if(isPCM)
        {
            err = AudioFileReadBytes(fid, false, 0, (UInt32*)&bytesRead, theData);
        }
        else
        {
            AudioBufferList theDataBuffer;
            theDataBuffer.mNumberBuffers = 1;
            theDataBuffer.mBuffers[0].mDataByteSize = bytesRead;
            theDataBuffer.mBuffers[0].mNumberChannels = theOutputFormat.mChannelsPerFrame;
            theDataBuffer.mBuffers[0].mData = theData;
            
            // Read the data into an AudioBufferList
            err = ExtAudioFileRead(extRef, (UInt32*)&theFileLengthInFrames, &theDataBuffer);
            
        }
        if(err == noErr)
        {
            // success
            *outDataSize = (ALsizei)bytesRead;
            if(isPCM)
                *outDataFormat = (isStereo ? (is16Bits ? AL_FORMAT_STEREO16 : AL_FORMAT_STEREO8)
                                                    : (is16Bits ? AL_FORMAT_MONO16 : AL_FORMAT_MONO8));
            else
                *outDataFormat = (isStereo ? AL_FORMAT_STEREO16 :AL_FORMAT_MONO16);
            *outSampleRate = (ALsizei)theOutputFormat.mSampleRate;
        }
        else
        {
            // failure
            free (theData);
            theData = NULL; // make sure to return NULL
            return ExitFunction(extRef, fid, theData);
        }
    }
    return ExitFunction(extRef, fid, theData);
}

void* ExitFunction(ExtAudioFileRef extRef, AudioFileID fid, void* theData)
{
	// Dispose the ExtAudioFileRef, it is no longer needed
	if (extRef)
		ExtAudioFileDispose(extRef);
    if (fid)
		AudioFileClose(fid);
	return theData;
}


@implementation CALPlayer

-(id)init
{
    mDevice=alcOpenDevice(NULL);
	parentPlayer=nil;
	mContext = nil;
    if (mDevice)
    {
        mContext=alcCreateContext(mDevice, NULL);
        alcMakeContextCurrent(mContext);
    }
    alGetError();
    int n;
    for (n=0; n<NALCHANNELS; n++)
    {
        pSources[n]=0;
        pSounds[n]=nil;
    }
    bPaused=NO;
    bSessionInterrupted=NO;
    return self;
}
-(id)initWithPlayer:(CALPlayer*)parent
{
    mDevice=parent->mDevice;
	parentPlayer = parent;
    int n;
    for (n=0; n<NALCHANNELS; n++)
    {
        pSources[n]=0;
        pSounds[n]=nil;
    }
    bPaused=NO;
    return self;
}

-(void)dealloc
{
    if (mDevice && parentPlayer==nil)
    {
        int n;
        for (n=0; n<NALCHANNELS; n++)
        {
            if (pSources[n]!=0)
            {
                alDeleteSources(1, &pSources[n]);
            }
        }
        alcMakeContextCurrent(NULL);
        alcDestroyContext(mContext);
        alcCloseDevice(mDevice);
    }
    [super dealloc];
}
-(int)play:(CSound*)pSound loops:(int)nl channel:(int)channel
{
    if (pSound->bufferID==0)
    {
        return -1;
    }
    if (mDevice)
    {
        bPaused=NO;
        if (pSounds[channel]==pSound)
        {
            nLoops[channel]=nl;
			alSourceStop(pSources[channel]);
			alSourcei(pSources[channel], AL_BUFFER, AL_NONE);
			
			if(nl > 0)
			{
				alSourcei(pSources[channel], AL_LOOPING, AL_FALSE);
				for(int i=0; i<nl; ++i)
					alSourceQueueBuffers(pSources[channel], 1, &pSound->bufferID);
			}
			else
			{
				alSourcei(pSources[channel], AL_BUFFER,  pSound->bufferID);
				alSourcei(pSources[channel], AL_LOOPING, AL_TRUE);
			}
			
			alSourceRewind(pSources[channel]);
			alSourcePlay(pSources[channel]);
            return channel;
        }
        if (pSounds[channel]!=nil)
        {
            alSourceStop(pSources[channel]);
        }
        if (pSources[channel]==0)
        {
            alGenSources(1, &pSources[channel]);
        }
        pSounds[channel]=pSound;
        nLoops[channel]=nl;
        float pan = [pSound getPan] * 0.99f; // not perfect but work

		alSourceStop(pSources[channel]);
		alSourcei(pSources[channel], AL_BUFFER, AL_NONE);
		
		if(nl > 0)
		{
			alSourcei(pSources[channel], AL_LOOPING, AL_FALSE);
			for(int i=0; i<nl; ++i)
				alSourceQueueBuffers(pSources[channel], 1, &pSound->bufferID);
		}
		else
		{
			alSourcei(pSources[channel], AL_BUFFER,  pSound->bufferID);
			alSourcei(pSources[channel], AL_LOOPING, AL_TRUE);
		}
		
        alSourcef(pSources[channel], AL_PITCH, 1.0f);
        alSourcef(pSources[channel], AL_GAIN, 1.0f);
		
        alSourcei(pSources[channel], AL_SOURCE_RELATIVE, TRUE);
        if(pan != 0)
        {
            alSourcef(pSources[channel], AL_GAIN, 1.1f);
            alSource3f(pSources[channel], AL_POSITION, pan, 0, abs(pan));
        }
        else
            alSource3f(pSources[channel], AL_POSITION, 0.0f, 0.0f, 0.0f);

        alSourceRewind(pSources[channel]);
        alSourcePlay(pSources[channel]);
		
        return channel;
    }       
    return -1;
}
-(void)resetSources
{
    int n;
    for (n=0; n<NALCHANNELS; n++)
    {
        if (pSources[n]!=0)
        {
            ALenum state;
            alGetSourcei(pSources[n], AL_SOURCE_STATE, &state);
            if (state!=AL_PLAYING && state!=AL_PAUSED)
            {
                alDeleteSources(1, &pSources[n]);
                pSources[n]=0;
            }            
        }
    }
}
-(void)beginInterruption
{
    if(bSessionInterrupted)
        return;

    NSLog(@"Started Interruption ...");
    
    mContext = alcGetCurrentContext();
    alcMakeContextCurrent(NULL);
    alcSuspendContext(mContext);
    
    bSessionInterrupted=YES;

}
-(void)endInterruption
{
    if(!bSessionInterrupted)
        return;

    if (alcGetCurrentContext() != NULL)
          alcMakeContextCurrent(NULL);
    alcMakeContextCurrent(mContext);
    alcProcessContext(mContext);
    
    bSessionInterrupted=NO;

    NSLog(@"Ended Interruption ...");
}

-(BOOL)isSessionInterrupted
{
    return bSessionInterrupted;
}

-(BOOL)requestAudioSession
{
    NSError* error = nil;
    BOOL bResult = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if(error != nil)
        NSLog(@"Audio error: %@", [error localizedDescription]);
    
    [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:&error];
    return bResult;
}

-(BOOL)dropAudioSession
{
    NSError* error = nil;
    BOOL bResult = [[AVAudioSession sharedInstance] setActive:NO error:&error];
    if(error != nil)
        NSLog(@"Audio error: %@", [error localizedDescription]);

    return bResult;
}

-(void)stop:(int)nSound
{
    if (nSound>=0 && pSources[nSound]!=0)
    {
        alSourceStop(pSources[nSound]);
		alDeleteSources(1, &pSources[nSound]);
		pSources[nSound]=0;
        pSounds[nSound]=nil;
        bPaused=NO;
    }
}
-(void)pause:(int)nSound
{
    if (nSound>=0 && pSources[nSound]!=0)
    {
        alSourcePause(pSources[nSound]);
        bPaused=YES;
    }
}
-(void)resume:(int)nSound
{
    if (nSound>=0 && pSources[nSound]!=0)
    {
        alSourcePlay(pSources[nSound]);
        bPaused=NO;
    }
}
-(void)rewind:(int)nSound
{
    if (nSound>=0 && pSources[nSound]!=0)
    {
        alSourceRewind(pSources[nSound]);
    }
}
-(void)setVolume:(int)nSound volume:(float)v
{
    if (nSound>=0 && pSources[nSound]!=0)
    {
        alSourcef(pSources[nSound], AL_GAIN, v);
    }
}
-(void)setPitch:(int)nSound pitch:(float)v
{
    if (nSound>=0 && pSources[nSound]!=0)
    {
        alSourcef(pSources[nSound], AL_PITCH, v);
    }
}
-(void)setPan:(int)nSound pan:(float)p
{
    if (nSound>=0 && pSources[nSound]!=0)
    {
        float pan = p * 0.99f; // not perfect but work
        if(pan != 0)
        {
            alSourcef(pSources[nSound], AL_GAIN, 1.1f*([pSounds[nSound] getVolume]/100.0f));
            alSource3f(pSources[nSound], AL_POSITION, pan, 0, abs(pan));
        }
        else
        alSource3f(pSources[nSound], AL_POSITION, 0, 0, 0);
    }
}
-(BOOL)checkPlaying:(int)nSound
{
    if (bPaused)
    {
        return true;
    }
    if (nSound>=0 && pSources[nSound]!=0)
    {
        if (pSounds[nSound]!=nil)
        {
            ALenum state;
            alGetSourcei(pSources[nSound], AL_SOURCE_STATE, &state);
            if (state==AL_PLAYING || state==AL_INITIAL || state==AL_PAUSED)
            {
                return true;
            }
            pSounds[nSound]=nil;
        }
    }
    return false;    
}

-(int)getPosition:(int)nSound
{
    float offset = 0;
    int loops=0;
    int  pos=0;
    
    alGetSourcef(pSources[nSound], AL_SEC_OFFSET, &offset);
    alGetSourcei(pSources[nSound], AL_BUFFERS_QUEUED, &loops);
    //NSLog(@"Audio position: %f", offset*1000);
    pos = (int)(offset*1000);
    if(pos > (loops-1)*pSounds[nSound]->duration)
        pos -= (loops-1)*pSounds[nSound]->duration;
    
    return pos;
}

-(void)setPosition:(int)nSound andPos:(float)p
{
    if (nSound>=0 && pSources[nSound]!=0)
    {
        alSourcef(pSources[nSound], AL_SEC_OFFSET, ((double)p/1000));
    }
    
}

-(void)setAllowOtherAppSounds:(BOOL)bflag
{
    enable_ext_sounds = bflag;
}

@end
