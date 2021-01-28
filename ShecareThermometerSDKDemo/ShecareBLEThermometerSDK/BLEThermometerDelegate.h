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
 *  Invoked when system has connected the thermometer.
 */
-(void)bleDidConnectThermometer;
/**
 *  Invoked when system has failed to connect to the thermometer.
 */
-(void)bleDidFailedToConnectThermometer:(CBPeripheral *) thermometer;
/**
 *  Invoked when system has disconneted the conencted thermometer.
 */
-(void)bleDidDisconnectThermometer:(CBPeripheral *) thermometer error: (NSError*) error;

#pragma mark update value

/**
 *  Invoked when the temperature measurement has updated.
 *  @param  temperature the updated temperature measurement.
 *  @param  timestamp the timestamp of the measurement.
 *  @param  flag online/offline...
 *  @param  firmwareVersion the version of the firmware.
 */
-(void)thermometerDidUploadTemperature:(double)temperature timestamp:(NSDate*)timestamp endmeasureFlag:(YCBLEMeasureFlag)flag firmwareVersion:(NSString *)firmwareVersion;

-(void)thermometerDidUploadTemperatures:(NSArray <YCTemperature *>*)temperatures firmwareVersion:(NSString *)firmwareVersion;

/**
 *  Invoked when the firmware revision updated.
 *  @param firmwareRevision the firmware revision.
 */
-(void)bleThermometerDidUpdateFirmwareRevision:(NSString*) firmwareRevision;

-(void)bleThermometer:(ShecareBLEThermometer *)bleTherm didUpdateSynchronizationDateResult:(YCBLEWriteResult)type;

-(void)bleThermometerDidSetAlarm:(BOOL)success;

#pragma mark Bluetooth State monitoring

-(void)bleThermometerBluetoothDidUpdateState;

///  获取温度计电量结果的回调
-(void)bleThermometerDidGetThermometerPower:(float)powerValue;
///  获取温度计 时间 的回调
-(void)bleThermometerDidGetThermometerTime:(NSString *)time;
///  获取体温计 绑定结果 的回调
-(void)bleThermometerDidBindThermometer:(BOOL)success;
///  温度类型结果的回调
-(void)bleThermometerDidChangeTempTypeSucceed:(BOOL)success;

///  设置 测温模式 的回调
-(void)bleThermometerDidSetMeasureMode:(BOOL)success;
///  获取体温计测温模式的回调
-(void)bleThermometerDidGetMeasureMode:(BLEMeasureMode)mode;
///  获取体温计预热时间和测温时间，单位 s
-(void)bleThermometerDidGetMeasureTime:(NSInteger)measure warmupTime:(NSInteger)warmup;
///  设置预热时间的回调
-(void)bleThermometerDidSetWarmupTime:(BOOL)success;
///  设置测温时间的回调
-(void)bleThermometerDidSetMeasureTime:(BOOL)success;
///  清空温度的回调
-(void)bleThermometerDidClearDatas:(BOOL)success;
///  Invoked when the macAddress updated.
-(void)bleThermometerDidGetMACAddress:(NSString*)macAddress;

@required

@end

@protocol BLEThermometerOADDelegate <NSObject>

@required

-(void)bleThermometerDidReadFirmwareImageType:(YCBLEFirmwareImageType)imgReversion;

-(void)bleThermometerDidBeginUpdateFirmwareImage;

-(void)bleThermometerDidUpdateFirmwareImage:(YCBLEOADResultType)type message:(NSString *)message;

-(void)bleThermometerUpdateFirmwareImageProgress:(CGFloat)progress;

-(void)bleThermometerDidOnOTAStatus:(BOOL)isOn;

@optional

@end
