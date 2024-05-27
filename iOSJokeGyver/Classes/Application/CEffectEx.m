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
// CEffectEx: effect executable code
//
//----------------------------------------------------------------------------------
#import "CEffectEx.h"
#import "CEffect.h"
#import "CEffectParam.h"
#import "CEffectBank.h"
#import "CRenderer.h"

#import "CRunApp.h"
#import "CImageBank.h"
#import "CFile.h"
#import "CValue.h"

@implementation CEffectEx

-(id)initWithApp:(CRunApp*)App
{
    app = App;
    indexShader = -1;
    blendColor  = 0xFFFFFFFF;
    nParams = 0;
    name = nil;
    hasExtras = NO;
    useBackground = NO;
    return self;
}

-(void)dealloc
{
    [self destroyShader];
    
    if(name != nil)
        [name release];
 
    if(vertexData != nil)
        [vertexData release];
    
    if(fragData != nil)
        [fragData release];
    
    if (eParams!=nil)
    {
        for(int i =0; i < nParams; i++)
        {
            if(eParams[i]->img_handle != -1)
                [app->imageBank delImage:eParams[i]->img_handle];
            
            [eParams[i] release];
        }
        free(eParams);
    }
        
    [super dealloc];
}

-(bool)initializeByIndex:(int)index withEffectParam:(int)rgba
{
    CEffect* e = [app->effectBank getEffectFromIndex:index];
    if(e != nil) {
        handle = index;     // Not sure handle is equal index yet
        blendColor = rgba;

        name = [[NSString alloc]initWithString:e->name];
        nParams= e->nParams;
        vertexData = [[NSString alloc]initWithString:e->vertexData];
        fragData = [[NSString alloc]initWithString:e->fragData];
        eParams = [e copyParams];
        
        useBackground = (e->options & EFFECTOPT_BKDTEXTUREMASK) != 0 ? YES : NO;
        return [self initializeShader];
    }
    return NO;
}

-(bool)initializeByName:(NSString*)effectName withEffectParam:(int)rgba
{
    CEffect* e = [app->effectBank getEffectByName:effectName];
    if(e != nil) {
        handle = e->handle;     // Not sure handle is equal index yet
        blendColor = rgba;

        name = [[NSString alloc]initWithString:e->name];
        nParams= e->nParams;
        vertexData = [[NSString alloc]initWithString:e->vertexData];
        fragData = [[NSString alloc]initWithString:e->fragData];
        eParams = [e copyParams];
        
        useBackground = (e->options & EFFECTOPT_BKDTEXTUREMASK) != 0 ? YES : NO;
        return [self initializeShader];

    }
    return false;
}

-(bool)initializeShader
{
    NSMutableArray* vars = [[NSMutableArray alloc] init];
    for (int i=0 ; i < nParams; i++)
    {
        [vars addObject:[[NSString alloc] initWithString:eParams[i]->name]];
    }

    //NSLog(@"shader name: %@", name);

    if(indexShader != -1)
        app->renderer->removeShader(indexShader);
    
    indexShader = app->renderer->addShader(name, vertexData, fragData, vars, true, false);

    [vars release];
    if(indexShader != -1)
    {
        if(useBackground)
            app->renderer->setBackgroundUse(indexShader);
        return YES;
    }
    return NO;
}

-(void)setEffectData:(int*)values
{
    if(values != nil)
    {
        for(int i=0; i < nParams; i++)
        {
            switch(eParams[i]->nValueType)
            {
                case EFFECTPARAM_SURFACE:
                {
                    short value = (short)values[i];
                    if(value != -1)
                    {
                        hasExtras |= YES;
                        [app->imageBank loadImageByHandle:value];
                        eParams[i]->img_handle = value;
                    }
                    break;
                }
               case EFFECTPARAM_FLOAT:
                    eParams[i]->fValue = *(float*)&values[i];
                    break;
                default:
                    eParams[i]->nValue = values[i];
                    break;
            }
        }
        [self updateShader];
    }

}

-(bool)removeShader
{
    if(indexShader != -1)
    {
        app->renderer->removeShader(indexShader);
        indexShader = -1;
        return YES;
    }
    return NO;
}

-(bool)destroyShader
{
    if(indexShader != -1)
    {
        app->renderer->removeShader(indexShader);
        indexShader = -1;
        return YES;
    }
    return NO;
}

-(NSString*)getName
{
    return name;
}

-(int)getRGBA
{
    return blendColor;
}

-(void)setRGBA:(int)color
{
    blendColor = color;
}

