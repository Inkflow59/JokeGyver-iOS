//
//  CRunGDPRConsent.m
//  RuntimeIPhone
//
//  Created by Fernando Vivolo on 08/28/2018.
//  Copyright (c) 2016-2018 Clickteam. All rights reserved.
//

#import <AdSupport/AdSupport.h>
#import "CRunGDPRConsent.h"
#import "CRun.h"
#import "CRunApp.h"
#import "CBitmap.h"
#import "CFile.h"
#import "CObject.h"
#import "CCreateObjectInfo.h"
#import "CExtension.h"
#import "CServices.h"
#import "CCndExtension.h"
#import "CActExtension.h"
#import "CValue.h"



@implementation CRunGDPRConsent

#define CNDONFORMLOADED     0
#define CNDONFORMFAILED     1
#define CNDONFORMOPENED     2
#define CNDONFORMCLOSED     3
#define CNDISADSFREE        4
#define CNDISCONSENTSTATUS  5
#define CNDONERROR          6
#define CND_LAST            7


#define ACTUNDERAGE        0
#define ACTLOADFORM        1
#define ACTSHOWFORM        2
#define ACTDEBUGGEOMODE    3
#define ACTSETSTATUS       4

#define EXPGDPRSTATUS      0
#define EXPDEBUGGEOMODE    1
#define EXPGDPRADSLIST     2
#define EXPERROR           3


-(int)getNumberOfConditions
{
    return CND_LAST;
}

-(BOOL)createRunObject:(CFile*)file withCOB:(CCreateObjectInfo*)cob andVersion:(int)version
{
    [file setUnicode:YES];
    [file readAShort];
    [file readAShort];
    [file readAShort];
    [file readAShort];
    short lflag = [file readAShort];
    short wflag = [file readAShort];

    PUBLISHER_ID = [[NSString alloc] initWithString:[file readAStringWithSize:65]];
    POLICY_URL = [[NSString alloc] initWithString:[file readAStringWithSize:264]];
        
    if([PUBLISHER_ID length ] > 0)
    {
        PUBLISHER_ID = [PUBLISHER_ID stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@","];
        PUBLISHER_ID = [PUBLISHER_ID stringByReplacingOccurrencesOfString:@",," withString:@","];
    }
    if([POLICY_URL length] > 0)
    {
        POLICY_URL = [POLICY_URL stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@","];
        POLICY_URL = [POLICY_URL stringByReplacingOccurrencesOfString:@",," withString:@","];
    }


    szError = [[NSString alloc] initWithString:@""];
    expRet =[[CValue alloc] initWithInt:0];
    

    //NSLog(@"Created");
    return NO;
}

- (void) destroyRunObject:(BOOL)bFast {
    NSLog(@"Destroy");
    [PUBLISHER_ID release];
    [POLICY_URL release];
    [publisherIds release];
    if(form != nil)
        form = nil;
}

- (void) pauseRunObject {
    NSLog(@"Went to pause");
}

- (void) continueRunObject {
    NSLog(@"Return from Pause");
}

-(int)handleRunObject
{
    [self startEUConsentForm];
    return REFLAG_ONESHOT;
}

-(void)readPreferences
{
    userChooseAdFree = [[NSUserDefaults standardUserDefaults] integerForKey:@"EUFree"] == 0 ? NO:YES;
    consentstatus = (PACConsentStatus)[[NSUserDefaults standardUserDefaults] integerForKey:@"EUConsent"];
    adProviders = PACConsentInformation.sharedInstance.adProviders;
    if(adProviders == nil || [adProviders count] == 0)
        adProviders =  (NSArray*)[[NSUserDefaults standardUserDefaults] objectForKey:@"adapters"];
}

-(void)savePreferences
{
    adProviders = PACConsentInformation.sharedInstance.adProviders;
    [[NSUserDefaults standardUserDefaults] setInteger:userChooseAdFree?1:0 forKey:@"EUFree"];
    [[NSUserDefaults standardUserDefaults] setInteger:(int)consentstatus forKey:@"EUConsent"];
    if(adProviders != nil && [adProviders count] > 0)
        [[NSUserDefaults standardUserDefaults] setObject:adProviders forKey:@"adapters"];

}

-(void)destroyForm
{
    if(form != nil)
       [form dealloc];
    form = nil;
}

