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
//  CRunKcDbl.h
//  RuntimeIPhone
//
//  Created By Fernando Vivolo
//  Copyright (c) 2011-2021 Clickteam. All rights reserved.
//  06/02/2021 changes made to improve performance and use
//  less memory
//

#import "CRunKcDbl.h"
#import "CFile.h"
#import "CRunApp.h"
#import "CValue.h"
#import "CExtension.h"
#import "CRun.h"
#import "CCndExtension.h"
#import "CRunView.h"
#import "CRect.h"
#import "CRunView.h"
#import "CCreateObjectInfo.h"

#define CND_LAST 0
#define ACT_SETFORMAT_STD 0
#define ACT_SETFORMAT_NDIGITS 1
#define ACT_SETFORMAT_NDECIMALS 2

#define EXP_ADD 0
#define EXP_SUB 1
#define EXP_MUL 2
#define EXP_DIVIDE 3
#define EXP_FMT_NDIGITS 4
#define EXP_FMT_NDECIMALS 5

#define SAFE_RELEASE(X) if(X != nil) {[X release]; X = nil;}

@implementation CRunKcDbl

-(int)getNumberOfConditions
{
    return CND_LAST;
}

- (BOOL)createRunObject:(CFile *)file withCOB:(CCreateObjectInfo *)cob andVersion:(int)version
{

    ho->hoX = cob->cobX;
    ho->hoY = cob->cobY;
    ho->hoImgWidth = 32;
    ho->hoImgHeight = 32;
    
    fmtObj = [[NSNumberFormatter alloc] init];
    nf = [[NSNumberFormatter alloc] init];
    
    nDigits = 32;
    nDecimals = -1;
    return YES;
}
// Actions
// --------------------------------------------

-(void)action:(int)num withActExtension:(CActExtension *)act
{
    switch (num)
    {
        case ACT_SETFORMAT_STD:
            [self Act_SetFormat_Std];
            break;
        case ACT_SETFORMAT_NDIGITS:
            [self Act_SetFormat_NDigits:[act getParamExpression:rh withNum:0]];
            break;
        case ACT_SETFORMAT_NDECIMALS:
            [self Act_SetFormat_NDecimals:[act getParamExpression:rh withNum:0]];
            break;
    }
    
}

-(void)destroyRunObject:(BOOL)bFast
{
    if(fmtObj != nil)
        [fmtObj release];
    fmtObj = nil;
    
    if(nf != nil)
        [nf release];
    nf = nil;

}



-(void)Act_SetFormat_Std
{
    nDigits = 32;
    nDecimals = -1;
}

-(void)Act_SetFormat_NDigits:(int)n
{
    nDigits = n;
    
    if(nDigits <= 0)
        nDigits = 1;
    
    if(nDigits > 256)
        nDigits = 256;
    
    nDecimals = -1;
}

-(void)Act_SetFormat_NDecimals:(int)n
{
    nDecimals = n;
    
    if(nDecimals <= 0)
        nDecimals = 1;
    
    if(nDecimals > 256)
        nDecimals = 256;
    
}

// Expressions
// --------------------------------------------
- (CValue *)expression:(int)num
{
    switch (num)
    {
    case EXP_ADD:
        return [self doubleAdd:[[ho getExpParam] getString] with:[[ho getExpParam] getString]];
    case EXP_SUB:
        return [self doubleSubstract:[[ho getExpParam] getString] with:[[ho getExpParam] getString]];
    case EXP_MUL:
        return [self doubleMultiply:[[ho getExpParam] getString] with:[[ho getExpParam] getString]];
    case EXP_DIVIDE:
        return [self doubleDivide:[[ho getExpParam] getString] with:[[ho getExpParam] getString]];
    case EXP_FMT_NDIGITS:
        return [self Exp_Fmt_NDigits:[[ho getExpParam] getString] withDigits:[[ho getExpParam] getInt]];
    case EXP_FMT_NDECIMALS:
        return [self Exp_Fmt_NDecimals:[[ho getExpParam] getString] withDecimals:[[ho getExpParam] getInt]];
    }
    return nil;
}

