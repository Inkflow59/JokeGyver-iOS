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
//  RuntimeIPhoneAppDelegate.m
//  RuntimeIPhone
//
//  Created by Francois Lionet on 08/10/09.
//  Copyright Clickteam 2012. All rights reserved.
//

#import "RuntimeIPhoneAppDelegate.h"
#import "Services/CFile.h"
#import "CRunApp.h"
#import "CRun.h"
#import "MainViewController.h"
#import "CRunViewController.h"
#import "CRunView.h"
#import "MainView.h"
#import "CALPlayer.h"
#import "CRun.h"
#import "CSoundPlayer.h"
#import "CArrayList.h"
#import "CIni.h"

#import <AVFoundation/AVFoundation.h>

#ifdef __IPHONE_7_0
#import <GameController/GameController.h>
#endif

void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

@implementation RuntimeIPhoneAppDelegate
@synthesize window;


-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return [runApp supportedOrientations];
    //The "| 2" part is a workaround for UIPopoverController crash in iOS6.0.x (Fixed in iOS6.1)
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BOOL doesExpansionExist = NO;
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    /**
     *  Let check for Support library directory
     *  NSApplicationSupportDirectory
     */
    NSURL *appDirectory = [self applicationDataDirectory];
    //If there isn't an App Support Directory yet ...
    if (appDirectory != nil
            &&[[NSFileManager defaultManager] fileExistsAtPath:[appDirectory path] isDirectory:NULL])
    {
        // Check for Application.cci file in the application support library, if so use it as a valid cci file
        NSURL* fileURL = [NSURL URLWithString:@"Application.cci" relativeToURL:appDirectory];
        appPath=[[fileURL path] retain];
        doesExpansionExist = YES;
    }
    else
    {
        appPath=[[NSBundle mainBundle] pathForResource: @"Application" ofType:@"cci"];
    }
    runApp=[[CRunApp alloc] initWithPath:appPath];
    [CRunApp setRunApp:runApp];
    runApp->appDelegate = self;
    eventSubscribers = [[CArrayList alloc] init];
    [runApp load];
    
    [UIApplication sharedApplication].statusBarHidden = (runApp->bStatusBar==NO);
    
    // Set up the window and content view
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    runApp->window = window;
    
    mainViewController = [[MainViewController alloc] initWithRunApp:runApp];
    runViewController=[[CRunViewController alloc] initWithApp:runApp];
    
    MainView* mainView = (MainView*)[mainViewController view];
    CRunView* runView = (CRunView*)[runViewController view];
    [mainView addSubview:runView];
    
    [window setRootViewController:mainViewController];
    [window layoutIfNeeded];
    [window makeKeyAndVisible];
    
    [runApp setMainViewController:mainViewController];
    [runView initApplication:runApp];
    [runView setNeedsDisplay];
    
    runApp->expansion_available = doesExpansionExist;
    
    // Let register with New Notification Mode started at iOS 10.0
    [self registerForRemoteNotification];
    return YES;
}

-(void)dealloc
{
    [appPath release];
    [runApp release];
    [runViewController release];
    [mainViewController release];
    [window release];
    [eventSubscribers release];
    
    [adMob_Global release];
    
    [super dealloc];
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    if(runApp == nil || runApp->run == nil)
        return;
    
    int eventCount = [eventSubscribers size];
    for(int i=0; i<eventCount; ++i)
    {
        id<UIApplicationDelegate> dlgobj = (id<UIApplicationDelegate>)[eventSubscribers get:i];
        if([dlgobj respondsToSelector:@selector(applicationDidReceiveMemoryWarning:)])
            [dlgobj applicationDidReceiveMemoryWarning:application];
    }
    
    if (runApp->iOSObject!=nil)
        [runApp->run callEventExtension:runApp->iOSObject withCode:3 andParam:0];
    [runApp cleanMemory];
}

