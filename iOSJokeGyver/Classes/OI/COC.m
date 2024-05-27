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
// COC: classe abstraite d'objectsCommon
//
//----------------------------------------------------------------------------------
#import "COC.h"
#import "COI.h"
#import "CFile.h"
#import "CRunApp.h"
#import "CEffectEx.h"
#import "CSprite.h"
#import "CMask.h"

@implementation COC

-(void)load:(CFile*)file withType:(short)type andCOI:(COI*)pOI
{
}
-(void)enumElements:(id)enumImages withFont:(id)enumFonts
{
}

-(void)spriteDraw:(CGContextRef)g withSprite:(CSprite*)spr andImageBank:(CImageBank*)bank andX:(int)x andY:(int)y
{
}

-(void)spriteKill:(CSprite*)spr
{
}

-(CMask*)spriteGetMask
{
	return nil;
}

/*
    CEffect code for Objects
 */
-(int)checkOrCreateEffectIfNeeded:(CRunApp*)app andCOI:(COI*)oiPtr
{
    if(![app->effectBank isEmpty]) {
        if (ocEffect == nil) {

            ocEffect = [[CEffectEx alloc] initWithApp:app];
            if ([ocEffect initializeByIndex:oiPtr->oiIndexEffect withEffectParam:oiPtr->oiInkEffectParam]) // Needs a handle (from objects)??
            {
                [self fillEffectData:oiPtr];
                return [ocEffect getIndexShader];
            } else
                return -1;

        } else
            return [ocEffect getIndexShader];
    }
    else
        return -1;
}

-(void)fillEffectData:(COI*)oiPtr
{
    if(oiPtr->oiEffectOffset != 0 && ocEffect != nil)
    {
        if(oiPtr->oiEffectData != nil)
            [ocEffect setEffectData:oiPtr->oiEffectData];
    }
}

@end
