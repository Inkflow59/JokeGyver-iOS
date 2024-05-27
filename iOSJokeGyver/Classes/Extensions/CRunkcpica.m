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
//  CRunkcpica.m
//  RuntimeIPhone
//
//  Created by Anders Riggelsen on 9/13/11.
//  Copyright (c) 2011 Clickteam. All rights reserved.
//

#import "CRunkcpica.h"
#import "CFile.h"
#import "CRunApp.h"
#import "CBitmap.h"
#import "CCreateObjectInfo.h"
#import "CValue.h"
#import "CExtension.h"
#import "CRun.h"
#import "CCndExtension.h"
#import "CRunView.h"
#import "CServices.h"
#import "CImageBank.h"
#import "CImage.h"
#import "CFontInfo.h"
#import "CRect.h"
#import "CRCom.h"
#import "CObjectCommon.h"
#import "CObjInfo.h"
#import "CRSpr.h"
#import "Reachability.h"
#import "MainViewController.h"
#import "CRenderToTexture.h"

#define PICTURE_RESIZE 0x0001
#define PICTURE_HIDEONSTART 0x0002
#define OLD_PICTURE_TRANSP_BLACK 0x0008
#define PICTURE_TRANSP_FIRSTPIXEL 0x0010
#define PICTURE_FLIPPED_HORZ 0x0020
#define PICTURE_FLIPPED_VERT 0x0040
#define PICTURE_RESAMPLE 0x0080
#define WRAPMODE_OFF 0x0100
#define PICTURE_LINKDIR 0x00010000

#define ACT_LOADPICTURE 0
#define ACT_LOADPICTUREREQ 1
#define ACT_SETHOTSPOT 2
#define ACT_SETSIZEPIXELS 3
#define ACT_SETANGLE 4
#define ACT_SETSEMITRANSPRATIO 5
#define ACT_SETHOTSPOT_TOPLEFT 6
#define ACT_SETHOTSPOT_TOPCENTER 7
#define ACT_SETHOTSPOT_TOPRIGHT 8
#define ACT_SETHOTSPOT_CENTERLEFT 9
#define ACT_SETHOTSPOT_CENTER 10
#define ACT_SETHOTSPOT_CENTERRIGHT 11
#define ACT_SETHOTSPOT_BOTTOMLEFT 12
#define ACT_SETHOTSPOT_BOTTOMCENTER    13
#define ACT_SETHOTSPOT_BOTTOMRIGHT 14
#define ACT_FLIPH 15
#define ACT_FLIPV 16
#define ACT_LINKDIR 17
#define ACT_UNLINKDIR 18
#define ACT_LOOKAT 19
#define ACT_SETOFFSETX 20
#define ACT_SETOFFSETY 21
#define ACT_SETRESIZE_FAST 22
#define ACT_SETRESIZE_RESAMPLE 23
#define ACT_SETWRAPMODE_ON 24
#define ACT_SETWRAPMODE_OFF 25
#define ACT_ADDBACKDROP 26
#define ACT_SETAUTORESIZE_ON 27
#define ACT_SETAUTORESIZE_OFF 28
#define ACT_ZOOMPERCENT 29
#define ACT_ZOOMWIDTH 30
#define ACT_ZOOMHEIGHT 31
#define ACT_ZOOMRECT 32

#define CND_PICTURELOADED 0
#define CND_ISFLIPPED_HORZ 1
#define CND_ISFLIPPED_VERT 2
#define CND_ISWRAPMODE_ON 3

#define EXP_GETPICTURENAME 0
#define EXP_GETPICTUREXSIZE 1
#define EXP_GETPICTUREYSIZE 2
#define EXP_GETRESIZEDXSIZE 3
#define EXP_GETRESIZEDYSIZE 4
#define EXP_GETDISPLAYXSIZE 5
#define EXP_GETDISPLAYYSIZE 6
#define EXP_GETHOTSPOTX 7
#define EXP_GETHOTSPOTY 8
#define EXP_GETIANGLE 9
#define EXP_GETSEMITRANSPRATIO 10
#define EXP_GETOFFSETX 11
#define EXP_GETOFFSETY 12
#define EXP_GETZOOMFACTORX 13
#define EXP_GETZOOMFACTORY 14


@interface ImgMask :NSObject
{
@public
    CGPoint topLeft;
    CGPoint topRight;
    CGPoint bottomLeft;
    CGPoint bottomRight;
}
    +(id)alloc;
    -(id)init;
@end
    
@implementation ImgMask
    +(id)alloc
    {
        return [super alloc];
    }
    -(id)init
    {
        topLeft = CGPointMake(0,0);
        topRight = CGPointMake(0,0);
        bottomLeft = CGPointMake(0,0);
        bottomRight = CGPointMake(0,0);
        return [super init];
    }

@end

@implementation CRunkcpica

-(int)getNumberOfConditions
{
    return 4;
}

