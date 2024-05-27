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
//  CRenderer.cpp
//  RuntimeIPhone
//
//  Created by Anders Riggelsen on 8/20/13.
//  Copyright (c) 2013 Clickteam. All rights reserved.
//


#import "CRenderer.h"

#import "CRenderToTexture.h"
#import "CoreMath.h"
#import "CServices.h"
#import "CShader.h"
#import "CRunView.h"
#import "CRunApp.h"
#import "CRun.h"
#import "CArrayList.h"
#import "CRunFrame.h"
#import "CBitmap.h"
#import "CLayer.h"

static CRenderer* ssRenderer;

#define CHECK_GL_ERROR() ({ GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s\n", __error, __FUNCTION__); (__error ? NO : YES); })



CRenderer::CRenderer(CRunView* runView)
{
    currentShader = NULL;
    defaultShader = NULL;
    gradientShader = NULL;
    currentLayer = NULL;
    
    effectShader = NULL;
    perspectiveShader = NULL;
    sinewaveShader = NULL;

    shaders_vector = shader_init_vector(NUM_INIT_SHADER);
    iShader = -1;
    
    //Do set opengl3 or 2 with apple suggested code
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    isOpenGL2 = false;
    if(context == nil)
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        isOpenGL2 = true;
    }
    
    if (!context)
        return;
    if(![EAGLContext setCurrentContext:context])
        return;

    view = runView;
    windowSize = CGSizeMake(view->appRect.size.width, view->appRect.size.height);
    topLeft = CGPointMake(0, 0);
    texturesToRemove = [[CArrayList alloc] init];
    forgetCachedState();
    ssRenderer = this;

    // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
    
    glGenFramebuffers(1, &defaultFramebuffer);
    glGenRenderbuffers(1, &colorRenderbuffer);

    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);

    glGenRenderbuffers(1, &stencilbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, stencilbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8_OES, (int)windowSize.width, (int)windowSize.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, stencilbuffer);

    glEnable(GL_BLEND);
    usesBlending = YES;
    usesScissor = NO;

    usedTextures = [[NSMutableSet alloc] init];
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);

    currentRenderState.framebuffer = defaultFramebuffer;
    currentRenderState.viewport = Viewport(0, 0, view->appRect.size.width, view->appRect.size.height);
    currentRenderState.transform = Mat3f::identity();
    currentRenderState.projection = Mat3f::orthogonalProjectionMatrix(0, 0, view->appRect.size.width, view->appRect.size.height);
    currentRenderState.newprojection = YES;
    currentRenderState.newtransform  = YES;
    //Vertices:
    
    GLfloat vertices[8] = {
        0.0f,    0.0f,
        1.0f,    0.0f,
        0.0f,    1.0f,
        1.0f,    1.0f
    };
    
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), &vertices, GL_STATIC_DRAW);
    
    defaultShader = new CShader(this);
    gradientShader = new CShader(this);

    defaultShader->loadShader(@"default", true, false);
    gradientShader->loadShader(@"gradient", false, true);
    //defaultShader->bindShader();      //???
    
    backingProgram = -1;
    
    originX = originY = 0;
    scaleX = scaleY = 1.0;
    
    supportedExtensions = [[NSMutableSet alloc] init];
    NSString* extensionString = [NSString stringWithUTF8String:(char *)glGetString(GL_EXTENSIONS)];
    NSArray* extensions = [extensionString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for(NSString* oneExtension in extensions)
    {
        if(![oneExtension isEqualToString:@""])
            [supportedExtensions addObject:oneExtension];
    }

    printf("OpenGL version is %s.\n", (char *)glGetString(GL_VERSION));
    printf("GLSL version is %s.\n", (char *)glGetString(GL_SHADING_LANGUAGE_VERSION));
    
    checkForError();
}

CRenderer* CRenderer::getRenderer()
{
    return ssRenderer;
}

CRenderer::~CRenderer()
{
    destroyFrameBuffers();
    delete defaultShader;
    delete gradientShader;
    [texturesToRemove release];

    delete perspectiveShader;
    delete sinewaveShader;
    
    shader_vector_free(shaders_vector);
    
    // Tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];

    [context release];
    context = nil;
}

void CRenderer::pushRenderingState(Vec2f offset)
{
    renderStateStack.push(currentRenderState);
    Mat3f offsetMatrix = Mat3f::translationMatrix(offset.x, offset.y);
    setTransformMatrix(Mat3f::multiply(currentRenderState.transform, offsetMatrix));
}

void CRenderer::pushRenderingState()
{
    renderStateStack.push(currentRenderState);
}

void CRenderer::popRenderingState()
{
    currentRenderState = renderStateStack.pop();

    glBindFramebuffer(GL_FRAMEBUFFER, currentRenderState.framebuffer);
    setProjectionMatrix(topLeft.x, topLeft.y, currentRenderState.contentSize.x, currentRenderState.contentSize.y);
    forgetCachedState();
}

