//
//  AppDelegate.h
//  ShecareThermometerSDKDemo
//
//  Created by KyokuSei on 2021/1/24.
//

#import <UIKit/UIKit.h>
#import <SCBLESDK/SCBLESDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

///  蓝牙连接类型
@property (nonatomic, assign) YCBLEConnectType connectType;

- (void)startScan;

@end

