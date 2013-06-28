//
//  OAuthStarterKitAppDelegate.m
//  OAuthStarterKit
//
//  Created by Christina Whitney on 4/11/11.
//  Copyright 2011 self. All rights reserved.
//

#import "OAuthStarterKitAppDelegate.h"
#import "ProfileTabView.h"

@implementation OAuthStarterKitAppDelegate


@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ProfileTabView *profileViewController = [[ProfileTabView alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = profileViewController;
    
    [self.window makeKeyAndVisible];
    return YES;
}




- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
