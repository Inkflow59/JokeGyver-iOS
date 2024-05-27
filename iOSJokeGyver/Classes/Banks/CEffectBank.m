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
#import "CEffectBank.h"
#import "CEffect.h"
#import "CEffectParam.h"

#import "CRunApp.h"
#import "CFile.h"

#define EFFECTPARAM_INT 0
#define EFFECTPARAM_FLOAT 1
#define EFFECTPARAM_INTFLOAT4 2

@implementation CEffectBank

-(id)initWithApp:(CRunApp*)App
{
    app=App;
    nEffects = 0;
    return self;
}

-(void)dealloc
{
    if (effects!=nil)
    {
        for(int i =0; i < nEffects; i++)
        {
            [effects[i] release];
        }
        free(effects);
    }
    
    [super dealloc];
}
-(void)preLoad:(CFile*)file
{
    effectsBankOffset = [file getFilePointer];
    // Number of Effects
    nEffects = [file readAInt];
    if (nEffects == 0)
        return;

    effects = (CEffect**)calloc(nEffects, sizeof(CEffect*));
    effectsOffset = (int*)calloc(nEffects, sizeof(int));

    int n;
    for(n=0; n < nEffects ; n++)
    {
        effectsOffset[n] = [file readAInt];
    }

    [self load:file];
}

-(void)load:(CFile *)file
{
    for(int n=0; n < nEffects ; n++)
    {
        effects[n] = [[CEffect alloc] init];
        if(effects[n] != nil)
        {
            long offset = effectsBankOffset + effectsOffset[n];
            [file seek:offset];
            
            effects[n]->handle = n;

            int nameOffset = [file readAInt];
            int fxDataOffset = [file readAInt];
            int paramOffset = [file readAInt];
            effects[n]->options = [file readAInt];
            [file readAInt];
            
            file->bUnicode = false;
            [file seek:(offset+nameOffset)];
            effects[n]->name = [file readAString];
            
            if(fxDataOffset != 0)
            {
                [file seek:(offset + fxDataOffset)];
                NSString* fxData= [file readAString];
                if([fxData length] > 0) {
                    effects[n]->vertexData = [[NSString alloc] initWithString:[self getVertexBlock:fxData]];
                    effects[n]->fragData = [[NSString alloc] initWithString:[self getFragmentBlock:fxData]];
                    [fxData release];
                }
            }
            
            if(paramOffset != 0)
            {
                [file seek:(offset + paramOffset)];
                long startParams = [file getFilePointer];
                int nparams = [file readAInt];
                effects[n]->nParams = nparams;
                
                if (nparams != 0)
                {
                    int paramTypeOffset = [file readAInt];
                    int paramNameOffset = [file readAInt];
                    
                    [effects[n] fillParams:file StartAt:(long)startParams OffsetName:(int)paramNameOffset andTypeOffSet:(int)paramTypeOffset];
                }
            }
            file->bUnicode = true;
        }
    }
}

-(bool)isEmpty
{
    return nEffects == 0;
}

-(CEffect*)getEffectFromIndex:(int)index
{
    if (index>=0 && index<nEffects)
        return effects[index];
    return nil;
}

-(CEffect*)getEffectByName:(NSString*)name
{
    int n;
    for(n=0; n < nEffects ; n++)
    {
        if([effects[n]->name containsString:name])
            return effects[n];
    }
    return nil;
}

-(NSString*)getVertexBlock:(NSString*)block
 {
     NSString* s=@"";
     
     NSRange startRange = [block rangeOfString:@"//@Begin_vertex\r\n"];
     NSRange endRange = [block rangeOfString:@"//@End"];

     NSInteger start = NSMaxRange (startRange);
     NSInteger length = endRange.location - start;
     
     s = [block substringWithRange:NSMakeRange(start, length)];
     s = [s stringByReplacingOccurrencesOfString:@"//version_####" withString:@"#version 300 es"];
     //NSLog(@"%@", s);
     
     return s;
 }

-(NSString*)getFragmentBlock:(NSString*)block
 {
     NSString* s=@"";

     NSRange startRange = [block rangeOfString:@"//@Begin_fragment\r\n"];
     NSRange endRange = [block rangeOfString:@"//@End"
                                     options:NSLiteralSearch
                                       range:NSMakeRange(startRange.location, [block length]-startRange.location)];

     NSInteger start = NSMaxRange (startRange);
     NSInteger length = endRange.location - start;

     s = [block substringWithRange:NSMakeRange(start, length)];
     s = [s stringByReplacingOccurrencesOfString:@"//version_####" withString:@"#version 300 es"];
     //NSLog(@"%@", s);
     
     return s;
 }

@end

