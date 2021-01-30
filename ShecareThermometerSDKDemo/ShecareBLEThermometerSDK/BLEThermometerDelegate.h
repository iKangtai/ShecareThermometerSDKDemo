//
//  BLEThermometerDelegate.h
//  BasalTemperatureShow
//
//  Created by ikangtai on 13-7-14.
//  Copyright (c) 2013年 ikangtai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class ShecareBLEThermometer;
@class BLEEnumDefines;
@class YCTemperature;

@protocol BLEThermometerDelegate <NSObject>

@optional

#pragma mark link management

/**
 * 连接设备成功的回调
 */
-(void)bleDidConnectThermometer;

/**
 * 连接设备失败的回调
 */
-(void)bleDidFailedToConnectThermometer:(CBPeripheral *)thermometer;

/**
 * 断开与设备连接的回调
 */
-(void)bleDidDisconnectThermometer:(CBPeripheral *)thermometer error:(NSError*)error;

#pragma mark update value

/**
 *  温度测量完成的回调
 *  @param  temperature 测量温度
 *  @param  timestamp 测量时间
 *  @param  flag 温度测量标志位
 *  @param  firmwareVersion 固件版本
 */
-(void)thermometerDidUploadTemperature:(double)temperature timestamp:(NSDate*)timestamp endmeasureFlag:(YCBLEMeasureFlag)flag firmwareVersion:(NSString *)firmwareVersion;

/**
 *  温度测量完成的回调
 *  @param  temperatures  测量温度数组
 *  @param  firmwareVersion 固件版本
 */
-(void)thermometerDidUploadTemperatures:(NSArray <YCTemperature *>*)temperatures firmwareVersion:(NSString *)firmwareVersion;

/**
 *  固件版本的回调
 *  @param firmwareRevision 固件版本
 */
-(void)bleThermometerDidUpdateFirmwareRevision:(NSString*) firmwareRevision;

/**
 *  同步时间的回调
 *  @param type 指令发送结果
 */
-(void)bleThermometer:(ShecareBLEThermometer *)bleTherm didUpdateSynchronizationDateResult:(YCBLEWriteResult)type;

#pragma mark Bluetooth State monitoring

-(void)bleThermometerBluetoothDidUpdateState;

/**
 * 获取温度计电量结果的回调
 * @param powerValue 电量
 */
-(void)bleThermometerDidGetThermometerPower:(float)powerValue;
/**
 * 获取温度计 时间 的回调
 * @param time 时间字符串 e.g. 2020-11-30 12:00:00
 */
-(void)bleThermometerDidGetThermometerTime:(NSString *)time;
/**
 * 获取体温计 绑定结果 的回调
 * @param success 结果
 */
-(void)bleThermometerDidBindThermometer:(BOOL)success;
/**
 * 温度类型结果的回调
 * @param success 结果
 */
-(void)bleThermometerDidChangeTempTypeSucceed:(BOOL)success;
/**
 * 设置测温模式的回调
 * @param success 结果
 */
-(void)bleThermometerDidSetMeasureMode:(BOOL)success;
/**
 * 获取体温计测温模式的回调
 * @param mode 测温模式
 */
-(void)bleThermometerDidGetMeasureMode:(BLEMeasureMode)mode;
/**
 * 获取体温计预热时间和测温时间，单位s
 * @param measure 测温时间
 * @param warmup 预热时间
 */
-(void)bleThermometerDidGetMeasureTime:(NSInteger)measure warmupTime:(NSInteger)warmup;
/**
 * 设置预热时间的回调
 * @param success 结果
 */
-(void)bleThermometerDidSetWarmupTime:(BOOL)success;
/**
 * 设置测温时间的回调
 * @param success 结果
 */
-(void)bleThermometerDidSetMeasureTime:(BOOL)success;
/**
 * 清空温度的回调
 * @param success 结果
 */
-(void)bleThermometerDidClearDatas:(BOOL)success;
/**
 * mac地址的回调
 * @param macAddress mac地址
 */
-(void)bleThermometerDidGetMACAddress:(NSString*)macAddress;

@required

@end

@protocol BLEThermometerOADDelegate <NSObject>

@required

/**
 * 用户硬件镜像版本的回调
 * @param imgReversion 用户硬件镜像版本
 */
-(void)bleThermometerDidReadFirmwareImageType:(YCBLEFirmwareImageType)imgReversion;

/**
 * 开始镜像文件写入的回调
 */
-(void)bleThermometerDidBeginUpdateFirmwareImage;

/**
 * 完成镜像文件写入的回调
 * @param type  OAD 错误类型
 * @param message OAD 错误信息
 */
-(void)bleThermometerDidUpdateFirmwareImage:(YCBLEOADResultType)type message:(NSString *)message;

/**
 * 镜像文件写入进度的回调
 * @param progress 完成进度
 */
-(void)bleThermometerUpdateFirmwareImageProgress:(CGFloat)progress;

/**
 * 设备连接状态的回调
 * @param isOn 连接状态
 */
-(void)bleThermometerDidOnOTAStatus:(BOOL)isOn;

@optional

@end