- (void)startEUConsentForm
{
    if(publisherIds != nil)
        [publisherIds release];
    publisherIds = [[NSArray alloc] init];
    if (publisherIds != nil)
    {
        [publisherIds arrayByAddingObject:PUBLISHER_ID];

        [PACConsentInformation.sharedInstance
            requestConsentInfoUpdateForPublisherIdentifiers:publisherIds
                    completionHandler:^(NSError *_Nullable error) {
                            if (error)
                            {
                                szError = [[NSString alloc] initWithString:[error description]];
                                [ho pushEvent:CNDONERROR withParam:0];
                            }
                            else
                            {
                                consentstatus = PACConsentInformation.sharedInstance.consentStatus;
                                debugGeoMode = (int)PACConsentInformation.sharedInstance.debugGeography;
                            }
                            [self readPreferences];
                    }];
    }
}

-(void)createConsentForm
{
    NSURL *privacyURL = [NSURL URLWithString:POLICY_URL];
    form = [[PACConsentForm alloc] initWithApplicationPrivacyPolicyURL:privacyURL];
    form.shouldOfferPersonalizedAds = YES;
    form.shouldOfferNonPersonalizedAds = YES;
    form.shouldOfferAdFree = YES;
}

/*
 *
 *         Conditions
 *
 *
 */

-(BOOL)condition:(int)num withCndExtension:(CCndExtension*)cnd
{
    
    switch (num) {
        case CNDONFORMLOADED:
            return [self cndOnFormLoaded:cnd];
        case CNDONFORMFAILED:
            return [self cndOnFormFailed:cnd];
        case CNDONFORMOPENED:
            return [self cndOnFormOpened:cnd];
        case CNDONFORMCLOSED:
            return [self cndOnFormClosed:cnd];
        case CNDISADSFREE:
            return [self cndIsAdsFree:cnd];
        case CNDISCONSENTSTATUS:
            return [self cndIsConsentStatus:cnd];
        case CNDONERROR:
            return [self cndOnError:cnd];
    }
    return NO;
}

/*
 *
 *         Actions
 *
 *
 */

-(void)action:(int)num withActExtension:(CActExtension *)act;
{
    
    switch (num) {
        case ACTUNDERAGE:
            [self actUnderAge:act];
            break;
        case ACTLOADFORM:
            [self actLoadEUForm:act];
            break;
        case ACTSHOWFORM:
            [self actShowEUForm:act];
            break;
        case ACTDEBUGGEOMODE:
            [self actDebugGeoMode:act];
            break;
        case ACTSETSTATUS:
            [self actSetEUStatus:act];
            break;
   }
}

/*
 *
 *         Expressions
 *
 *
 */

- (CValue *) expression:(int)num {
    
    switch (num) {
        case EXPGDPRSTATUS:
            return [self expGetConsentStatus];
        case EXPDEBUGGEOMODE:
            return [self expDebugGeoMode];
        case EXPGDPRADSLIST:
            return [self expAdapterListAsString];
        case EXPERROR:
            return [self expStringError];
    }
    return [rh getTempString:@""];;
}

//========================================================

-(BOOL)cndOnFormLoaded:(CCndExtension*)cnd
{
    return YES;
}

-(BOOL)cndOnFormFailed:(CCndExtension*)cnd
{
    return YES;
}

-(BOOL)cndOnFormOpened:(CCndExtension*)cnd
{
    return YES;
}

-(BOOL)cndOnFormClosed:(CCndExtension*)cnd
{
    return YES;
}

-(BOOL)cndIsAdsFree:(CCndExtension*)cnd
{
    return userChooseAdFree;
}

-(BOOL)cndIsConsentStatus:(CCndExtension*)cnd
{
    return consentstatus-1 == [cnd getParamExpression:rh withNum:0];
}

-(BOOL)cndOnError:(CCndExtension*)cnd
{
    return YES;
}

/*
 *
 *          Actions
 */

-(void)actUnderAge:(CActExtension*)act
{
    int p1 = [act getParamExpression:rh withNum:0];
    if(p1 == 0)
        PACConsentInformation.sharedInstance.tagForUnderAgeOfConsent = NO;
    if(p1 == 1)
        PACConsentInformation.sharedInstance.tagForUnderAgeOfConsent = YES;
}

