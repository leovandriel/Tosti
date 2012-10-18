//
//  TOTouchAppDelegate.m
//  Tosti
//
//  Copyright (c) 2012 Tosti. All rights reserved.
//

#import "TOTouchAppDelegate.h"
#import "TOViewController.h"


@implementation TOTouchAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    TOViewController *controller = [[TOViewController alloc] init];
    self.window.rootViewController = controller;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
