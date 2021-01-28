//
//  YCUtility.h
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15-1-8.
//  Copyright (c) 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//


#import <UIKit/UIKit.h>

@class YCUserHardwareInfoModel;
@class YCUserTemperatureModel;

@interface YCUtility : NSObject

///  控制器通用返回按钮
+ (UIBarButtonItem *)navigationBackItemWithTarget:(id)target action:(SEL)action;
///  生成一个个唯一编码
+ (NSString *)generateUniqueIdentifier;

///  保存 Temperature Info 地址
+ (void)addTemperatureInfoToLocal:(YCUserTemperatureModel *)temperatureInfo;
///  获取保存的 TemperatureInfo 列表
+ (NSArray <YCUserTemperatureModel *>*)temperatureInfoList;

///  保存 Hardware Info 地址
+ (void)addHardwareInfoToLocal:(YCUserHardwareInfoModel *)hardwareInfo;
///  获取绑定的 MAC 列表
+ (NSString *)bindedMACAddressList;
///  获取固件的镜像文件夹路径
+ (NSString *)firmwareImageFolderPath;
///  获取对应固件版本、固件镜像版本的 OAD 文件路径
+ (NSString *)firmwareImagePath:(NSString *)firmwareVersion;
///  为文件增加一个扩展属性
+ (BOOL)extendedWithPath:(NSString *)path key:(NSString *)key value:(NSData *)value;
///  读取文件扩展属性
+ (NSData *)extendedWithPath:(NSString *)path key:(NSString *)key;
///  版本号比较
+ (NSComparisonResult)compareVersion:(NSString *)version1 and:(NSString *)version2;

///  APP 是否成功绑定了体温计设备
+ (BOOL)isAppBindThermometerSuccessed;
///  APP 是否成功绑定了硬件设备
+ (BOOL)isAppBindHardwareSuccessed;

///  让 APP 打开指定 URL
+ (void)handleOpenURL:(NSURL *)url;
///  打开控制器
+ (void)showVC:(UIViewController *)vc;

///  判断是否是iPhone X 系列
+ (BOOL)isiPhoneXSeries;

@end
