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
// Updated 09/27/2019 FVD

#import "CRunWebView2.h"

#import "CFile.h"
#import "CRunApp.h"
#import "CCCA.h"
#import "CCreateObjectInfo.h"
#import "CValue.h"
#import "CExtension.h"
#import "CRun.h"
#import "CCndExtension.h"
#import "CRunView.h"
#import "CServices.h"
#import "CImage.h"
#import "CRect.h"
#import "CRunView.h"
#import "CActExtension.h"
#import "CObjectCommon.h"


#define CND_ONLOADCOMPLETE	0
#define CND_ONSTATUSCHANGE	1
#define CND_STARTEDLOADING	2
#define CND_ONNAVIGATE		3
#define CND_ONWEBCLICK		4
#define CND_ONERROR			5
#define CND_ONPROGRESS		6
#define CND_LAST			7

#define ACT_LOADURL				0
#define ACT_BLOCKHTML			1
#define ACT_GOFORWARDWEB		2
#define ACT_GOBACKWEB			3
#define ACT_STOPWEB				4
#define ACT_REFRESHWEB			5
#define ACT_EXECUTESNIPPET		6
#define ACT_PUSHARGUMENT		7
#define ACT_CALLSCRIPTFUNCTION	8
#define ACT_HIDEWINDOW			9
#define ACT_SHOWWINDOW			10
#define ACT_XPOSITION			11
#define ACT_YPOSITION			12
#define ACT_WSIZE				13
#define ACT_HSIZE				14
#define ACT_RESIZETOFIT			15
#define ACT_INLINEHTML5			16
#define ACT_LOADDOCDOCUMENT		17
#define ACT_SCROLLWEBTOP		18
#define ACT_SCROLLWEBEND		19
#define ACT_SCROLLWEBXY			20
#define ACT_SETZOOMWEB			21
#define ACT_GRABWEBIMAGE		22
#define ACT_INSERTHTML			23
#define ACT_NAVMODE				24
#define ACT_SETUSERAGENT		25
#define ACT_DOURLTOFILE			26

#define EXP_GETERRORVAL				0
#define EXP_GETSTATUSSTR			1
#define EXP_GETCURRENTURL			2
#define EXP_GETNAVIGATEURL			3
#define EXP_GETCLICKEDLINK			4
#define EXP_GETHTMLSOURCE			5
#define EXP_GETEXECUTESNIPPET		6
#define EXP_GETCALLFUNCTIONINT		7
#define EXP_GETCALLFUNCTIONFLOAT	8
#define EXP_GETCALLFUNCTIONSTR		9
#define EXP_GETWEBPAGEWIDTH			10
#define EXP_GETWEBPAGEHEIGHT		11
#define EXP_GETWEBPAGEZOOM			12
#define EXP_GETFORMITEM				13
#define EXP_GETHTMLTAGID			14
#define EXP_GETDOMRETSTR			15
#define EXP_GETDOMCLSSTR			16
#define EXP_GETWEBPROGRESS			17
#define EXP_GETUSERAGENT			18
#define EXP_GETPOSX                 19
#define EXP_GETPOSY                 20
#define EXP_GETWIDTH                21
#define EXP_GETHEIGHT               22

#define VISIBLE_AT_START        0x0008


@implementation CRunWebView2

- (void)resetProgress {
    currentProgress = 0.0f;
    loaded = NO;
}

- (void)resetForNewPage {
    // Reset progress
    [self resetProgress];
}

-(void)timerCallback {
    if (loaded) {
        if (currentProgress >= 1) {
            if(myWebTimer != nil)
                [myWebTimer invalidate];
            myWebTimer = nil;
        }
        else {
            currentProgress += 0.1;
            @synchronized(ho)
            {
                [ho pushEvent:CND_ONPROGRESS withParam:0];
            }
        }
    }
    else {
        currentProgress += 0.05;
        if(ho != nil && ho->hoIdentifier == nIdentifier)
        {
            @synchronized(ho)
            {
                [ho pushEvent:CND_ONPROGRESS withParam:0];
            }
        }
        if (currentProgress >= 0.95) {
            currentProgress = 0.95;
        }
    }
}

