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
// CLAYER : classe layer
//
//----------------------------------------------------------------------------------
#import "CLayer.h"
#import "CFile.h"
#import "CArrayList.h"
#import "CRun.h"
#import "CRunApp.h"
#import "CRunFrame.h"

@implementation CLayer

-(id)initWithFrame:(CRunFrame*)ownerFrame
{
	if(self = [super init])
	{
		pBkd2=nil;
		pLadders=nil;
		m_loZones = nil;
		frame = ownerFrame;
		scaleX = 1;
		scaleY = 1;
		scale = 1;

		angle = 0;
		xDest = 0;
		yDest = 0;
		xSpot = 0;
		ySpot = 0;

		x = y = dx = dy = 0;
		xOff = yOff = 0;
        
        effectShader = -1;
        effectEx = nil;
	}
	return self;
}
-(void)dealloc
{
	[pBkd2 clearRelease];
	[pLadders clearRelease];
	[pBkd2 release];
	[pLadders release];
	[pName release];
	
	if(m_loZones != nil)
	{
		[m_loZones clearRelease];
		[m_loZones release];
	}
    if(effectData)
        free(effectData);
    
	[super dealloc];
}
-(void)load:(CFile*)file
{
	dwOptions=[file readAInt];
	xCoef=[file readAFloat];
	yCoef=[file readAFloat];
	nBkdLOs=[file readAInt];
	nFirstLOIndex=[file readAInt];
	pName=[file readAString];
	
	backUp_dwOptions=dwOptions;
	backUp_xCoef=xCoef;
	backUp_yCoef=yCoef;
	backUp_nBkdLOs=nBkdLOs;
	backUp_nFirstLOIndex=nFirstLOIndex;
}
-(Mat3f)getTransformMatrix
{
	CRunApp* app		= frame->app;
	CRun* run			= app->run;
	Vec2f rhHotspot		= Vec2f(app->scXSpot + round(run->rhWindowX * xCoef), app->scYSpot + round(run->rhWindowY * yCoef));
	Vec2f destination	= Vec2f(app->scXDest - x, app->scYDest - y);
	Vec2f lScale		= Vec2f(scaleX * app->scScaleX, scaleY * app->scScaleY);
	Vec2f hotspot		= Vec2f(xSpot, ySpot) + rhHotspot;
	return Mat3f::objectRotationMatrix(destination, Vec2fOne, lScale, hotspot, angle + app->scAngle);
}
-(void)updateVisibleRect
{
    CRunApp* app		= frame->app;
    CRun* run			= app->run;
    visibleRect = CRectCreateAtPosition(round(run->rhWindowX * xCoef) + x,
                                        round(run->rhWindowY * yCoef) + y,
                                        app->gaCxWin,
                                        app->gaCyWin);
    
    /*
     killRect = CRectCreateAtPosition(-GAME_XBORDER,
     -GAME_YBORDER,
     run->rhLevelSx + GAME_XBORDER*2,
     run->rhLevelSy + GAME_YBORDER*2);
     */
    killRect = CRectCreate(run->rh3XMinimumKill,
                           run->rh3YMinimumKill,
                           run->rh3XMaximumKill,
                           run->rh3YMaximumKill);

    
    handleRect = CRectCreate(round(run->rhWindowX*xCoef) + x - COLMASK_XMARGIN,
                             round(run->rhWindowY*yCoef) + y - COLMASK_YMARGIN,
                             round(run->rhWindowX*xCoef) + x + run->rh3WindowSx + COLMASK_XMARGIN,
                             round(run->rhWindowY*yCoef) + y + run->rh3WindowSy + COLMASK_YMARGIN);
    if(handleRect.left < 0)
        handleRect.left = killRect.left;
    
    if(handleRect.right > run->rhLevelSx)
        handleRect.right = killRect.right;
    
    if(handleRect.top < 0)
        handleRect.top = killRect.top;
    
    if(handleRect.bottom > run->rhLevelSy)
        handleRect.bottom = killRect.bottom;
}

-(void)scrollToX:(int)newX andY:(int)newY
{
        newX = round(newX*xCoef);
        newY = round(newY*yCoef);
        dx = newX-xOff;
        dy = newY-yOff;
        xOff = newX;
        yOff = newY;
}

-(void)resetZones
{
    if(m_loZones != nil)
    {
        [m_loZones clearRelease];
        [m_loZones release];
        m_loZones = nil;
    }
}

/*
    CEffect code for Objects
 */
-(int)checkOrCreateEffectIfNeededByIndex:(int)index andEffectParam:(int)rgba
{
    CRunApp* app = frame->app;
    if(![app->effectBank isEmpty])
    {
        if (effectEx == nil) {

            effectEx = [[CEffectEx alloc] initWithApp:app];
            if ([effectEx initializeByIndex:index withEffectParam:rgba]) // Needs a handle (from objects)??
            {
                [effectEx setEffectData:effectData];
                return [effectEx getIndexShader];
            } else
                return -1;

        } else
            return [effectEx getIndexShader];
    }
    else
        return -1;
}

-(int)checkOrCreateEffectIfNeededByName:(NSString*)name andEffectParam:(int)rgba
{
    CRunApp* app = frame->app;
    if(![app->effectBank isEmpty])
    {
        if (effectEx == nil) {

            effectEx = [[CEffectEx alloc] initWithApp:app];
            if ([effectEx initializeByName:name withEffectParam:rgba])
                return [effectEx getIndexShader];
            else
                return -1;

        } else if ([effectEx->name containsString:name])
            return [effectEx getIndexShader];
        else {
            [effectEx removeShader];
            [effectEx release];
            
            effectEx = [[CEffectEx alloc] initWithApp:app];
            if ([effectEx initializeByName:name withEffectParam:rgba])
                return [effectEx getIndexShader];
            else
                return -1;
        }
    }
    else
        return -1;
}

-(int)checkOrCreateEffectIfNeeded:(CRunApp*)app
{
    if(![app->effectBank isEmpty])
    {
        if (effectEx == nil) {

            effectEx = [[CEffectEx alloc] initWithApp:app];
            if ([effectEx initializeByIndex:effectIndex withEffectParam:effectParam])
            {
                [effectEx setEffectData:effectData];
                effectShader = [effectEx getIndexShader];
            } else
                effectShader = -1;

        } else
            effectShader = [effectEx getIndexShader];
    }
    else
        effectShader = -1;
    
    return effectShader;
}

-(int)checkOrCreateEffectIfNeeded:(CRunApp*)app andName:(NSString*)name
{
    if(![app->effectBank isEmpty])
    {
        if (effectEx == nil) {

            effectEx = [[CEffectEx alloc] initWithApp:app];
            if ([effectEx initializeByName:name withEffectParam:effectParam])
                effectShader = [effectEx getIndexShader];
            else
                effectShader = -1;

        } else if ([effectEx->name containsString:name])
            effectShader = [effectEx getIndexShader];
        else {
            [effectEx removeShader];
            [effectEx release];
            
            effectEx = [[CEffectEx alloc] initWithApp:app];
            if ([effectEx initializeByName:name withEffectParam:effectParam])
                effectShader = [effectEx getIndexShader];
            else
                effectShader = -1;
        }
    }
    else
        effectShader = -1;
    
    return effectShader;
}
@end