-(int)getIndexShader
{
    return indexShader;
}

-(int)getParamType:(int)paramIdx
{
    if(eParams != nil)
    {
        if(paramIdx >=0 && paramIdx < nParams)
        {
            return eParams[paramIdx]->nValueType;
        }
    }
    return -1;
}

-(int)getParamIndex:(NSString*)name
{
    int index = -1;
    for(int i=0; i < nParams; i++)
    {
        if([eParams[i]->name containsString:name])
        {
            index = i;
            break;
        }
    }
    return index;
}

-(NSString*)getParamName:(int)paramIdx
{
    if(eParams != nil)
    {
        if(paramIdx >=0 && paramIdx < nParams)
        {
            return eParams[paramIdx]->name;
        }
    }
    return nil;
}

-(int)getParamInt:(int)paramIdx
{
    if(eParams != nil)
    {
        if(paramIdx >=0 && paramIdx < nParams)
        {
            return eParams[paramIdx]->nValue;
        }
    }
    return -1;
}

-(float)getParamFloat:(int)paramIdx
{
    if(eParams != nil)
    {
        if(paramIdx >=0 && paramIdx < nParams)
        {
            return eParams[paramIdx]->fValue;
        }
    }
    return -1.0f;
}

-(bool)setParamValue:(int)index andValue:(CValue*)value
{
    if(indexShader != -1 && index >= 0 && index < nParams) {
        app->renderer->setEffectShader(indexShader);

            switch (eParams[index]->nValueType) {
                case EFFECTPARAM_FLOAT:
                {
                    eParams[index]->fValue = (float)[value getDouble];
                    app->renderer->updateVariable1f(eParams[index]->name, eParams[index]->fValue);
                    break;
                }
                case EFFECTPARAM_INTFLOAT4: {
                    eParams[index]->nValue = [value getInt];
                    float *float4f = (float *)malloc(sizeof(float) * 4);
                    int color = eParams[index]->nValue;
                    for (int i = 0; i < 4; i++) {
                        float4f[i] = (float) (color & 0xFF) / 255.0f;
                        color >>= 8;
                    }
                    app->renderer->updateVariable4f(eParams[index]->name, float4f[0], float4f[1], float4f[2], float4f[3]);
                    free(float4f);
                    break;
                }
                default:
                    eParams[index]->nValue = [value getInt];
                    app->renderer->updateVariable1i(eParams[index]->name, eParams[index]->nValue);
                    break;

            }
        app->renderer->removeEffectShader();
        return YES;
    }

    return NO;
}

-(void)setParamAt:(int)paramIdx withIntValue:(int)value
{
    if(eParams != nil)
    {
        if(paramIdx >=0 && paramIdx < nParams)
        {
            eParams[paramIdx]->nValue = value;
            if(indexShader != -1)
            {
                app->renderer->setEffectShader(indexShader);
                app->renderer->updateVariable1i(eParams[paramIdx]->name, eParams[paramIdx]->nValue);
                app->renderer->removeEffectShader();
            }
        }
    }
}

-(void)setParamAt:(int)paramIdx withFloatValue:(float)value
{
    if(eParams != nil)
    {
        if(paramIdx >=0 && paramIdx < nParams)
        {
            eParams[paramIdx]->fValue = value;
            if(indexShader != -1)
            {
                app->renderer->setEffectShader(indexShader);
                app->renderer->updateVariable1f(eParams[paramIdx]->name, eParams[paramIdx]->fValue);
                app->renderer->removeEffectShader();
            }
        }
    }
}

-(void)setParamAt:(int)paramIdx withFloat4Value:(int)value
{
    if(eParams != nil)
    {
        if(paramIdx >=0 && paramIdx < nParams)
        {
            eParams[paramIdx]->nValue = value;
            if(indexShader != -1
                    && eParams[paramIdx]->nValueType ==  EFFECTPARAM_INTFLOAT4)
            {
                float *float4f = (float *)malloc(sizeof(float) * 4);
                int color = eParams[paramIdx]->nValue;
                for (int i = 0; i < 4; i++)
                {
                    float4f[i] = (float)(color & 0xFF) / 255.0f;
                    color >>= 8;
                }
                app->renderer->setEffectShader(indexShader);
                app->renderer->updateVariable4f(eParams[paramIdx]->name, float4f[0], float4f[1], float4f[2], float4f[3]);
                app->renderer->removeEffectShader();
                free(float4f);
            }
        }
    }
}

