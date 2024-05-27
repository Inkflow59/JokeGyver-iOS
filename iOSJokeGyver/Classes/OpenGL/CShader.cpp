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
//  CShader.m
//  RuntimeIPhone
//
//  Created by Anders Riggelsen on 6/10/10.
//  Copyright 2010 Clickteam. All rights reserved.
//

#import "CShader.h"
#import "CBitmap.h"
#import "CRenderer.h"

CShader::CShader(CRenderer* renderer)
{
	render = renderer;
	currentEffect = -1;
	currentR = currentG = currentB = currentA = -1;

	for (int i=0; i<NUM_UNIFORMS; ++i) {
		uniforms[i] = -1;
	}
	forgetCachedState();
    
    for (int i=0; i<NUM_XTRATEX; ++i) {
        extraTexID[i] = -1;
    }
    hasExtras = false;
    useBackground = false;
    bckgTexID = -1;

}
CShader::~CShader()
{
    if(program)
        glDeleteProgram(program);
    
    if(sname)
    {
        [sname release];
        sname = nil;
    }
}

void CShader::checkError()
{
    GLenum err = glGetError();
    if (GL_NO_ERROR != err)
        NSLog(@"Shader, got OpenGL Error: %i", err);

}

bool CShader::loadShader(NSString* name, NSString* vertexShader, NSString* fragmentShader, bool useTexCoord, bool useColors)
{
    sname = [[NSString alloc] initWithString:name];

	program = glCreateProgram();
	usesTexCoord = useTexCoord;
	usesColor = useColors;

	// Create and compile vertex shader
	if (!compileShader(&vertexProgram, vertexShader, GL_VERTEX_SHADER))
	{
		NSLog(@"Failed to compile vertex shader");
		return FALSE;
	}
	// Create and compile fragment shader
	if (!compileShader(&fragmentProgram, fragmentShader, GL_FRAGMENT_SHADER))
	{
		NSLog(@"Failed to compile fragment shader");
		return FALSE;
	}

	glAttachShader(program, vertexProgram);
	glAttachShader(program, fragmentProgram);

	glBindAttribLocation(program, ATTRIB_VERTEX, "position");

	if (!linkProgram(program))
	{
		NSLog(@"Failed to link program: %d", program);

		if (vertexProgram)
		{
			glDeleteShader(vertexProgram);
			vertexProgram = 0;
		}
		if (fragmentProgram)
		{
			glDeleteShader(fragmentProgram);
			fragmentProgram = 0;
		}
		if (program)
		{
			glDeleteProgram(program);
			program = 0;
		}
		return FALSE;
	}
    
	glUseProgram(program);
	uniforms[UNIFORM_PROJECTIONMATRIX] = glGetUniformLocation(program, "projectionMatrix");
	uniforms[UNIFORM_INKEFFECT] = glGetUniformLocation(program, "inkEffect");
	uniforms[UNIFORM_RGBA] = glGetUniformLocation(program, "blendColor");
	uniforms[UNIFORM_TRANSFORMMATRIX] = glGetUniformLocation(program, "transformMatrix");
	uniforms[UNIFORM_OBJECTMATRIX] = glGetUniformLocation(program, "objectMatrix");

	if(useTexCoord)
	{
		uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(program, "imgTexture");
        uniforms[UNIFORM_BCKGTEXTURE] = glGetUniformLocation(program, "bckgTexture");
		uniforms[UNIFORM_TEXTUREMATRIX] = glGetUniformLocation(program, "textureMatrix");
		glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
		glActiveTexture(GL_TEXTURE0);
	}

	if(useColors)
	{
		uniforms[UNIFORM_GRADIENT] = glGetUniformLocation(program, "colorMatrix");
	}


    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, 0);
    glEnableVertexAttribArray(ATTRIB_VERTEX);


    newProjection = YES;

	return TRUE;
}

GLuint CShader::compileShader(GLuint* shader, NSString* shaderSource, GLint type)
{
	GLint status;
	const GLchar *source = [shaderSource UTF8String];

	*shader = glCreateShader(type);
	glShaderSource(*shader, 1, &source, NULL);
	glCompileShader(*shader);

	GLint logLength;
	glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0)
	{
		GLchar *log = (GLchar *)malloc(logLength);
		glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader %@ of type:%d compile log:\n%s", sname, type, log);
		free(log);
	}

	glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	if (status == 0)
	{
		glDeleteShader(*shader);
		NSLog(@"Unable to compile shader");
		return FALSE;
	}

	return TRUE;
}