void CRenderer::destroyFrameBuffers()
{
    if (defaultFramebuffer)
    {
        glDeleteFramebuffers(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }
    if (colorRenderbuffer)
    {
        glDeleteRenderbuffers(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }
    
    glDeleteVertexArrays(1, &vao);
}

// Clear the frame, ready for rendering
void CRenderer::clear(float red, float green, float blue)
{
    currentTextureID = -1;
    glClearColor(red, green, blue, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
}

void CRenderer::clear()
{
    float r,g,b;
    int background;
    if(view->pRunApp->frame != nil)
        background = BGRtoARGB(view->pRunApp->frame->leBackground);
    else
        background = BGRtoARGB(view->pRunApp->gaBorderColour);

    r = ((background >> 16) & 0xFF)/255.0f;
    g = ((background >> 8) & 0xFF)/255.0f;
    b = (background & 0xFF)/255.0f;
    clear(r,g,b);
}

void CRenderer::clearWithRunApp(CRunApp* app)
{
    float r,g,b;
    int background;
    if(app->frame != nil)
        background = BGRtoARGB(app->frame->leBackground);
    else
        background = BGRtoARGB(app->gaBorderColour);

    r = ((background >> 16) & 0xFF)/255.0f;
    g = ((background >> 8) & 0xFF)/255.0f;
    b = (background & 0xFF)/255.0f;
    clear(r,g,b);
}

void CRenderer::swapBuffers()
{
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

void CRenderer::flush()
{
    glFlush();
}

void CRenderer::checkForError()
{
    GLenum err = glGetError();
    if (GL_NO_ERROR != err)
        NSLog(@"Got OpenGL Error: %i", err);
}

void CRenderer::forgetShader()
{
    CShader* shaderToBindAgain = currentShader;
    currentShader = NULL;
    shaderToBindAgain->bindShader();
}

void CRenderer::forgetCachedState()
{
    currentTextureID = -1;
    currentBlendEquationA = currentBlendEquationB = currentBlendFunctionA = currentBlendFunctionB = -1;
    cR = cG = cB = cA = 1.0f;
    currentViewport = Viewport(0,0,0,0);

    if(defaultShader != NULL)
        defaultShader->forgetCachedState();
    if(gradientShader != NULL)
        gradientShader->forgetCachedState();

    if(currentShader != NULL)
    {
        CShader* shaderToBindAgain = currentShader;
        currentShader = NULL;
        if(shaderToBindAgain != NULL)
            shaderToBindAgain->bindShader();
    }
}

void CRenderer::setCurrentShader(CShader* shader)
{
    if(currentShader == shader)
        return;
    
    currentShader = shader;
    
    shader->newProjection = YES;
    shader->newTransform = YES;
    forgetCachedState();
}

//Renders the given image with the previously defined shaders and settings.
void CRenderer::renderSimpleImage(int x, int y, int w, int h)
{
    currentShader->setObjectMatrix(Mat3f::objectMatrix(Vec2f(x,y), Vec2f(w,h), Vec2fZero));
    currentShader->getBackground(x, y, w, h);
    currentShader->bindVertexArray();
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    currentShader->deleteBackground();
}

//The most common image rendering method.
void CRenderer::renderImage(CTexture* image, int x, int y, int w, int h, int inkEffect, int inkEffectParam)
{
    uploadTexture(image);
    setInkEffect(inkEffect, inkEffectParam, effectShader);
    currentShader->setTexture(image);
    currentShader->getBackground(x, y, w, h);
    currentShader->setObjectMatrix(Mat3f::objectMatrix(Vec2f(x,y), Vec2f(w,h), Vec2fZero));
    currentShader->bindVertexArray();
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    currentShader->deleteBackground();
    
}

//The most common image rendering method.
void CRenderer::renderScaledRotatedImage(CTexture* image, float angle, float sX, float sY, int hX, int hY, int x, int y, int w, int h, int inkEffect, int inkEffectParam)
{
    uploadTexture(image);
    setInkEffect(inkEffect, inkEffectParam, effectShader);
    currentShader->setTexture(image);
    currentShader->getBackground(x-hX*sX, y-hY*sY, w*sX, h*sY);
    currentShader->setObjectMatrix(Mat3f::objectRotationMatrix(Vec2f(x,y), Vec2f(w,h), Vec2f(sX,sY), Vec2f(hX, hY), angle));
    currentShader->bindVertexArray();
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    currentShader->deleteBackground();
}

//Renders a tiled picture with clipping.
void CRenderer::renderPattern(CTexture* image, int x, int y, int w, int h, int inkEffect, int inkEffectParam, bool flipX, bool flipY, float scaleX, float scaleY)
{
    CRect visibleRect  = currentLayer->visibleRect;

    //Limit the amount of repetitions to what only is visible
    int startX = x;
    int startY = y;
    int endX = x+w;
    int endY = y+h;

    //Update shader information
    [image uploadTexture];
    setInkEffect(inkEffect, inkEffectParam, effectShader);
    currentShader->setTexture(image);
    currentShader->getBackground(x, y, w, h);
    
    int iw = image->width * scaleX;
    int ih = image->height * scaleY;
    int tw = image->textureWidth;
    int th = image->textureHeight;

    if(startX < -iw)
        startX %= iw;

    if(startY < -ih)
        startY %= ih;

    if(endX > visibleRect.right)
        endX = (endX-visibleRect.width()) % iw + visibleRect.right;

    if(endY > visibleRect.bottom)
        endY = (endY-visibleRect.height()) % ih + visibleRect.bottom;

    w = endX - startX;
    h = endY - startY;

    int wMiW = w % iw;
    int hMiH = h % ih;

    int lastX = endX - wMiW;
    int lastY = endY - hMiH;

    BOOL xDivisible = (wMiW == 0);
    BOOL yDivisible = (hMiH == 0);

    BOOL flipped = flipX || flipY;

    //Texture coordinate matrices
    Mat3f normalTexCoord = image->textureMatrix;
    Mat3f current = normalTexCoord;

    float rx, ry;
    for(int cY=startY; cY<endY; cY+=ih)
    {
        for(int cX=startX; cX<endX; cX+=iw)
        {
            int drawWidth = iw;
            int drawHeight = ih;

            current = normalTexCoord;

            if(cX==lastX && !xDivisible)
            {
                drawWidth = wMiW;
                rx = drawWidth/(float)(tw*scaleX);
                current.a = rx;
            }

            if(cY==lastY && !yDivisible)
            {
                drawHeight = hMiH;
                ry = drawHeight/(float)(th*scaleY);
                current.e = ry;
            }

            if(flipped)
                current = current.flippedTexCoord(flipX, flipY);

            currentShader->setTexCoord(current);

            currentShader->setObjectMatrix(Mat3f::objectMatrix(Vec2f(cX,cY), Vec2f(drawWidth,drawHeight), Vec2fZero));
            currentShader->bindVertexArray();
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            currentShader->deleteBackground();
        }
    }
}


//Renders a tiled picture with clipping.
void CRenderer::renderPattern(CTexture* image, int x, int y, int w, int h, int inkEffect, int inkEffectParam)
{
    //Use the fast rendering mode if the image is Power-Of-Two sized
    if([image imageIsPOT])
    {
        [image expectTilableImage];
        [image uploadTexture];
        setInkEffect(inkEffect, inkEffectParam, nil);
        Mat3f texMatrix = Mat3f::textureMatrix(0, 0, w, h, image->originalWidth, image->originalHeight);
        currentShader->setTexture(image, texMatrix);
        currentShader->getBackground(x, y, w, h);
        currentShader->setObjectMatrix(Mat3f::objectMatrix(Vec2f(x,y), Vec2f(w,h), Vec2fZero));
        currentShader->bindVertexArray();
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        currentShader->deleteBackground();
    }
    else
    {
        //Use the slow but pixel perfect rendering option
        renderPattern(image, x, y, w, h, inkEffect, inkEffectParam, false, false);
    }
}

void CRenderer::renderSolidColor(int color, int x, int y, int w, int h, int inkEffect, int inkEffectParam)
{
    renderGradient(GradientColor(color), x, y, w, h, inkEffect, inkEffectParam);
}

void CRenderer::renderSolidColor(int color, CRect rect, int inkEffect, int inkEffectParam)
{
    renderGradient(GradientColor(color), (int)rect.left, (int)rect.top, (int)rect.width(), (int)rect.height(), inkEffect, inkEffectParam);
}

//The perspective rendering method.
void CRenderer::renderPerspective(CRenderToTexture* image, int x, int y, int w, int h, float fA, float fB, int dir, int inkEffect, int inkEffectParam)
{
    if(perspectiveShader == NULL)
    {
        perspectiveShader = new CShader(this);
        bool wait = perspectiveShader->loadShader(@"perspective_ext", true, false);
        sleep(.005);
        if(wait)
        {
            GLuint pers_program = perspectiveShader->program;
            perspectiveShader->uniforms[UNIFORM_VAR1] = glGetUniformLocation(pers_program, "fA");
            perspectiveShader->uniforms[UNIFORM_VAR2] = glGetUniformLocation(pers_program, "fB");
            perspectiveShader->uniforms[UNIFORM_VAR3] = glGetUniformLocation(pers_program, "pDir");
            if(!perspectiveShader->linkProgram(pers_program))
            {
                perspectiveShader = NULL;
                return;
            }
        }
    }
    
    if(perspectiveShader == NULL || perspectiveShader->program <= 0)
        return;
    
    setInkEffect(inkEffect, inkEffectParam, perspectiveShader);

    currentShader->setVariable1f("fA", fA);
    currentShader->setVariable1f("fB", fB);
    currentShader->setVariable1i("pDir", dir);
    //Also You can send variable using the uniform array
    //perspectiveShader->setVariable1f(perspectiveShader->uniforms[UNIFORM_VAR1], fA);
    //perspectiveShader->setVariable1f(perspectiveShader->uniforms[UNIFORM_VAR2], fB);
    //perspectiveShader->setVariable1i(perspectiveShader->uniforms[UNIFORM_VAR3], dir);
    
    uploadTexture(image);
 
    //currentShader->setTexture(image);
    Mat3f texMatrix = image->textureMatrix;
    texMatrix.flippedTexCoord(false, true);
    currentShader->setTexture(image, texMatrix);
    currentShader->setObjectMatrix(Mat3f::objectMatrix(Vec2f(x,y), Vec2f(w,h), Vec2fZero));
    currentShader->bindVertexArray();
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

//The sinewave rendering method.
void CRenderer::renderSinewave(CRenderToTexture* image, int x, int y, int w, int h, float zoom, float wave, float offset, int dir, int inkEffect, int inkEffectParam)
{
    if(!sinewaveShader)
    {
        sinewaveShader = new CShader(this);
        bool wait = sinewaveShader->loadShader(@"sinewave_ext", true, false);
        sleep(.005);
        if(wait)
        {
            GLuint sine_program = sinewaveShader->program;
            sinewaveShader->uniforms[UNIFORM_VAR1] = glGetUniformLocation(sine_program, "Zoom");
            sinewaveShader->uniforms[UNIFORM_VAR2] = glGetUniformLocation(sine_program, "Wave");
            sinewaveShader->uniforms[UNIFORM_VAR3] = glGetUniformLocation(sine_program, "OffSet");
            sinewaveShader->uniforms[UNIFORM_VAR4] = glGetUniformLocation(sine_program, "pDir");
            if(!sinewaveShader->linkProgram(sine_program))
            {
                sinewaveShader = NULL;
                return;
            }
        }
    }
    if(!sinewaveShader || sinewaveShader->program <= 0)
        return;
    
    setInkEffect(inkEffect, inkEffectParam, sinewaveShader);

    currentShader->setVariable1f("Zoom", zoom);
    currentShader->setVariable1f("Wave", wave);
    currentShader->setVariable1f("OffSet", offset);
    currentShader->setVariable1i("pDir", dir);
    
    uploadTexture(image);
    
    currentShader->setTexture(image);
    currentShader->setObjectMatrix(Mat3f::objectMatrix(Vec2f(x,y), Vec2f(w,h), Vec2fZero));
    currentShader->bindVertexArray();
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


void CRenderer::setOrigin(int x, int y)
{
    originX = x;
    originY = y;
}

//Blit wrappers for the transition system
void CRenderer::renderBlitFull(CRenderToTexture* source)
{
    renderStretch(source, 0, 0, source->width, source->height, 0, 0, source->width, source->height);
}

void CRenderer::renderBlit(CRenderToTexture* source, int xDst, int yDst, int xSrc, int ySrc, int width, int height)
{
    renderStretch(source, xDst, yDst, width, height, xSrc, ySrc, width, height);
}

void CRenderer::renderFade(CRenderToTexture* source, int alpha)
{
    renderStretch(source, 0, 0, source->width, source->height, 0, 0, source->width, source->height, 1, alpha/2);
}

void CRenderer::renderStretch(CRenderToTexture* source, int xDst, int yDst, int wDst, int hDst, int xSrc, int ySrc, int wSrc, int hSrc, int inkEffect, int inkEffectParam)
{
    uploadTexture(source);

    if(currentRenderState.framebuffer == defaultFramebuffer)
    {
        xDst += originX;
        yDst += originY;
    }

    Mat3f texCoord = Mat3f::textureMatrixFlipped(xSrc, ySrc, wSrc, hSrc, source->height, source->textureWidth, source->textureHeight);
    Mat3f transform = Mat3f::objectMatrix(Vec2f(xDst, yDst), Vec2f(wDst, hDst), Vec2fZero);

    setInkEffect(inkEffect, inkEffectParam, effectShader);
    currentShader->setTexture(source, texCoord);
    currentShader->setObjectMatrix(transform);
    currentShader->getBackground(xSrc, ySrc, wSrc, hSrc);
    currentShader->bindVertexArray();
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    currentShader->deleteBackground();
}

void CRenderer::useBlending(BOOL useBlending)
{
    if(useBlending)
    {
        if(!usesBlending)
        {
            glEnable(GL_BLEND);
            usesBlending = YES;
        }
    }
    else
    {
        if(usesBlending)
        {
            glDisable(GL_BLEND);
            usesBlending = NO;
        }
    }
}

BOOL CRenderer::getBlending()
{
    return usesBlending;
}

void CRenderer::uploadTexture(CTexture* texture)
{
    texture->usageCount++;

    if(texture->textureId != -1)
        return;

    textureUsage += [texture uploadTexture];

    //Add texture to set of used textures if it has a valid image-bank handle
    if(texture->isPrunable && texture->handle != -1 && [usedTextures containsObject:texture] == NO)
        [usedTextures addObject:texture];
}

void CRenderer::removeTexture(CTexture* texture, BOOL cleanMemory)
{
    textureUsage -= [texture deleteTexture];
    if(cleanMemory)
        [texture cleanMemory];

    if([usedTextures containsObject:texture] == YES)
        [usedTextures removeObject:texture];
}

void CRenderer::updateViewport()
{
    setViewport(Viewport(0,0,backingWidth,backingHeight));
}

void CRenderer::setViewport(Viewport viewport)
{
    if(currentViewport != viewport)
    {
        glViewport(viewport.position.x, viewport.position.y, viewport.size.x, viewport.size.y);
        currentViewport = viewport;
    }
}

void CRenderer::setCurrentLayer(CLayer *layer)
{
    currentLayer = layer;
    setTransformMatrix( layer != nil ? [layer getTransformMatrix] : Mat3f::identity() );
}

void CRenderer::cleanMemory()
{
    NSEnumerator* enumerator = [usedTextures objectEnumerator];
    id value;
    while ((value = [enumerator nextObject]))
    {
        CTexture* texture = value;
        textureUsage -= [texture deleteTexture];
        texture->usageCount = 0;
    }
    [usedTextures removeAllObjects];
}


//Generates a list of all unused textures over a timespan of 10 seconds
//The renderer will release these textures spread out over the next 10 seconds for minimal speed impact
void CRenderer::cleanUnused()
{
    //NSLog(@"Texture usage: %f MB", (textureUsage/1024.0f)/1024.0f);

    //Clean prune list just to be sure no textures are added twice:
    [texturesToRemove clear];

    NSEnumerator* enumerator = [usedTextures objectEnumerator];
    id value;
    while ((value = [enumerator nextObject]))
    {
        CTexture* texture = value;
        if(texture->usageCount == 0)
            [texturesToRemove add:(void*)texture];
        texture->usageCount = 0;
    }
    //NSLog(@"Generated clean list of %i entries", [texturesToRemove size]);
}

//Remove one unused texture at a time.
void CRenderer::pruneTexture()
{
    int index = [texturesToRemove size]-1;
    if(index >= 0)
    {
        CTexture* texture = (CTexture*)[texturesToRemove get:index];
        //Recheck that the texture wasn't used
        if(texture->usageCount == 0)
            removeTexture(texture, true);

        [texturesToRemove removeIndex:index];
        //NSLog(@"Pruned texture %@", texture);
    }
}

void CRenderer::clearPruneList()
{
    [texturesToRemove clear];
}

void CRenderer::setClip(int x, int y, int w, int h)
{
    int currentWidth = currentRenderState.framebufferSize.x;
    int currentHeight = currentRenderState.framebufferSize.y;

    w = MIN(currentWidth,w);
    h = MIN(currentHeight,h);
    x = MAX(0,x);
    y = MAX(0,y);

    if(!(usesScissor=glIsEnabled(GL_SCISSOR_TEST)))
    {
        glEnable(GL_SCISSOR_TEST);
        usesScissor = YES;
    }
    glScissor(x, backingHeight-y-h, w, h);
}

void CRenderer::resetClip()
{
    if(usesScissor)
    {
        glDisable(GL_SCISSOR_TEST);
        usesScissor = NO;
    }
}

void CRenderer::setBlendEquation(GLenum equation)
{
    if(currentBlendEquationA != equation)
    {
        currentBlendEquationA = equation;
        glBlendEquation(equation);
    }
}

void CRenderer::setBlendEquationSeperate(GLenum equationA, GLenum equationB)
{
    if(currentBlendEquationA != equationA || equationB != currentBlendEquationB)
    {
        currentBlendEquationA = equationA;
        currentBlendEquationB = equationB;
        glBlendEquationSeparate(equationA, equationB);
    }
}

void CRenderer::setBlendFunction(GLenum sFactor, GLenum dFactor)
{
    if(currentBlendFunctionA != sFactor || currentBlendFunctionB != dFactor)
    {
        currentBlendFunctionA = sFactor;
        currentBlendFunctionB = dFactor;
        glBlendFunc(sFactor, dFactor);
    }
}

void CRenderer::setBlendColor(float red, float green, float blue, float alpha)
{
    if(cA != alpha || cR != red || cG != green || cB != blue)
    {
        cR = red;
        cG = green;
        cB = blue;
        cA = alpha;
    }
}

void CRenderer::bindRenderBuffer()
{
    [EAGLContext setCurrentContext:context];
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
}

void CRenderer::setInkEffect(int effect, int effectParam, CShader* shader)
{
    bool useBasic = YES;
    CShader* useShader = defaultShader;
    unsigned int rgbaCoeff;
    float red = 1.0f, green = 1.0f, blue = 1.0f, alpha = 1.0f;

    //Ignores shader effects
    if((effect & BOP_MASK)==BOP_EFFECTEX)
    {
        effect = BOP_BLEND;
        rgbaCoeff = effectParam;
        red = ((rgbaCoeff>>16) & 0xFF) / 255.0f;
        green = ((rgbaCoeff>>8) & 0xFF) / 255.0f;
        blue = (rgbaCoeff & 0xFF) / 255.0f;
        alpha = (rgbaCoeff >> 24)/255.0f;
    }
    //Extracts the RGB Coefficient
    else if((effect & BOP_RGBAFILTER) != 0)
    {
        effect = MAX(effect & BOP_MASK, BOP_BLEND);
        useBasic = NO;

        rgbaCoeff = effectParam;
        red = ((rgbaCoeff>>16) & 0xFF) / 255.0f;
        green = ((rgbaCoeff>>8) & 0xFF) / 255.0f;
        blue = (rgbaCoeff & 0xFF) / 255.0f;
        alpha = (rgbaCoeff >> 24)/255.0f;
    }
    //Uses the generic INK-effect
    else
    {
        effect &= BOP_MASK;
        if(effectParam == -1)
            alpha = 1.0f;
            else
                alpha = 1.0f - effectParam/128.0f;
    }

    // Use shader program
    if(shader != NULL)
    {
        useShader = shader;
        effect = MAX(effect & BOP_MASK, BOP_BLEND);
    }

    useShader->bindShader();
    currentShader->setInkEffect(effect);
    currentShader->setRGBCoeff(red, green, blue, alpha);
}

void CRenderer::setTransformMatrix(const Mat3f matrix)
{
    currentRenderState.transform = matrix;
    currentRenderState.newtransform = YES;
//    defaultShader->newTransform = YES;
//    gradientShader->newTransform = YES;
//
//    if(perspectiveShader != NULL)
//        perspectiveShader->newProjection = YES;
//    if(sinewaveShader != NULL)
//        sinewaveShader->newProjection = YES;

}

void CRenderer::setProjectionMatrix(int x, int y, int width, int height)
{
    currentRenderState.projection = Mat3f::orthogonalProjectionMatrix(x, y, width, height);
    currentRenderState.newprojection = YES;
//    defaultShader->newProjection = YES;
//    gradientShader->newProjection = YES;
//
//    if(effectShader != NULL)
//        effectShader->newProjection = YES;
//    if(perspectiveShader != NULL)
//        perspectiveShader->newProjection = YES;
//    if(sinewaveShader != NULL)
//        sinewaveShader->newProjection = YES;

    setViewport(Viewport(x, y, width, height));
}

void CRenderer::setSurfaceTextureAtIndex(CTexture* image, NSString* name, int index)
{
    if(image == NULL || effectShader == NULL)
        return;
    
    if(image->textureId == -1)
        uploadTexture(image);
    
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;
    
   shader->setSurfaceTextureAtIndex(image, [name UTF8String], index);
    
}

void CRenderer::updateSurfaceTexture()
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;
    
   shader->updateSurfaceTexture();

}

void CRenderer::renderLine(Vec2f pA, Vec2f pB, int color, float thickness)
{
    float angle = atan2(pB.y-pA.y, pB.x-pA.x);
    float length = pA.distanceTo(pB);
    Mat3f lineMatrix = Mat3f::objectRotationMatrix(pA, Vec2f(length, thickness), Vec2fOne, Vec2f(0, thickness/2), -radiansToDegrees(angle));

    //Update shader information
    setInkEffect(0, 0, gradientShader);
    currentShader->setGradientColors(color);
    currentShader->setObjectMatrix(lineMatrix);
    currentShader->bindVertexArray();
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

void CRenderer::renderGradient(GradientColor gradient, int x, int y, int w, int h, int inkEffect, int inkEffectParam)
{
    float alpha;
    unsigned int rgbaCoeff = inkEffectParam;
    if((inkEffect & BOP_MASK)==BOP_EFFECTEX || (inkEffect & BOP_RGBAFILTER) != 0)
    {
        alpha = (rgbaCoeff >> 24)/255.0f;
    }
    else
    {
        if(inkEffectParam == -1)
            alpha = 1.0f;
        else
            alpha = 1.0f - inkEffectParam/128.0f;
    }
    gradient.a.a = alpha;
    gradient.b.a = alpha;
    gradient.c.a = alpha;
    gradient.d.a = alpha;

    setInkEffect(0, 0, gradientShader);
    currentShader->setGradientColors(gradient);
    currentShader->setObjectMatrix(Mat3f::objectMatrix(Vec2f(x,y), Vec2f(w,h), Vec2fZero));
    currentShader->bindVertexArray();
    currentShader->getBackground(x, y, w, h);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    currentShader->deleteBackground();

}

void CRenderer::renderGradient(GradientColor gradient, CRect rect, int inkEffect, int inkEffectParam)
{
    renderGradient(gradient, (int)rect.left, (int)rect.top, (int)rect.width(), (int)rect.height(), inkEffect, inkEffectParam);
}

bool CRenderer::resizeFromLayer(CAEAGLLayer* layer)
{
    // Allocate color buffer backing based on the current layer size
    [EAGLContext setCurrentContext:context];
    
    layer.bounds = CGRectMake(layer.bounds.origin.x, layer.bounds.origin.y, windowSize.width, windowSize.height);

    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);

    currentRenderState.framebufferSize = Vec2i(backingWidth, backingHeight);
    currentRenderState.contentSize = Vec2f(backingWidth, backingHeight);
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);

    glBindRenderbuffer(GL_RENDERBUFFER, stencilbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8_OES, backingWidth, backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, stencilbuffer);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

    forgetCachedState();
    setProjectionMatrix(topLeft.x, topLeft.y, currentRenderState.contentSize.x, currentRenderState.contentSize.y);
    return YES;
}


void CRenderer::screenAreaToTexture(CTexture* texture, int x , int y, int width, int height, int mode)
{

//#define FXCOPY
#ifdef FXCOPY
    glBindFramebuffer(GL_READ_FRAMEBUFFER, defaultFramebuffer);
    glReadBuffer(GL_COLOR_ATTACHMENT0);

    glBindTexture(GL_TEXTURE_2D, texture->textureId);
    glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, x, backingHeight - y - height, width, height);

    Mat3f texMatrix = Mat3f::textureMatrixFlipped(0, 0, width, height, height,texture->originalWidth, texture->originalHeight);
    texture->textureMatrix = texMatrix;
#else

    glBindTexture(GL_TEXTURE_2D, texture->textureId);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture->textureId, 0);
    
    glBindFramebuffer(GL_READ_FRAMEBUFFER, defaultFramebuffer);
    glReadBuffer(GL_COLOR_ATTACHMENT0);

    glBlitFramebuffer(x, backingHeight - y - height,
                      width + x, backingHeight - y ,
                      0, 0, texture->textureWidth, texture->textureHeight,
                      GL_COLOR_BUFFER_BIT,
                      GL_LINEAR);
    //NSLog(@"failed to make framebuffer blit %x", glGetError());
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
    Mat3f texMatrix = Mat3f::textureMatrixFlipped(0, 0,
                                           texture->textureWidth, texture->textureHeight,
                                           texture->textureHeight,
                                           texture->textureWidth, texture->textureHeight);
    //Mat3f texMatrix = Mat3f::identity();
    texture->textureMatrix = texMatrix;
    
#endif
    //Reset
    glBindTexture(GL_TEXTURE_2D, 0);
    forgetCachedState();
}

void CRenderer::screenPixelsToTexture(CTexture* texture, int x , int y, int width, int height)
{
    int scale = 1;
    UIScreen* screen = [ UIScreen mainScreen ];
    if ( [ screen respondsToSelector:@selector(scale) ] )
    scale = (int) [ screen scale ];
    
    width *= scale;
    height*= scale;
    
    NSInteger dataLen = width * height * 4;
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(dataLen);
    
    glReadPixels(x, y, width, backingHeight - y - height, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid *)buffer);
    
    // mirrored to screen
    GLubyte *buffer2 = (GLubyte *) malloc(dataLen);
    if(buffer2 == nil)
    {
        free(buffer);
        return;
    }
    for(int j = 0; j <height; j++)
    {
        for(int i = 0; i <width * 4; i++)
        {
            buffer2[(height - 1 - j) * width * 4 + i] = buffer[j * 4 * width + i];
        }
    }
    
    free(buffer);
    
    glBindTexture(GL_TEXTURE_2D, texture->textureId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    if(texture->textureWidth <= width && texture->textureHeight <= height)
    {
        
        int pixels = texture->textureWidth*texture->textureHeight;
        int newSize = pixels*4;
        
        if(texture->textureWidth == width && texture->textureHeight == height)
        {
            //Texture data can be directly transfered to the graphics card without copying
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texture->textureWidth, texture->textureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, buffer2);
        }
        else
        {
            //Copy to intermediate texture is required
            GLubyte* texData = (GLubyte*)malloc(newSize);
            memset(texData, 0, newSize);
            
            int lineWidth = width*4;
            int bLineWidth = (lineWidth+3) & ~3;
            
            for(int j=0; j<height; ++j)
            memcpy((char*)texData + texture->textureWidth*j*4, (char*)buffer2 + bLineWidth*j, lineWidth);
            
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texture->textureWidth, texture->textureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, texData);
            free(texData);
        }
    }
    if(buffer2 != nil)
        free(buffer2);
}

