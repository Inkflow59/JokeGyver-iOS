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
// CRUNGET: Get object
//
//----------------------------------------------------------------------------------
#import <Foundation/Foundation.h>

@class CCreateObjectInfo;
@class CActExtension;
@class CCndExtension;
@class CFile;
@class CValue;

@interface NSString (util)

-(int) indexOf:(NSString *)text startAt:(int)start;
-(NSString *)substringFrom:(int)from length:(int)leng;

@end

@interface CRunGet : CRunExtension <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
{
    BOOL getPending;
    BOOL usePost;
    BOOL active;
    NSMutableDictionary* postData;
    NSMutableData* receivedData;
    NSURLConnection* conn;
    NSMutableArray* customHeaders;
    NSMutableURLRequest* request;
    NSURLSession* session;
    NSURLSessionDataTask* task;
    NSString* username;
    NSString* password;
    NSString* userAgent;
    NSString* received;
    double timeout;
    int responseCode;
    int flag;
    NSStringEncoding charsetHeader;
    NSStringEncoding charsetToUse;
    NSString* charSet;
}
-(int)getNumberOfConditions;
-(BOOL)createRunObject:(CFile*)file withCOB:(CCreateObjectInfo*)cob andVersion:(int)version;
-(int)handleRunObject;
-(void)destroyRunObject:(BOOL)bFast;

//Connection delegates:
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler;
-(void)URLSession:(NSURLSession *)session dataTask:task didReceiveData:(NSData *)data;
-(void)URLSession:(NSURLSession *)session task:task didCompleteWithError:(NSError *)error;

//Utilities
-(NSString*)reverseCharset:(int)uCodePage;

-(BOOL)condition:(int)num withCndExtension:(CCndExtension*)cnd;
-(void)action:(int)num withActExtension:(CActExtension*)act;
-(CValue*)expression:(int)num;

enum
{
    GETCP_FROMWEBPAGE	= 0x0000,
    GETCP_FROMAPP		= 0x0001,
    GETCP_UTF8          = 0x0002,
    GETCP_MAX
};


@end