- (void)actLoadEUForm:(CActExtension *)act
{
    if(form == nil)
      [self createConsentForm];
    if (form != nil)
    {
        [form loadWithCompletionHandler:^(NSError *_Nullable error) {
          NSLog(@"Load complete. Error: %@", error);
          if (error)
          {
              // Consent form error.
              szError = [[NSString alloc] initWithString:[error description]] ;
              [ho pushEvent:CNDONERROR withParam:0];
              [ho pushEvent:CNDONFORMFAILED withParam:0];
          }
          else
          {
              // Load successful.
              [ho pushEvent:CNDONFORMLOADED withParam:0];
          }
        }];
    }
}

- (void)actShowEUForm:(CActExtension *)act
{
    if (form != nil)
    {
        mainViewController = ho->hoAdRunHeader->rhApp->mainViewController;
        
        [form presentFromViewController:mainViewController
            dismissCompletion:^(NSError *_Nullable error, BOOL userPrefersAdFree) {
                userChooseAdFree = NO;
                // Check the user's consent choice.
                consentstatus = PACConsentInformation.sharedInstance.consentStatus;
               if (error)
                {
                    // Consent form error.
                    szError = [[NSString alloc] initWithString:[error description]] ;
                    [ho pushEvent:CNDONERROR withParam:0];
                    [ho pushEvent:CNDONFORMFAILED withParam:0];
                }
                else if (userPrefersAdFree)
                {
                    // The user prefers to use a paid version of the app.
                    userChooseAdFree = YES;
                    [ho pushEvent:CNDONFORMCLOSED withParam:0];
                }
                else
                {
                     [ho pushEvent:CNDONFORMCLOSED withParam:0];
                }
                // Save some preferences to handle this
                [self savePreferences];
                [self destroyForm];
        }];
        [ho pushEvent:CNDONFORMOPENED withParam:0];
    }
}

- (void)actDebugGeoMode:(CActExtension *)act
{
    int p1 = [act getParamExpression:rh withNum:0];
    PACConsentInformation.sharedInstance.tagForUnderAgeOfConsent = NO;
    if (p1 == 0)
    {
        // Geography appears as Disabled for debug devices.
        PACConsentInformation.sharedInstance.debugGeography = PACDebugGeographyDisabled;
    }
    if (p1 == 1)
    {
        // Geography appears as in EEA for debug devices.
        PACConsentInformation.sharedInstance.debugGeography = PACDebugGeographyEEA;
     }
    if (p1 == 2)
    {
        // Geography appears as not in EEA for debug devices.
        PACConsentInformation.sharedInstance.debugGeography = PACDebugGeographyNotEEA;
    }
    debugGeoMode = (int)PACConsentInformation.sharedInstance.debugGeography;

    if (p1 > 0)
    {
        NSUUID *adid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        NSLog(@"Advertising ID: %@",
              ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString);
        NSArray* fields = [[NSArray alloc] initWithObjects:[adid UUIDString], nil];

        if (fields != nil && [fields count] > 0)
            PACConsentInformation.sharedInstance.debugIdentifiers = fields;
    }
    [self startEUConsentForm];
}

- (void)actSetEUStatus:(CActExtension *)act
{
    int p1 = [act getParamExpression:rh withNum:0]+1;
    if(p1 < 0 || p1 > 2)
        return;
    
    PACConsentInformation.sharedInstance.consentStatus = p1;
    [self savePreferences];
}

/*
 *
 *     Expressions
 *
 */

-(CValue*)expGetConsentStatus
{
    [expRet forceInt:((int)consentstatus-1)];
    return expRet;
}

-(CValue*)expDebugGeoMode
{
    [expRet forceInt:debugGeoMode];
    return expRet;
}

-(CValue*)expAdapterListAsString
{
    [expRet forceString:@""];
    adProviders = PACConsentInformation.sharedInstance.adProviders;
    if(adProviders != nil && [adProviders count] > 0)
    {
        NSError* error = nil;
        NSData *json = [NSJSONSerialization dataWithJSONObject:adProviders options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];

        [expRet forceString:error?@"":jsonString];
    }
    
    return expRet;
}

- (CValue *) expStringError {
    [expRet forceString:@""];
    if (szError != nil)
        [expRet forceString:szError];
    return expRet;
}


@end