UIImage* CRenderer::screenAreaToImage(int x , int y, int width, int height)
{
    int scale = 1;
    UIScreen* screen = [ UIScreen mainScreen ];
    if ( [ screen respondsToSelector:@selector(scale) ] )
    scale = (int) [ screen scale ];
    
    width *= scale;
    height*= scale;
    NSInteger dataLen = width * height * 4;
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(dataLen);
    
    GLint viewPort[4];
    glGetIntegerv(GL_VIEWPORT, (GLint*)&viewPort);
    
    glReadPixels(x, viewPort[3] + 1 - y - height, width, height, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid *)buffer);
    // mirrored to screen
    GLubyte *buffer2 = (GLubyte *) malloc(dataLen);
    if(buffer2 == nil)
    {
        free(buffer);
        return nil;
    }
    for(int j = 0; j <height; j++)
    {
        for(int i = 0; i <width * 4; i++)
        {
            buffer2[(height - 1 - j) * width * 4 + i] = buffer[j * 4 * width + i];
        }
    }
    free(buffer);
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, dataLen, NULL);
    
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    // then make the uiimage from imageref
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease( imageRef );
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpaceRef);
    free(buffer2);
    
    return myImage;
}

//Shader operation
int CRenderer::addShader(NSString* shaderName, NSString* vertexShader, NSString* fragmentShader, NSArray* shaderVariables, bool useTexCoord, bool useColors)
{

    CShader* shader = new CShader(this);
    if(shader->loadShader(shaderName, vertexShader, fragmentShader, useTexCoord, useColors))
    {
        GLuint shader_program = shader->program;
        for (int i = 0; i < [shaderVariables count]; i++)
        {
            if([shaderVariables objectAtIndex:i] != nil)
                shader->uniforms[UNIFORM_VAR1+i] = glGetUniformLocation(shader_program, [[shaderVariables objectAtIndex:i] UTF8String]);
        }
        if(shader->linkProgram(shader_program))
        {
            int newIndex = shader_vector_append(shaders_vector, shader);
            //NSLog(@"Shader:%@ with index:%d", shaderName, newIndex);
            return newIndex;
        }
    }
    return -1;
}
int CRenderer::addShader(NSString* shaderName, NSArray* shaderVariables, bool useTexCoord, bool useColors)
{

    CShader* shader = new CShader(this);
    if(shader->loadShader(shaderName, useTexCoord, useColors))
    {
        GLuint shader_program = shader->program;
        for (int i = 0; i < [shaderVariables count]; i++)
        {
            if([shaderVariables objectAtIndex:i] != nil)
                shader->uniforms[UNIFORM_VAR1+i] = glGetUniformLocation(shader_program, [[shaderVariables objectAtIndex:i] UTF8String]);
        }
        if(shader->linkProgram(shader_program))
        {
            int newIndex = shader_vector_append(shaders_vector, shader);
            //NSLog(@"Shader:%@ with index:%d", shaderName, newIndex);
            return newIndex;
        }
    }

    return -1;
}
void CRenderer::removeShader(int shaderIndex)
{
    if(shaderIndex < 0 || shaderIndex >= shader_vector_size(shaders_vector))
        return;
    
    CShader* shader = (CShader*)shader_vector_get(shaders_vector, shaderIndex);
    if(shader != NULL)
    {
        if(currentShader == shader)
            currentShader = NULL;
        shader->detachShader();
        shader_vector_removeByIndex(shaders_vector, shaderIndex);
    }
    
}
void CRenderer::setEffectShader(int shaderIndex)
{
    if(shaderIndex < 0 || shaderIndex >= shader_vector_size(shaders_vector))
        return;

    iShader = shaderIndex;
    effectShader = (CShader*)shader_vector_get(shaders_vector, shaderIndex);
    //NSLog(@"shader index: %d and vector %p", shaderIndex, effectShader);
    if(effectShader != NULL)
        setCurrentShader(effectShader);
}
void CRenderer::removeEffectShader()
{
    effectShader = NULL;
    iShader = -1;
}
void CRenderer::updateVariable1i(NSString* varName, int value)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;
    const GLchar *name = [varName UTF8String];
    shader->setVariable1i(name, value);

}
void CRenderer::updateVariable1i(int varIndex, int value)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;

    shader->setVariable1i(varIndex, value);

}
void CRenderer::updateVariable1f(NSString* varName, float value)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;

    const GLchar *name = [varName UTF8String];
    shader->setVariable1f(name, value);

}
void CRenderer::updateVariable1f(int varIndex, float value)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;

    shader->setVariable1f(varIndex, value);

}

