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
 * Callback for successful connection of the device
 * @param thermometer current thermometer example
 */
-(void)didConnectThermometer:(SCBLEThermometer *)thermometer;

/**
 * Callback for failed device connection
 * @param thermometer current thermometer example
 */
-(void)didFailedToConnectThermometer:(SCBLEThermometer *)thermometer;

/**
 * Callback for abnormal disconnection from the device
 * @param thermometer current thermometer example
 */
-(void)didDisconnectThermometer:(SCBLEThermometer *)thermometer error:(NSError*)error;

/**
 * Callback for device Bluetooth status change
 * @param thermometer current thermometer example
 * @param state updated Bluetooth state
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didUpdateBluetoothState:(YCBLEState)state;

/**
 * Callback when temperature measurement is completed
 * @param thermometer current thermometer example
 * @param temperatures measure temperature array
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didUploadTemperatures:(NSArray <SCBLETemperature *>*)temperatures;

@optional

/**
 * Sync time callback
 * @param thermometer current thermometer example
 * @param result "success" or "fail" 
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didSynchronizeDate:(NSString *)result;

/**
 * Get the callback of the thermometer power result
 * @param thermometer current thermometer example
 * @param powerValue power
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didGetPower:(NSString *)powerValue;

/**
 * Set the callback of the temperature type result
 * @param thermometer current thermometer example
 * @param result "success" or "fail"
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didChangeTemperatureUnit:(NSString *)result;

/**
 * Return data from the fetal heart monitor
 * @param fhr fetal heart rate
 * @param fha fetal heart sound
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didGetFHR:(NSInteger)fhr fha:(NSData *)fha;

@end


@protocol BLEThermometerOADDelegate <NSObject>

@required

/**
 * Callback when the image file starts to be written
 * @param thermometer current thermometer example
 */
-(void)thermometerDidBeginFirmwareImageUpdate:(SCBLEThermometer *)thermometer;

/**
 * Completion of the callback for writing the image file
 * @param thermometer current thermometer example
 * @param type OAD error type
 * @param message OAD error message
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didUpdateFirmwareImage:(YCBLEOADResultType)type message:(NSString *)message;

/**
 * Callback of mirror file writing progress
 * @param thermometer current thermometer example
 * @param progress complete progress
 */
-(void)thermometer:(SCBLEThermometer *)thermometer firmwareImageUpdateProgress:(CGFloat)progress;

@optional

/**
 * Callback of the user's hardware mirroring version. Only for OAD, not for OTA
 * @param thermometer current thermometer example
 * @param imgReversion user hardware mirror version
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didReadFirmwareImageType:(YCBLEFirmwareImageType)imgReversion;

/**
 * Callback of device power connection status. The fourth-generation thermometer uses a lithium battery, and it must be connected to the power supply for OTA; the third-generation thermometer uses a button battery and does not need to implement this proxy method.
 * @param thermometer current thermometer example
 * @param isOn Power connection status
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didGetOTAPowerStatus:(BOOL)isOn;

@end