-(void)applicationWillResignActive:(UIApplication *)application
{
    if(runApp == nil || runApp->run == nil)
        return;
    
    NSLog(@"Will resign active ...");
    [CIni saveAllOpenINIfiles];
    
    int eventCount = [eventSubscribers size];
    for(int i=0; i<eventCount; ++i)
    {
        id<UIApplicationDelegate> dlgobj = (id<UIApplicationDelegate>)[eventSubscribers get:i];
        if([dlgobj respondsToSelector:@selector(applicationWillResignActive:)])
            [dlgobj applicationWillResignActive:application];
    }
    
    if (runApp->run!=nil && runApp->run->rhObjectList != nil)
    {
        if (runApp->iOSObject!=nil)
        {
            [runApp->run callEventExtension:runApp->iOSObject withCode:2 andParam:0];
        }
        [runApp->run doRunLoop];
        [runApp->runView drawNoUpdate];
        runApp->run->appActive=NO;
        if(![runApp->run isPaused])
        {
            NSLog(@"pausing ...");
            [runApp->run pause2];
        }
    }
    [runViewController->runView pauseTimer];
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    if(runApp == nil || runApp->run == nil)
        return;
    
    NSLog(@"Did Enter Background ...");
    [CIni saveAllOpenINIfiles];
    
    int eventCount = [eventSubscribers size];
    for(int i=0; i<eventCount; ++i)
    {
        id<UIApplicationDelegate> dlgobj = (id<UIApplicationDelegate>)[eventSubscribers get:i];
        if([dlgobj respondsToSelector:@selector(applicationDidEnterBackground:)])
            [dlgobj applicationDidEnterBackground:application];
    }
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    if(runApp == nil || runApp->run == nil)
        return;
    
    NSLog(@"Will enter foreground ...");
    runApp->renderer->clear();
    
    int eventCount = [eventSubscribers size];
    for(int i=0; i<eventCount; ++i)
    {
        id<UIApplicationDelegate> dlgobj = (id<UIApplicationDelegate>)[eventSubscribers get:i];
        if([dlgobj respondsToSelector:@selector(applicationWillEnterForeground:)])
            [dlgobj applicationWillEnterForeground:application];
    }
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{

    if(runApp == nil)
        return;
    
    NSLog(@"Did become active ...");
    [runApp->ALPlayer requestAudioSession];
    if([runApp->ALPlayer isSessionInterrupted])
    {
        [runApp->ALPlayer endInterruption];
        [runApp->ALPlayer resetSources];
    }
    
    if (runApp->run!=nil)
    {
        // Only resume if sounds are paused by delegate going to background
        if(runApp->soundPlayer->pausedBy != 1)
        {
            NSLog(@"resuming ...");
            [runApp->run resume2];
        }
        runApp->run->appActive=YES;
        if (runApp->iOSObject!=nil)
        {
            [runApp->run callEventExtension:runApp->iOSObject withCode:1 andParam:0];
        }
    }
    if(runViewController != nil && runViewController->runView != nil)
        [runViewController->runView resumeTimer];
    
    int eventCount = [eventSubscribers size];
    for(int i=0; i<eventCount; ++i)
    {
        id<UIApplicationDelegate> dlgobj = (id<UIApplicationDelegate>)[eventSubscribers get:i];
        if([dlgobj respondsToSelector:@selector(applicationDidBecomeActive:)])
            [dlgobj applicationDidBecomeActive:application];
    }
}

-(void)applicationWillTerminate:(UIApplication *)application
{
    if(runApp == nil)
        return;
    
    [CIni saveAllOpenINIfiles];
    
    int eventCount = [eventSubscribers size];
    for(int i=0; i<eventCount; ++i)
    {
        id<UIApplicationDelegate> dlgobj = (id<UIApplicationDelegate>)[eventSubscribers get:i];
        if([dlgobj respondsToSelector:@selector(applicationWillTerminate:)])
            [dlgobj applicationWillTerminate:application];
    }
    
    if (runApp->run!=nil)
        [runApp->run killRunLoop:0 keepSounds:NO];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [runApp endApplication];
    [runApp release];
    runApp=nil;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 100000
#pragma mark - Notification iOs < 10
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if(runApp == nil || runApp->run == nil)
        return;
    
    int eventCount = [eventSubscribers size];
    for(int i=0; i<eventCount; ++i)
    {
        id<UIApplicationDelegate> dlgobj = (id<UIApplicationDelegate>)[eventSubscribers get:i];
        if([dlgobj respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)])
            [dlgobj application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if(runApp == nil || runApp->run == nil)
        return;
    
    int eventCount = [eventSubscribers size];
    for(int i=0; i<eventCount; ++i)
    {
        id<UIApplicationDelegate> dlgobj = (id<UIApplicationDelegate>)[eventSubscribers get:i];
        if([dlgobj respondsToSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)])
            [dlgobj application:application didFailToRegisterForRemoteNotificationsWithError:error];
    }
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if(runApp == nil || runApp->run == nil)
        return;
    
    int eventCount = [eventSubscribers size];
    for(int i=0; i<eventCount; ++i)
    {
        id<UIApplicationDelegate> dlgobj = (id<UIApplicationDelegate>)[eventSubscribers get:i];
        if([dlgobj respondsToSelector:@selector(application:didReceiveRemoteNotification:)])
            [dlgobj application:application didReceiveRemoteNotification:userInfo];
    }
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if(runApp == nil || runApp->run == nil)
        return;
    
    int eventCount = [eventSubscribers size];
    for(int i=0; i<eventCount; ++i)
    {
        id<UIApplicationDelegate> dlgobj = (id<UIApplicationDelegate>)[eventSubscribers get:i];
        if([dlgobj respondsToSelector:@selector(application:didReceiveLocalNotification:)])
            [dlgobj application:application didReceiveLocalNotification:notification];
    }
}
#else
#pragma mark - Notification iOs >= 10
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    NSLog(@"User Info = %@",notification.request.content.userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
    if(runApp == nil || runApp->run == nil)
    {
        return;
    }
    
    int eventCount = [eventSubscribers size];
    for(int i=0; i<eventCount; ++i)
    {
        id<UNUserNotificationCenterDelegate> dlgobj = (id<UNUserNotificationCenterDelegate>)[eventSubscribers get:i];
        if([dlgobj respondsToSelector:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:)])
            [dlgobj userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
    }

}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    NSLog(@"User Info = %@",response.notification.request.content.userInfo);
    
    completionHandler();
    if(runApp == nil || runApp->run == nil)
    {
        return;
    }
    int eventCount = [eventSubscribers size];
    for(int i=0; i<eventCount; ++i)
    {
        id<UNUserNotificationCenterDelegate> dlgobj = (id<UNUserNotificationCenterDelegate>)[eventSubscribers get:i];
        if([dlgobj respondsToSelector:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)])
            [dlgobj userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    }
}
#endif

#pragma mark - Class Methods
- (void)registerForRemoteNotification {
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUALTO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        /*
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
         */
        // uncomment if you want to use notification in your application
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#pragma clang diagnostic pop
    }
}

#pragma mark -- Support Utilities for Expansion
- (NSURL*)applicationDataDirectory {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* possibleURLs = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSURL* appSupportDir = nil;
    NSURL* appDirectory = nil;
    
    if ([possibleURLs count] >= 1)
        appSupportDir = [possibleURLs objectAtIndex:0]; //Choose first
    
    // If a valid app support directory exists, add the
    // app's bundle ID to it to specify the final directory.
    if (appSupportDir)
    {
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        appDirectory = [appSupportDir URLByAppendingPathComponent:appBundleID];
    }
    
    return appDirectory;
}
@end
