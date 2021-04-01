# ShecareThermometerSDKDemo

## Demo 

<http://fir.ikangtai.cn/kf21>

[English](README.md) | 中文文档

## 访问指南
### SDK 功能

| 功能                    |  描述       |
| ------------------------- | ------------      |
| 扫描附近的蓝牙设备          | 扫描手机附近的蓝牙设备，并每秒刷新设备列表 |
| 连接Shecare体温计以同步数据&nbsp;&nbsp;| 连接温度计以同步数据，设置温度计的温度单位和时间，并获取固件版本 |
| 连接Shecare额温枪同步数据&nbsp;&nbsp;| 连接额温枪同步数据并获取固件版本号 |
| 连接Shecare胎心仪同步数据&nbsp;&nbsp;| 连接胎心仪同步数据并获取固件版本号 |

### 集成注意事项

1. 最低兼容版本 iOS 11.0；
2. 需要引入 CoreBluetooth 系统库；

### 核心类定义

#### 核心服务类：SCBLEThermometer

```Objective-C
/// 由 `孕橙` 统一分配的应用唯一标识符，用于区分不同的集成方
@property (nonatomic, copy) NSString *appId;
/// 由 `孕橙` 统一分配的应用秘钥，用于 SDK 校验
@property (nonatomic, copy) NSString *appSecret;
/// 根据userId、手机号、邮箱之类信息生成用户的唯一ID，与试纸SDK生成的unionid相同
@property (nonatomic, copy) NSString *unionId;
/// 代理对象，需要实现 BLEThermometerDelegate、BLEThermometerOADDelegate 协议
@property (nonatomic, weak) id <BLEThermometerDelegate> delegate;
@property (nonatomic, weak) id <BLEThermometerOADDelegate> oadDelegate;

/** 单例 */
+(instancetype)sharedThermometer;

/**
 * 返回当前设备的 BLE 状态
 */
- (YCBLEState)bleState;

/**
 * 断开当前连接的设备
 */
- (void)disconnectActiveThermometer;

/**
 * 扫描并连接设备
 *
 * @param macList 用户绑定的 MAC 地址列表，形式为逗号分隔的字符串，如 “C8:FD:19:02:92:8D,C8:FD:19:02:92:8E”
 *
 * @return 如果成功开始扫描，返回 true，否则返回 false
 */
- (BOOL)connectThermometerWithMACList:(NSString *)macList;

/**
 * 停止扫描
 */
- (void)stopThermometerScan;

/**
 * Check firmware version
 *
 * @param completion 回调，返回当前连接的硬件是否需要升级；如果需要升级，在 imagePaths 里返回镜像文件的 URL
 */
- (void)checkFirmwareVersionCompletion:(void (^)(BOOL needUpgrade, NSDictionary * _Nullable imagePaths))completion;

/**
 * 开始 OAD
 *
 * @param imgPaths 固件安装包所在的路径（A面和B面）
 */
- (void)updateThermometerFirmware:(NSArray <NSString *>*)imgPaths;

/**
 * 停止正在进行的 OAD
 */
- (void)stopUpdateThermometerFirmwareImage;

/**
 * 修改温度类型、获取电量、给硬件返回接收到的温度数量 和 开始获取温度 等指令
 *
 * @param type 指令类型
 */
- (void)pushNotifyWithType:(NSInteger)type;

/**
 * 上传胎心记录
 */
- (void)uploadFetalHeartRecord:(SCBLEFHRecordModel *)record;

/**
 * 获取 “客服” 链接
 */
- (NSURL *)customerServiceURLWithModel:(SCBLECustomerServiceModel *)model;
```

#### SCBLEDefines

