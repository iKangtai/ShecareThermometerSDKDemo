//
//  CommonAppDelegate.h
//  Shecare
//
//  Created by mac on 2019/12/27.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEThermometerDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class YCMessageModel;
@interface YCCommonAppDelegate : NSObject

@property (nonatomic, strong, nullable) NSMutableArray *validTemps;

+(YCCommonAppDelegate *)shared;

-(void)prepareAppWithOptions:(NSDictionary *)launchOptions;

///  开始扫描、连接设备
-(void)scan;
///  根据当前 App 状态，返回合适的扫描和连接类型
-(YCBLEConnectType)getNewConnectType;
/**
 * 断开当前连接的设备
 * connectType: 重置蓝牙连接类型
 */
-(void)disconnectActiveThermometer:(YCBLEConnectType)connectType;

- (void)thermometerDidUploadTemperature:(double)temperature timestamp:(NSDate *)timestamp endmeasureFlag:(YCBLEMeasureFlag)flag firmwareVersion:(NSString *)firmwareVersion;

@end

NS_ASSUME_NONNULL_END
