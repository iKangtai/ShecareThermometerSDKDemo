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
        YCUserTemperatureModel *modelI = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
        if (![modelI.temperatureID isEqualToString:temperatureInfo.temperatureID]) {
            [newInfos addObject:obj];
        }
    }];
    NSData *newInfoData = [NSKeyedArchiver archivedDataWithRootObject:temperatureInfo];
    [newInfos addObject:newInfoData];
    
    [[NSUserDefaults standardUserDefaults] setObject:newInfos forKey:kDefaults_UserTemperatureInfos];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_DidSaveHardwareTemperaturesToDB object:newInfos.copy];
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

+ (NSComparisonResult)compareVersion:(NSString *)version1 and:(NSString *)version2 {
    
    //  if version1 is newest  than version2 or the same with version2 , return YES, else return NO
    float F1 = [version1 floatValue];
    float F2 = [version2 floatValue];
    
    if (F1 - F2 > 10e-8) {
        return NSOrderedDescending;
    }
    else if (fabsf(F1 - F2) >= 0 && fabsf(F1 - F2) < 10e-8) {
        return NSOrderedSame;
    }
    
    return NSOrderedAscending;
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

+ (BOOL)isiPhoneXSeries {
#if TARGET_IPHONE_SIMULATOR
    return (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 896)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(896, 414)));
#else
    return [[self getDevicePlatform] hasPrefix:@"iPhone X"] || [[self getDevicePlatform] hasPrefix:@"iPhone 11"];
#endif
}

+ (NSString*)getDevicePlatform {
    //  系统的版本号
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *platform = [NSString stringWithFormat:@"%@ %@", [self deviceInfoWithPlatform:[self getMachineInfo]], systemVersion];
    return platform;
}

+ (NSString *)getMachineInfo {
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+ (NSString *)deviceInfoWithPlatform:(NSString *)platform {
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524/A1593)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586/A1589)";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s (A1633/A1688/A1691/A1700)";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus (A1634/A1687/A1690/A1699)";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE (A1662/A1723/A1724)";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7 (A1660/A1779/A1780)";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus (A1661/A1785/A1786)";
    if ([platform isEqualToString:@"iPhone9,3"]) return @"iPhone 7 (A1778)";
    if ([platform isEqualToString:@"iPhone9,4"]) return @"iPhone 7 Plus (A1784)";
    if ([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    if ([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    if ([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone12,1"]) return @"iPhone 11";
    if ([platform isEqualToString:@"iPhone12,3"]) return @"iPhone 11 Pro";
    if ([platform isEqualToString:@"iPhone12,5"]) return @"iPhone 11 Pro Max";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288/A1319)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    if ([platform isEqualToString:@"iPod7,1"])   return @"iPod Touch 6G (A1574)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1 (A1219/A1337)";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1 (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1 (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1 (A1455)";
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2 (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2 (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2 (A1491)";
    if ([platform isEqualToString:@"iPad4,7"])   return @"iPad Mini 3 (A1599)";
    if ([platform isEqualToString:@"iPad4,8"])   return @"iPad Mini 3 (A1600)";
    if ([platform isEqualToString:@"iPad4,9"])   return @"iPad Mini 3 (A1601)";
    if ([platform isEqualToString:@"iPad5,1"])   return @"iPad Mini 4 (A1538)";
    if ([platform isEqualToString:@"iPad5,2"])   return @"iPad Mini 4 (A1550)";
    if ([platform isEqualToString:@"iPad5,3"])   return @"iPad Air 2 (A1566)";
    if ([platform isEqualToString:@"iPad5,4"])   return @"iPad Air 2 (A1567)";
    if ([platform isEqualToString:@"iPad6,7"])   return @"iPad Pro (12.9 inch) (A1584)";
    if ([platform isEqualToString:@"iPad6,8"])   return @"iPad Pro (12.9 inch) (A1652)";
    if ([platform isEqualToString:@"iPad6,3"])   return @"iPad Pro (9.7 inch) (A1673)";
    if ([platform isEqualToString:@"iPad6,4"])   return @"iPad Pro (9.7 inch) (A1674/A1675)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return @"iOS UnKnown Platform";
}

@end
