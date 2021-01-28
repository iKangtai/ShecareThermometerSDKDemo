//
//  ShecareBLEThermometer.h
//  ShecareBLEThermometer
//
//  Created by 北京爱康泰科技有限责任公司 on 16/8/2.
//  Copyright © 2016年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEThermometerDefines.h"
#import "BLEThermometerDelegate.h"

@interface YCTemperature : NSObject

/// Temperature
@property (nonatomic, assign) double temperature;
/// The measure time
@property (nonatomic, copy) NSString *time;
/// Flag
@property (nonatomic, assign) YCBLEMeasureFlag flag;

@end

@interface ShecareBLEThermometer : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

/// Use for CBCentralManagerOptionRestoreIdentifierKey. Different users have different values to avoid cross-multiplexing connections between each other
@property (nonatomic, copy) NSString *restoreIDKey;
///  call back delegate
@property (nonatomic, weak) id <BLEThermometerDelegate> delegate;
///  OAD Delegate
@property (nonatomic, weak) id <BLEThermometerOADDelegate> oadDelegate;
///  the active thermometer conencted to the local central
@property (nonatomic, strong) CBPeripheral *activeThermometer;
///  蓝牙连接类型
@property (nonatomic, assign) YCBLEConnectType connectType;
///  硬件版本信息
@property (nonatomic, copy) NSString *firmwareVersion;
///  ImageType，OAD 升级的时候使用
@property (nonatomic, assign) YCBLEFirmwareImageType image_type;
///  MAC Address
@property (nonatomic, copy) NSString *macAddress;
///  硬件名称
@property (copy, nonatomic) NSString *hardwareName;
///  是否正在 OAD
@property (assign, nonatomic) BOOL isOADing;
///  用于返回 蓝牙交互过程中 是否有 异常信息
@property (nonatomic, assign) BOOL bleError;

@property int suotaVersion;
@property int suotaMtu;
@property int suotaPatchDataSize;
@property int suotaL2CapPsm;


///  单例
+ (instancetype)sharedThermometer;

/**
 * 判断 CBPeripheral 是否是 A32 硬件
 */
- (BOOL)isA32:(CBPeripheral *)peripheral;

/**
 * 判断 CBPeripheral 是否是 A33 硬件
 */
- (BOOL)isA33:(CBPeripheral *)peripheral;

/**
 * 返回当前设备的 BLE 状态
 */
- (YCBLEState)bleState;

/**
 * Conenct to the specified thermometer.
 *
 * @param thermometer the specified thermometer.
 */
- (void)connectThermometer:(CBPeripheral *)thermometer;

/**
 * 断开当前连接的设备
 */
- (void)disconnectActiveThermometer;

/**
 * 检索 “系统已连接设备列表” 并连接满足 Service 条件的设备
 */
- (void)connectRetrievePeripherals;

/**
 * 扫描并连接设备
 *
 * @param macList 用户绑定的 MAC 地址列表，形式为逗号分隔的字符串，如 “C8:FD:19:02:92:8D,C8:FD:19:02:92:8E”
 *
 * @return 如果成功开始扫描，返回 true，否则返回 false
 */
- (BOOL)connectThermometerWithMACList:(NSString *)macList;

/**
 *  停止扫描
 */
- (void)stopThermometerScan;

/**
 *  开始 OAD
 *
 * @param imgPaths 固件安装包所在的路径（A面和B面）
 */
- (void)updateThermometerFirmware:(NSArray <NSString *>*)imgPaths;

/**
 *  停止正在进行的 OAD
 */
- (void)stopUpdateThermometerFirmwareImage;

/**
 * 清空温度、修改温度类型、获取电量、给硬件返回接收到的温度数量 和 开始获取温度 等指令
 *
 * @param cleanState 指令类型
 */
- (void)setCleanState:(YCBLECommandType)cleanState xx:(Byte)xx yy:(Byte)yy;

/**
 * 同步设备时间
 *
 * @param date 时间
 */
- (void)asynchroizationTimeFromLocal:(NSDate *)date;

@end