- (double) StringToDouble:(NSString *)ps {
    double r = 0;

    @try {
        if(nf == nil)
            nf = [[NSNumberFormatter alloc] init];
        [nf setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        r = [[nf numberFromString:ps] doubleValue];
    }
    @catch (NSException * e) {
        NSLog(@"wrong conversion");
    }
    
    return r;
}

- (NSString *) DoubleToString:(double)v {
    NSNumber *doubleNumber = [NSNumber numberWithDouble:v];
    NSString * param = [doubleNumber stringValue];
    NSRange rangeNeg = [param rangeOfString:@"-"] ;
    NSRange rangeDot = [param rangeOfString:@"."];
    
    if(fmtObj == nil)
        fmtObj = [[NSNumberFormatter alloc] init];
    
    if (nDecimals == -1)
    {
        if (([param length] > 2) && ([[param substringFromIndex:[param length] - 2] isEqualToString:@".0"]))
        {
            param = [param substringWithRange:NSMakeRange(0, [param length] - 2)];
        }
        if(v - (int)v > 0) //if (rangeDot.location != NSNotFound)
        {
            int length = (int)[[param substringWithRange:NSMakeRange(0, rangeDot.location)] length];
            if (length > nDigits + ((rangeNeg.location != NSNotFound) ? 1 : 0)) {
                NSString * formatDig = @"";
                
                for (int i = 0; i < nDigits - 1; i++) {
                    if (i == 0) {
                        formatDig = @".";
                    }
                    formatDig = [formatDig stringByAppendingString:@"0"];
                }
                
                [fmtObj setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
                NSString* fmtFormat = [[@"0" stringByAppendingString:formatDig] stringByAppendingString:@"E000"];
                [fmtObj setPositiveFormat:fmtFormat];
                [fmtObj setNegativeFormat:[@"-" stringByAppendingString:fmtFormat]];
                NSString * plusLess = [fmtObj stringFromNumber:doubleNumber];
                NSString* s1 = [plusLess substringWithRange:NSMakeRange(0, [plusLess rangeOfString:@"E"].location)];
                return [[s1 stringByAppendingString:@"e+"] stringByAppendingString:[plusLess substringFromIndex:[plusLess rangeOfString:@"E"].location + 1]];
            }
            NSString * prefix = [param substringWithRange:NSMakeRange(0, rangeDot.location)];
            NSString * formatDec = @"";
            int step = (int)([prefix length] - ((rangeNeg.location != NSNotFound) ? 1 : 0));
            
            for (int i = 0; i < step; i++) {
                formatDec = [formatDec stringByAppendingString:@"#"];
            }
            
            formatDec = [formatDec stringByAppendingString:@"."];
            
            for (int i = (int)[formatDec length] - 1; i < nDigits; i++) {
                formatDec = [formatDec stringByAppendingString:@"0"];
            }
            
            [fmtObj setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            [fmtObj setPositiveFormat:formatDec];
            [fmtObj setNegativeFormat:[@"-" stringByAppendingString:formatDec]];
            [fmtObj setMinimumIntegerDigits:[prefix length] - ((rangeNeg.location != NSNotFound) ? 1 : 0)];
            return [fmtObj stringFromNumber:doubleNumber];
        }
        else {
            if ([param length] > nDigits + ((rangeNeg.location != NSNotFound) ? 1 : 0)) {
                NSString * formatDig = @"";
                
                for (int i = 0; i < nDigits - 1; i++) {
                    if (i == 0) {
                        formatDig = @".";
                    }
                    formatDig = [formatDig stringByAppendingString:@"0"];
                }
            
                [fmtObj setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
                NSString* fmtFormat = [[@"0" stringByAppendingString:formatDig] stringByAppendingString:@"E000"];
                [fmtObj setPositiveFormat:fmtFormat];
                [fmtObj setNegativeFormat:[@"-" stringByAppendingString:fmtFormat]];
                NSString * plusLess = [fmtObj stringFromNumber:doubleNumber];
                return [[[plusLess substringWithRange:NSMakeRange(0, [plusLess rangeOfString:@"E"].location)]stringByAppendingString:@"e+"] stringByAppendingString: [plusLess substringFromIndex:([plusLess rangeOfString:@"E"].location + 1)]];
            }
            return param;
        }
    }
    else {
        NSString * format = @"";
        NSString * prefix = @"";
        int step = (int)([prefix length] - ((rangeNeg.location != NSNotFound) ? 1 : 0));
        if(rangeDot.location != NSNotFound)
            prefix = [param substringWithRange:NSMakeRange(0, rangeDot.location)];
        
        for (int i = 0; i < step; i++) {
            format = [format stringByAppendingString:@"#"];
        }
        
        NSString * decimalPlaces = @"";
        
        for (int i = 0; i < nDecimals; i++) {
            decimalPlaces = [decimalPlaces stringByAppendingString:@"0"];
        }
        
        if (![decimalPlaces isEqualToString:@""]) {
            format = [format stringByAppendingString:[@"." stringByAppendingString:decimalPlaces]];
        }

        [fmtObj setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [fmtObj setPositiveFormat:format];
        [fmtObj setNegativeFormat:[@"-" stringByAppendingString:format]];
        [fmtObj setMinimumFractionDigits:(NSUInteger)nDecimals];
        [fmtObj setMaximumFractionDigits:(NSUInteger)nDecimals];
        [fmtObj setMinimumIntegerDigits:step];
        NSString* result;
        if([doubleNumber doubleValue] == 0 )
            result = [@"0" stringByAppendingString:[fmtObj stringFromNumber:doubleNumber]];
        else
            result = [fmtObj stringFromNumber:doubleNumber];

        return result;
    }
}


- (CValue *)doubleAdd:(NSString *)first with:(NSString *)second
{
    NSString *resultString = @"";
    if(first != nil && second != nil)
    {
        double val1 = [self StringToDouble:first];
        double val2 = [self StringToDouble:second];
        val1 +=val2;
        resultString = [self DoubleToString:val1];
        val1 = 0;
        val2 = 0;

    }
    return [rh getTempString:resultString];
}
- (CValue *)doubleSubstract:(NSString *)first with:(NSString *)second
{
    NSString *resultString = @"";
    if(first != nil && second != nil)
    {
        double val1 = [self StringToDouble:first];
        double val2 = [self StringToDouble:second];
        val1 -=val2;
        resultString = [self DoubleToString:val1];
    }
    return [rh getTempString:resultString];
}

- (CValue *)doubleMultiply:(NSString *)first with:(NSString *)second
{
    NSString *resultString = @"";
    if(first != nil && second != nil)
    {
        double val1 = [self StringToDouble:first];
        double val2 = [self StringToDouble:second];
        val1 *=val2;
        resultString = [self DoubleToString:val1];
    }
    return [rh getTempString:resultString];
}
- (CValue *)doubleDivide:(NSString *)first with:(NSString *)second
{
    NSString *resultString = @"";
    if(first != nil && second != nil)
    {
        double val1 = [self StringToDouble:first];
        double val2 = [self StringToDouble:second];
        if(val2 != 0)
        {
            val1 /=val2;
            resultString = [self DoubleToString:val1];
        }
    }
    return [rh getTempString:resultString];
}

- (CValue *)Exp_Fmt_NDigits:(NSString *)param withDigits:(int)n
{
    NSRange rangeNeg = [param rangeOfString:@"-"] ;
    NSRange rangeDot = [param rangeOfString:@"."];
    NSNumber* doubleNumber = [[NSNumber alloc] initWithDouble:[self StringToDouble:param]];
    n = MIN(MAX(0, n), 256);
    
    if(fmtObj == nil)
        fmtObj = [[NSNumberFormatter alloc] init];
    
    if (([param length] > 2) && ([[param substringFromIndex:[param length] - 2] isEqualToString:@".0"]))
    {
        param = [param substringWithRange:NSMakeRange(0, [param length] - 2)];
    }
    
    if (rangeDot.location != NSNotFound)
    {
        int length = (int)[[param substringWithRange:NSMakeRange(0, rangeDot.location)] length];
        if (length > nDigits + ((rangeNeg.location != NSNotFound) ? 1 : 0)) {
            NSString * formatDig = @"";
            
            for (int i = 0; i < n - 1; i++) {
                if (i == 0) {
                    formatDig = @".";
                }
                formatDig = [formatDig stringByAppendingString:@"0"];
            }
            
            [fmtObj setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            NSString* fmtFormat = [[@"0" stringByAppendingString:formatDig] stringByAppendingString:@"E000"];
            [fmtObj setPositiveFormat:fmtFormat];
            [fmtObj setNegativeFormat:[@"-" stringByAppendingString:fmtFormat]];
            NSString * plusLess = [fmtObj stringFromNumber:doubleNumber];
            NSString* s1 = [plusLess substringWithRange:NSMakeRange(0, [plusLess rangeOfString:@"E"].location)];
            return [rh getTempString:[[s1 stringByAppendingString:@"e+"] stringByAppendingString:[plusLess substringFromIndex:[plusLess rangeOfString:@"E"].location + 1]]];

        }
        NSString * prefix = [param substringWithRange:NSMakeRange(0, rangeDot.location)];
        NSString * formatDec = @"";
        
        for (int i = 0; i < (int)[prefix length] - ((rangeNeg.location != NSNotFound) ? 1 : 0); i++) {
            formatDec = [formatDec stringByAppendingString:@"#"];
        }
        
        formatDec = [formatDec stringByAppendingString:@"."];
        
        for (int i = (int)[formatDec length] - 1; i < n; i++) {
            formatDec = [formatDec stringByAppendingString:@"0"];
        }
        
        [fmtObj setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [fmtObj setPositiveFormat:formatDec];
        [fmtObj setNegativeFormat:[@"-" stringByAppendingString:formatDec]];
        [fmtObj setMinimumIntegerDigits:(int)[prefix length] - ((rangeNeg.location != NSNotFound) ? 1 : 0)];
        return [rh getTempString:[fmtObj stringFromNumber:doubleNumber]];
    }
    else {
        if ([param length] > n + ((rangeNeg.location != NSNotFound) ? 1 : 0)) {
            NSString * formatDig = @"";
            
            for (int i = 0; i < n - 1; i++) {
                if (i == 0) {
                    formatDig = @".";
                }
                formatDig = [formatDig stringByAppendingString:@"0"];
            }
            
            [fmtObj setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            NSString* fmtFormat = [[@"0" stringByAppendingString:formatDig] stringByAppendingString:@"E000"];
            [fmtObj setPositiveFormat:fmtFormat];
            [fmtObj setNegativeFormat:[@"-" stringByAppendingString:fmtFormat]];
            NSString * plusLess = [fmtObj stringFromNumber:doubleNumber];
            return [rh getTempString:[[[plusLess substringWithRange:NSMakeRange(0, [plusLess rangeOfString:@"E"].location)]stringByAppendingString:@"e+"] stringByAppendingString: [plusLess substringFromIndex:([plusLess rangeOfString:@"E"].location + 1)]]];
        }
        return [rh getTempString:param];
    }
}

- (CValue *)Exp_Fmt_NDecimals:(NSString *)param withDecimals:(int)n
{
    NSRange rangeNeg = [param rangeOfString:@"-"] ;
    NSRange rangeDot = [param rangeOfString:@"."];
    NSNumber* doubleNumber = [[NSNumber alloc] initWithDouble:[self StringToDouble:param]];
    NSString * format = @"";
    NSString * prefix = @"";
    if(rangeDot.location != NSNotFound)
        prefix = [param substringWithRange:NSMakeRange(0, rangeDot.location)];
    
    for (int i = 0; i < (int)[prefix length] - ((rangeNeg.location != NSNotFound) ? 1 : 0); i++) {
        format = [format stringByAppendingString:@"#"];
    }
    
    NSString * decimalPlaces = @"";
    
    for (int i = 0; i < n; i++) {
        decimalPlaces = [decimalPlaces stringByAppendingString:@"0"];
    }
    
    if (![decimalPlaces isEqualToString:@""]) {
        format = [format stringByAppendingString:[@"." stringByAppendingString:decimalPlaces]];
    }

    if(fmtObj == nil)
        fmtObj = [[NSNumberFormatter alloc] init];
    
    [fmtObj setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [fmtObj setPositiveFormat:format];
    [fmtObj setNegativeFormat:[@"-" stringByAppendingString:format]];
    [fmtObj setMinimumFractionDigits:(NSUInteger)n];
    [fmtObj setMaximumFractionDigits:(NSUInteger)n];
    [fmtObj setMinimumIntegerDigits:(int)[prefix length] - ((rangeNeg.location != NSNotFound) ? 1 : 0)];
    NSString* result;
    if([doubleNumber doubleValue] == 0 )
        result = [@"0" stringByAppendingString:[fmtObj stringFromNumber:doubleNumber]];
    else
        result = [fmtObj stringFromNumber:doubleNumber];

    return [rh getTempString:result];
}

@end