-(BOOL)createRunObject:(CFile*)file withCOB:(CCreateObjectInfo*)cob andVersion:(int)version
{
    dwEditorWidth = [file readAInt];
    dwEditorHeight = [file readAInt];
    dwScreenWidth = dwEditorWidth;
    dwScreenHeight = dwEditorHeight;
    [ho setWidth:dwEditorWidth];
    [ho setHeight:dwEditorHeight];
    dwImageFlags = [file readAInt];
    first_pixel = ((dwImageFlags & PICTURE_TRANSP_FIRSTPIXEL) != 0);
    color_transp = swapRGB([file readAInt]); //dwTranspColor
    szImageName = [[rh->rhApp getRelativePath:[file readAStringWithSize:260]] retain];
    highQuality = NO;
    aImage = nil;
    iHotSpotX = 0;
    iHotSpotY = 0;
    fAngle = 0;
    nOffsetX = 0;
    nOffsetY = 0;
    flippedH = flippedV = NO;
    mainViewController = ho->hoAdRunHeader->rhApp->mainViewController;
    
    uConnection = nil;
    uData = nil;
#ifdef USE_PHOTO_LIBRARY
    imageSelector = nil;
    popOverController = nil;
#endif
    renderToTexture = nil;
    CObjInfo* oinfo = ho->hoOiList;
    transparent = ((oinfo->oilInkEffect & EFFECTFLAG_TRANSPARENT) != 0);
    isLoaded = NO;
    [self act_LoadPicture:szImageName];
    return YES;
}

-(void)destroyRunObject:(BOOL)bFast
{
    [szImageName release];
    if(uConnection != nil)
    {
        [uConnection cancel];
    }

    if(aImage != nil)
        [aImage release];

#ifdef USE_PHOTO_LIBRARY
    if(imageSelector != nil)
    {
        [mainViewController dismissViewControllerAnimated:NO];
        imageSelector.delegate=nil;
        [imageSelector autorelease];
        imageSelector = nil;
    }
    if(popOverController != nil)
    {
        [popOverController dismissPopoverAnimated:NO];
        popOverController.delegate = nil;
        [popOverController autorelease];
        popOverController = nil;
    }
#endif
    
    if(renderToTexture != nil)
    {
        [renderToTexture release];
    }
}

-(int)handleRunObject
{
    if ((dwImageFlags & PICTURE_LINKDIR) != 0)
    {
        float angle = ([rh getDir:ho] * 360) / 32;
        while (angle < 0)
            angle += 360;
        while (angle >= 360)
            angle -= 360;
        if (fAngle != angle)
        {
            fAngle = angle;
            [self onChange];
        }
        
    }
    return 0;
}

-(CImage*)getImage
{
    return aImage;
}

-(int)getPictureWidth
{
    return dwPictureWidth;
}
-(int)getPictureHeight
{
    return dwPictureHeight;
}

-(void)displayRunObject:(CRenderer *)renderer
{
    if(aImage==nil || [ho getWidth]==0 || [ho getHeight]==0)
        return;

    int width = [ho getWidth];
    int height = [ho getHeight];

    float scaleX = dwScreenWidth / (float)dwPictureWidth;
    float scaleY = dwScreenHeight / (float)dwPictureHeight;

    //Get the offset into range
    [aImage setResampling:((dwImageFlags & PICTURE_RESAMPLE) != 0)];

    BOOL wrap = (dwImageFlags & WRAPMODE_OFF)==0;
    CTexture* imageToDraw = aImage;
    BOOL actualBlending = renderer->usesBlending;
    renderer->useBlending(true);

    if((wrap && (nOffsetX != 0 || nOffsetY != 0 )) || flippedH || flippedV)
    {
        if(renderToTexture == nil)
            renderToTexture = [[CRenderToTexture alloc] initWithWidth:width    andHeight:height andRunApp:rh->rhApp];

        if(wrap)
        {
            if(scaleX != 1.0)
                nOffsetX *= scaleX;
            if(scaleY != 1.0)
                nOffsetY *= scaleY;
            nOffsetX %= dwPictureWidth*2;
            nOffsetY %= dwPictureHeight*2;
        }

        [renderToTexture bindFrameBuffer];
        [renderToTexture clearWithAlphaDontBind:0];
        renderer->renderPattern(aImage, -nOffsetX, -nOffsetY, dwPictureWidth*4, dwPictureHeight*4, 0, 0, flippedH, flippedV, scaleX, scaleY);
        [renderToTexture unbindFrameBuffer];

        imageToDraw = renderToTexture;
    }
    renderer->renderScaledRotatedImage(imageToDraw,
                                       fAngle,
                                       scaleX,
                                       scaleY,
                                       iHotSpotX,
                                       iHotSpotY,
                                       ho->hoX,
                                       ho->hoY,
                                       dwPictureWidth,
                                       dwPictureHeight,
                                       ho->ros->rsEffect,
                                       ho->ros->rsEffectParam);
    renderer->useBlending(actualBlending);
}

-(BOOL)condition:(int)num withCndExtension:(CCndExtension *)cnd
{
    switch (num)
    {
        case CND_PICTURELOADED:
            return isLoaded && (aImage != nil);
        case CND_ISFLIPPED_HORZ:
            return ((dwImageFlags & PICTURE_FLIPPED_HORZ) != 0);
        case CND_ISFLIPPED_VERT:
            return ((dwImageFlags & PICTURE_FLIPPED_VERT) != 0);
        case CND_ISWRAPMODE_ON:
            return ((dwImageFlags & WRAPMODE_OFF) == 0);
    }
    return NO;
}

