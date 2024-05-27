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
//  CRunStencilMask.h
//  RuntimeIPhone
//
//  Created by Anders Riggelsen on 18/06/15.
//  Copyright (c) 2011 Clickteam. All rights reserved.
//

#import "CRunStencilMask.h"
#import "CFile.h"
#import "CRunApp.h"
#import "CCreateObjectInfo.h"
#import "CValue.h"
#import "CExtension.h"
#import "CRun.h"
#import "CCndExtension.h"
#import "CActExtension.h"
#import "CRunView.h"
#import "CServices.h"
#import "CImageBank.h"
#import "CImage.h"
#import "CFontInfo.h"
#import "CRect.h"
#import "CRCom.h"
#import "CObjectCommon.h"
#import "CRSpr.h"
#import "CShader.h"

@implementation CRunStencilMask

-(int)getNumberOfConditions
{
	return 0;
}

-(BOOL)createRunObject:(CFile*)file withCOB:(CCreateObjectInfo*)cob andVersion:(int)version
{
	[ho setWidth:[file readAShort]];
	[ho setHeight:[file readAShort]];

	stencilMode = [file readAInt];
	numImages = [file readAInt];
	for (int n=0; n<numImages; n++)
		images[n] = [file readAShort];
	[ho loadImageList:images withLength:numImages];
	currentImage = 0;

	shader = NULL;
	if(stencilMode != 2)
	{
		NSString* fragShader = @"varying lowp vec2 texCoordinate;\
		\
		uniform sampler2D texture;\
		uniform lowp int inkEffect;\
		uniform lowp vec4 blendColor;\
		\
		void main()\
		{\
			lowp vec4 color = texture2D(texture, texCoordinate) * blendColor;\
			if(color.a > 0.5)\
				gl_FragColor = color;\
			else discard;\
		}";

		NSString* vertShader = @"attribute vec2 position;\
		uniform sampler2D texture;\
		uniform mat3 projectionMatrix;\
		uniform mat3 transformMatrix;\
		uniform mat3 objectMatrix;\
		uniform mat3 textureMatrix;\
		varying vec2 texCoordinate;\
		void main()\
		{\
			vec3 pos = vec3(position, 1);\
			texCoordinate = (textureMatrix * pos).xy;\
			gl_Position = vec4(projectionMatrix * transformMatrix * objectMatrix * pos, 1);\
		}";

		shader = new CShader(rh->rhApp->renderer);
		shader->loadShader(@"StencilShader", vertShader, fragShader, true, false);
	}

	return YES;
}

-(void)destroyRunObject:(BOOL)bFast
{
	if(shader)
	{
		delete shader;
		shader = NULL;
	}
}

-(void)displayRunObject:(CRenderer *)renderer
{
	switch (stencilMode)
	{
		case 0:		//Mask inside
		case 1:		//Mask outside
		{
			glEnable(GL_STENCIL_TEST);
			glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
			glStencilMask(0xFF);
			glStencilFunc(GL_ALWAYS, 1, 0xFF);
			glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);

			CImage* image = [ho getImage:images[currentImage]];

			//Inject our own shader for the time being
			CShader* defaultShader = renderer->defaultShader;
			renderer->defaultShader = shader;
			renderer->currentShader = shader;
			renderer->forgetShader();
			shader->forgetCachedState();

			renderer->renderImage(image, [ho getX], [ho getY], [ho getWidth], [ho getHeight], 0, 0);

			//Restore the original shader again:
			renderer->defaultShader = defaultShader;
			renderer->currentShader = defaultShader;
			renderer->forgetCachedState();

			glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
			glStencilMask(0x00);
			glStencilFunc(stencilMode == 0 ? GL_EQUAL : GL_NOTEQUAL, 1, 0xFF);
			glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
			break;
		}

		default:
		case 2:		//Clear mask
		{
			glStencilMask(0xFF);
			glClear(GL_STENCIL_BUFFER_BIT);
			glDisable(GL_STENCIL_TEST);
			glStencilMask(0x00);
			break;
		}
	}
}

-(void)action:(int)num withActExtension:(CActExtension *)act
{
	currentImage = clamp([act getParamExpression:rh withNum:0], 0, numImages-1);
}

-(CValue*)expression:(int)num
{
	switch (num)
	{
		case 0:
			return [rh getTempValue:currentImage];
			break;
		case 1:
			return [rh getTempValue:numImages];
			break;
	}
	return [rh getTempValue:0];
}

@end
