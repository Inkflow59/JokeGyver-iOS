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
#import "CRunExtension.h"
#import "CExtension.h"
#import "CRun.h"
#import "CRunApp.h"
#import "CFile.h"
#import "CCreateObjectInfo.h"
#import "CBitmap.h"
#import "CMask.h"
#import "CActExtension.h"
#import "CCndExtension.h"
#import "CFontInfo.h"
#import "CRect.h"
#import "CServices.h"
#import "CImage.h"
#import "CValue.h"
#import "NSExtensions.h"

#import "CRunGet.h"

//TODO: These errorcodes are subject to change (must agree on error codes with Windows version)
#define ERRORCODE_TIMEOUT 1
#define ERRORCODE_HTTPERROR 2
#define ERRORCODE_BAD_CREDENTIALS 3

#define GETFLAG_CPMASK 3

@implementation NSString (util)

- (int) indexOf:(NSString *)text startAt:(int)start{
    [self substringFromIndex:start];
    NSRange range = NSMakeRange(start, self.length - start);
    range = [[self substringFromIndex:start] rangeOfString:text];
    if ( range.length > 0 ) {
        return ((int)range.location + start);
    } else {
        return -1;
    }
}

-(NSString *)substringFrom:(int)from length:(int)leng {
    [self substringFromIndex:from];
    NSRange range = NSMakeRange(from, leng);
    return [self substringWithRange:range];
    
}

- (int)countString:(NSString *)stringToCount {
    int nOccurrence=0;
    NSRange range = NSMakeRange(0, self.length);
    range = [self rangeOfString:stringToCount options:NSCaseInsensitiveSearch range:range locale:nil];
    while (range.location != NSNotFound) {
        nOccurrence++;
        range = NSMakeRange(range.location+range.length, self.length-(range.location+range.length));
        range = [self rangeOfString:stringToCount options:NSCaseInsensitiveSearch range:range locale:nil];
    }
    
    return nOccurrence;
}

@end

@implementation CRunGet


-(int)getNumberOfConditions
{
    return 3;
}

-(BOOL)createRunObject:(CFile*)file withCOB:(CCreateObjectInfo*)cob andVersion:(int)version
{
    flag = [file readAInt];
    getPending = NO;
    usePost = NO;
    postData = [[NSMutableDictionary alloc] init];
    customHeaders = [[NSMutableArray alloc] init];
    conn=nil;
    username = @"";
    password = @"";
    userAgent = @"";
    timeout = 60;
    responseCode = 0;
    received = @"";
    charSet=@"ISO-8559-1";
    active=YES;
    return true;
}

//Connection delegates:
-(void)destroyRunObject:(BOOL)bFast
{
    
    active=NO;
    
    if (session != nil && getPending && task.state != NSURLSessionTaskStateCompleted)
    {
        [session invalidateAndCancel];
        [NSThread sleepForTimeInterval:.1];
    }
    session = nil;
    

    if(receivedData != nil)
        [receivedData release];
    
    receivedData = nil;
    
    if(request != nil)
        [request release];
    
    request = nil;
    
    [received release];
    [postData release];
    [customHeaders release];
}

-(int)handleRunObject
{
    return REFLAG_ONESHOT;
}