-(void)action:(int)num withActExtension:(CActExtension *)act
{
    switch (num)
    {
        case ACT_LOADPICTURE:
            [self act_LoadPicture:[act getParamFilename:rh withNum:0]];
            break;
        case ACT_LOADPICTUREREQ:
            [self act_LoadPictureFromSelector];
            break;
        case ACT_SETHOTSPOT:
            [self act_SetHotSpot:[act getParamExpression:rh withNum:0] andY:[act getParamExpression:rh withNum:1]];
            break;
        case ACT_SETSIZEPIXELS:
            [self act_SetSizePixels:[act getParamExpression:rh withNum:0] andHeight:[act getParamExpression:rh withNum:1]];
            break;
        case ACT_SETANGLE:
            [self act_SetAngle:[act getParamExpression:rh withNum:0]];
            break;
        case ACT_SETSEMITRANSPRATIO:
            [self act_SetSemiTranspRatio:[act getParamExpression:rh withNum:0]];
            break;
        case ACT_SETHOTSPOT_TOPLEFT:
            [self act_SetHotSpot_TopLeft];
            break;
        case ACT_SETHOTSPOT_TOPCENTER:
            [self act_SetHotSpot_TopCenter];
            break;
        case ACT_SETHOTSPOT_TOPRIGHT:
            [self act_SetHotSpot_TopRight];
            break;
        case ACT_SETHOTSPOT_CENTERLEFT:
            [self act_SetHotSpot_CenterLeft];
            break;
        case ACT_SETHOTSPOT_CENTER:
            [self act_SetHotSpot_Center];
            break;
        case ACT_SETHOTSPOT_CENTERRIGHT:
            [self act_SetHotSpot_CenterRight];
            break;
        case ACT_SETHOTSPOT_BOTTOMLEFT:
            [self act_SetHotSpot_BottomLeft];
            break;
        case ACT_SETHOTSPOT_BOTTOMCENTER:
            [self act_SetHotSpot_BottomCenter];
            break;
        case ACT_SETHOTSPOT_BOTTOMRIGHT:
            [self act_SetHotSpot_BottomRight];
            break;
        case ACT_FLIPH:
            [self act_FlipH];
            break;
        case ACT_FLIPV:
            [self act_FlipV];
            break;
        case ACT_LINKDIR:
            [self act_LinkDir];
            break;
        case ACT_UNLINKDIR:
            [self act_UnlinkDir];
            break;
        case ACT_LOOKAT:
            [self act_LookAt:[act getParamExpression:rh withNum:0] andY:[act getParamExpression:rh withNum:1]];
            break;
        case ACT_SETOFFSETX:
            [self act_SetOffsetX:[act getParamExpression:rh withNum:0]];
            break;
        case ACT_SETOFFSETY:
            [self act_SetOffsetY:[act getParamExpression:rh withNum:0]];
            break;
        case ACT_SETRESIZE_FAST:
            [self act_SetResizeFast];
            break;
        case ACT_SETRESIZE_RESAMPLE:
            [self act_SetResizeResample];
            break;
        case ACT_SETWRAPMODE_ON:
            [self act_SetWrapMode_On];
            break;
        case ACT_SETWRAPMODE_OFF:
            [self act_SetWrapMode_Off];
            break;
        case ACT_ADDBACKDROP:
            [self act_AddBackdrop:[act getParamExpression:rh withNum:0]
                            destY:[act getParamExpression:rh withNum:1]
                          sourceX:[act getParamExpression:rh withNum:2]
                          sourceY:[act getParamExpression:rh withNum:3]
                            width:[act getParamExpression:rh withNum:4]
                           height:[act getParamExpression:rh withNum:5]
                         obstacle:[act getParamBorder:rh withNum:6]];
            break;
        case ACT_SETAUTORESIZE_ON:
            [self act_AutoResizeOn];
            break;
        case ACT_SETAUTORESIZE_OFF:
            [self act_AutoResizeOff];
            break;
        case ACT_ZOOMPERCENT:
            [self act_ZoomPercent:[act getParamExpression:rh withNum:0]];
            break;
        case ACT_ZOOMWIDTH:
            [self act_ZoomWidth:[act getParamExpression:rh withNum:0]];
            break;
        case ACT_ZOOMHEIGHT:
            [self act_ZoomHeight:[act getParamExpression:rh withNum:0]];
            break;
        case ACT_ZOOMRECT:
            [self act_ZoomRect:[act getParamExpression:rh withNum:0]
                        height:[act getParamExpression:rh withNum:1]
                      zoomMode:[act getParamExpression:rh withNum:2]];
            break;
    }
}

