//
//  CRunGDPRConsent.h
//  RuntimeIPhone
//
//  Created by Fernando Vivolo on 08/28/2018.
//  Copyright (c) 2016-2018 Clickteam. All rights reserved.
//

#import <PersonalizedAdConsent/PersonalizedAdConsent.h>
#import "CRunExtension.h"
#import "MainViewController.h"

@class MainViewController;


@interface CRunGDPRConsent : CRunExtension
{

  CValue * expRet;
    
  BOOL appEndOn;
  MainViewController* mainViewController;
    
  NSString* szError;
    
  PACConsentForm *form;
  NSArray* publisherIds;
  NSString* PUBLISHER_ID;
  NSString* POLICY_URL;
  NSArray *adProviders;
  PACConsentStatus consentstatus;
  int debugGeoMode;
  BOOL userChooseAdFree;
}

-(int)getNumberOfConditions;
-(BOOL)createRunObject:(CFile*)file withCOB:(CCreateObjectInfo*)cob andVersion:(int)version;
-(void)destroyRunObject:(BOOL)bFast;
-(void)pauseRunObject;
-(void)continueRunObject;
-(BOOL)condition:(int)num withCndExtension:(CCndExtension *)cnd;
-(void)action:(int)num withActExtension:(CActExtension *)act;
-(CValue*)expression:(int)num;

@end