-(void)setParamAt:(int)paramIdx withTexture:(int)image_handle
{
    if(eParams != nil)
    {
        if(paramIdx >=0 && paramIdx < nParams)
        {
            if(indexShader != -1
                    && eParams[paramIdx]->nValueType ==  EFFECTPARAM_SURFACE)
            {
                if(eParams[paramIdx]->img_handle != -1)
                {
                    [app->imageBank removeImageByHandle:eParams[paramIdx]->img_handle];
                }
                eParams[paramIdx]->img_handle = image_handle;
                app->renderer->setEffectShader(indexShader);
                CImage* img = [app->imageBank getImageFromHandle:eParams[paramIdx]->img_handle];
                if(img == nil)
                {
                    [app->imageBank loadImageByHandle:eParams[paramIdx]->img_handle];
                    img = [app->imageBank getImageFromHandle:eParams[paramIdx]->img_handle];
                }
                if(img != nil)
                {
                    int index = 0;
                    [img updateTextureMode:GL_REPEAT];
                    app->renderer->setSurfaceTextureAtIndex(img, eParams[paramIdx]->name, ++index);
                }
                app->renderer->removeEffectShader();
            }
        }
    }
}

-(bool)updateShader
{
    if(eParams != nil && indexShader != -1)
    {
        if(nParams == 0)
            return NO;

        app->renderer->setEffectShader(indexShader);
        int index = 0;

        for(int n=0; n < nParams; n++) {
            switch(eParams[n]->nValueType)
            {
                case EFFECTPARAM_SURFACE:
                {
                    NSString* var_name = eParams[n]->name;
                    if(eParams[n]->img_handle != -1)
                    {
                        CImage* img = [app->imageBank getImageFromHandle:eParams[n]->img_handle];
                        if(img == nil)
                        {
                            [app->imageBank loadImageByHandle:eParams[n]->img_handle];
                            img = [app->imageBank getImageFromHandle:eParams[n]->img_handle];
                        }
                        if(img != nil)
                        {
                            [img updateTextureMode:GL_REPEAT];
                            app->renderer->setSurfaceTextureAtIndex(img, var_name, ++index);
                        }
                    }
                    break;
                }
                case EFFECTPARAM_FLOAT:
                {
                    NSString* var_name = eParams[n]->name;
                    float var_value= eParams[n]->fValue;
                    app->renderer->updateVariable1f(var_name, var_value);
                    break;
                }
                case EFFECTPARAM_INTFLOAT4:
                {
                    float *float4f = (float *)malloc(sizeof(float) * 4);
                    int color = eParams[n]->nValue;
                    for (int i = 0; i < 4; i++)
                    {
                        float4f[i] = (float)(color & 0xFF) / 255.0f;
                        color >>= 8;
                    }
                    app->renderer->updateVariable4f(eParams[n]->name, float4f[0], float4f[1], float4f[2], float4f[3]);
                    free(float4f);
                    break;
                }
                default:
                    app->renderer->updateVariable1i(eParams[n]->name, eParams[n]->nValue);
                    break;

            }
        }
        app->renderer->removeEffectShader();
        return YES;
    }
    return NO;
}

-(bool)updateParamTexture
{
    if(eParams != nil && indexShader != -1)
    {
        if(nParams == 0 || !hasExtras)
            return NO;

        for(int n=0; n < nParams; n++) {
            if(eParams[n]->nValueType == EFFECTPARAM_SURFACE)
            {
                if(eParams[n]->img_handle != -1)
                {
                    CImage* img = [app->imageBank getImageFromHandle:eParams[n]->img_handle];
                    if(img == nil)
                        [app->imageBank loadImageByHandle:eParams[n]->img_handle];
                }
            }
        }
        return YES;
    }
    return NO;
}

-(bool)refreshParamSurface
{
    if(eParams != nil && indexShader != -1)
    {
        if(nParams == 0 || !hasExtras)
            return NO;

        app->renderer->setEffectShader(indexShader);
        int index = 0;
        
        for(int n=0; n < nParams; n++) {
            if(eParams[n]->nValueType == EFFECTPARAM_SURFACE)
            {
                NSString* var_name = eParams[n]->name;
                if(eParams[n]->img_handle != -1)
                {
                    CImage* img = [app->imageBank getImageFromHandle:eParams[n]->img_handle];
                    if(img != nil)
                    {
                        [img updateTextureMode:GL_REPEAT];
                        app->renderer->setSurfaceTextureAtIndex(img, var_name, ++index);
                    }
                }
            }
        }
        app->renderer->removeEffectShader();
        return YES;
    }
    return NO;
}

@end
