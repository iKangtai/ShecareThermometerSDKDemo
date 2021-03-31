//
//  YCUtility.m
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15-1-8.
//  Copyright (c) 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCUtility.h"
#import "YCUserHardwareInfoModel.h"
#import "YCUserTemperatureModel.h"
#include <sys/xattr.h>
#import "sys/sysctl.h"


@implementation YCUtility

+ (UIBarButtonItem *)navigationBackItemWithTarget:(id)target action:(SEL)action {
    UIBarButtonItem *result = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon_record"] style:UIBarButtonItemStylePlain target:target action:action];
    result.tintColor = [UIColor mainColor];
    result.accessibilityIdentifier = @"navigationBackItem";
    return result;
}

+ (NSString *)generateUniqueIdentifier {
    CFUUIDRef uniqueIdentifier = CFUUIDCreate(NULL);
    CFStringRef uniqueIdentifierString = CFUUIDCreateString(NULL, uniqueIdentifier);
    CFRelease(uniqueIdentifier);
    return CFBridgingRelease(uniqueIdentifierString);
}

+ (void)addTemperatureInfoToLocal:(YCUserTemperatureModel *)temperatureInfo {
    NSArray *oldInfos = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaults_UserTemperatureInfos];
    NSMutableArray *newInfos = [NSMutableArray array];
    [oldInfos enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (@available(iOS 11.0, *)) {
            YCUserTemperatureModel *modelI = [NSKeyedUnarchiver unarchivedObjectOfClass:[YCUserTemperatureModel class] fromData:obj error:nil];
            if (![modelI.temperatureID isEqualToString:temperatureInfo.temperatureID]) {
                [newInfos addObject:obj];
            }
        } else {
            YCUserTemperatureModel *modelI = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
            if (![modelI.temperatureID isEqualToString:temperatureInfo.temperatureID]) {
                [newInfos addObject:obj];
            }
        }
    }];
    if (@available(iOS 11.0, *)) {
        NSData *newInfoData = [NSKeyedArchiver archivedDataWithRootObject:temperatureInfo requiringSecureCoding:false error:nil];
        if (newInfoData != nil) {
            [newInfos addObject:newInfoData];
        }
    } else {
        NSData *newInfoData = [NSKeyedArchiver archivedDataWithRootObject:temperatureInfo];
        if (newInfoData != nil) {
            [newInfos addObject:newInfoData];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:newInfos forKey:kDefaults_UserTemperatureInfos];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray <YCUserTemperatureModel *>*)temperatureInfoList {
    NSArray *temperatureInfos = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaults_UserTemperatureInfos];
    if (temperatureInfos.count == 0) {
        return @[];
    }
    NSMutableArray *temperatureInfoList = [NSMutableArray array];
    for (NSData *data in temperatureInfos) {
        YCUserTemperatureModel *modelI = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [temperatureInfoList addObject:modelI];
    }
    return temperatureInfoList;
}

+ (void)addHardwareInfoToLocal:(YCUserHardwareInfoModel *)hardwareInfo {
    NSArray *oldInfos = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaults_UserHardwareInfos];
    NSMutableArray *newInfos = [NSMutableArray array];
    [oldInfos enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YCUserHardwareInfoModel *modelI = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
        if (![modelI.macAddress isEqualToString:hardwareInfo.macAddress]) {
            [newInfos addObject:obj];
        }
    }];
    NSData *newInfoData = [NSKeyedArchiver archivedDataWithRootObject:hardwareInfo];
    [newInfos addObject:newInfoData];
    
    [[NSUserDefaults standardUserDefaults] setObject:newInfos forKey:kDefaults_UserHardwareInfos];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)bindedMACAddressList {
    NSArray *bindedDatas = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaults_UserHardwareInfos];
    if (bindedDatas.count == 0) {
        return @"";
    }
    
    NSMutableString *macsStrM = [NSMutableString string];
    for (NSData *data in bindedDatas) {
        YCUserHardwareInfoModel *modelI = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [macsStrM appendFormat:@"%@,", modelI.macAddress];
    }
    return macsStrM.length > 1 ? [macsStrM substringToIndex:macsStrM.length-1] : @"";
}

+ (NSArray <YCUserHardwareInfoModel *>*)bindedDeviceModels {
    NSArray *bindedDatas = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaults_UserHardwareInfos];
    
    NSMutableArray *resultM = [NSMutableArray array];
    for (NSData *data in bindedDatas) {
        YCUserHardwareInfoModel *modelI = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [resultM addObject:modelI];
    }
    return resultM.copy;
}

+(void)removeDevice:(NSString *)macAddress {
    NSArray *oldInfos = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaults_UserHardwareInfos];
    NSMutableArray *newInfos = [NSMutableArray array];
    [oldInfos enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YCUserHardwareInfoModel *modelI = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
        if (![modelI.macAddress isEqualToString:macAddress]) {
            [newInfos addObject:obj];
        }
    }];
    if (newInfos.count > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:newInfos forKey:kDefaults_UserHardwareInfos];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDefaults_UserHardwareInfos];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)firmwareImageFolderPath {
    NSString *appDocumentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [appDocumentsFolder stringByAppendingPathComponent:@"firmware"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    return path;
}

+ (NSString *)firmwareImagePath:(NSString *)firmwareVersion {
    NSString *imgName = @"Athermometer.bin";
    NSString *appDocumentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [appDocumentsFolder stringByAppendingPathComponent:@"firmware"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *pathStr = [path stringByAppendingPathComponent:imgName];
    return pathStr;
}

+ (NSData *)extendedWithPath:(NSString *)path key:(NSString *)key {
    NSError *error = NULL;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if (!attributes) {
        return nil;
    }
    NSDictionary *extendedAttributes = [attributes objectForKey:@"NSFileExtendedAttributes"];
    if (!extendedAttributes) {
        return nil;
    }
    return [extendedAttributes objectForKey:key];
}

+ (BOOL)extendedWithPath:(NSString *)path key:(NSString *)key value:(NSData *)value {
    NSDictionary *extendedAttributes = [NSDictionary dictionaryWithObject:
                                        [NSDictionary dictionaryWithObject:value forKey:key]
                                                                   forKey:@"NSFileExtendedAttributes"];
    
    NSError *error = NULL;
    BOOL sucess = [[NSFileManager defaultManager] setAttributes:extendedAttributes ofItemAtPath:path error:&error];
    return sucess;
}

+ (BOOL)isAppBindThermometerSuccessed {
    NSArray *bindedDatas = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaults_UserHardwareInfos];
    return bindedDatas.count > 0;
}

+ (BOOL)isAppBindHardwareSuccessed {
    NSString *macList = [self bindedMACAddressList];
    return (macList.length >= 17);
}

+ (void)handleOpenURL:(NSURL *)url {
    if (url == nil) {
        return;
    }
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (void)showVC:(UIViewController *)vc {
    UIViewController *currentVC = [UIViewController currentViewController];
    [currentVC.navigationController pushViewController:vc animated:true];
}

+(BOOL)hasNotch {
    if (@available(iOS 11.0, *)) {
        CGFloat bottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
        return bottom > 0;
    } else {
        return false;
    }
}

+(NSString *)fhAudioWavPath:(NSString *)recordId {
    NSString *appDocumentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [appDocumentsFolder stringByAppendingPathComponent:@"baby-sound"];
    // 先创建子目录. 注意,若果直接调用AudioFileCreateWithURL创建一个不存在的目录创建文件会失败
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        NSLog(@"Error: %@", error);
    }
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav", recordId]];
    return filePath;
}

@end
