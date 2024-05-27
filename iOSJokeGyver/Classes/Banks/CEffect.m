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
// CEffect: effect code
//
//----------------------------------------------------------------------------------
#import "CEffect.h"
#import "CEffectParam.h"
#import "CFile.h"

@implementation CEffect

-(void)dealloc
{
    if(name != nil)
        [name release];
 
    if(vertexData != nil)
        [vertexData release];
    
    if(fragData != nil)
        [fragData release];
    
    if (effectParams!=nil)
    {
        for(int i =0; i < nParams; i++)
        {
            [effectParams[i] release];
        }
        free(effectParams);
    }
    
    
    [super dealloc];
}

-(id)initWithApp:(CRunApp*)ap
{
    app = ap;
    hasExtras = NO;
    return self;
}

-(void)fillParams:(CFile*)file StartAt:(long)startParams OffsetName:(int)paramNameOffset andTypeOffSet:(int)paramTypeOffset
{
    if(nParams == 0)
        return;
    
    effectParams = (CEffectParam**)calloc(nParams, sizeof(CEffectParam*));
    
    for (int i = 0; i < nParams; i++) {
        effectParams[i] = [[CEffectParam alloc] init];
    }
    
    [file seek:startParams + paramTypeOffset];
    for (int i = 0; i < nParams; i++)
    {
        effectParams[i]->nValueType = (int)[file readAByte];
    }
    [file seek:startParams + paramNameOffset];
    for (int i = 0; i < nParams; i++)
    {
        effectParams[i]->name = [file readAString];
    }
}

-(void)fillValues:(CFile*)file andOffset:(int)fileOffset
 {
     long debut = [file getFilePointer];
     [file seek:fileOffset];

     int number = [file readAInt];
     if(number == nParams)
     {
         for (int i=0; i < nParams; i++)
         {
             switch(effectParams[i]->nValueType)
             {
                 case EFFECTPARAM_SURFACE:
                     hasExtras |= YES;
                     effectParams[i]->img_handle = (short)[file readAInt];
                     break;
                 case EFFECTPARAM_FLOAT:
                     effectParams[i]->fValue = [file readAFloat];
                     break;
                 case EFFECTPARAM_INTFLOAT4:
                 default:
                     effectParams[i]->nValue = [file readAInt];
                     break;
             }
         }
     }
     [file seek:debut];
 }

-(CEffectParam**)copyParams
 {
     if(effectParams == nil || nParams == 0)
         return nil;

     CEffectParam** cep = (CEffectParam**)malloc(nParams * sizeof(CEffectParam*));
     
     for(int n=0; n < nParams ; n++)
     {
         cep[n] = [[CEffectParam alloc] init];
         if(cep[n] != nil) {
             cep[n]->name = [[NSString alloc] initWithString:effectParams[n]->name];
             cep[n]->nValueType = effectParams[n]->nValueType;
             cep[n]->nValue = effectParams[n]->nValue;
             cep[n]->fValue = effectParams[n]->fValue;
         }
     }
     return cep;
 }


@end
