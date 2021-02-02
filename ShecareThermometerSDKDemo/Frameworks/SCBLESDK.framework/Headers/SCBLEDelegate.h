//
//  SCBLEDelegate.h
//  SCBLESDK
//
//  Created by ikangtai on 13-7-14.
//  Copyright (c) 2013年 ikangtai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SCBLEDefines.h"

@class SCBLEThermometer;
@class BLEEnumDefines;
@class SCBLETemperature;
@protocol BLEThermometerDelegate <NSObject>

@required
/**
 *  连接设备成功的回调
 *  @param  thermometer 当前体温计实例
 */
-(void)didConnectThermometer:(SCBLEThermometer *)thermometer ;

/**
 *  连接设备失败的回调
 *  @param  thermometer 当前体温计实例
 */
-(void)didFailedToConnectThermometer:(SCBLEThermometer *)thermometer;

/**
 *  与设备的连接异常断开的回调
 *  @param  thermometer 当前体温计实例
 */
-(void)didDisconnectThermometer:(SCBLEThermometer *)thermometer error:(NSError*)error;

/**
 *  设备蓝牙状态改变的回调
 *  @param  thermometer 当前体温计实例
 *  @param  state 更新后的蓝牙状态
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didUpdateBluetoothState:(YCBLEState)state;

/**
 *  温度测量完成的回调
 *  @param  thermometer 当前体温计实例
 *  @param  temperatures  测量温度数组
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didUploadTemperatures:(NSArray <SCBLETemperature *>*)temperatures;

@optional

/**
 *  同步时间的回调
 *  @param  thermometer 当前体温计实例
 *  @param  success 指令发送结果
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didSynchronizeDate:(BOOL)success;

/**
 *  获取温度计电量结果的回调
 *  @param  thermometer 当前体温计实例
 *  @param  powerValue 电量
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didGetPower:(float)powerValue;

/**
 *  设置温度类型结果的回调
 *  @param  thermometer 当前体温计实例
 *  @param  success 结果
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didChangeTemperatureUnit:(BOOL)success;


@end


@protocol BLEThermometerOADDelegate <NSObject>

@required

/**
 *  镜像文件开始写入的回调
 *  @param  thermometer 当前体温计实例
 */
-(void)thermometerDidBeginFirmwareImageUpdate:(SCBLEThermometer *)thermometer;

/**
 *  完成镜像文件写入的回调
 *  @param  thermometer 当前体温计实例
 *  @param  type  OAD 错误类型
 *  @param  message OAD 错误信息
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didUpdateFirmwareImage:(YCBLEOADResultType)type message:(NSString *)message;

/**
 *  镜像文件写入进度的回调
 *  @param  thermometer 当前体温计实例
 *  @param  progress 完成进度
 */
-(void)thermometer:(SCBLEThermometer *)thermometer firmwareImageUpdateProgress:(CGFloat)progress;

@optional

/**
 *  用户硬件镜像版本的回调。仅用于 OAD，不适用于 OTA
 *  @param  thermometer 当前体温计实例
 *  @param  imgReversion 用户硬件镜像版本
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didReadFirmwareImageType:(YCBLEFirmwareImageType)imgReversion;

/**
 *  设备电源连接状态的回调。四代体温计使用锂电池，OTA 时必须连接电源；三代体温计使用纽扣电池，不需要实现此代理方法。
 *  @param  thermometer 当前体温计实例
 *  @param  isOn 电源连接状态
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didGetOTAPowerStatus:(BOOL)isOn;

@optional

@end