-(CValue*)expression:(int)num
{
    switch (num)
    {
        case EXP_GETPICTURENAME:
            return [rh getTempString:szImageName];
        case EXP_GETPICTUREXSIZE:
            return [rh getTempValue:dwPictureWidth];
        case EXP_GETPICTUREYSIZE:
            return [rh getTempValue:dwPictureHeight];
        case EXP_GETRESIZEDXSIZE:
            return [rh getTempValue:dwScreenWidth];
        case EXP_GETRESIZEDYSIZE:
            return [rh getTempValue:dwScreenHeight];
        case EXP_GETDISPLAYXSIZE:
        {
            return [rh getTempValue:(int)[ho getWidth]];
        }
        case EXP_GETDISPLAYYSIZE:
        {
            return [rh getTempValue:(int)[ho getHeight]];
        }
        case EXP_GETHOTSPOTX:
            return [rh getTempValue:iHotSpotX];
        case EXP_GETHOTSPOTY:
            return [rh getTempValue:iHotSpotY];
        case EXP_GETIANGLE:
            return [rh getTempValue:fAngle];
        case EXP_GETSEMITRANSPRATIO:
        {
            float alpha = 1.0f;
            if ((ho->ros->rsEffect & BOP_RGBAFILTER) != 0)
                alpha =  (float)((ho->ros->rsEffectParam >> 24) & 0xFF) / 255.0f;
            else if ((ho->ros->rsEffect & BOP_MASK ) == BOP_BLEND)
                return [rh getTempValue:(int)((float)(ho->ros->rsEffectParam * 100) / 128)];
            
            return [rh getTempValue:(1-alpha)*255.0f];
        }
        case EXP_GETOFFSETX:
            return [rh getTempValue:nOffsetX];
        case EXP_GETOFFSETY:
            return [rh getTempValue:nOffsetY];
        case EXP_GETZOOMFACTORX:
        {
            if(dwPictureWidth==0)
                return [rh getTempValue:0];
            return [rh getTempValue:((int)dwScreenWidth * 100) / (int)dwPictureWidth];
        }
        case EXP_GETZOOMFACTORY:
        {
            if(dwPictureHeight==0)
                return [rh getTempValue:0];
            return [rh getTempValue:((int)dwScreenHeight * 100) / (int)dwPictureHeight];
        }
    }
    return [rh getTempDouble:0];
}

-(void) updateImgSpot
{
    float xs = iHotSpotX;
    float ys = iHotSpotY;
    
    // Scaling
    if (dwScreenWidth != dwPictureWidth && dwPictureWidth != 0)
        xs = ((xs * dwScreenWidth) / dwPictureWidth);
    if (dwScreenHeight != dwPictureHeight && dwPictureHeight != 0)
        ys = ((ys * dwScreenHeight) / dwPictureHeight);
    
    // Rotation
    if (fAngle != 0) {
        float cosa;
        float sina;
        if (fAngle == 90) {
            cosa = 0.0;
            sina = 1.0;
        }
        else if (fAngle == 270) {
            cosa = 0.0;
            sina = -1.0;
        }
        else {
            cosa = (float) cos(fAngle * M_PI / 180.0f);
            sina = (float) sin(fAngle * M_PI / 180.0f);
        }
        
        // Rotation / center
        int xaxis = dwScreenWidth / 2;
        int yaxis = dwScreenHeight / 2;
        
        int x2 = (int) ((xs - xaxis) * cosa + (ys - yaxis) * sina);
        int y2 = (int) ((ys - yaxis) * cosa - (xs - xaxis) * sina);
        
        // Translation
        xs = x2 + ho->hoImgWidth / 2;
        ys = y2 + ho->hoImgHeight / 2;
    }
    
    ho->hoImgXSpot = floor(xs);
    ho->hoImgYSpot = floor(ys);
}

-(void) setHotSpot:(int)xs andY:(int)ys
{
    if (iHotSpotX != xs || iHotSpotY != ys)
    {
        ho->hoX -= ho->hoImgXSpot;
        ho->hoY -= ho->hoImgYSpot;
        iHotSpotX = xs;
        iHotSpotY = ys;
        [self updateImgSpot];
        ho->hoX += ho->hoImgXSpot;
        ho->hoY += ho->hoImgYSpot;
    }
    
}

-(void) rotateRect:(float)angle
{
    int x, y;
    double cosa, sina;
    
    if (angle == 90.0)
    {
        cosa = 0.0;
        sina = 1.0;
    }
    else if (angle == 180.0)
    {
        cosa = -1.0;
        sina = 0.0;
    }
    else if (angle == 270.0)
    {
        cosa = 0.0;
        sina = -1.0;
    }
    else
    {
        double arad = angle * M_PI / 180.0f;
        cosa = cos(arad);
        sina = sin(arad);
    }
    
    double nhxcos;
    double nhxsin;
    double nhycos;
    double nhysin;
    nhxcos = nhxsin = nhycos = nhysin = 0.0;
    ImgMask *cMask = [[ImgMask alloc] init];
    cMask->topLeft.x = cMask->topLeft.y = 0;
    x = ho->hoImgWidth;
    nhxcos = x * cosa;
    nhxsin = x * sina;
    cMask->topRight.x = (int) floor(nhxcos + nhysin);
    cMask->topRight.y = (int) floor(nhycos - nhxsin);
    
    y = ho->hoImgHeight;
    nhycos = y * cosa;
    nhysin = y * sina;
    cMask->bottomRight.x = (int) floor(nhxcos + nhysin);
    cMask->bottomRight.y = (int) floor(nhycos - nhxsin);
    
    cMask->bottomLeft.x = cMask->topLeft.x + cMask->bottomRight.x - cMask->topRight.x;
    cMask->bottomLeft.y = cMask->topLeft.y + cMask->bottomRight.y - cMask->topRight.y;
    
    int xmin = MIN(cMask->topLeft.x, MIN(cMask->topRight.x, MIN(cMask->bottomRight.x, cMask->bottomLeft.x)));
    int ymin = MIN(cMask->topLeft.y, MIN(cMask->topRight.y, MIN(cMask->bottomRight.y, cMask->bottomLeft.y)));
    int xmax = MAX(cMask->topLeft.x, MAX(cMask->topRight.x, MAX(cMask->bottomRight.x, cMask->bottomLeft.x)));
    int ymax = MAX(cMask->topLeft.y, MAX(cMask->topRight.y, MAX(cMask->bottomRight.y, cMask->bottomLeft.y)));
    
    ho->hoImgWidth = (int)round(xmax - xmin);
    ho->hoImgHeight = (int)round(ymax - ymin);
    [cMask dealloc];
}