```Objective-C
///  指令类型：OAD
#define YCBLECommandTypeOAD       2
///  指令类型：获取电量
#define YCBLECommandTypeGetPower  3
///  指令类型：温度类型 ℃
#define YCBLECommandTypeSetUnitC  4
///  指令类型：温度类型 ℉
#define YCBLECommandTypeSetUnitF  5

///  硬件镜像版本
typedef NS_ENUM(NSInteger, YCBLEFirmwareImageType) {
    ///  未知版本
    YCBLEFirmwareImageTypeUnknown,
    ///  A 版本
    YCBLEFirmwareImageTypeA,
    ///  B 版本
    YCBLEFirmwareImageTypeB,
};

///  蓝牙连接类型
typedef NS_ENUM(NSInteger, YCBLEConnectType) {
    ///  绑定时的连接（可以连接所有设备）
    YCBLEConnectTypeBinding     = 0,
    ///  非绑定时的连接（只能连接 “已绑定” 的硬件）
    YCBLEConnectTypeNotBinding  = 1
};

///  蓝牙状态定义
typedef NS_ENUM(NSInteger, YCBLEState) {
    ///  BLE 可用
    YCBLEStatePoweredOn = 0,
    ///  未知状态
    YCBLEStateUnknown,
    ///  不支持 BLE
    YCBLEStateUnsupported,
    ///  用户未授权
    YCBLEStateUnauthorized,
    ///  BLE 关闭
    YCBLEStatePoweredOff,
    ///  Resetting
    YCBLEStateResetting
};

///  OAD 错误类型
typedef NS_ENUM(NSInteger, YCBLEOADResultType) {
    ///  OAD 成功结束
    YCBLEOADResultTypeSucceed   = 0,
    ///  PAD 失败（指令发送结束 2s 后，还没有断开连接）
    YCBLEOADResultTypeFailed    = 1,
    ///  OAD 正在运行
    YCBLEOADResultTypeIsRunning = 2,
};
```

#### Delegate

- BLEThermometerDelegate

```Objective-C
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
 *  @param result 指令发送结果 "success" or "fail" 
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didSynchronizeDate:(NSString *)result;

/**
 *  获取温度计电量结果的回调
 *  @param  thermometer 当前体温计实例
 *  @param  powerValue 电量
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didGetPower:(NSString *)powerValue;

/**
 *  设置温度类型结果的回调
 *  @param  thermometer 当前体温计实例
 *  @param result 指令发送结果 "success" or "fail" 
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didChangeTemperatureUnit:(NSString *)result;

/**
 * 返回胎心仪相关数据
 * @param fhr 胎心率
 * @param fha 胎心音
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didGetFHR:(NSInteger)fhr fha:(NSData *)fha;
```

- BLEThermometerOADDelegate


```Objective-C
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
```

### 其他类定义
```Objective-C
@interface SCBLECustomerServiceModel: NSObject

/// 设备Mac地址,非必传
@property (nonatomic, copy) NSString *macAddress;
/// 年龄，非必传
@property (nonatomic, assign) NSInteger age;
/// 孕周,非必传
@property (nonatomic, assign) NSInteger pregnantWeek;
/// 设备类型, 1、2、3体温计，4 额温枪， 5 胎心仪 ,非必传
@property (nonatomic, assign) NSInteger hardwareType;
/// 购买时间，秒，非必传
@property (nonatomic, assign) NSTimeInterval bindTime;

@end

@interface SCBLEFHRecordModel : NSObject

/// 音频文件的二进制数据
@property (nonatomic, strong) NSData *audioData;
/// 音频文件后缀名
@property (nonatomic, copy) NSString *fileExtension;
/// 记录 ID
@property (nonatomic, copy) NSString *recordId;
/// 记录时长，单位 秒
@property (nonatomic, copy) NSString *duration;
/// 记录标题，推荐使用 “孕？周？天”
@property (nonatomic, copy) NSString *title;
/// 产生记录的时间
@property (nonatomic, strong) NSDate *recordTime;
/// 平均胎心率
@property (nonatomic, copy) NSString *averageFhr;
/// 胎动次数
@property (nonatomic, copy) NSString *quickening;
/// 胎心率和胎动的记录详情
@property (nonatomic, copy) NSString *history;

@end


@interface SCBLETemperature : NSObject

/// Temperature
@property (nonatomic, assign) double temperature;
/// The measure time
@property (nonatomic, copy) NSString *time;

@end
```