-(void)getURL:(NSString*)url
{
    if(getPending)
        return;
    
    NSRange range = [url rangeOfString:@"@"];
    if(range.location == NSNotFound)
    {
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        //Only URL encode whatever comes after the @ sign if it exists (so it doesn't URL encode any usernames and passwords again - since they must be URL-encoded beforehand).
        NSString* postAt = [[url substringFromIndex:range.location+1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        url = [NSString stringWithFormat:@"%@@%@", [url substringToIndex:range.location], postAt];
    }
    
    NSURL* nsURL = [NSURL URLWithString:url];
    
    if(request != nil)
        [request release];
    
    request = [[NSMutableURLRequest alloc] initWithURL:nsURL];
    [request setTimeoutInterval:timeout];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];

    configuration.URLCache = nil;
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    //User agent header
    if([userAgent length] > 0)
        [configuration setHTTPAdditionalHeaders:@{@"User-Agent":userAgent}];
    
    //Custom headers
    for(NSString* header : customHeaders)
    {
        NSRange range = [header rangeOfString:@":" options:NSLiteralSearch];
        if(range.location != NSNotFound)
        {
            NSString* headerName = [header substringToIndex:range.location];
            NSString* headerValue = [header substringFromIndex:range.location+range.length];
            [configuration setHTTPAdditionalHeaders:@{headerName:headerValue}];
        }
    }
    [customHeaders removeAllObjects];
    
    NSData *data=nil;
    
    //If it should prepare the POST string and send it.
    if(usePost)
    {
        NSString* postString =  [NSString string];
        int count = 0;
        for (NSString* key in [postData allKeys])
        {
            NSString* escaped = [NSString stringWithFormat:@"%@", [postData objectForKey:key]];
            if(![escaped containsString:@"%"])
                escaped = [escaped stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

            if(count != 0)
                postString = [NSString stringWithFormat:@"%@&%@=%@", postString, key, escaped];
            else
                postString = [NSString stringWithFormat:@"%@=%@", key, escaped];
            count++;
        }
        
        NSData* rawPostData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString* contentLength = [NSString stringWithFormat:@"%d", (int)[rawPostData length]];
        
        [request setHTTPMethod:@"POST"];
        [configuration setHTTPAdditionalHeaders:@{@"Content-Type":@"application/x-www-form-urlencoded; charset=UTF-8;",
                                                  @"Content-Length":contentLength}];
        
        [postData removeAllObjects];
        
        data = [NSData dataWithData:(NSData*) rawPostData];
    }
    else
    {
        [request setHTTPMethod:@"GET"];
    }
    
    if (session != nil && getPending && task.state != NSURLSessionTaskStateCompleted)
    {
        [session invalidateAndCancel];
        [NSThread sleepForTimeInterval:.1];
    }
    session = nil;

    if (session == nil)
        session = [NSURLSession sessionWithConfiguration:configuration  delegate:self delegateQueue:nil];
    
    
    if(usePost)
    {
        task = [session uploadTaskWithRequest:request fromData:data];
        usePost = NO;
    }
    else
        task = [session dataTaskWithRequest:request];
    
    [task resume];
    getPending = (task != nil);
    
}

-(void)setPOSTdata:(NSString*)data forHeader:(NSString*)header
{
    usePost = YES;
    [postData setValue:data forKey:header];
}

-(NSStringEncoding)ReadEncodings:(NSString*)szCharset
{
    NSStringEncoding uEncoding = NSUTF8StringEncoding;
    if(szCharset != nil) {
        CFStringEncoding aEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)szCharset);
        uEncoding = CFStringConvertEncodingToNSStringEncoding(aEncoding);
        //NSLog(@"%lu",[uEncoding unsignedLongValue]);
    }
    else
        uEncoding = -1;
    return uEncoding;
}