-(void) onChange
{
    ho->hoImgWidth = dwScreenWidth;
    ho->hoImgHeight = dwScreenHeight;
    if (fAngle != 0.0 )
        [self rotateRect:fAngle];
    [self updateImgSpot];
    ho->roc->rcScaleX = dwScreenWidth/(float)dwPictureWidth;
    ho->roc->rcScaleY = dwScreenHeight/(float)dwPictureHeight;
    [ho modif];
}

-(UIImage*)loadImageFromString:(NSString*)filename
{
    if([filename isEqualToString:@""])
        return nil;
    
    isLoaded = NO;
    __block UIImage* imageToLoad = nil;
    if([filename hasPrefix:@"http"])
    {
        [szImageName release];
        szImageName = [filename retain];
        
#ifdef __IPHONE_5_0
        if(uConnection != nil)
        {
            [uConnection cancel];
            [uData release];
        }
        
        NSURLRequestCachePolicy cachePolicy = NSURLRequestReloadIgnoringCacheData;
        
        //If there is no internet connection available only ask for cached data
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        if (networkStatus == NotReachable)
            cachePolicy = NSURLRequestReturnCacheDataDontLoad;
        
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:filename] cachePolicy:cachePolicy timeoutInterval:10.0];
        
        uData = [[NSMutableData alloc] initWithCapacity:2048];
        uConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        return nil;    //Do nothing until the request has finished
#else
        NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:filename]];
        imageToLoad = [UIImage imageWithData:imageData];
#endif
    }
    else
    {
        
        [szImageName release];
        szImageName = [[rh->rhApp getRelativePath:filename] retain];
        NSData* imageData = [rh->rhApp loadResourceData:filename];
        if(imageData != nil)
            imageToLoad = [UIImage imageWithData:imageData];
        else if([filename containsString:@"file:///var"])   // Is it a file?
        {
            NSURL* url = [[NSURL alloc] initWithString:filename];
            NSData* data = [[NSData alloc] initWithContentsOfURL:url];
            imageToLoad = [UIImage imageWithData:data];
            NSLog(@"Image orientation %ld", imageToLoad.imageOrientation);
        }
        else
        {
            // Final try, is an asset?
            PHAsset *asset = nil;
            NSURL *asseturl = [NSURL URLWithString:filename];
            PHFetchOptions* fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.sortDescriptors = @[
                [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
            ];
            PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[asseturl] options:fetchOptions];
            
            if (fetchResult != nil && fetchResult.count > 0)
                asset = [fetchResult lastObject];
            
            if (asset) {
                // get photo info from this asset
                PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
                imageRequestOptions.synchronous = NO;
                imageRequestOptions.networkAccessAllowed = YES;
                imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
                imageRequestOptions.version = PHImageRequestOptionsVersionCurrent;
                imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
                if(@available(iOS 13, *))
                {
                    [[PHImageManager defaultManager]
                     requestImageDataForAsset:asset
                     options:imageRequestOptions
                     resultHandler:^(NSData *imageData, NSString *dataUTI,
                                     UIImageOrientation orientation,
                                     NSDictionary *info)
                     {
                        NSLog(@"info = %@", info);
                        if(imageData != nil)
                        {
                            imageToLoad = [UIImage imageWithData:imageData];
                            [imageToLoad retain];
                            [self loadUIImage:imageToLoad];
                        }
                    }];
                }
                else
                {
                    [[PHImageManager defaultManager]
                     requestImageDataForAsset:asset
                     options:imageRequestOptions
                     resultHandler:^(NSData *imageData, NSString *dataUTI,
                                     UIImageOrientation orientation,
                                     NSDictionary *info)
                     {
                        NSLog(@"info = %@", info);
                        if(imageData != nil)
                        {
                            imageToLoad = [UIImage imageWithData:imageData];
                            [imageToLoad retain];
                            [self loadUIImage:imageToLoad];
                        }
                    }];
                }
            }
        }
        
    }
    return imageToLoad;
}

