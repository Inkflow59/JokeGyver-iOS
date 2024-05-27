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
// -----------------------------------------------------------------------------
//
// CBKD2 : objet paste dans le decor
//
// -----------------------------------------------------------------------------
#import "CBkd2.h"
#import "COI.h"
#import "CRun.h"
#import "CSprite.h"
#import "CSpriteGen.h"
#import "CRunApp.h"
#import "CEffectEx.h"

@implementation CBkd2

-(id)initWithCRun:(CRun*)rh
{
	rhPtr=rh;
	loHnd = oiHnd = 0; 
    x = y = spotX = spotY = 0;
	img = colMode = nLayer = obstacleType;
    pSpr[0] = pSpr[1] = pSpr[2] = pSpr[3] = nil;
	inkEffect = inkEffectParam = spriteFlag = 0;
    bkdEffectShader = -1;
	return self;
}
-(void)dealloc
{
	[self clearSprites];
	[super dealloc];
}
-(void)clearSprites
{
	int n;
	for (n=0; n<4; n++)
	{
		if (pSpr[n]!=nil)
		{
			[rhPtr->spriteGen delSpriteFast:pSpr[n]];
			pSpr[n] = nil;
		}
	}
}

/*
CEffect code for Objects
*/
-(int)checkOrCreateEffectIfNeeded:(CRunApp*)app andCOI:(COI*)oiPtr
 {
     if(bkdEffect == nil)
     {
         bkdEffect = [[CEffectEx alloc] initWithApp:app];
         if ([bkdEffect initializeByIndex:oiPtr->oiIndexEffect withEffectParam:oiPtr->oiInkEffectParam]) 
         {
             [self fillEffectData:oiPtr];
             return [bkdEffect getIndexShader];
         }
         else
             return -1;

     }
     else
         return [bkdEffect getIndexShader];
 }

-(void)fillEffectData:(COI*)oiPtr
 {
     if(oiPtr->oiEffectOffset != 0 && bkdEffect != nil)
     {
         if(oiPtr->oiEffectData != nil)
             [bkdEffect setEffectData:oiPtr->oiEffectData];
     }
 }

@end
