//
//  SCBLEThermometer.h
//  SCBLESDK
//
//  Created by 北京爱康泰科技有限责任公司 on 16/8/2.
//  Copyright © 2016年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SCBLEDefines.h"
#import "SCBLEDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCBLETemperature : NSObject

/// Temperature
@property (nonatomic, assign) double temperature;
/// The measure time
@property (nonatomic, copy) NSString *time;

@end


@interface SCBLEThermometer : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

///  Delegate
@property (nonatomic, weak) id <BLEThermometerDelegate> delegate;
///  OAD Delegate
@property (nonatomic, weak) id <BLEThermometerOADDelegate> oadDelegate;
///  当前连接的蓝牙设备
@property (nonatomic, strong, nullable) CBPeripheral *activePeripheral;
///  蓝牙连接类型
@property (nonatomic, assign) YCBLEConnectType connectType;
///  硬件版本信息
@property (nonatomic, copy) NSString *firmwareVersion;
///  ImageType，OAD 升级的时候使用
@property (nonatomic, assign) YCBLEFirmwareImageType imageType;
///  MAC Address
@property (nonatomic, copy) NSString *macAddress;
///  硬件名称
@property (copy, nonatomic) NSString *hardwareName;
///  是否正在 OAD
@property (assign, nonatomic) BOOL isOADing;

@property int suotaVersion;
@property int suotaMtu;
@property int suotaPatchDataSize;
@property int suotaL2CapPsm;


/// Singleton
+ (instancetype)sharedThermometer;

/**
 * Return the BLE status of the current device
 */
- (YCBLEState)bleState;

/**
 * Disconnect the currently connected device
 */
- (void)disconnectActiveThermometer;

/**
 * Scan and connect the device
 *
 * @param macList user-bound MAC address list, in the form of a comma-separated string, such as "C8:FD:19:02:92:8D,C8:FD:19:02:92:8E"
 *
 * @return If the scan starts successfully, return true, otherwise return false
 */
- (BOOL)connectThermometerWithMACList:(NSString *)macList;

/**
 * Stop scanning
 */
- (void)stopThermometerScan;

/**
 * Check firmware version
 *
 * @param completion Callback, return whether the currently connected hardware needs to be upgraded; if it needs to be upgraded, return the URL of the image file in imagePaths回调，返回当前连接的硬件是否需要升级；如果需要升级，在 imagePaths 里返回镜像文件的 URL
 */
- (void)checkFirmwareVersionCompletion:(void (^)(BOOL needUpgrade, NSDictionary * _Nullable imagePaths))completion;

/**
 * Start OAD
 *
 * @param imgPaths The path where the firmware installation package is located (side A and side B)
 */
- (void)updateThermometerFirmware:(NSArray <NSString *>*)imgPaths;

/**
 * Stop the ongoing OAD
 */
- (void)stopUpdateThermometerFirmwareImage;

/**
 * Modify the temperature type, obtain the power, return the received temperature quantity to the hardware, and start obtaining the temperature, etc.
 *
 * @param type command type
 */
- (void)pushNotifyWithType:(NSInteger)type;

@end

NS_ASSUME_NONNULL_END