-(int)getNumberOfConditions
{
	return CND_LAST;
}

-(BOOL)createRunObject:(CFile*)file withCOB:(CCreateObjectInfo*)cob andVersion:(int)version
{
	int width =[file readAShort];
	int height=[file readAShort];
    flags = [file readAInt];
    webVisible = (flags & VISIBLE_AT_START) != 0;
    
    [ho setWidth:width];
    [ho setHeight:height];
    
	CGRect frame = CGRectMake(ho->hoX - rh->rhWindowX, ho->hoY - rh->rhWindowY, ho->hoImgWidth, ho->hoImgHeight);
    
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'initial-scale=1.0'); document.getElementsByTagName('head')[0].appendChild(meta);";

    wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    wkWebConfig.preferences.javaScriptEnabled = true;
    wkWebView2 = [[WKWebView alloc] initWithFrame:frame configuration:wkWebConfig];
    wkWebView2.translatesAutoresizingMaskIntoConstraints = NO;

    wkWebView2.tag = 19991;
	[rh->rhApp positionUIElement:wkWebView2 withObject:ho];
    wkWebView2.UIDelegate = self;
	wkWebView2.navigationDelegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
    wkWebView2.allowsBackForwardNavigationGestures = YES;
	[ho->hoAdRunHeader->rhApp->runView addSubview:wkWebView2];
    if(!webVisible)
        [wkWebView2 setHidden:YES];
    else
        [wkWebView2 setHidden:NO];
    
    nIdentifier = ho->hoIdentifier;
	allowedURL = nil;
	errorString = @"";
	errorNumber = 0;
	allowAllURLS = YES;
    mimetype = @"text/HTML; charset=UTF-8;ISO-8558-1;ANSI";
    [self resetProgress];
	return YES;
}

- (void)webView:(WKWebView *)wkWebView2 didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self resetProgress];
    //0.03333 is roughly 1/30, so it will update at 30 FPS
    myWebTimer = [NSTimer scheduledTimerWithTimeInterval:0.03333 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
    [ho pushEvent:CND_STARTEDLOADING withParam:0];
}

- (void)webView:(WKWebView *)wkWebView2 didFinishNavigation:(WKNavigation *)navigation {
        currentProgress = 1;
        loaded = YES;
        [ho pushEvent:CND_ONPROGRESS withParam:0];
        [ho pushEvent:CND_ONLOADCOMPLETE withParam:0];
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        wkWebView2.scrollView.maximumZoomScale = 4.0f; // set max to 400
        wkWebView2.scrollView.minimumZoomScale = 0.25f; // set min a original zoom.
    #endif
}


- (void)webView:(WKWebView *)wkWebView2 didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    errorString = [[error localizedDescription] retain];
    errorNumber = error.code;
    [ho pushEvent:CND_ONERROR withParam:0];
}

- (void)webView:(WKWebView *)wkWebView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    [currentURL release];
    currentURL = [[NSString alloc] initWithString:[navigationAction.request.URL absoluteString]];
    
    if(navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        [ho pushEvent:CND_ONWEBCLICK withParam:0];
        if(allowAllURLS)
            [ho pushEvent:CND_ONNAVIGATE withParam:0];
    }
    if(navigationAction.navigationType == WKNavigationTypeFormSubmitted
       || navigationAction.navigationType == WKNavigationTypeFormResubmitted)
    {
        [ho pushEvent:CND_ONWEBCLICK withParam:0];
    }
    if(navigationAction.navigationType == WKNavigationTypeBackForward)
        [ho pushEvent:CND_ONNAVIGATE withParam:0];
    
    if(allowAllURLS) {
        if(navigationAction.navigationType == WKNavigationTypeReload)
            [ho pushEvent:CND_STARTEDLOADING withParam:0];
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    if(allowedURL == nil)
    {
        testedURL = [navigationAction.request.URL retain];
        [ho pushEvent:CND_STARTEDLOADING withParam:0];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    else
    {
        if([navigationAction.request.URL isEqual:allowedURL])
        {
            [allowedURL release];
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }
        else
        {
            [testedURL release];
            testedURL = [navigationAction.request.URL retain];
            [self resetForNewPage];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
}

- (void)webView:(WKWebView *)wkWebView2 decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    
    [rh->rhApp->mainViewController presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    
    [rh->rhApp->mainViewController presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *result))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:prompt
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = prompt;
        textField.secureTextEntry = NO;
        textField.text = defaultText;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler([alert.textFields.firstObject text]);
    }]];
    
    [rh->rhApp->mainViewController presentViewController:alert animated:YES completion:nil];
}

