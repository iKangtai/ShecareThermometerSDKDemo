//
//  YCBindingThermometerModel.h
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15/2/2.
//  Copyright (c) 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YCUserHardwareInfoModel : NSObject

@property (copy, nonatomic) NSString *macAddress;

@property (copy, nonatomic) NSString *hardwareVersion;

@property (strong, nonatomic) NSNumber *syncType;

+ (instancetype)modelWithMACAddress:(NSString *)macAddress version:(NSString *)version syncType:(BOOL)synced;

-(UIImage *)hardwareImg;
-(NSString *)hardwareTitle;

@end