-(NSString*)reverseCharset:(int)uCodePage
{
    NSString* szCharset = @"";
    
    if(uCodePage == 28591)
    {
        szCharset =@"iso-8859-1";       // iso-8859-1 translation
    }
    else if(uCodePage == 28592)
    {
        szCharset = @"iso-8859-2";       // iso-8859-2 translation
    }
    else if(uCodePage == 28593)
    {
        szCharset = @"iso-8859-3";       // iso-8859-3 translation
    }
    else if(uCodePage == 28594)
    {
        szCharset = @"iso-8859-4";       // iso-8859-4 translation
    }
    else if(uCodePage == 28595)
    {
        szCharset = @"iso-8859-5";       // iso-8859-5 translation
    }
    else if(uCodePage == 28596)
    {
        szCharset = @"iso-8859-6";       // iso-8859-6 translation
    }
    else if(uCodePage == 28597)
    {
        szCharset = @"iso-8859-7";       // iso-8859-7 translation
    }
    else if(uCodePage == 28598)
    {
        szCharset = @"iso-8859-8";       // iso-8859-8 translation
    }
    else if(uCodePage == 1251)
    {
        szCharset = @"windows-1251";       // windows-1251 translation
    }
    else if(uCodePage == 1252)
    {
        szCharset = @"windows-1252";       // windows-1252 translation
    }
    else if(uCodePage == 1253)
    {
        szCharset = @"windows-1253";       // windows-1253 translation
    }
    else if(uCodePage == 1254)
    {
        szCharset = @"windows-1254";       // windows-1254 translation
    }
    else if(uCodePage == 1255)
    {
        szCharset = @"windows-1255";       // windows-1255 translation
    }
    else if(uCodePage == 20936)
    {
        szCharset = @"gb2312";       // gbk2312 translation
    }
    else if(uCodePage == 936)
    {
        szCharset = @"gbk";       // gbk translation
    }
    else if(uCodePage == 950)
    {
        szCharset = @"big5";       // big5 translation
    }
    else if(uCodePage == 20866)
    {
        szCharset = @"koi8-r";	// koi8-r translation
    }
    else if(uCodePage == 51932)
    {
        szCharset = @"euc-jp";       // euc-jp translation
    }
    else if(uCodePage == 51949)
    {
        szCharset = @"euc-kr";       // euc-kr translation
    }
    else if(uCodePage == 51936)
    {
        szCharset = @"euc-cn";       // euc-cn translation
    }
    else if(uCodePage == 50222)
    {
        szCharset = @"iso-2022-jp";       // iso-2022-jp translation
    }
    else if(uCodePage == 50225)
    {
        szCharset = @"iso-2022-kr";       // iso-2022-kr translation
    }
    else if(uCodePage == 65001)
    {
        szCharset = @"utf-8";       // UTF-8 translation
    }
    else if(uCodePage == 0)
    {
        szCharset = @"utf-8";       // UTF-8 translation, language neutral
    }
    else {
        szCharset = nil;       // No Page
    }
    return szCharset;
}