-(int)handleRunObject
{
    if(wkWebView2 != nil && rh->rhApp->subApp != nil)
    {
        if(rh->rhApp->subApp->bVisible)
            [wkWebView2 setHidden:NO];
        else
            [wkWebView2 setHidden:YES];
    }
    if(webVisible)
        [rh->rhApp positionUIElement:wkWebView2 withObject:ho];
    return 0;
}

-(void)destroyRunObject:(BOOL)bFast
{
    nIdentifier = -123401234;   //impossible identifier
    [wkWebView2 stopLoading];
    wkWebView2.navigationDelegate=nil;
    
	[[ho->hoAdRunHeader->rhApp->runView viewWithTag:19991] removeFromSuperview];
    [wkWebView2 release];
    wkWebView2 = nil;
    
    [myWebTimer invalidate];
    myWebTimer = nil;
    
	if(testedURL != nil)
		[testedURL release];
	if(allowedURL != nil)
		[allowedURL release];
	if(errorString != nil)
		[errorString release];
    if(currentURL != nil)
        [currentURL release];

    //Clean cache
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];
}


// Conditions
// --------------------------------------------------
-(BOOL)condition:(int)num withCndExtension:(CCndExtension*)cnd
{
	switch (num)
	{
		case CND_ONLOADCOMPLETE:
		case CND_ONSTATUSCHANGE:
		case CND_STARTEDLOADING:
		case CND_ONNAVIGATE:
		case CND_ONWEBCLICK:
		case CND_ONERROR:
		case CND_ONPROGRESS:
			return true;
			break;
	}        
	return NO;
}


