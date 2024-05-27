/* Copyright (c) 1996-2019 Clickteam
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "CRunExtension.h"

@class CFile;
@class CCreateObjectInfo;
@class CValue;
@class CCndExtension;

@interface CRunWebView2 : CRunExtension <WKUIDelegate, WKNavigationDelegate>
{
    int oldX;
    int oldY;
    int oldW;
    int oldH;
    WKWebView *wkWebView2;
    WKUserScript *wkUScript;
    WKWebViewConfiguration *wkWebConfig;
    WKUserContentController *wkUController;
    NSString* currentURL;
    
	NSURL* allowedURL;
	NSURL* testedURL;
	NSString* errorString;
	NSInteger errorNumber;
	BOOL allowAllURLS;
    float currentProgress;
    NSTimer *myWebTimer;
    BOOL loaded;
    NSString* mimetype;
    NSString* encoding;
    
    NSURLConnection *mConnection;
    NSMutableData* mdata;
    NSString* urlFile;
    NSString* downfolder;
    NSString* downfile;
    NSInteger download_size;
    float download_progress;
    int nIdentifier;
    int flags;
    BOOL webVisible;
}

-(int)getNumberOfConditions;
-(BOOL)createRunObject:(CFile*)file withCOB:(CCreateObjectInfo*)cob andVersion:(int)version;
-(void)destroyRunObject:(BOOL)bFast;
-(BOOL)condition:(int)num withCndExtension:(CCndExtension *)cnd;
-(void)action:(int)num withActExtension:(CActExtension *)act;
-(CValue*)expression:(int)num;

- (NSString*)executeJSforString:(NSString *)jsString;
- (int)executeJSforInteger:(NSString *)jsString;
- (double)executeJSforDouble:(NSString *)jsString;
@end


