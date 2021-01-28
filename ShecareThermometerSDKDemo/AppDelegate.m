//
//  AppDelegate.m
//  ShecareThermometerSDKDemo
//
//  Created by KyokuSei on 2021/1/24.
//

#import "AppDelegate.h"
#import "YCMainViewController.h"
#import "YCCommonAppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[YCCommonAppDelegate shared] prepareAppWithOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[YCMainViewController alloc] init]];
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