bool CShader::loadShader(NSString* shaderName, bool useTexCoord, bool useColors)
{
	NSString* vertShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh" inDirectory:@""];
	NSString* vertexShader = [NSString stringWithContentsOfFile:vertShaderPathname encoding:NSUTF8StringEncoding error:nil];
	NSString* fragShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh" inDirectory:@""];
	NSString* fragmentShader = [NSString stringWithContentsOfFile:fragShaderPathname encoding:NSUTF8StringEncoding error:nil];
	return loadShader(shaderName, vertexShader, fragmentShader, useTexCoord, useColors);
}

bool CShader::linkProgram(GLuint prog)
{
	GLint status;

    glLinkProgram(prog);

    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }

    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;

    return TRUE;
}

bool CShader::validateProgram(GLuint prog)
{
/*
	 GLint logLength, status;

    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }

    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
*/
    return TRUE;
}

void CShader::detachShader()
{
    glDetachShader(program, vertexProgram);
    glDetachShader(program, fragmentProgram);

    if (vertexProgram)
    {
        glDeleteShader(vertexProgram);
        vertexProgram = 0;
    }
    if (fragmentProgram)
    {
        glDeleteShader(fragmentProgram);
        fragmentProgram = 0;
    }
    if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }
    if(sname)
    {
        [sname release];
        sname = nil;
    }
}
void CShader::setRGBCoeff(float red, float green, float blue, float alpha)
{
	if(currentA != alpha || currentR != red || currentG != green || currentB != blue)
	{
		int uniformLoc = uniforms[UNIFORM_RGBA];
		glUniform4f(uniformLoc, red, green, blue, alpha);
		currentR = red;
		currentG = green;
		currentB = blue;
		currentA = alpha;
	}
}

void CShader::setInkEffect(int effect)
{
	//Set transparency based on the inkEffect
	switch (effect)
	{
		default:
		case BOP_COPY:
		case BOP_BLEND:
		case BOP_BLEND_REPLEACETRANSP:
		case BOP_BLEND_DONTREPLACECOLOR:
		case BOP_OR:
		case BOP_XOR:
		case BOP_MONO:
		case BOP_INVERT:
			render->setBlendEquation(GL_FUNC_ADD);
			render->setBlendFunction(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			break;
		case BOP_ADD:
			render->setBlendEquation(GL_FUNC_ADD);
			render->setBlendFunction(GL_SRC_ALPHA, GL_ONE);
			break;
		case BOP_SUB:
			render->setBlendEquationSeperate(GL_FUNC_REVERSE_SUBTRACT, GL_FUNC_ADD);
			render->setBlendFunction(GL_SRC_ALPHA, GL_ONE);
			break;
	}

	if(currentEffect != effect)
	{
		glUniform1i(uniforms[UNIFORM_INKEFFECT], effect);
		currentEffect = effect;
	}
}

void CShader::bindVertexArray()
{
    glBindVertexArray(render->vao);
}

void CShader::unbindVertexArray()
{
    glBindVertexArray(0);
}

void CShader::bindShader()
{
    if(render == NULL)
        return;
        
	if(this != render->currentShader)
	{
		glUseProgram(program);
		render->currentShader = this;
	}
	
    if(newProjection || render->currentRenderState.newtransform)
    {
        glUniformMatrix3fv(uniforms[UNIFORM_PROJECTIONMATRIX], 1, GL_FALSE, (float*)&render->currentRenderState.projection);
        newProjection = NO;
    }
    if(newTransform || render->currentRenderState.newtransform)
    {
        glUniformMatrix3fv(uniforms[UNIFORM_TRANSFORMMATRIX], 1, GL_FALSE, (float*)&render->currentRenderState.transform);
        newTransform = NO;
    }
}

void CShader::unbindShader()
{
    glUseProgram(0);
}

void CShader::forgetCachedState()
{
	prevTexCoord = Mat3f::zero();
	currentA = -1;
	currentR = -1;
	currentG = -1;
	currentB = -1;
	newProjection = YES;
	newTransform = YES;
}

void CShader::setTexCoord(Mat3f &texCoord)
{
	if(prevTexCoord != texCoord)
	{
		glUniformMatrix3fv(uniforms[UNIFORM_TEXTUREMATRIX], 1, GL_FALSE, (float*)&texCoord);
		prevTexCoord = texCoord;
	}
}

void CShader::setTexture(CTexture* texture)
{
	int texId = texture->textureId;
	if(render->currentTextureID != texId)
	{
        glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, texId);
		render->currentTextureID = texId;
	}
	if(prevTexCoord != texture->textureMatrix)
	{
		glUniformMatrix3fv(uniforms[UNIFORM_TEXTUREMATRIX], 1, GL_FALSE, (float*)&texture->textureMatrix);
		prevTexCoord = texture->textureMatrix;
	}
    
    updateSurfaceTexture();
}

