/* Copyright (c) 1996-2019 Clickteam
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
// --------------------------------------------------------------------------
// 
// VIRTUAL JOYSTICK
// 
// --------------------------------------------------------------------------
#import "CJoystick.h"
#import "CRunApp.h"
#import "CRunView.h"
#import "CRenderer.h"
#import "CImage.h"

#import <GameController/GameController.h>

#define DEADZONE  0.25f
#define JOY_ANGLEGAP  70

#define COMFORT_DPAD 1.15
#define COMFORT_JPAD 1.00

@implementation CJoystick

-(id)initWithApp:(CRunApp*)a
{
	if(self = [super init])
	{
		app=a;

		NSString* path;
		path=[[NSBundle mainBundle] pathForResource: @"joyback" ofType:@"png"];
		joyBack=[[UIImage alloc] initWithContentsOfFile:path];
		path=[[NSBundle mainBundle] pathForResource: @"joyfront" ofType:@"png"];
		joyFront=[[UIImage alloc] initWithContentsOfFile:path];
		path=[[NSBundle mainBundle] pathForResource: @"fire1U" ofType:@"png"];
		fire1U=[[UIImage alloc] initWithContentsOfFile:path];
		path=[[NSBundle mainBundle] pathForResource: @"fire2U" ofType:@"png"];
		fire2U=[[UIImage alloc] initWithContentsOfFile:path];
		path=[[NSBundle mainBundle] pathForResource: @"fire1D" ofType:@"png"];
		fire1D=[[UIImage alloc] initWithContentsOfFile:path];
		path=[[NSBundle mainBundle] pathForResource: @"fire2D" ofType:@"png"];
		fire2D=[[UIImage alloc] initWithContentsOfFile:path];

        path=[[NSBundle mainBundle] pathForResource: @"joyup" ofType:@"png"];
        joyUp=[[UIImage alloc] initWithContentsOfFile:path];
        path=[[NSBundle mainBundle] pathForResource: @"joyupd" ofType:@"png"];
        joyUpD=[[UIImage alloc] initWithContentsOfFile:path];
        path=[[NSBundle mainBundle] pathForResource: @"joydown" ofType:@"png"];
        joyDown=[[UIImage alloc] initWithContentsOfFile:path];
        path=[[NSBundle mainBundle] pathForResource: @"joydownd" ofType:@"png"];
        joyDownD=[[UIImage alloc] initWithContentsOfFile:path];
        path=[[NSBundle mainBundle] pathForResource: @"joyleft" ofType:@"png"];
        joyLeft=[[UIImage alloc] initWithContentsOfFile:path];
        path=[[NSBundle mainBundle] pathForResource: @"joyleftd" ofType:@"png"];
        joyLeftD=[[UIImage alloc] initWithContentsOfFile:path];
        path=[[NSBundle mainBundle] pathForResource: @"joyright" ofType:@"png"];
        joyRight=[[UIImage alloc] initWithContentsOfFile:path];
        path=[[NSBundle mainBundle] pathForResource: @"joyrightd" ofType:@"png"];
        joyRightD=[[UIImage alloc] initWithContentsOfFile:path];

		joyBackTex = [CImage loadUIImage:joyBack];
		joyFrontTex = [CImage loadUIImage:joyFront];
        joyUpTex = [CImage loadUIImage:joyUp];
        joyUpDTex = [CImage loadUIImage:joyUpD];
        joyDownTex = [CImage loadUIImage:joyDown];
        joyDownDTex = [CImage loadUIImage:joyDownD];
        joyLeftTex = [CImage loadUIImage:joyLeft];
        joyLeftDTex = [CImage loadUIImage:joyLeftD];
        joyRightTex = [CImage loadUIImage:joyRight];
        joyRightDTex = [CImage loadUIImage:joyRightD];
		fire1UTex = [CImage loadUIImage:fire1U];
		fire2UTex = [CImage loadUIImage:fire2U];
		fire1DTex = [CImage loadUIImage:fire1D];
		fire2DTex = [CImage loadUIImage:fire2D];

		flags=0;

		joystickX=0;
		joystickY=0;
		joystick=0;
		imagesX[KEY_JOYSTICK]=JPOS_NOTDEFINED;
		imagesY[KEY_JOYSTICK]=JPOS_NOTDEFINED;
		imagesX[KEY_FIRE1]=JPOS_NOTDEFINED;
		imagesY[KEY_FIRE1]=JPOS_NOTDEFINED;
		imagesX[KEY_FIRE2]=JPOS_NOTDEFINED;
		imagesY[KEY_FIRE2]=JPOS_NOTDEFINED;

		int sxApp=a->gaCxWin;
		int syApp=a->gaCyWin;
        CGRect screen=[[UIScreen mainScreen] bounds];
		int sxScreen=screen.size.width;
		int syScreen=screen.size.height;
		CGFloat scale=[UIScreen mainScreen].scale;
		sxScreen*=scale;
		syScreen*=scale;
		zoom=1.0;

		float minSizeInCm = 1;
		float desiredScreenSizeInCm = 1;

		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			minSizeInCm = 14.8;
			desiredScreenSizeInCm = 2.0;
		}
		else
		{
			minSizeInCm = 5.1;
			desiredScreenSizeInCm = 1.5;
		}
		float pixelsPerCm = MIN(sxApp,syApp)/minSizeInCm;
		zoom = (pixelsPerCm * desiredScreenSizeInCm)/80.0;	//80 being the pixel size of the joystick image
    }
	return self;
}
-(void)dealloc
{
	[joyBack release];
	[joyFront release];
    [joyUp release];
    [joyUpD release];
    [joyDown release];
    [joyDownD release];
    [joyLeft release];
    [joyLeftD release];
    [joyRight release];
    [joyRightD release];
	[fire1U release];
	[fire2U release];
	[fire1D release];
	[fire2D release];
	[joyBackTex release];
	[joyFrontTex release];
    [joyUpTex release];
    [joyUpDTex release];
    [joyDownTex release];
    [joyDownDTex release];
    [joyLeftTex release];
    [joyLeftDTex release];
    [joyRightTex release];
    [joyRightDTex release];
	[fire1UTex release];
	[fire2UTex release];
	[fire1DTex release];
	[fire2DTex release];
	[super dealloc];
}
-(void)reset:(int)f
{
	[app->runView setMultiTouch:YES];

	flags=f;
    
    //flags &= ~JFLAG_DPAD;

    //Radius Size percentage
    if ( (flags & JFLAG_DPAD) != 0 )
    {
        joyradsize = (int) ceil(sqrt(joyLeft.size.width*joyLeft.size.width + joyUp.size.height*joyUp.size.height)) * zoom;
        COMFORT_FACTOR = COMFORT_DPAD;
    }
    else
    {
        joyradsize = (int) ceil(sqrt(joyBack.size.width/2*joyBack.size.width/2 + joyBack.size.height/2*joyBack.size.height/2)) * zoom;
        COMFORT_FACTOR = COMFORT_JPAD;
    }
    joydeadzone = DEADZONE * joyradsize;

    joyanglezone = JOY_ANGLEGAP*PI/180;

    [self setPositions];
}
-(void)setPositions
{	
	int sx, sy;
	sx=app->gaCxWin;
	sy=app->gaCyWin;
	if ((flags&JFLAG_LEFTHANDED)==0)
	{
		if ((flags&JFLAG_JOYSTICK)!=0)
		{
            if((flags & JFLAG_DPAD) != 0)
            {
                imagesX[KEY_JOYSTICK]=16+(joyLeft.size.width)*zoom;
                imagesY[KEY_JOYSTICK]=sy-16-(joyDown.size.height)*zoom;
            }
            else
            {
                imagesX[KEY_JOYSTICK]=16+(joyBack.size.width/2)*zoom;
                imagesY[KEY_JOYSTICK]=sy-16-(joyBack.size.height/2)*zoom;
            }
		}
		if ((flags&JFLAG_FIRE1)!=0 && (flags&JFLAG_FIRE2)!=0)
		{
			imagesX[KEY_FIRE1]=sx-(fire1U.size.width/2+32)*zoom;
			imagesY[KEY_FIRE1]=sy-(fire1U.size.height/2+16)*zoom;
			imagesX[KEY_FIRE2]=sx-(fire2U.size.width/2+16)*zoom;
			imagesY[KEY_FIRE2]=sy-(fire2U.size.height/2+fire1U.size.height+24)*zoom;
		}
		else if ((flags&JFLAG_FIRE1)!=0)
		{
			imagesX[KEY_FIRE1]=sx-(fire1U.size.width/2+16)*zoom;
			imagesY[KEY_FIRE1]=sy-(fire1U.size.height/2+16)*zoom;
		}
		else if ((flags&JFLAG_FIRE2)!=0)
		{
			imagesX[KEY_FIRE2]=sx-(fire2U.size.width/2+16)*zoom;
			imagesY[KEY_FIRE2]=sy-(fire2U.size.height/2+16)*zoom;
		}
	}
	else
	{
		if ((flags&JFLAG_JOYSTICK)!=0)
		{
            if((flags & JFLAG_DPAD) != 0)
            {
                imagesX[KEY_JOYSTICK]=sx-(16+joyLeft.size.width)*zoom;
                imagesY[KEY_JOYSTICK]=sy-(16+joyDown.size.height)*zoom;
            }
            else
            {
                imagesX[KEY_JOYSTICK]=sx-(16+joyBack.size.width/2)*zoom;
                imagesY[KEY_JOYSTICK]=sy-(16+joyBack.size.height/2)*zoom;
            }
		}
		if ((flags&JFLAG_FIRE1)!=0 && (flags&JFLAG_FIRE2)!=0)
		{
			imagesX[KEY_FIRE1]=(fire1U.size.width/2+16+fire2U.size.width*2/3)*zoom;
			imagesY[KEY_FIRE1]=sy-(fire1U.size.height/2+16)*zoom;
			imagesX[KEY_FIRE2]=(fire2U.size.width/2+16)*zoom;
			imagesY[KEY_FIRE2]=sy-(fire2U.size.height/2+fire1U.size.height+24)*zoom;
		}
		else if ((flags&JFLAG_FIRE1)!=0)
		{
			imagesX[KEY_FIRE1]=(fire1U.size.width/2+16)*zoom;
			imagesY[KEY_FIRE1]=sy-(fire1U.size.height/2+16)*zoom;
		}
		else if ((flags&JFLAG_FIRE2)!=0)
		{
			imagesX[KEY_FIRE2]=(fire2U.size.width/2+16)*zoom;
			imagesY[KEY_FIRE2]=sy-(fire2U.size.height/2+16)*zoom;
		}
	}
}	
-(void)setXPosition:(int)f withPos:(int)p
{
	if ((f&JFLAG_JOYSTICK)!=0)
	{
		imagesX[KEY_JOYSTICK]=p;
	}
	else if ((f&JFLAG_FIRE1)!=0)
	{
		imagesX[KEY_FIRE1]=p;
	}
	else if ((f&JFLAG_FIRE2)!=0)
	{
		imagesX[KEY_FIRE2]=p;
	}
}
-(void)setYPosition:(int)f withPos:(int)p
{
	if ((f&JFLAG_JOYSTICK)!=0)
	{
		imagesY[KEY_JOYSTICK]=p;
	}
	else if ((f&JFLAG_FIRE1)!=0)
	{
		imagesY[KEY_FIRE1]=p;
	}
	else if ((f&JFLAG_FIRE2)!=0)
	{
		imagesY[KEY_FIRE2]=p;
	}
}
-(void)draw
{
	CRenderer* renderer = app->runView->renderer;

	//Hide the on-screen joysticks when an external controller is connected
	if([app->runView hasAnyGameControllerConnected])
		return;
	
	if ((flags&JFLAG_JOYSTICK)!=0)
	{
        if ((flags&JFLAG_DPAD)!=0)
        {
            CImage* tex = (joystick & 1) ? joyUpDTex : joyUpTex;
            renderer->renderImage(tex,
                                  imagesX[KEY_JOYSTICK]-(tex->width/2)*zoom,
                                  imagesY[KEY_JOYSTICK]-(tex->height)*zoom,
                                  tex->width*zoom,
                                  tex->height*zoom, 0, 0);
            tex = (joystick & 2) ? joyDownDTex : joyDownTex;
            renderer->renderImage(tex,
                                  imagesX[KEY_JOYSTICK]-(tex->width/2)*zoom,
                                  imagesY[KEY_JOYSTICK],
                                  tex->width*zoom,
                                  tex->height*zoom, 0, 0);
            tex = (joystick & 4) ? joyLeftDTex : joyLeftTex;
            renderer->renderImage(tex,
                                  imagesX[KEY_JOYSTICK]-(tex->width)*zoom,
                                  imagesY[KEY_JOYSTICK]-(tex->height/2)*zoom,
                                  tex->width*zoom,
                                  tex->height*zoom, 0, 0);
            tex = (joystick & 8) ? joyRightDTex : joyRightTex;
            renderer->renderImage(tex,
                                  imagesX[KEY_JOYSTICK],
                                  imagesY[KEY_JOYSTICK]-(tex->height/2)*zoom,
                                  tex->width*zoom,
                                  tex->height*zoom, 0, 0);
        }
        else
        {
            renderer->renderImage(joyBackTex,
                                  imagesX[KEY_JOYSTICK]-(joyBackTex->width/2)*zoom,
                                  imagesY[KEY_JOYSTICK]-(joyBackTex->height/2)*zoom,
                                  joyBackTex->width*zoom,
                                  joyBackTex->height*zoom, 0, 0);
            
            renderer->renderImage(joyFrontTex,
                                  imagesX[KEY_JOYSTICK]+joystickX-(joyFrontTex->width/2)*zoom,
                                  imagesY[KEY_JOYSTICK]+joystickY-(joyFrontTex->height/2)*zoom,
                                  joyFrontTex->width*zoom,
                                  joyFrontTex->height*zoom, 0, 0);
        }
	}
	if ((flags&JFLAG_FIRE1)!=0)
	{
		CImage* tex = ((joystick&0x10)==0) ? fire1UTex : fire1DTex;
		renderer->renderImage(tex, imagesX[KEY_FIRE1]-(tex->width/2)*zoom,
							  imagesY[KEY_FIRE1]-(tex->height/2)*zoom,
							  tex->width*zoom,
							  tex->height*zoom,
							  0, 0);
	}
	if ((flags&JFLAG_FIRE2)!=0)
	{
		CImage* tex = ((joystick&0x20)==0) ? fire2UTex : fire2DTex;
		renderer->renderImage(tex, imagesX[KEY_FIRE2]-(tex->width/2)*zoom,
							  imagesY[KEY_FIRE2]-(tex->height/2)*zoom,
							  tex->width*zoom,
							  tex->height*zoom,
							  0, 0);
	}
}

-(void)resetTouches
{
	for (int n=0; n<MAX_TOUCHES; n++)
	{
		touches[n]=nil;
	}
	joystick = joystickX = joystickY = 0;
}

-(BOOL)touchBegan:(UITouch*)touch
{
	//Ignore the on-screen joysticks when an external controller is connected
	if([app->runView hasAnyGameControllerConnected])
		return NO;

	CGPoint position = [touch locationInView:app->runView];
	
	BOOL bFlag=NO;
	int key=[self getKey:position.x withY:position.y];
	if (key!=KEY_NONE)
	{
		touches[key]=touch;
		if (key==KEY_JOYSTICK)
		{
			joystick&=0xF0;
			bFlag=YES;
            
            if ( (flags & JFLAG_DPAD) != 0 )
            {
                joystickX=position.x-imagesX[KEY_JOYSTICK];
                joystickY=position.y-imagesY[KEY_JOYSTICK];
                [self setJoystickStateBasedOnXY];
            }

		}		
		if (key==KEY_FIRE1)
		{
			joystick|=0x10;
			bFlag=YES;
		}
		else if (key==KEY_FIRE2)
		{
			joystick|=0x20;
			bFlag=YES;
		}
	}
	return bFlag;
}
-(void)touchMoved:(UITouch*)touch
{
	//Ignore the on-screen joysticks when an external controller is connected
	if([app->runView hasAnyGameControllerConnected])
		return;

	CGPoint position = [touch locationInView:app->runView];
	
	int key=[self getKey:position.x withY:position.y];
	if (key==KEY_JOYSTICK)
	{
		touches[KEY_JOYSTICK]=touch;
	}
	if (touch==touches[KEY_JOYSTICK])
	{
		joystickX=position.x-imagesX[KEY_JOYSTICK];
		joystickY=position.y-imagesY[KEY_JOYSTICK];
		[self setJoystickStateBasedOnXY];
	}
}

-(void)setJoystickStateBasedOnXY
{
    if ( (flags & JFLAG_DPAD) == 0 )
    {
        if (joystickX<-joyBack.size.width/4*zoom)
        {
            joystickX=-joyBack.size.width/4*zoom;
        }
        if (joystickX>joyBack.size.width/4*zoom)
        {
            joystickX=joyBack.size.width/4*zoom;
        }
        if (joystickY<-joyBack.size.height/4*zoom)
        {
            joystickY=-joyBack.size.height/4*zoom;
        }
        if (joystickY>joyBack.size.height/4*zoom)
        {
            joystickY=joyBack.size.height/4*zoom;
        }
    }

    joystick&=0xF0;
	double h=sqrt(joystickX*joystickX+joystickY*joystickY);
    double angle=fmod((PI*2.0 - atan2(joystickY, joystickX)),PI*2.0);

    // Is the radius vector above the deadzone and border of the joystick base
    if (h > joydeadzone && h <= joyradsize*COMFORT_FACTOR)
    {
        joystickX= (int) (cos(angle)*joyradsize/2);
        joystickY= (int) (sin(angle)*-joyradsize/2);

        int j=0;
        // Checking in 45 degrees zone equal (PI/4); 1/4, 2/4, 3/4, 4/4, 5/4, 6/4, 7/4, 8/4
        // organized like 8/4, 2/4, 4/4, 6/4,  priority for right, up, left and down
        if (angle>=0.0)
        {
            while(true) {
                // Right
                if([self InsideZone:angle withAngleRef:0.0 andGap:joyanglezone]
                        || [self InsideZone:angle withAngleRef:2.0*PI andGap:joyanglezone]) {
                    j=8;
                    break;
                }
                // Up
                if([self InsideZone:angle withAngleRef:PI/2.0 andGap:joyanglezone]) {
                    j=1;
                    break;
                }
                // Left
                if([self InsideZone:angle withAngleRef:PI andGap:joyanglezone]) {
                    j=4;
                    break;
                }
                // Down
                if([self InsideZone:angle withAngleRef:(PI/4.0)*6.0 andGap:joyanglezone]) {
                    j=2;
                    break;
                }
                // Right/Up
                if([self InsideZone:angle withAngleRef:(PI/4.0) andGap:PI/2.0-joyanglezone]) {
                    j=9;
                    break;
                }
                // Left/Up
                if([self InsideZone:angle withAngleRef:(PI/4.0)*3.0 andGap:PI/2.0-joyanglezone]) {
                    j=5;
                    break;
                }
                // Left/Down
                if([self InsideZone:angle withAngleRef:(PI/4.0)*5.0 andGap:PI/2.0-joyanglezone]) {
                    j=6;
                    break;
                }
                // Right/Down
                if([self InsideZone:angle withAngleRef:(PI/4.0)*7.0 andGap:PI/2.0-joyanglezone]) {
                    j=10;
                    break;
                }
                
                break;
            }
        }

        joystick|=j;
    }

}

-(BOOL)InsideZone:(double)angle withAngleRef:(double) angle_ref andGap:(double) gap
{
    // check if the angle is in the range, could be ported using degrees instead.
    return (angle > (angle_ref-gap/2) && angle < (angle_ref+gap/2));
}

-(void)touchEnded:(UITouch*)touch
{
	//Ignore the on-screen joysticks when an external controller is connected
	if([app->runView hasAnyGameControllerConnected])
		return;

	int n;
	for (n=0; n<MAX_TOUCHES; n++)
	{
		if (touches[n]==touch)
		{
			touches[n]=nil;
			switch (n)
			{
				case KEY_JOYSTICK:
					joystickX=0;
					joystickY=0;
					joystick&=0xF0;
					break;
				case KEY_FIRE1:
					joystick&=~0x10;
					break;
				case KEY_FIRE2:
					joystick&=~0x20;
					break;
			}
			break;
		}
	}	
}
-(void)touchCancelled:(UITouch*)touch
{
	[self touchEnded:touch];
}

-(int)getKey:(int)x withY:(int)y
{
	if (flags&JFLAG_JOYSTICK)
	{
        if((flags & JFLAG_DPAD) != 0)
        {
            if (x>=imagesX[KEY_JOYSTICK]-(joyLeft.size.width)*zoom && x<imagesX[KEY_JOYSTICK]+(joyRight.size.width)*zoom)
            {
                if (y>imagesY[KEY_JOYSTICK]-(joyUp.size.height)*zoom && y<imagesY[KEY_JOYSTICK]+(joyDown.size.height)*zoom)
                {
                    return KEY_JOYSTICK;
                }
            }
        }
        else
        {
            if (x>=imagesX[KEY_JOYSTICK]-(joyBack.size.width/2)*zoom && x<imagesX[KEY_JOYSTICK]+(joyBack.size.width/2)*zoom)
            {
                if (y>imagesY[KEY_JOYSTICK]-(joyBack.size.height/2)*zoom && y<imagesY[KEY_JOYSTICK]+(joyBack.size.height/2)*zoom)
                {
                    return KEY_JOYSTICK;
                }
            }
        }
	}
	if (flags&JFLAG_FIRE1)
	{
		if (x>=imagesX[KEY_FIRE1]-(fire1U.size.width/2)*zoom && x<imagesX[KEY_FIRE1]+(fire1U.size.width/2)*zoom)
		{
			if (y>imagesY[KEY_FIRE1]-(fire1U.size.height/2)*zoom && y<imagesY[KEY_FIRE1]+(fire1U.size.height/2)*zoom)
			{
				return KEY_FIRE1;
			}
		}
	}
	if (flags&JFLAG_FIRE2)
	{
		if (x>=imagesX[KEY_FIRE2]-(fire2U.size.width/2)*zoom && x<imagesX[KEY_FIRE2]+(fire2U.size.width/2)*zoom)
		{
			if (y>imagesY[KEY_FIRE2]-(fire2U.size.height/2)*zoom && y<imagesY[KEY_FIRE2]+(fire2U.size.height/2)*zoom)
			{
				return KEY_FIRE2;
			}
		}
	}
	return KEY_NONE;
}
-(unsigned char)getJoystick
{
	return joystick;
}
@end