#ifdef __IPHONE_5_0
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [uData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage* imageToLoad = [UIImage imageWithData:uData];
    
    if(imageToLoad == nil)
        return;
    
    [self loadUIImage:imageToLoad];
    [uData release];
    [uConnection autorelease];
    uData = nil;
    uConnection = nil;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Fetching image '%@' failed with error: %@", szImageName, error);
    [uData release];
    [uConnection autorelease];
    uData = nil;
    uConnection = nil;
}
#endif

- (float)fixOrientation:(UIImage *)Image
{
    float angle=0;
    switch (Image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            angle = 180;
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            angle = 90;
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            angle = -90;
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    while(angle < 0)
        angle += 360;
    while(angle >= 360)
        angle -= 360;
    return angle;
}

-(void)loadUIImage:(UIImage*)imageToLoad
{
    if(imageToLoad == nil)
        return;
    
    if(aImage != nil)
        [aImage release];
    BOOL alpha_img = [self hasAlpha:imageToLoad];
    if(!transparent && alpha_img)
        imageToLoad = [self removeTransparency:imageToLoad];
    if(transparent && !alpha_img && !first_pixel)
        imageToLoad = [self removeColor:imageToLoad andColor:color_transp];

    aImage = [CImage loadUIImage:imageToLoad];
    int dwWidth = aImage->width;
    int dwHeight = aImage->height;

    dwPictureWidth = dwWidth;
    dwPictureHeight = dwHeight;
    
    fAngle = [self fixOrientation:imageToLoad];
    isLoaded = YES;

    if ((dwImageFlags & PICTURE_RESIZE) == 0)
    {
        dwEditorWidth = dwWidth;
        dwEditorHeight= dwHeight;
        dwScreenWidth = dwWidth;
        dwScreenHeight = dwHeight;
        [ho setWidth:dwWidth];
        [ho setHeight:dwHeight];
    }
    [self onChange];
}


-(void)act_LoadPicture:(NSString*)filename
{
    UIImage* imageToLoad = [self loadImageFromString:filename];
    if(imageToLoad != nil)
        [self loadUIImage:imageToLoad];
}


-(void)act_LoadPictureFromSelector
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        return;
    isLoaded = NO;
#ifdef USE_PHOTO_LIBRARY
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        // Access has been granted.
        permission_status = YES;
        [self DoImagePicker];
    }
    
    else if (status == PHAuthorizationStatusDenied) {
        // Access has been denied.
        permission_status = NO;
    }
    
    else if (status == PHAuthorizationStatusNotDetermined) {
        
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                // Access has been granted.
                permission_status = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self DoImagePicker];
                });
            }
            
            else {
                // Access has been denied.
                permission_status = NO;
            }
        }];
    }
    
    else if (status == PHAuthorizationStatusRestricted) {
        // Restricted access - normally won't happen.
        permission_status = NO;
    }
#endif
}

#ifdef USE_PHOTO_LIBRARY
-(void)DoImagePicker
{
    [ho pause];

    imageSelector=[[UIImagePickerController alloc] init];
    imageSelector.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imageSelector.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imageSelector.allowsEditing=NO;
    imageSelector.delegate=self;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [mainViewController presentViewController:imageSelector animated:YES];
    }
    else
    {
        popOverController = [[UIPopoverController alloc] initWithContentViewController:imageSelector];
        popOverController.delegate = self;
        UIView* view = (UIView*)rh->rhApp->mainView;
        CGRect viewRect = rh->rhApp->lastInteraction;
        [popOverController presentPopoverFromRect:viewRect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(void)popoverControllerDidDismissPopover:(UIPopoverPresentationController *)popoverController
{
    imageSelector.delegate=nil;
    [imageSelector autorelease];
    imageSelector = nil;
    
    popoverController.delegate = nil;
    [popoverController autorelease];
    popOverController = nil;

    [ho resume];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [mainViewController dismissViewControllerAnimated:YES];
        imageSelector.delegate=nil;
        [imageSelector autorelease];
        imageSelector = nil;
    }
    else
        [popOverController dismissPopoverAnimated:YES];

    [ho resume];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    UIImage* loadedimage = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    NSURL* url = (NSURL*)[info objectForKey:UIImagePickerControllerReferenceURL];

    [szImageName release];
    szImageName = [[NSString alloc] initWithString:[url relativeString]];

    //if(loadedimage.size.width <= 2048 && loadedimage.size.height <= 2048)     // Updating size for iOS 7 ?
    if(loadedimage.size.width <= 3264 && loadedimage.size.height <= 3264)
            [self loadUIImage:loadedimage];
    else
        //[self loadUIImage:[CServices imageWithImage:loadedimage scaledToSize:CGSizeMake(2048, 2048)]];
        [self loadUIImage:[CServices imageWithImage:loadedimage scaledToSize:CGSizeMake(3264, 3264)]];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        imageSelector.delegate=nil;
        [mainViewController dismissViewControllerAnimated:YES];
        [imageSelector autorelease];
        imageSelector = nil;
    }
    else
        [popOverController dismissPopoverAnimated:YES];

    [ho resume];
}
#endif