void CRenderer::updateVariable2i(NSString* varName, int value0, int value1)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;

    const GLchar *name = [varName UTF8String];
    shader->setVariable2i(name, value0, value1);

}
void CRenderer::updateVariable2i(int varIndex, int value0, int value1)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;

    shader->setVariable2i(varIndex, value0, value1);

}
void CRenderer::updateVariable2f(NSString* varName, float value0, float value1)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;

    const GLchar *name = [varName UTF8String];
    shader->setVariable2f(name, value0, value1);

}
void CRenderer::updateVariable2f( int varIndex, float value0, float value1)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;

    shader->setVariable2f(varIndex, value0, value1);

}

void CRenderer::updateVariable3i(NSString* varName, int value0, int value1, int value2)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;

    const GLchar *name = [varName UTF8String];
    shader->setVariable3i(name, value0, value1, value2);

}
void CRenderer::updateVariable3i(int varIndex, int value0, int value1, int value2)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;

    shader->setVariable3i(varIndex, value0, value1, value2);

}
void CRenderer::updateVariable3f(NSString* varName, float value0, float value1, float value2)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;
    const GLchar *name = [varName UTF8String];
    shader->setVariable3f(name, value0, value1, value2);

}
void CRenderer::updateVariable3f( int varIndex, float value0, float value1, float value2)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;

    shader->setVariable3f(varIndex, value0, value1, value2);

}
void CRenderer::updateVariable4i(NSString* varName, int value0, int value1, int value2, int value3)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;
    const GLchar *name = [varName UTF8String];
    shader->setVariable4i(name, value0, value1, value2, value3);

}
void CRenderer::updateVariable4i(int varIndex, int value0, int value1, int value2, int value3)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;

    shader->setVariable4i(varIndex, value0, value1, value2, value3);
}
void CRenderer::updateVariable4f(NSString* varName, float value0, float value1, float value2, float value3)
{
    if(iShader < 0)
            return;

        CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
        if(shader == NULL)
            return;
        const GLchar *name = [varName UTF8String];
        shader->setVariable4f(name, value0, value1, value2, value3);

}
void CRenderer::updateVariable4f(int varIndex, float value0, float value1, float value2, float value3)
{
    if(iShader < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, iShader);
    if(shader == NULL)
        return;

    shader->setVariable4f(varIndex, value0, value1, value2, value3);
}
void CRenderer::setBackgroundUse(int shaderIndex)
{
    if(shaderIndex < 0)
        return;

    CShader* shader = (CShader*)shader_vector_get(shaders_vector, shaderIndex);
    if(shader == NULL)
        return;

    shader->setBackgroundUse();
}

