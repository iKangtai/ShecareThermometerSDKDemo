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

@interface SCBLECustomerServiceModel: NSObject

/// Device MAC address, optional.
@property (nonatomic, copy) NSString *macAddress;
/// Age, optional.
@property (nonatomic, assign) NSInteger age;
/// Gestational age in weeks, optional.
@property (nonatomic, assign) NSInteger pregnantWeek;
/// Device type, optional: 1, 2, 3. Digital thermometer, 4. Forehead thermometer, 5. Fetal heart monitor.
@property (nonatomic, assign) NSInteger hardwareType;
/// Purchase time in seconds, optional.
@property (nonatomic, assign) NSTimeInterval bindTime;

@end

@interface SCBLEFHRecordModel : NSObject

/// Binary data of an audio file
@property (nonatomic, strong) NSData *audioData;
/// Audio file extension
@property (nonatomic, copy) NSString *fileExtension;
/// Record Id
@property (nonatomic, copy) NSString *recordId;
/// Recording duration in seconds
@property (nonatomic, copy) NSString *duration;
/// Recording title, recommended format: "? Week? Day"
@property (nonatomic, copy) NSString *title;
/// The time when the record was created
@property (nonatomic, strong) NSDate *recordTime;
/// Average fetal heart rate
@property (nonatomic, copy) NSString *averageFhr;
/// Fetal movement count
@property (nonatomic, copy) NSString *quickening;
/// Detailed record of fetal heart rate and movement
@property (nonatomic, copy) NSString *history;

@end


@interface SCBLETemperature : NSObject

/// Temperature
@property (nonatomic, assign) double temperature;
/// The measure time
@property (nonatomic, copy) NSString *time;

@end


@interface SCBLEThermometer : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

/// A unique application identifier, uniformly assigned by YunCheng, used to distinguish different integration parties.
@property (nonatomic, copy) NSString *appId;
/// A unified application secret key distributed by YunCheng for SDK verification.
@property (nonatomic, copy) NSString *appSecret;
/// To align with the test strip SDK, a unique user ID.
@property (nonatomic, copy) NSString *unionId;
/// Base URL for SDK calls to the server-side interface. If not set, the built-in default will be used.
@property (nonatomic, copy) NSString *baseURL;

///  Delegate
@property (nonatomic, weak) id <BLEThermometerDelegate> delegate;
///  OAD Delegate
@property (nonatomic, weak) id <BLEThermometerOADDelegate> oadDelegate;
///  Currently connected Bluetooth device
@property (nonatomic, strong, nullable) CBPeripheral *activePeripheral;
///  Type of Bluetooth connection
@property (nonatomic, assign) YCBLEConnectType connectType;
///  Firmware Version
@property (nonatomic, copy) NSString *firmwareVersion;
///  Image Type, used for OAD
@property (nonatomic, assign) YCBLEFirmwareImageType imageType;
///  MAC Address
@property (nonatomic, copy) NSString *macAddress;
///  Hardware Name
@property (copy, nonatomic) NSString *hardwareName;
///  Is an OAD in progress
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
 */
- (void)connectThermometerWithMACList:(NSString *)macList;

/**
 * Stop scanning
 */
- (void)stopThermometerScan;

/**
 * Check firmware version
 *
 * @param completion Callback, return whether the currently connected hardware needs to be upgraded; if it needs to be upgraded, return the URL of the image file in imagePaths.
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

/**
 * Upload fetal heart rate data
 */
- (void)uploadFetalHeartRecord:(SCBLEFHRecordModel *)record;

/**
 * Get the "customer service" link.
 */
- (NSURL *)customerServiceURLWithModel:(SCBLECustomerServiceModel *)model;

@end

NS_ASSUME_NONNULL_END