-(void)act_SetSizePixels:(int)width andHeight:(int)height
{
    dwScreenWidth = MAX(0, width);
    dwScreenHeight = MAX(0, height);
    
    [self onChange];
}

-(void)act_SetHotSpot:(int)x andY:(int)y
{
    [self setHotSpot:x andY:y];
}

-(void)act_SetAngle:(float)angle
{
    while(angle < 0)
        angle += 360;
    while(angle >= 360)
        angle -= 360;
    if(fAngle != angle)
    {
        fAngle = angle;
        ho->roc->rcAngle = angle;
        [self onChange];
    }
}
-(void)act_SetHotSpot_TopLeft
{
    [self setHotSpot:0 andY:0];
}
-(void)act_SetHotSpot_TopCenter
{
    [self setHotSpot:dwPictureWidth/2 andY:0];
}
-(void)act_SetHotSpot_TopRight
{
    [self setHotSpot:dwPictureWidth-1 andY:0];
}
-(void)act_SetHotSpot_CenterLeft
{
    [self setHotSpot:0 andY:dwPictureHeight/2];
}
-(void)act_SetHotSpot_Center
{
    [self setHotSpot:dwPictureWidth/2 andY:dwPictureHeight/2];
}
-(void)act_SetHotSpot_CenterRight
{
    [self setHotSpot:dwPictureWidth-1 andY:dwPictureHeight/2];
}
-(void)act_SetHotSpot_BottomLeft
{
    [self setHotSpot:0 andY:dwPictureHeight-1];
}
-(void)act_SetHotSpot_BottomCenter
{
    [self setHotSpot:dwPictureWidth/2 andY:dwPictureHeight-1];
}
-(void)act_SetHotSpot_BottomRight
{
    [self setHotSpot:dwPictureWidth-1 andY:dwPictureHeight-1];
}
-(void)act_FlipH
{
    flippedH = !flippedH;
}
-(void)act_FlipV
{
    flippedV = !flippedV;
}
-(void)act_LinkDir
{
    dwImageFlags |= PICTURE_LINKDIR;
}
-(void)act_UnlinkDir
{
     dwImageFlags &= ~PICTURE_LINKDIR;
}
-(void)act_LookAt:(int)tgtx andY:(int)tgty
{
    int srcx = ho->hoX - ho->hoImgXSpot + ho->hoImgWidth/2;
    int srcy = ho->hoY - ho->hoImgYSpot + ho->hoImgHeight/2;
    // Calcul de l'angle (entre le centre de l'image et le point destination)
    int angle;
    if ( srcx == tgtx )
    {
        if ( tgty < srcy )
        {
            angle = 90;
        }
        else
        {
            angle = 270;
        }
    }
    else
    {
        angle = (int)( atan2(abs(tgty-srcy),abs(tgtx-srcx)) * 180 / 3.141592653589f);
        // Trouver le bon cadran
        if ( tgtx > srcx )
        {
            if ( tgty > srcy )
            {
                angle = 360 - angle;
            }
        }
        else
        {
            if ( tgty > srcy )
            {
                angle = 180 + angle;
            }
            else
            {
                angle = 180 - angle;
            }
        }
    }
    if (fAngle != angle) {
        fAngle = angle;
        [self onChange];
    }
}

-(void)act_SetOffsetX:(int)offsetX
{
    nOffsetX = offsetX;
}

-(void)act_SetOffsetY:(int)offsetY
{
    nOffsetY = offsetY;
}

-(void)act_SetResizeFast
{
    dwImageFlags &= ~PICTURE_RESAMPLE;
}

-(void)act_SetResizeResample
{
    dwImageFlags |= PICTURE_RESAMPLE;
}

-(void)act_SetWrapMode_On
{
    dwImageFlags &= ~WRAPMODE_OFF;
}

-(void)act_SetWrapMode_Off
{
    dwImageFlags |= WRAPMODE_OFF;
}

-(void)act_AddBackdrop:(int)dX destY:(int)dY sourceX:(int)sX sourceY:(int)sY width:(int)width height:(int)height obstacle:(short)obstacle
{
    //TODO: Add backdrop
    /*
    kcpicaImage pSf = psf;
    if (pSf == null )
    {
        pSf = kcpicaImage.Create(psfOrg, psfOrg.getWidth(), psfOrg.getHeight());
    }
    if ( pSf != null && w > 0 && h > 0 &&
        x < pSf.width && y < pSf.height && x + w > 0 && y + h > 0 )
    {
        RenderingHints hints;
        int hintsInt;
        if (highQuality == YES)
        {
            hints = new RenderingHints(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
            hintsInt = Image.SCALE_SMOOTH;
        }
        else
        {
            hints = new RenderingHints(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_SPEED);
            hintsInt = Image.SCALE_FAST;
        }
        BufferedImage sf = new BufferedImage(w,h,BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = sf.createGraphics();
        g.setRenderingHints(hints);
        g.setBackground(new Color(0,0,0,0));
        g.clearRect(0, 0, w, h);
        pSf.drawToGraphics(g, 0, 0, x, y, w, h, highQuality);
        //pSf->Blit(sf, 0, 0, x, y, w, h, BMODE_OPAQUE, BOP_COPY, 0, BLTF_COPYALPHA);
        Image n = sf.getScaledInstance(w, h, hintsInt);
        ho.addBackdrop(n, xDest, yDest, ho.ros.rsEffect, ho.ros.rsEffectParam, col, ho.hoLayer);
    }
  */
}

