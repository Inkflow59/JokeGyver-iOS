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
//  MainView.m
//  RuntimeIPhone
//
//  Created by Anders Riggelsen on 3/30/11.
//  Copyright 2011 Clickteam. All rights reserved.
//

#import "MainView.h"
#import "CRunView.h"
#import "CRunApp.h"

@implementation MainView

-(id)initWithFrame:(CGRect)rect andRunApp:(CRunApp*)rApp
{
	if(self = [super initWithFrame:rect])
	{
		screenRect = rect;
		runApp = rApp;
		return self;
	}
	return nil;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	return YES;
}

-(void)layoutSubviews
{
	if([self.subviews count] == 0)
		return;
		
	CRunView* runView = (CRunView*)[self.subviews objectAtIndex:0];
	CRunApp* rhApp = runView->pRunApp;
	
	if(rhApp == nil)
		return;
	
    runView->appRect = CGRectMake(0, 0, rhApp->gaCxWin,  rhApp->gaCyWin);

	CGSize s = [rhApp windowSize];
	CGSize z = screenRect.size;	
	CGSize a = runView->appRect.size;
	float scale = MIN(z.width/a.width, z.height/a.height);
	
	//Center in screen
	viewScaleX = viewScaleY = scale;
	CGAffineTransform t = CGAffineTransformMakeScale(viewScaleX, viewScaleY);
	
	if(rhApp->viewMode == VIEWMODE_STRETCH)
	{
		viewScaleX = z.width/a.width;
		viewScaleY = z.height/a.height;
		t = CGAffineTransformMakeScale(viewScaleX, viewScaleY);
	}
	runView.center = CGPointMake(s.width/2.0, s.height/2.0);
	runView.transform = t;
	
	//Set status bar orientation (fix for Q&A UIAlertViews showing in wrong orientation)
	UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
	switch (runApp->actualOrientation)
	{
		case ORIENTATION_PORTRAIT:
			orientation = UIInterfaceOrientationPortrait; break;
		case ORIENTATION_PORTRAITUPSIDEDOWN:
			orientation = UIInterfaceOrientationPortraitUpsideDown; break;
		case ORIENTATION_LANDSCAPELEFT:
			orientation = UIInterfaceOrientationLandscapeLeft; break;
		case ORIENTATION_LANDSCAPERIGHT:
			orientation = UIInterfaceOrientationLandscapeRight; break;
        default:
            orientation = UIInterfaceOrientationUnknown;
	}
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 130000
        [UIApplication sharedApplication].statusBarOrientation = orientation;
#endif
    //[self setNeedsDisplay];
}



@end