void CShader::setTexture(CTexture* texture, Mat3f &textureMatrix)
{
	int texId = texture->textureId;
	if(render->currentTextureID != texId)
	{
        glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, texId);
		render->currentTextureID = texId;
	}
	if(prevTexCoord != textureMatrix)
	{
		glUniformMatrix3fv(uniforms[UNIFORM_TEXTUREMATRIX], 1, GL_FALSE, (float*)&textureMatrix);
		prevTexCoord = textureMatrix;
	}
    
    updateSurfaceTexture();
}

void CShader::getBackground(int x, int y, int w, int h)
{
    if(!useBackground || uniforms[UNIFORM_BCKGTEXTURE] == -1)
        return;

    int i = 0;
    if(hasExtras)
    {
        for(i=0; i < NUM_XTRATEX ; i++)
        {
            if(extraTexID[i] == -1)
                break;
        }
    }
    
    GLint old_active = -1;
    glGetIntegerv(GL_ACTIVE_TEXTURE, &old_active);

    glActiveTexture(GL_TEXTURE1+i);
    
    glGenTextures(1, (GLuint *) &bckgTexID);
    glBindTexture(GL_TEXTURE_2D, bckgTexID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glBindTexture(GL_TEXTURE_2D, 0);


    glBindFramebuffer(GL_READ_FRAMEBUFFER, render->defaultFramebuffer);
    glReadBuffer(GL_COLOR_ATTACHMENT0);

    glBindTexture(GL_TEXTURE_2D, bckgTexID);
    glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, x, render->backingHeight-y-h, w, h);


    glUniform1i(uniforms[UNIFORM_BCKGTEXTURE], i+1);


    glActiveTexture(old_active);

}

void CShader::deleteBackground()
{
    if(!useBackground || uniforms[UNIFORM_BCKGTEXTURE] == -1)
        return;

    if(bckgTexID != -1)
    {
        glBindTexture(GL_TEXTURE_2D, bckgTexID);
        glDeleteTextures (1, (GLuint *) &bckgTexID);
        bckgTexID = -1;
    }
}

void CShader::setSurfaceTextureAtIndex(CTexture* texture, const GLchar* name, int index)
{
    if(index <= 0 || index > NUM_XTRATEX+1)
        return;
    
    glUseProgram(program);
    int loc = glGetUniformLocation(program, name);
    if(loc != -1)
    {
        glUniform1i(loc, index);
    }
    //NSLog(@"Setting in shader: %s and handle: %d texture: %d in index:%d in location:%d",name, texture->handle, texture->textureId, index, loc);
    extraTexID[index-1] = texture->textureId;
    hasExtras |= TRUE;
    
}

void CShader::updateSurfaceTexture()
{
    if(!hasExtras)
        return;

    GLint actActive = -1;
    glGetIntegerv(GL_ACTIVE_TEXTURE, &actActive);
    
    for(int i=0 ; i < NUM_XTRATEX; i++)
    {
        if(extraTexID[i] != -1)
        {
            glActiveTexture(GL_TEXTURE1 + i);
            glBindTexture(GL_TEXTURE_2D, extraTexID[i]);
        }
    }

    glActiveTexture(actActive);

}

void CShader::setObjectMatrix(const Mat3f &matrix)
{
	glUniformMatrix3fv(uniforms[UNIFORM_OBJECTMATRIX], 1, GL_FALSE, (float*)&matrix);
}

void CShader::setGradientColors(GradientColor gradient)
{
	glUniformMatrix4fv(uniforms[UNIFORM_GRADIENT], 1, GL_FALSE, (float*)&gradient);
}

void CShader::setGradientColors(int color)
{
	GradientColor gradient = GradientColor(color);
	glUniformMatrix4fv(uniforms[UNIFORM_GRADIENT], 1, GL_FALSE, (float*)&gradient);
}

