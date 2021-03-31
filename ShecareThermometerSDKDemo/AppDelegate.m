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
    
    YCMainViewController *temVC = [[YCMainViewController alloc] init];
    temVC.title = @"首页";
    UINavigationController *temNavC = [[UINavigationController alloc] initWithRootViewController:temVC];
    temNavC.navigationBar.translucent = false;
    
    self.window.rootViewController = temNavC;
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