-(void)act_AutoResizeOn
{
    dwImageFlags |= PICTURE_RESIZE;
    dwScreenWidth = dwEditorWidth;
    dwScreenHeight = dwEditorHeight;
    [ho setWidth: (int)dwScreenWidth];
    [ho setHeight:(int)dwScreenHeight];
    [self onChange];
}

-(void)act_AutoResizeOff
{
    dwImageFlags &= ~PICTURE_RESIZE;
    if (dwPictureWidth != 0 )
    {
        dwScreenWidth = dwPictureWidth;
        dwScreenHeight = dwPictureHeight;
    }
    else
    {
        dwScreenWidth = dwEditorWidth;
        dwScreenHeight = dwEditorHeight;
    }
    [ho setWidth:(int)dwScreenWidth];
    [ho setHeight:(int)dwScreenHeight];
    [self onChange];
}

-(void)act_ZoomPercent:(int)percent
{
    dwScreenWidth = (int)ceil((double)(dwPictureWidth * percent) / 100.0);
    //dwScreenHeight = (int)ceil((double)(dwPictureHeight * percent) / 100.0);
    dwScreenHeight = (int)((double)dwPictureHeight/dwPictureWidth * dwScreenWidth) ;
    [self onChange];
}

-(void)act_ZoomWidth:(int)width
{
    dwScreenWidth = width;
    if (dwPictureWidth != 0 )
    {
        dwScreenHeight = ((int)dwPictureHeight * dwScreenWidth) / (int)dwPictureWidth;
    }
    [self onChange];
}

-(void)act_ZoomHeight:(int)height
{
    dwScreenHeight = height;
    if (dwPictureHeight != 0 )
    {
        dwScreenWidth = ((int)dwPictureWidth * dwScreenHeight) / (int)dwPictureHeight;
    }
    [self onChange];
}

-(void)act_ZoomRect:(int)width height:(int)height zoomMode:(int)evenIfSmaller
{
    BOOL bResizeEvenIfSmaller = (evenIfSmaller == 1);

    int iw = (int)dwPictureWidth;
    int ih = (int)dwPictureHeight;
    int nw = 0;
    int nh = 0;
    if ( width != 0 && height != 0 )
    {
        if ( bResizeEvenIfSmaller || iw > width || ih > height )
        {
            if ( iw/width > ih/height )
            {
                nw = width;
                if ( iw != 0 )
                {
                    nh = round((ih * width) / iw);
                }
            }
            else
            {
                nh = height;
                if ( ih != 0 )
                {
                    nw = round((iw * height) / ih);
                }
            }
        }
        else
        {
            nw = iw;
            nh = ih;
        }
    }
    dwScreenWidth = nw;
    dwScreenHeight= nh;
    [self onChange];
}

-(void)act_SetSemiTranspRatio:(int)ratio
{
    // Build 283.2: simple copy from CEvent / actSetSemiTransparency
    if((ho->ros->rsEffect & BOP_RGBAFILTER) != 0 && self->transparent)
    {
        ratio = clamp(255-ratio*2.55, 0, 255);
        ho->ros->rsEffect = (ho->ros->rsEffect & BOP_MASK) | BOP_RGBAFILTER;
    
        unsigned int rgbaCoeff = ho->ros->rsEffectParam;
        unsigned int alphaPart = (unsigned int)ratio << 24;
        unsigned int rgbPart = (rgbaCoeff & 0x00FFFFFF);
        ho->ros->rsEffectParam = alphaPart | rgbPart;
    }
    else
    {
        ratio = clamp((int)((float)ratio*128/100), 0, 128);
        ho->ros->rsEffect&=~EFFECT_MASK;
        ho->ros->rsEffect|=BOP_BLEND;   // EFFECT_SEMITRANSP;
        ho->ros->rsEffectParam=(DWORD)ratio;
    }
    [ho modif];
}

/******************************
 *
 *   Utilities
 *
 ******************************/

- (BOOL)hasAlpha : (UIImage*) img
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(img.CGImage);
    return (
            alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast
            );
    
}

- (UIImage*)removeTransparency: (UIImage *) image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw a black background
    CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 1.0f);
    CGContextFillRect(ctx, imageRect);
    
    [image drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:1.0f];
    
    UIImage* result_img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result_img;
}

- (UIImage*)removeColor: (UIImage *) image andColor:(int)color
{
    int red =   CGFloat((color & 0xFF0000) >> 16);
    int green = CGFloat((color & 0x00FF00) >> 8);
    int blue =  CGFloat(color & 0x0000FF);
    const CGFloat colorMasking[6] ={
        static_cast<CGFloat>(red), static_cast<CGFloat>(red),
        static_cast<CGFloat>(green), static_cast<CGFloat>(green),
        static_cast<CGFloat>(blue), static_cast<CGFloat>(blue)
        
    };
    
    CGImageRef rawImageRef=image.CGImage;
    
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iphone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    return result;
}

@end