void CShader::setGradientColors(int a, int b, BOOL horizontal)
{
	GradientColor gradient = GradientColor(a, b, horizontal);
	glUniformMatrix4fv(uniforms[UNIFORM_GRADIENT], 1, GL_FALSE, (float*)&gradient);
}

void CShader::setGradientColors(int a, int b, int c, int d)
{
	GradientColor gradient = GradientColor(a, b, c, d);
	glUniformMatrix4fv(uniforms[UNIFORM_GRADIENT], 1, GL_FALSE, (float*)&gradient);
}

void CShader::setVariable1i(const GLchar* field, int value)
{
    glUseProgram(program);
    GLint uniformId = glGetUniformLocation(program, field);
    if(uniformId != -1)
        glUniform1i(uniformId, value);
}
void CShader::setVariable1f(const GLchar* field, float value)
{
    glUseProgram(program);
    GLint uniformId = glGetUniformLocation(program, field);
    if(uniformId != -1)
        glUniform1f(uniformId, value);
}
void CShader::setVariable2i(const GLchar* field, int value0, int value1)
{
    glUseProgram(program);
    GLint uniformId = glGetUniformLocation(program, field);
    if(uniformId != -1)
        glUniform2i(uniformId, value0, value1);
}
void CShader::setVariable2f(const GLchar* field, float value0, float value1)
{
    glUseProgram(program);
    GLint uniformId = glGetUniformLocation(program, field);
    if(uniformId != -1)
        glUniform2f(uniformId, value0, value1);
}
void CShader::setVariable3i(const GLchar* field, int value0, int value1, int value2)
{
    glUseProgram(program);
    GLint uniformId = glGetUniformLocation(program, field);
    if(uniformId != -1)
        glUniform3i(uniformId, value0, value1, value2);
}
void CShader::setVariable3f(const GLchar* field, float value0, float value1, float value2)
{
    glUseProgram(program);
    GLint uniformId = glGetUniformLocation(program, field);
    if(uniformId != -1)
        glUniform3f(uniformId, value0, value1, value2);
}
void CShader::setVariable4i(const GLchar* field, int value0, int value1, int value2, int value3)
{
    glUseProgram(program);
    GLint uniformId = glGetUniformLocation(program, field);
    if(uniformId != -1)
        glUniform4i(uniformId, value0, value1, value2, value3);
}
void CShader::setVariable4f(const GLchar* field, float value0, float value1, float value2, float value3)
{
    glUseProgram(program);
    GLint uniformId = glGetUniformLocation(program, field);
    if(uniformId != -1)
        glUniform4f(uniformId, value0, value1, value2, value3);
}
void CShader::setVariable1i(int uniform_field, int value)
{
    glUseProgram(program);
    if(uniform_field > -1)
        glUniform1i(uniform_field, value);
}
void CShader::setVariable1f(int uniform_field, float value)
{
    glUseProgram(program);
    if(uniform_field > -1)
        glUniform1f(uniform_field, value);
}
void CShader::setVariable2i(int uniform_field, int value0, int value1)
{
    glUseProgram(program);
    if(uniform_field > -1)
        glUniform2i(uniform_field, value0, value1);
}
void CShader::setVariable2f(int uniform_field, float value0, float value1)
{
    glUseProgram(program);
    if(uniform_field > -1)
        glUniform2f(uniform_field, value0, value1);
}
void CShader::setVariable3i(int uniform_field, int value0, int value1, int value2)
{
    glUseProgram(program);
    if(uniform_field > -1)
        glUniform3i(uniform_field, value0, value1, value2);
}
void CShader::setVariable3f(int uniform_field, float value0, float value1, float value2)
{
    glUseProgram(program);
    if(uniform_field > -1)
        glUniform3f(uniform_field, value0, value1, value2);
}
void CShader::setVariable4i(int uniform_field, int value0, int value1, int value2, int value3)
{
    glUseProgram(program);
    if(uniform_field > -1)
        glUniform4i(uniform_field, value0, value1, value2, value3);
}
void CShader::setVariable4f(int uniform_field, float value0, float value1, float value2, float value3)
{
    glUseProgram(program);
    if(uniform_field > -1)
        glUniform4f(uniform_field, value0, value1, value2, value3);
}
void CShader::setBackgroundUse()
{
    useBackground = true;
}