#pragma mark - NSURLSession delegate methods

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    if(receivedData != nil)
        [receivedData release];
    
    receivedData = [[NSMutableData alloc] init];
    [receivedData setLength:0];
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    responseCode =(int)[httpResponse statusCode];
    
    NSString* resCharset = [[httpResponse allHeaderFields] valueForKey:@"content-type"];
    
    NSArray *linefull = [resCharset componentsSeparatedByString:@";"];
    if(linefull && [linefull count] > 0 && [linefull[0] containsString:@"charset"]) {
        NSArray *field = [linefull[0] componentsSeparatedByString:@"="];
        charSet=[[[[NSString alloc] initWithString:field[1]] stringByReplacingOccurrencesOfString:@"\"" withString:@""] autorelease];
        charSet=[charSet stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        charsetHeader = [self ReadEncodings:charSet];
    }
    else if(linefull && [linefull count] > 1 && [linefull[1] containsString:@"charset"]) {
        NSArray *field = [linefull[1] componentsSeparatedByString:@"="];
        charSet=[[[[NSString alloc] initWithString:field[1]] stringByReplacingOccurrencesOfString:@"\"" withString:@""] autorelease];
        charSet=[charSet stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        charsetHeader = [self ReadEncodings:charSet];
    }
    else
        charsetHeader = -1;
    
    if (responseCode == 408 && active)
        [ho pushEvent:2 withParam: 0];
    
    completionHandler(NSURLSessionResponseAllow);
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if(receivedData != nil)
        [receivedData appendData:data];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)dataTask didCompleteWithError:(NSError *)error
{
    getPending = NO;
    [received release];
    received = nil;
    
    if(error != nil)
    {
        NSLog(@"%@", error);
        
        if(error.code <= 0  && active ) {
            [ho pushEvent:2 withParam:0];
            responseCode = (int)error.code;
        }
    }
    else
    {
        
        if(receivedData != nil && receivedData.length > 0) {
            switch(flag&GETFLAG_CPMASK) {
                case GETCP_FROMWEBPAGE:
                {
                    //From Content
                    NSString* text = [[NSString alloc]initWithData:receivedData encoding:NSASCIIStringEncoding];
                    int start = [[text lowercaseString]indexOf:@"charset" startAt:0];
                    if(start > 0) {
                        start = [text indexOf:@"=" startAt:start];
                        int end, end1, end2, end3, end4;
                        end1 = [text indexOf:@">" startAt:start];
                        end2 = [text indexOf:@" " startAt:start];
                        end3 = [text indexOf:@";" startAt:start];
                        end4 = [text indexOf:@"/" startAt:start];
                        end = mind(end1, mind(end2, mind(end3, end4)));
                        charSet = [text substringFrom:(start+1) length:(end-start)];
                        charSet=[charSet stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        charSet=[charSet stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                        charsetToUse = [self ReadEncodings:charSet];
                    }
                    else
                        charsetToUse = -1;
                    
                    if(charsetToUse == -1) {
                        charsetToUse = charsetHeader;
                    }
                    [text autorelease];
                    // DEFAULT ENCODING FOR WEBVIEW iOS IS ISOLATIN1
                    if(charsetToUse == -1)
                        charsetToUse = NSISOLatin1StringEncoding;
                    
                    received = [[NSString alloc]initWithData:receivedData encoding:charsetToUse];
                    break;
                }
                case GETCP_FROMAPP:
                {
                    charSet = [self reverseCharset: ho->hoAdRunHeader->rhApp->codePage];
                    charsetToUse = [self ReadEncodings:charSet];
                    received = [[NSString alloc]initWithData:receivedData encoding:charsetToUse];
                    break;
                }
                case GETCP_UTF8:
                    received = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
                    break;
                    
            }
        }
        if(active)
            [ho pushEvent:0 withParam:0];
    }
    
}


-(BOOL)condition:(int)num withCndExtension:(CCndExtension*)cnd
{
    switch(num)
    {
        case 0:	//CID_CNDGETCOMPLETE
            return YES;
        case 1:	//CID_CNDGETPENDING
            return getPending;
        case 2: //CID_CNDGETTIMEOUT
            return YES;
    }
    return NO;
}

-(void)action:(int)num withActExtension:(CActExtension*)act
{
    switch(num)
    {
        case 0:	//AID_ACTGETURL
            [self getURL:[act getParamExpString:rh withNum:0]];
            break;
        case 1:	//AID_ACTPOSTDATA
        {
            usePost = YES;
            NSString* header = [act getParamExpString:rh withNum:0];
            NSString* data = [act getParamExpString:rh withNum:1];
            [self setPOSTdata:data forHeader:header];
            break;
        }
        case 2:	//AID_ACTCUSTOMHEADER
        {
            [customHeaders addObject:[act getParamExpString:rh withNum:0]];
            break;
        }
        case 3:	//AID_ACTUSER
        {
            [username release];
            username = [[act getParamExpString:rh withNum:0] retain];
            break;
        }
        case 4:	//AID_ACTPASSWORD
        {
            [password release];
            password = [[act getParamExpString:rh withNum:0] retain];
            break;
        }
        case 5:	//AID_ACTTIMEOUT
        {
            timeout = [act getParamExpression:rh withNum:0]/1000.0;
            break;
        }
        case 6:	//AID_ACTUSERAGENT
        {
            NSString* string = [act getParamExpString:rh withNum:0];
            if([string isEqualToString:@""])
                string = @"";
            [userAgent release];
            userAgent = [string retain];
            break;
        }
            
    }
}

-(CValue*)expression:(int)num
{
    switch(num)
    {
        case 0:	//EID_EXPGETCONTENT
            if(received != nil)
                return [rh getTempString:received];
            return [rh getTempString:@""];
        case 1:	//EID_EXPURLENCODE
            return [rh getTempString:[[[ho getExpParam] getString] urlEncode]];
        case 2:	//EID_EXPLASTERROR
            return [rh getTempValue:responseCode];
    }
    return [rh getTempString:@""];	//Should never happen
}

-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    if (challenge.previousFailureCount == 0)
    {
        NSURLCredentialPersistence persistence = NSURLCredentialPersistenceForSession;
        NSURLCredential *credential = [NSURLCredential credentialWithUser:username password:password persistence:persistence];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
    else
    {
        // handle the fact that the previous attempt failed
        NSLog(@"%s: challenge.error = %@", __FUNCTION__, challenge.error);
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

@end
