//
//  AppDelegate.m
//  ShecareThermometerSDKDemo
//
//  Created by KyokuSei on 2021/1/24.
//

#import "AppDelegate.h"
#import "YCMainViewController.h"
#import "YCCommonAppDelegate.h"
#import <SCBLESDK/SCBLESDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[YCCommonAppDelegate shared] prepareAppWithOptions:launchOptions];
    
    [SCBLEThermometer sharedThermometer].appId = @"100017";
    [SCBLEThermometer sharedThermometer].appSecret = @"b1eed2fb4686e1b1049a9486d49ba015af00d5a0";
    [SCBLEThermometer sharedThermometer].unionId = @"15311411877";
    
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
