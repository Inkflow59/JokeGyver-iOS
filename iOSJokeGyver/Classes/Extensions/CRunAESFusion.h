/* Copyright (c) 1996-2016 Clickteam
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
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

#import "CRunExtension.h"

@class CCreateObjectInfo;
@class CFile;
@class CValue;

#define CND_OnError 0
#define CND_LAST    1
#define ACT_SetKey  0
#define EXP_Encrypt 0
#define EXP_Decrypt 1
#define EXP_GetError 2


@interface CRunAESFusion : CRunExtension
{
    NSString* Key;
    NSString* szError;
    NSString* result;
}
-(int)getNumberOfConditions;
-(BOOL)createRunObject:(CFile*)file withCOB:(CCreateObjectInfo*)cob andVersion:(int)version;
-(void)action:(int)num withActExtension:(CActExtension*)act;
-(CValue*)expression:(int)num;
-(CValue*)Encrypt;
-(CValue*)Decrypt;
-(CValue*)GetError;

-(NSData*)AESEncryptWithKey:(NSData*)data withKey:(NSString*)key;
-(NSData*)AESDecryptWithKey:(NSData*)data withKey:(NSString*)key;
-(NSString*)hexadecimalFromString:(NSData*)data;

-(NSString*)encryptString:(NSString*)plaintext withKey:(NSString*)key;
-(NSString*)decryptString:(NSString*)ciphertext withKey:(NSString*)key;

@end