void CRenderer::setCurrentView(int x, int y, float sX, float sY)
{
    baseX = x;
    baseY = y;
    scaleX = sX;
    scaleY = sY;
}




Viewport::Viewport()
{
    this->position = Vec2iZero;
    this->size = Vec2iZero;
}

Viewport::Viewport(Vec2i position, Vec2i size)
{
    this->position = position;
    this->size = size;
}

Viewport::Viewport(int x, int y, int width, int height)
{
    this->position = Vec2i(x,y);
    this->size = Vec2i(width, height);
}

float Viewport::aspect()
{
    return size.x/(float)size.y;
}

bool Viewport::operator==(const Viewport &rhs) const{return this->position == rhs.position && this->size == rhs.size;}
bool Viewport::operator!=(const Viewport &rhs) const{return !(*this == rhs);}



/*
 *    Vectorize Shaders code
 * ===========================
 */
sh_vector* shader_init_vector(size_t item_size)
{
    sh_vector* vec;
    vec = (sh_vector*)malloc(sizeof(sh_vector));
    vec->items = (void**)malloc(item_size* sizeof(void*));
    vec->size = item_size;
    for (int i = 0; i < vec->size; i++)
    {
        vec->items[i] = NULL;
    }
    vec->free = (int)item_size;
    return vec;
}

