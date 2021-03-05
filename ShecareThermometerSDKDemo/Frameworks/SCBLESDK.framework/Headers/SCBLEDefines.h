//
//  BLEThermometerDefines.h
//  SCBLESDK
//
//  Created by ikangtai on 13-6-30.
//  Copyright (c) 2013年 ikangtai. All rights reserved.
//

#ifndef BasalTemperatureShow_BLEThermometerDefines_h
#define BasalTemperatureShow_BLEThermometerDefines_h

/// Instruction type: OAD
#define YCBLECommandTypeOAD      2
/// Instruction type: get power
#define YCBLECommandTypeGetPower 3
/// Instruction type: temperature type ℃
#define YCBLECommandTypeSetUnitC 4
/// Instruction type: temperature type ℉
#define YCBLECommandTypeSetUnitF 5

/// Hardware mirror version
typedef NS_ENUM(NSInteger, YCBLEFirmwareImageType) {
    /// Unknown version
    YCBLEFirmwareImageTypeUnknown,
    /// A version
    YCBLEFirmwareImageTypeA,
    /// B version
    YCBLEFirmwareImageTypeB,
};

/// Bluetooth connection type
typedef NS_ENUM(NSInteger, YCBLEConnectType) {
    /// Connection during binding (all devices can be connected)
    YCBLEConnectTypeBinding = 0,
    /// Connection when unbound (only "bound" hardware can be connected)
    YCBLEConnectTypeNotBinding = 1
};

/// Bluetooth status definition
typedef NS_ENUM(NSInteger, YCBLEState) {
    /// Powered on
    YCBLEStatePoweredOn = 0,
    /// Unknown status
    YCBLEStateUnknown,
    /// BLE is not supported
    YCBLEStateUnsupported,
    /// User not authorized
    YCBLEStateUnauthorized,
    /// BLE off
    YCBLEStatePoweredOff,
    /// Resetting
    YCBLEStateResetting
};

/// OAD error type
typedef NS_ENUM(NSInteger, YCBLEOADResultType) {
    /// OAD successfully ended
    YCBLEOADResultTypeSucceed = 0,
    /// PAD failed (2s after the command is sent, the connection has not been disconnected)
    YCBLEOADResultTypeFailed = 1,
    /// OAD is running
    YCBLEOADResultTypeIsRunning = 2,
};

#endif
