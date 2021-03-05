# ShecareThermometerSDKDemo

## Demo 

<http://fir.ikangtai.cn/kf21>

English | [中文文档](README_zh.md)

## Access Guide
### SDK features

| Function item                    |  Function description      |
| ------------------------- | ------------      |
| Scan for nearby Bluetooth devices          | Scan for Bluetooth devices near the phone and refresh the device list every second |
| Connect to Shecare thermometer to synchronize data&nbsp;&nbsp;&nbsp;&nbsp;| Connect the thermometer to synchronize data, set the thermometer temperature unit and time, and get the firmware version |

### Integration considerations

1. The minimum compatible version iOS 11.0;
2. Need to introduce CoreBluetooth system library;

### Class definition

#### Core service class: SCBLEThermometer

```Objective-C
/** Proxy object, need to implement BLEThermometerDelegate, BLEThermometerOADDelegate protocol */
@property (nonatomic, weak) id <BLEThermometerDelegate> delegate;
@property (nonatomic, weak) id <BLEThermometerOADDelegate> oadDelegate;

/** Singleton */
+(instancetype)sharedThermometer;

/**
 * Return the BLE status of the current device
 */
-(YCBLEState)bleState;

/**
 * Disconnect the currently connected device
 */
-(void)disconnectActiveThermometer;

/**
 * Scan and connect the device
 *
 * @param macList user-bound MAC address list, in the form of a comma-separated string, such as "C8:FD:19:02:92:8D,C8:FD:19:02:92:8E"
 *
 * @return If the scan starts successfully, return true, otherwise return false
 */
-(BOOL)connectThermometerWithMACList:(NSString *)macList;

/**
 * Stop scanning
 */
-(void)stopThermometerScan;

/**
 * Check firmware version
 *
 * @param completion Callback, return whether the currently connected hardware needs to be upgraded; if it needs to be upgraded, return the URL of the image file in imagePaths
 */
- (void)checkFirmwareVersionCompletion:(void (^)(BOOL needUpgrade, NSDictionary * _Nullable imagePaths))completion;

/**
 * Start OAD
 *
 * @param imgPaths The path where the firmware installation package is located (side A and side B)
 */
-(void)updateThermometerFirmware:(NSArray <NSString *>*)imgPaths;

/**
 * Stop the ongoing OAD
 */
-(void)stopUpdateThermometerFirmwareImage;

/**
 * Modify the temperature type, obtain the power, return the received temperature quantity to the hardware, and start obtaining the temperature, etc.
 *
 * @param cleanState command type
 */
-(void)setCleanState:(NSInteger)cleanState xx:(Byte)xx yy:(Byte)yy;

/**
 * Synchronize device time
 *
 * @param time Time
 */
- (void)synchroizeTime:(NSDate *)time;
```

#### SCBLEDefines

```Objective-C
/// Instruction type: OAD
#define YCBLECommandTypeOAD 2
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
```

#### Delegate

- BLEThermometerDelegate

```Objective-C
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
 * @param success command to send the result
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didSynchronizeDate:(BOOL)success;

/**
 * Get the callback of the thermometer power result
 * @param thermometer current thermometer example
 * @param powerValue power
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didGetPower:(float)powerValue;

/**
 * Set the callback of the temperature type result
 * @param thermometer current thermometer example
 * @param success result
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didChangeTemperatureUnit:(BOOL)success;
```

- BLEThermometerOADDelegate


```Objective-C
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
```