int shader_vector_append(sh_vector* vec, void* item)
{
    if(vec->free != 0)
    {
        int i;
        for (i = 0; i < vec->size; i++)
        {
            if(vec->items[i] == NULL)
            {
                --vec->free;
                vec->items[i] = item;
                return  i;
            }
        }
    }

    vec->size++;
    vec->items = (void **) realloc(vec->items, vec->size * sizeof(item));
    vec->items[vec->size - 1] = item;
    vec->free = 0;
    return (int)(vec->size - 1);
}

int shader_vector_size(sh_vector* vec)
{
    return (int)(vec->size);
}

void shader_vector_remove(sh_vector* vec, void* item)
{
    for (int i = 0; i < vec->size; i++)
    {
        if(vec->items[i] == item)
        {
            free(vec->items[i]);
            vec->items[i] = NULL;
            vec->free++;
            break;
        }
    }

}

void shader_vector_removeByIndex(sh_vector* vec, int index)
{
    if(index < vec->size && index > -1)
    {
        free(vec->items[index]);
        vec->items[index] = NULL;
        vec->free++;
    }
}

void* shader_vector_get(sh_vector* vec, int index) {
    if(index < vec->size && index > -1)
        return (void*)vec->items[index];
    else
        return NULL;
}

void shader_vector_free(sh_vector* vec) {
    for (int i = 0; i < vec->size; i++)
        free(vec->items[i]);

    free(vec->items);
    free(vec);
}