// Actions
// -------------------------------------------------
-(void)action:(int)num withActExtension:(CActExtension*)act
{
	switch (num)
	{        
		case ACT_LOADURL:
		{
			[wkWebView2 stopLoading];

			NSURL* url = [NSURL URLWithString:[act getParamExpString:rh withNum:0]];
			NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:30];
			[wkWebView2 loadRequest:request];
			break;
		}
		case ACT_BLOCKHTML:
		{
            NSString* block = [act getParamExpString:rh withNum:0];
            [wkWebView2 loadHTMLString:block baseURL:[NSURL URLWithString:@"about:blank"]];
            break;
		}
		case ACT_GOFORWARDWEB:
		{
			[wkWebView2 goForward];
			break;
		}
		case ACT_GOBACKWEB:
		{
			[wkWebView2 goBack];
			break;
		}
		case ACT_STOPWEB:
		{
			[wkWebView2 stopLoading];
			break;
		}
		case ACT_REFRESHWEB:
		{
			[wkWebView2 reload];
			break;
		}
		case ACT_EXECUTESNIPPET:
		{
			NSString* function = [act getParamExpString:rh withNum:0];
			NSString* arguments = [act getParamExpString:rh withNum:1];

            NSString* jsString = @"";
            
            if(arguments.length == 0)
                jsString = [[NSString alloc] initWithFormat:@"%@", function];
            else
                jsString = [[NSString alloc] initWithFormat:@"%@(%@);", function, arguments];
            
            if([jsString length] > 0)
            {
                [wkWebView2 evaluateJavaScript:jsString completionHandler:nil];
            }
			break;
		}
		case ACT_HIDEWINDOW:
		{
			wkWebView2.hidden = YES;
            webVisible = NO;
			break;
		}
		case ACT_SHOWWINDOW:
		{
			wkWebView2.hidden = NO;
            webVisible = YES;
			break;
		}
		case ACT_XPOSITION:
		{
			[ho setX:[act getParamExpression:rh withNum:0]];
			break;
		}
		case ACT_YPOSITION:
		{
			[ho setY:[act getParamExpression:rh withNum:0]];
			break;
		}
		case ACT_WSIZE:
		{
			[ho setWidth:[act getParamExpression:rh withNum:0]];
            [ho->hoAdRunHeader->rhApp->runView invalidateIntrinsicContentSize];
			break;
		}
		case ACT_HSIZE:
		{
			[ho setHeight:[act getParamExpression:rh withNum:0]];
            [ho->hoAdRunHeader->rhApp->runView invalidateIntrinsicContentSize];
            break;
		}
		case ACT_RESIZETOFIT:
        {
            int param0 = [act getParamExpression:rh withNum:0];
            NSString *javascript = @"";
            if(param0 > 0)
            {
                javascript = @"var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);";
            }
            else
            {
                javascript = @"var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);";
            }
            [wkWebView2 evaluateJavaScript:javascript completionHandler:nil];
            break;
        }
		case ACT_INLINEHTML5:
		{
            int param0 = [act getParamExpression:rh withNum:0];
            if(param0 >0) {
                wkWebConfig.allowsAirPlayForMediaPlayback=YES;
                wkWebConfig.mediaTypesRequiringUserActionForPlayback=NO;
            }
            else {
                wkWebConfig.allowsAirPlayForMediaPlayback=NO;
                wkWebConfig.mediaTypesRequiringUserActionForPlayback=YES;
            }
			break;
		}
		case ACT_LOADDOCDOCUMENT:
		{
			NSData* doc = [rh->rhApp loadResourceData:[[ho getExpParam] getString]];
            if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_9_0)
            {
                [wkWebView2 loadData:doc MIMEType:@"text/html" characterEncodingName:@"HTML" baseURL:[NSURL URLWithString:@"about:empty"]];
            }
            else
            {
                NSString* s = [[NSString alloc] initWithData:doc encoding:NSUTF8StringEncoding];
                [wkWebView2 loadHTMLString:s baseURL:[NSURL URLWithString:@"about:empty"]];
            }
			break;
		}
		case ACT_SCROLLWEBTOP:
		{
			[wkWebView2.scrollView setContentOffset:CGPointZero animated:YES];
			break;
		}
		case ACT_SCROLLWEBEND:
		{
			CGSize fittingSize = wkWebView2.scrollView.contentSize;	//TODO: Find proper offset for scrolling to the bottom
			[wkWebView2.scrollView setContentOffset:CGPointMake(0, fittingSize.height+1000) animated:YES];
			break;
		}
		case ACT_SCROLLWEBXY:
		{
			CGPoint point = CGPointMake([act getParamExpression:rh withNum:0], [act getParamExpression:rh withNum:1]);
			[wkWebView2.scrollView setContentOffset:point animated:YES];
			break;
		}
		case ACT_SETZOOMWEB:
		{
            float zoom = [act getParamExpDouble:rh withNum:0]*100.0f;
			[wkWebView2.scrollView setZoomScale:zoom/100.0];
 			break;
		}
		case ACT_GRABWEBIMAGE:
		{
			UIGraphicsBeginImageContextWithOptions(CGSizeMake(ho->hoImgWidth, ho->hoImgHeight), NO, [UIScreen mainScreen].scale);
			[wkWebView2.layer renderInContext:UIGraphicsGetCurrentContext()];
			UIImage* screenImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();

			NSString* path = [rh->rhApp getPathForWriting:[act getParamExpString:rh withNum:0]];
			NSData* data = nil;
			if([path hasSuffix:@".jpg"])
				data = UIImageJPEGRepresentation(screenImage, 0.8);
			else
				data = UIImagePNGRepresentation(screenImage);
			[data writeToFile:path atomically:NO];
			break;
		}
		case ACT_INSERTHTML:
		{
            int param0 = [act getParamExpression:rh withNum:0];
            int param1 = [act getParamExpression:rh withNum:1];
            NSString* param2 = [act getParamExpString:rh withNum:2];
            NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"document.elements[%d].insertAdjacentHTML(%d, %@);", param0, param1, param2]];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:30];
            [wkWebView2 loadRequest:request];
            break;
		}
		case ACT_NAVMODE:
		{
			int mode = [act getParamExpression:rh withNum:0];
			allowAllURLS = (mode == 0);
			break;
		}
		case ACT_SETUSERAGENT:
		{
			NSString* userAgent = [act getParamExpString:rh withNum:0];
			NSDictionary* dictionary = [NSDictionary dictionaryWithObject:userAgent forKey:@"UserAgent"];
			[[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
			break;
		}
		case ACT_DOURLTOFILE:
		{
            urlFile = [act getParamExpString:rh withNum:0];
            downfolder = [act getParamExpString:rh withNum:1];
            downfile = [act getParamExpString:rh withNum:2];
            NSURL  *urlToDownload = [NSURL URLWithString:urlFile];
            NSURLRequest *request = [NSURLRequest requestWithURL:urlToDownload cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
            mConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO ];
            [mConnection start];
			break;
		}
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////
//
//             connection method
//
////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    download_size =0;
    download_progress =0;
    currentProgress = download_progress;
    mdata = [[NSMutableData alloc]initWithCapacity:0];
     if ([response statusCode] == 200) {
        download_size = [response expectedContentLength];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == mConnection) {
        [mdata appendData:data];
        download_progress = MIN(((float) [mdata length] / (float) download_size),1);
        currentProgress = download_progress;
        [ho pushEvent:CND_ONPROGRESS withParam:0];
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == mConnection) {
        NSString  *filePath = nil;
        if([downfolder length] == 0)
        {
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* path = [paths objectAtIndex:0];
            filePath = [NSString stringWithFormat:@"%@/%@", path,downfile];
        }
        else
        {
            filePath = [NSString stringWithFormat:@"%@/%@", downfolder,downfile];
        }
        if(filePath != nil) {
            [mdata writeToFile:filePath atomically:YES];
            [mdata release];
            mdata = nil;
            mConnection = nil;
            [ho pushEvent:CND_ONLOADCOMPLETE withParam:0];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Something went wrong ...
    if (connection == mConnection) {
        [mConnection release];
        [mdata release];
        [ho pushEvent:CND_ONERROR withParam:0];
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////

-(CValue*)expression:(int)num
{
	switch (num)
	{
		case EXP_GETERRORVAL:
			return [rh getTempValue:(int)errorNumber];
		case EXP_GETSTATUSSTR:
        {
            NSString* htmlSource = @"";
            NSString* jsString = @"window.status";
            htmlSource = [self executeJSforString:jsString];
            if(htmlSource != nil)
                return [rh getTempString:htmlSource];
            return [rh getTempString:@""];
        }
		case EXP_GETCURRENTURL:
		{
			NSString* windowLocation = @"";

			if(wkWebView2 != nil && wkWebView2.URL != nil)
				windowLocation = wkWebView2.URL.absoluteString;

			if([windowLocation isEqualToString:@""])
            {
                NSString* jsString = @"Window.location";
                NSString*wLocation = [self executeJSforString:jsString];
                if(wLocation != nil)
                    return [rh getTempString:wLocation];
            }
			return [rh getTempString:windowLocation];
		}
		case EXP_GETNAVIGATEURL:
        {
            if(currentURL != nil)
                return [rh getTempString:currentURL];
            return [rh getTempString:@""];
        }
		case EXP_GETCLICKEDLINK:
            if(testedURL != nil)
                return [rh getTempString:[testedURL absoluteString]];
            return [rh getTempString:@""];
        case EXP_GETHTMLSOURCE:
        {
            NSString* htmlSource = @"";
            NSString* jsString = @"document.documentElement.outerHTML";
            htmlSource = [self executeJSforString:jsString];
            if(htmlSource != nil)
                return [rh getTempString:htmlSource];
            return [rh getTempString:@""];
        }
		case EXP_GETEXECUTESNIPPET:
        {
            NSString* htmlSnippet = nil;
            NSString* jsString = [[NSString alloc] initWithFormat:@"%@", [[ho getExpParam] getString]];
            if(jsString != nil && [jsString length] > 0)
            {
                htmlSnippet = [self executeJSforString:jsString];
                if(htmlSnippet != nil)
                    return [rh getTempString:htmlSnippet];
            }
            return [rh getTempString:@""];
        }
        case EXP_GETCALLFUNCTIONINT:
        {
            NSString* function = [[ho getExpParam] getString];
            NSString* args = [[ho getExpParam] getString];
            NSString* jsString = @"";
            int htmlInteger = 0;
            
            if([args isEqualToString:@""])
                jsString = [[NSString alloc] initWithFormat:@"%@", function];
            else
                jsString = [[NSString alloc] initWithFormat:@"%@(%@);", function, args];
            
            if([jsString length] > 0)
                htmlInteger = [self executeJSforInteger:jsString];
 
            return [rh getTempValue:htmlInteger];
        }
		case EXP_GETCALLFUNCTIONFLOAT:
        {
            NSString* function = [[ho getExpParam] getString];
            NSString* args = [[ho getExpParam] getString];
            NSString* jsString = @"";
            double htmlDouble = 0.0;
            
            if([args isEqualToString:@""])
                jsString = [[NSString alloc] initWithFormat:@"%@", function];
            else
                jsString = [[NSString alloc] initWithFormat:@"%@(%@);", function, args];
            
            if([jsString length] > 0)
                htmlDouble = [self executeJSforDouble:jsString];

            return [rh getTempValue:htmlDouble];
        }
		case EXP_GETCALLFUNCTIONSTR:
        {
            NSString* function = [[ho getExpParam] getString];
            NSString* args = [[ho getExpParam] getString];
            NSString* jsString = nil;
            NSString* htmlString = nil;
            
            if([args isEqualToString:@""])
                jsString = [[NSString alloc] initWithFormat:@"%@", function];
            else
                jsString = [[NSString alloc] initWithFormat:@"%@(%@);", function, args];
            
            if(jsString != nil && [jsString length] > 0)
            {
                htmlString = [self executeJSforString:jsString];
                if(htmlString != nil)
                    return [rh getTempString:htmlString];
            }
            return [rh getTempString:@""];
        }
		case EXP_GETWEBPAGEWIDTH:
			return [rh getTempValue:wkWebView2.scrollView.contentSize.width];
		case EXP_GETWEBPAGEHEIGHT:
			return [rh getTempValue:wkWebView2.scrollView.contentSize.height];
		case EXP_GETWEBPAGEZOOM:
			return [rh getTempDouble:wkWebView2.scrollView.zoomScale];
        case EXP_GETFORMITEM:
        {
            NSString* item = [[ho getExpParam] getString];
            NSString* htmlString = nil;
            
            NSString* jsString = [[NSString alloc] initWithFormat:@"document.getElementsByName('%@')[0].value;", item];
            
            if(jsString != nil && [jsString length] > 0)
             {
                 htmlString = [self executeJSforString:jsString];
                 if(htmlString != nil)
                     return [rh getTempString:htmlString];
             }
             return [rh getTempString:@""];
        }
        case EXP_GETHTMLTAGID:
        {
            NSString* param0 = [[ho getExpParam] getString];
            int htmlInt = -1;
            
            NSString* jsString = [[NSString alloc] initWithFormat:@"Array.from(document.all).indexOf(document.getElementsByTagName(\"%@\")[0]);", param0];
            
            if(jsString != nil && [jsString length] > 0)
            {
                htmlInt = [self executeJSforInteger:jsString];
                //NSLog(@"executed: %@  return value: %d", jsString, htmlInt);
                if(htmlInt >= 0)
                    htmlInt +=1;
            }
            return [rh getTempValue:htmlInt];
        }
        case EXP_GETDOMRETSTR:
        {
            NSString* param0 = [[ho getExpParam] getString];
            NSString* param1 = [[ho getExpParam] getString];
            int param2 = MAX(0, [[ho getExpParam] getInt]);
            
            NSString* htmlString = nil;
            
            if([param0 length] > 0 && [param1 length] > 0)
            {
                NSString *jsString = [[NSString alloc] initWithFormat:@"function getInfoID() { \n"
                                      "    var inputs = document.getElementsByTagName(\"%@\");      \n"
                                      "    var count = 0; \n"
                                      "    for (var i=0; i < inputs.length; i++) { \n"
                                      "        if (inputs[i].getAttribute(\"id\") == \"%@\") { \n"
                                      "            if(count == %d) \n"
                                      "                return inputs[i].textContent; \n"
                                      "            count ++;\n        }\n    }\n    return \"\";\n}\ngetInfoID();" ,param1, param0,param2];
                
                if(jsString != nil && [jsString length] > 0)
                {
                    htmlString = [self executeJSforString:jsString];
                    if(htmlString != nil)
                        return [rh getTempString:htmlString];
                }
            }
            return [rh getTempString:@""];
        }
        case EXP_GETDOMCLSSTR:
        {
            NSString* param0 = [[ho getExpParam] getString];
            NSString* param1 = [[ho getExpParam] getString];
            int param2 = MAX(0, [[ho getExpParam] getInt]);
            
            NSString* htmlString = nil;
            
            if([param0 length] > 0 && [param1 length] > 0)
            {
                NSString *jsString = [[NSString alloc] initWithFormat:@"function getInfoClass() { \n"
                                      "    var inputs = document.getElementsByTagName(\"%@\");      \n"
                                      "    var count = 0; \n"
                                      "    for (var i=0; i < inputs.length; i++) { \n"
                                      "        if (inputs[i].getAttribute(\"class\") == \"%@\") { \n"
                                      "            if(count == %d) \n"
                                      "                return inputs[i].textContent; \n"
                                      "            count ++;\n        }\n    }\n    return \"\";\n}\ngetInfoClass();" ,param1, param0,param2];
                
                if(jsString != nil && [jsString length] > 0)
                {
                    htmlString = [self executeJSforString:jsString];
                    if(htmlString != nil)
                        return [rh getTempString:htmlString];
                }
            }
            return [rh getTempString:@""];
        }
		case EXP_GETWEBPROGRESS:
			return [rh getTempDouble:currentProgress*100];
			break;

		case EXP_GETUSERAGENT:
			return [rh getTempString:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserAgent"]];
        case EXP_GETPOSX:
            return [rh getTempValue:ho->hoX];
        case EXP_GETPOSY:
            return [rh getTempValue:ho->hoY];
        case EXP_GETWIDTH:
            return [rh getTempValue:ho->hoImgWidth];
        case EXP_GETHEIGHT:
            return [rh getTempValue:ho->hoImgHeight];
	}
	return [rh getTempString:@""];
}

- (NSString*)executeJSforString:(NSString *)jsString  {
    __block id resultString = nil;
    __block BOOL finished = NO;
    [wkWebView2 evaluateJavaScript:jsString completionHandler:^(id result, NSError *error) {
        if (error == nil)
        {
            if (result != nil)
            {
                resultString = [[NSString alloc] initWithString:(NSString*)result];
            }
        }
        else
        {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];

    while(!finished){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return resultString;
}

- (int)executeJSforInteger:(NSString *)jsString  {
    __block int resultValue = 0;
    __block BOOL finished = NO;
    [wkWebView2 evaluateJavaScript:jsString completionHandler:^(id result, NSError *error) {
        if (error == nil)
        {
            if (result != nil)
            {
                resultValue = [result intValue];
            }
        }
        else
        {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];

    while(!finished){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return resultValue;
}

- (double)executeJSforDouble:(NSString *)jsString  {
    __block double resultValue = 0;
    __block BOOL finished = NO;
    [wkWebView2 evaluateJavaScript:jsString completionHandler:^(id result, NSError *error) {
        if (error == nil)
        {
            if (result != nil)
            {
                resultValue = [result doubleValue];
            }
        }
        else
        {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];

    while(!finished){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return resultValue;
}

@end

