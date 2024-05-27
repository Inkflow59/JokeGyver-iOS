/* Copyright (c) 1996-2020 Clickteam
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
// CRunVideo
//
//----------------------------------------------------------------------------------
#import "CRuniOSVideo.h"
#import "CFile.h"
#import "CRunApp.h"
#import "CBitmap.h"
#import "CCreateObjectInfo.h"
#import "CValue.h"
#import "CExtension.h"
#import "CRun.h"
#import "CActExtension.h"
#import "CImageBank.h"
#import "CServices.h"
#import "CImage.h"
#import "CRunView.h"
#import "CRSpr.h"

#define CND_PLAYING 0
#define CND_STOPPED 1
#define CND_PAUSED 2
#define CND_AIRPLAYENABLED 3
#define CND_VIDATSTART 4
#define CND_VIDENDED 5
#define CND_VIDREADY 6
#define CND_LAST 7

#define ACT_SETURL 0
#define ACT_INITIALPLAYBACK 1
#define ACT_ENDPLAYBACK 2
#define ACT_REPEAT 3
#define ACT_PLAY 4
#define ACT_VIDEOPAUSE 5
#define ACT_STOP 6
#define ACT_SETPLAYBACKTIME 7
#define ACT_BEGINSEEKFORWARD 8
#define ACT_BEGINSEEKBACKWARD 9
#define ACT_ENDSEEK 10


#define EXP_DURATION 0
#define EXP_STATE 1
#define EXP_PLAYABLEDURATION 2
#define EXP_PLAYBACKTIME 3

#define VFLAG_PLAYATSTART   0x0001
#define VFLAG_REPEAT        0x0002
#define VFLAG_FULLSCREEN    0x0004
#define VFLAG_ALLOWAIRPLAY  0x0008

@implementation CRuniOSVideo

-(int)getNumberOfConditions
{
	return CND_LAST;
}

-(BOOL)createRunObject:(CFile*)file withCOB:(CCreateObjectInfo*)cob andVersion:(int)version
{
    ho->hoImgWidth=[file readAInt];
    ho->hoImgHeight=[file readAInt];
    flags=[file readAInt];
    controls=[file readAShort];
    scaling=[file readAShort];
    url=[file readAString];
    initialPlayback=-1;
    endPlayback=-1;
    oldX=oldY=-1;
    [self startVideo];
    return YES;
}

-(NSURL*)getURL:(NSString*)file
{
    NSURL* pUrl=nil;
    if ([file length]>7)
    {
        NSString* debut=[file substringToIndex:7];
        if ([debut caseInsensitiveCompare:@"http://"]==0
            || [debut caseInsensitiveCompare:@"https:/"]==0)
        {
            pUrl=[NSURL URLWithString:file];
        }
    }
    if (pUrl==nil)
    {
        NSRange point=[file rangeOfString:@"."];
        if (point.location!=NSNotFound)
        {
            NSString* extension=[file substringFromIndex:point.location+1];
            file=[file substringToIndex:point.location];
			NSString* resourcePath = [[NSBundle mainBundle] pathForResource:file ofType:extension];
            if(resourcePath == nil){
				NSLog(@"The video file %@.%@ was not found", file, extension);
				return nil;
			}
			pUrl=[NSURL fileURLWithPath:resourcePath];
        }
    }
    return pUrl;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    AVPlayer* player = avPlayerViewController.player;

    if(!player)
        return;
    if (object == player && [keyPath isEqualToString:@"status"]) {
        if (player.status == AVPlayerStatusReadyToPlay)
        {
            [ho pushEvent:CND_VIDREADY withParam:0];
            
            if((ho->ros->rsFlags & RSFLAG_VISIBLE) != 0)
                avPlayerViewController.view.hidden = NO;
            
            if ((flags&VFLAG_PLAYATSTART) != 0)
            {
                if ((flags&VFLAG_FULLSCREEN) != 0)
                {
                    if (@available(iOS 11.0, *)) {
                        [self presentFullScreen:avPlayerViewController];
                    }
                }
                [player play];
            }
        }
    }
}

-(void)videoAtStart:(NSTimeInterval)seconds
{
    //NSLog(@"Video at start..");
    if(resetStart)
        [ho pushEvent:CND_VIDATSTART withParam:0];
    resetStart = NO;
}

-(void)startVideo
{
    NSURL* pUrl=[self getURL:url];
    if (pUrl!=nil)
    {
        resetStart = YES;
        videoStatus = 0;
        AVAsset *asset = [AVAsset assetWithURL:pUrl];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
        
        if (avPlayerViewController == nil)
        {
            AVPlayer* avPlayer= [AVPlayer playerWithPlayerItem:playerItem];
            avPlayerViewController = [AVPlayerViewController new];
            avPlayerViewController.player = avPlayer;
            avPlayerViewController.view.hidden = YES;
            avPlayerViewController.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
            avPlayerViewController.view.opaque = NO;
            
            switch (controls)
            {
                case 0:
                    [avPlayerViewController.view setUserInteractionEnabled:NO];
                    avPlayerViewController.showsPlaybackControls = NO;
                    if(@available(iOS 13.0, *))
                        avPlayerViewController.showsTimecodes = NO;
                    break;
                case 1:
                    [avPlayerViewController.view setUserInteractionEnabled:NO];
                    avPlayerViewController.showsPlaybackControls = NO;
                    if(@available(iOS 13.0, *))
                        avPlayerViewController.showsTimecodes = YES;
                    break;
                case 2:
                    [avPlayerViewController.view setUserInteractionEnabled:NO];
                    avPlayerViewController.showsPlaybackControls = NO;
                    break;
                case 3:
                    [avPlayerViewController.view setUserInteractionEnabled:YES];
                    avPlayerViewController.showsPlaybackControls = YES;
                    break;
            }

            switch (scaling)
            {
                case 1:
                    avPlayerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
                    break;
                case 2:
                    avPlayerViewController.videoGravity = AVLayerVideoGravityResizeAspectFill;
                    break;
                case 3:
                    avPlayerViewController.videoGravity = AVLayerVideoGravityResize;
                    break;
            }

            if ((flags&VFLAG_REPEAT)!=0)
            {
                avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            }
            else
            {
                avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
            }
            
            [avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
            if(@available(iOS 10.0, *))
                [avPlayer addObserver:self forKeyPath:@"timeControlStatus" options:0 context:nil];
            else
                [avPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];

           timeObserver = [avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(3, 10) queue:NULL usingBlock:^(CMTime time){
                    NSTimeInterval seconds = CMTimeGetSeconds(time);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //NSLog(@"seconds =%f", seconds);
                    if(seconds < 0.005)
                    {
                        [self videoAtStart:seconds];
                    }
                });
            }];
                
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(moviePlayBackDidFinish:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[avPlayer currentItem]];
            if (initialPlayback!=-1)
            {
                int32_t timeScale = avPlayer.currentItem.asset.duration.timescale;
                CMTime initialtime=CMTimeMakeWithSeconds(initialPlayback/1000.0, timeScale);
                avPlayer.currentItem.reversePlaybackEndTime = initialtime;
            }
            if (endPlayback!=-1)
            {
                int32_t timeScale = avPlayer.currentItem.asset.duration.timescale;
                CMTime endtime=CMTimeMakeWithSeconds(endPlayback/1000.0, timeScale);
                avPlayer.currentItem.forwardPlaybackEndTime = endtime;
            }
            CGRect rect;
            if ((flags&VFLAG_FULLSCREEN) != 0)
            {
                if(@available(iOS 11.0, *))
                {
                    avPlayerViewController.exitsFullScreenWhenPlaybackEnds = YES;
                    avPlayerViewController.entersFullScreenWhenPlaybackBegins = YES;
                }
                rect=[[UIScreen mainScreen] bounds];
                [rh->rhApp->mainViewController addChildViewController:avPlayerViewController];
                [rh->rhApp->mainView addSubview:avPlayerViewController.view];
            }
            else
            {
                [rh->rhApp->runView addSubview:avPlayerViewController.view];
                rect=CGRectMake(ho->hoX-rh->rhWindowX, ho->hoY-rh->rhWindowY, ho->hoImgWidth, ho->hoImgHeight);
            }
                                     
            avPlayerViewController.view.frame = rect;
            
            if(@available(iOS 11.0, *))
            {
                AVPlayerLayer* avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayerViewController.player];
                avPlayerLayer.needsDisplayOnBoundsChange = YES;
                [avPlayerLayer setFrame:rect];
            }
            else
            {
                avPlayerViewController.view.clipsToBounds = YES;
                avPlayerViewController.view.bounds = rect;
            }

            avPlayerViewController.delegate = self;
    
            oldX=ho->hoX;
            oldY=ho->hoY;
        }
        else
        {
            AVPlayer* avPlayer = avPlayerViewController.player;
            if(avPlayer != nil)
            {
                [avPlayer removeObserver:self forKeyPath:@"status"];
                if(@available(iOS 10.0, *))
                    [avPlayer removeObserver:self forKeyPath:@"timeControlStatus"];
                else
                    [avPlayer removeObserver:self forKeyPath:@"rate"];

                [avPlayer replaceCurrentItemWithPlayerItem:nil];
                [avPlayer replaceCurrentItemWithPlayerItem:playerItem];
                
                [avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
                if(@available(iOS 10.0, *))
                    [avPlayer addObserver:self forKeyPath:@"timeControlStatus" options:0 context:nil];
                else
                    [avPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];

            }
        }

        [self moviePosition];
    }
}

-(UIViewController*)viewController:(UIView*)view
{
    UIResponder *nextResponder =  view;
    do
    {
        nextResponder = [nextResponder nextResponder];

        if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController*)nextResponder;

    } while (nextResponder != nil);

    return nil;
}

- (void)playerViewController:(AVPlayerViewController *)playerViewController
willBeginFullScreenPresentationWithAnimationCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"will begin fullscreen...");
}

- (void)playerViewController:(AVPlayerViewController *)playerViewController
willEndFullScreenPresentationWithAnimationCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"will exit fullscreen...");
    if ((flags&VFLAG_FULLSCREEN) != 0)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if (avPlayerViewController!=nil)
        {
            [self endVideo];
        }
        [ho pushEvent:CND_VIDENDED withParam:0];
    }
}

-(void)endVideo
{
    if (avPlayerViewController!=nil)
    {
        avPlayerViewController.view.hidden = YES;
        [avPlayerViewController.player removeTimeObserver:timeObserver];
        [avPlayerViewController.player removeObserver:self forKeyPath:@"status" context:nil];
        if(@available(iOS 10.0, *))
            [avPlayerViewController.player removeObserver:self forKeyPath:@"timeControlStatus"];
        else
            [avPlayerViewController.player removeObserver:self forKeyPath:@"rate"];

        [avPlayerViewController dismissViewControllerAnimated:YES completion: nil];
        [avPlayerViewController removeFromParentViewController];
        [avPlayerViewController.view removeFromSuperview];
        avPlayerViewController.delegate = nil;
        [avPlayerViewController release];
        avPlayerViewController = nil;
        NSLog(@"Ended");
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification 
{
    if ((flags&VFLAG_REPEAT)!=0)
    {
        AVPlayerItem *pItem = [notification object];
        [pItem seekToTime:kCMTimeZero];
    }
    else
    {
        if ((flags&VFLAG_FULLSCREEN) != 0)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            if (avPlayerViewController!=nil)
            {
                [self endVideo];
            }
        }
        [ho pushEvent:CND_VIDENDED withParam:0];
    }
}

-(void)resetTouches:(NSNotification*)notification
{
	[rh->rhApp resetTouches];
}

-(void)destroyRunObject:(BOOL)bFast
{
    if (avPlayerViewController!=nil)
        [self endVideo];
	[rh->rhApp resetTouches];
}
-(int)handleRunObject
{
    if (rh->rhApp->bStatusBar==NO)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }

	if(!avPlayerViewController)
		return 0;

    
	if((ho->ros->rsFlags & RSFLAG_VISIBLE) == 0)
	{
		if(!avPlayerViewController.view.hidden)
            avPlayerViewController.view.hidden = YES;
	}
	else
    {
        if((avPlayerViewController.player.status & (AVPlayerItemStatusReadyToPlay | ~AVPlayerItemStatusUnknown)) != 0)
		{
			if(avPlayerViewController.view.hidden)
                avPlayerViewController.view.hidden = NO;
		}
    }
    

    return 0;
}

-(void) moviePosition
{
    int plusX = 0, plusY = 0;
    float width = ho->hoImgWidth;
    float height = ho->hoImgHeight;

    for(CRunApp* app = rh->rhApp; app != nil; app = app->parentApp)
    {
        if(app->subApp != nil)
        {
            plusX += app->parentX;
            plusY += app->parentY;
        }
   }
    
    plusX -= rh->rhWindowX;
    plusY -= rh->rhWindowY;

    CGRect newFrame = CGRectMake((ho->hoX+plusX), (ho->hoY+plusY), width, height);
    if(@available(iOS 11.0, *))
    {
        AVPlayerLayer* avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayerViewController.player];
        avPlayerLayer.needsDisplayOnBoundsChange = YES;
        [avPlayerLayer setFrame:newFrame];
        avPlayerViewController.view.frame = newFrame;
    }
    else
    {
        avPlayerViewController.view.frame = newFrame;
        avPlayerViewController.view.bounds = newFrame;
    }
}
//From "AVPlayerViewController+Fullscreen.h"
-(void)presentFullScreen:(AVPlayerViewController*)playerController
{
    NSString *selectorForFullscreen = @"transitionToFullScreenViewControllerAnimated:completionHandler:";
    if (@available(iOS 11.3, *)) {
        selectorForFullscreen = @"transitionToFullScreenAnimated:interactive:completionHandler:";
    } else if (@available(iOS 11.0, *)) {
        selectorForFullscreen = @"transitionToFullScreenAnimated:completionHandler:";
    }
    SEL fsSelector = NSSelectorFromString([@"_" stringByAppendingString:selectorForFullscreen]);
    if ([playerController respondsToSelector:fsSelector]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[playerController methodSignatureForSelector:fsSelector]];
        [inv setSelector:fsSelector];
        [inv setTarget:playerController];

        NSInteger index = 2; //arguments 0 and 1 are self and _cmd respectively, automatically set
        BOOL animated = YES;
        [inv setArgument:&(animated) atIndex:index];
        index++;

        if (@available(iOS 11.3, *)) {
            BOOL interactive = YES;
            [inv setArgument:&(interactive) atIndex:index]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
            index++;
        }

        id completionBlock = nil;
        [inv setArgument:&(completionBlock) atIndex:index];
        [inv invoke];
    }
}

-(void)displayRunObject:(CRenderer *)renderer
{
    if ((flags&VFLAG_FULLSCREEN)==0)
    {
        if (oldX!=ho->hoX || oldY!=ho->hoY)
        {
            oldX=ho->hoX;
            oldY=ho->hoY;
            [self moviePosition];

        }

    }
}

-(BOOL)condition:(int)num withCndExtension:(CCndExtension *)cnd
{
    switch(num)
    {
        case CND_PLAYING:
            return [self cndPlaying];
        case CND_STOPPED:
            return [self cndStopped];
        case CND_PAUSED:
            return [self cndPaused];
        case CND_AIRPLAYENABLED:
            return [self cndAirplayEnabled];
        case CND_VIDATSTART:
            return YES;
        case CND_VIDENDED:
            return YES;
        case CND_VIDREADY:
            return YES;
    }
    return NO;
}
-(BOOL)cndPlaying
{
    AVPlayer* avPlayer = avPlayerViewController.player;
    
    if (avPlayer!=nil)
    {
        if(@available(iOS 10.0, *))
            return avPlayer.timeControlStatus==AVPlayerTimeControlStatusPlaying;
        else
            return avPlayer.rate > 0.1;
    }
    return NO;
}
-(BOOL)cndStopped
{
    AVPlayer* avPlayer = avPlayerViewController.player;
    
    if (avPlayer!=nil)
    {
        return avPlayer.rate <= 0.001;
    }
    return NO;
}
-(BOOL)cndPaused
{
    AVPlayer* avPlayer = avPlayerViewController.player;
    
    if (avPlayer!=nil)
    {
        if(@available(iOS 10.0, *))
            return avPlayer.timeControlStatus==AVPlayerTimeControlStatusPaused;
        else
            return avPlayer.rate < 0.1;
    }
    return NO;
}
-(BOOL)cndAirplayEnabled
{
    AVPlayer* avPlayer = avPlayerViewController.player;
    
    if (avPlayer!=nil && [avPlayer respondsToSelector:@selector(allowsExternalPlayback)])
		return [avPlayer allowsExternalPlayback];
    return NO;
}

-(void)action:(int)num withActExtension:(CActExtension *)act
{
    AVPlayer* avPlayer = avPlayerViewController.player;
    
    switch(num)
    {
        case ACT_SETURL:
            resetStart = YES;
            url=[act getParamExpString:rh withNum:0];
            [self startVideo];
            break;
        case ACT_INITIALPLAYBACK:
             [self actInitialPlayback:act];
            break;
        case ACT_ENDPLAYBACK:
            [self actEndPlayback:act];
            break;
        case ACT_REPEAT:
            [self actRepeat:act];
            break;
        case ACT_PLAY:
            if (avPlayer!=nil)
            {
                if ((flags&VFLAG_FULLSCREEN) != 0)
                {
                    if (@available(iOS 10.0, *)) {
                        [self presentFullScreen:avPlayerViewController];
                    }
                }
                videoStatus = 1;
                [avPlayer setRate:1.0];
                [avPlayer play];
            }
            break;
        case ACT_VIDEOPAUSE:
            if (avPlayer!=nil)
            {
                [avPlayer pause];
                videoStatus = 2;
            }
            break;
        case ACT_STOP:
            if (avPlayer!=nil)
            {
                int32_t timeScale = avPlayer.currentItem.asset.duration.timescale;
                CMTime seektime=CMTimeMakeWithSeconds(0, timeScale);
                [avPlayer seekToTime:seektime];
                [avPlayer pause];
                videoStatus = 0;
            }
            break;
        case ACT_SETPLAYBACKTIME:
            [self actSetPlaybackTime:act];
            break;
        case ACT_BEGINSEEKFORWARD:
            if (avPlayer!=nil)
            {
                [avPlayer setRate:1.25];
                videoStatus = 3;
            }
            break;
        case ACT_BEGINSEEKBACKWARD:
            if (avPlayer!=nil)
            {
                [avPlayer setRate:-1.25];
                videoStatus = 4;
            }
            break;
        case ACT_ENDSEEK:
            if (avPlayer!=nil)
                [avPlayer setRate:1.0];
            break;
    }
}
-(void)actInitialPlayback:(CActExtension*)act
{
    AVPlayer* avPlayer = avPlayerViewController.player;
    
    initialPlayback=[act getParamExpression:rh withNum:0];
    if (avPlayer!=nil)
    {
        int32_t timeScale = avPlayer.currentItem.asset.duration.timescale;
        CMTime initialtime=CMTimeMakeWithSeconds(initialPlayback/1000.0, timeScale);
        avPlayer.currentItem.reversePlaybackEndTime = initialtime;
    }
}
-(void)actEndPlayback:(CActExtension*)act
{
    AVPlayer* avPlayer = avPlayerViewController.player;
    
    endPlayback=[act getParamExpression:rh withNum:0];
    if (avPlayer!=nil)
    {
        int32_t timeScale = avPlayer.currentItem.asset.duration.timescale;
        CMTime endtime=CMTimeMakeWithSeconds(endPlayback/1000.0, timeScale);
        avPlayer.currentItem.forwardPlaybackEndTime = endtime;
    }
}
-(void)actSetPlaybackTime:(CActExtension*)act
{
    AVPlayer* avPlayer = avPlayerViewController.player;
    
    int time=[act getParamExpression:rh withNum:0];
    if (avPlayer!=nil)
    {
        if(time < 0.01)
            resetStart = YES;

        int32_t timeScale = avPlayer.currentItem.asset.duration.timescale;
        CMTime seektime=CMTimeMakeWithSeconds(time/1000.0, timeScale);
        [avPlayer seekToTime:seektime];
    }
}
-(void)actRepeat:(CActExtension*)act
{
    AVPlayer* avPlayer = avPlayerViewController.player;
    
    int repeat=[act getParamExpression:rh withNum:0];
    if (repeat==0)
    {
        flags&=~VFLAG_REPEAT;
    }
    else
    {
        flags|=VFLAG_REPEAT;
    }
    if (avPlayer!=nil)
    {
        if ((flags&VFLAG_REPEAT)!=0)
        {
            avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        }
        else
        {
            avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        }
    }
}

-(CValue*)expression:(int)num
{
    switch (num)
    {
        case EXP_DURATION:
            return [self expDuration];
        case EXP_STATE:
            return [self expState];
        case EXP_PLAYABLEDURATION:
            return [self expPlayableDuration];
        case EXP_PLAYBACKTIME:
            return [self expPlaybackTime];
    }
    return [rh getTempValue:0];
}
-(CValue*)expPlaybackTime
{
    AVPlayer* avPlayer = avPlayerViewController.player;
    
    CValue* ret=[rh getTempValue:0];
    if (avPlayer!=nil)
    {
        int time=CMTimeGetSeconds(avPlayer.currentItem.currentTime)*1000;
        if (time<0)
            time=0;
        [ret forceInt:time];
    }
    return ret;
}

-(CValue*)expDuration
{
    AVPlayer* avPlayer = avPlayerViewController.player;
    
    CValue* ret=[rh getTempValue:0];
    if (avPlayer!=nil)
    {
        [ret forceInt:CMTimeGetSeconds(avPlayer.currentItem.duration)*1000];
    }
    return ret;
}

-(CValue*)expPlayableDuration
{
    AVPlayer* avPlayer = avPlayerViewController.player;
    
    CValue* ret=[rh getTempValue:0];
    if (avPlayer!=nil)
    {
        [ret forceInt:CMTimeGetSeconds(avPlayer.currentItem.duration)*1000];
    }
    return ret;
}
-(CValue*)expState
{
    AVPlayer* avPlayer = avPlayerViewController.player;
    
    CValue* ret=[rh getTempValue:0];
    if (avPlayer!=nil)
    {
        [ret forceInt:(int)videoStatus];
    }
    return ret;
}





@end
