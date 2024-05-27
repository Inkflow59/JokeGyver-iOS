/* Copyright (c) 1996-2017 Clickteam
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
// CRUNAESFUSION
//
//----------------------------------------------------------------------------------
#import "CRunAESFusion.h"
#import "CFile.h"
#import "CServices.h"
#import "CCreateObjectInfo.h"
#import "CCndExtension.h"
#import "CActExtension.h"
#import "CRun.h"
#import "CExtension.h"


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


@implementation CRunAESFusion


-(int)getNumberOfConditions
{
	return CND_LAST;
}

-(BOOL)createRunObject:(CFile*)file withCOB:(CCreateObjectInfo*)cob andVersion:(int)version
{
	return YES;
}

// Conditions
// -------------------------------------------------
-(BOOL)condition:(int)num withCndExtension:(CCndExtension*)cnd
{
    switch (num)
    {
        case CND_OnError:
            return YES;
    }
    return NO;
}

// Actions
// -------------------------------------------------
-(void)action:(int)num withActExtension:(CActExtension*)act
{
	switch (num)
	{
		case ACT_SetKey:
			Key = [act getParamExpString:rh withNum:0];
            if(Key.length != 16) {
                szError =@"Key string must be 16 characters in length";
                [ho pushEvent:0 withParam:0];
            }
			break;
				
	}
}
			
// Expressions
// --------------------------------------------
-(CValue*)expression:(int)num
{
	switch (num)
	{
		case EXP_Encrypt:
			return [self Encrypt];
			
		case EXP_Decrypt:
			return [self Decrypt];
			
		case EXP_GetError:
			return [self GetError];
	}
	return nil;
}

////////////////////////////////////////////////////////////////////////
//
//              AES functions
//
////////////////////////////////////////////////////////////////////////
- (NSData *)AESEncryptWithKey:(NSData*)data withKey:(NSString *)key {
    // 'key' should be 16 bytes for AES128, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    bzero(buffer, sizeof(buffer));
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode | kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        szError =@"";
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    if(cryptStatus != kCCSuccess) {
        if(cryptStatus == kCCUnimplemented)
            szError =@"Uninplemented";
        if(cryptStatus == kCCParamError)
            szError =@"Parameters error";
        if(cryptStatus == kCCOverflow)
            szError =@"Overflow result";
        if(cryptStatus == kCCBufferTooSmall)
            szError =@"Buffer too small";
        if(cryptStatus == kCCMemoryFailure)
            szError =@"Memory failure";
        if(cryptStatus == kCCDecodeError)
            szError =@"Decode Error";
        [ho pushEvent:0 withParam:0];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSData *)AESDecryptWithKey:(NSData*)data withKey:(NSString *)key {
    // 'key' should be 16 bytes for AES128, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    bzero(buffer, sizeof(buffer));
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode | kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        szError =@"";
       //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    if(cryptStatus != kCCSuccess) {
        if(cryptStatus == kCCUnimplemented)
            szError =@"Uninplemented";
        if(cryptStatus == kCCParamError)
            szError =@"Parameters error";
        if(cryptStatus == kCCOverflow)
            szError =@"Overflow result";
        if(cryptStatus == kCCBufferTooSmall)
            szError =@"Buffer too small";
        if(cryptStatus == kCCMemoryFailure)
            szError =@"Memory failure";
        if(cryptStatus == kCCDecodeError)
            szError =@"Decode Error";
        [ho pushEvent:0 withParam:0];
    }

    free(buffer); //free the buffer;
    return nil;
}

////////////////////////////////////////////////////////////////////////
//
//              AES Utilities
//
////////////////////////////////////////////////////////////////////////

- (NSString *)hexadecimalFromString:(NSData*)data {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}


- (NSData *)dataFromHexString:hexString {
    const char *chars = [hexString UTF8String];
    int i = 0;
    NSInteger len = [hexString length];
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}


- (NSString *) encryptString:(NSString*)plaintext withKey:(NSString*)key {
    NSData *data =  [self AESEncryptWithKey:[plaintext dataUsingEncoding:NSUTF8StringEncoding] withKey:key];
    NSString* hexstring = [self hexadecimalFromString:data];
    if(hexstring != nil)
        return [hexstring uppercaseString];
    else
        return@"";

}

- (NSString *) decryptString:(NSString *)ciphertext withKey:(NSString*)key {
    NSData *data = [self dataFromHexString:ciphertext];
    NSString* stringResult;
    stringResult = [[NSString alloc] initWithData:[self AESDecryptWithKey:data withKey:key] encoding:NSUTF8StringEncoding];
    if(stringResult != nil)
        return stringResult;
    else
        return @"";
}

-(CValue*)Encrypt
{
    NSString* plaintext=[[ho getExpParam] getString];
    return [rh getTempString:[self encryptString:plaintext withKey:Key]];
}

-(CValue*)Decrypt
{
    NSString* ciphertext=[[ho getExpParam] getString];
    return [rh getTempString:[self decryptString:ciphertext withKey:Key]];
}

-(CValue*)GetError
{
	return [rh getTempString:szError];
}




@end
