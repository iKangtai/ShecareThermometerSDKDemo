//
//  YCBindingThermometerModel.m
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15/2/2.
//  Copyright (c) 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCUserHardwareInfoModel.h"

@interface YCUserHardwareInfoModel()<NSCoding>

@end

@implementation YCUserHardwareInfoModel

-(instancetype)initWithMACAddress:(NSString *)macAddress version:(NSString *)version syncType:(BOOL)synced {
    if (self = [super init]) {
        self.macAddress = macAddress;
        self.hardwareVersion = version;
        self.syncType = @(synced);
    }
    return self;
}

+(instancetype)modelWithMACAddress:(NSString *)macAddress version:(NSString *)version syncType:(BOOL)synced {
    return [[self alloc] initWithMACAddress:macAddress version:version syncType:synced];
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.macAddress forKey:@"macAddress"];
    [aCoder encodeObject:self.hardwareVersion forKey:@"hardwareVersion"];
    [aCoder encodeObject:self.syncType forKey:@"syncType"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.macAddress = [aDecoder decodeObjectForKey:@"macAddress"];
        self.hardwareVersion = [aDecoder decodeObjectForKey:@"hardwareVersion"];
        self.syncType = [aDecoder decodeObjectForKey:@"syncType"];
    }
    return self;
}

-(UIImage *)hardwareImg {
    return [UIImage imageNamed:@"bind_img_1"];
}

-(NSString *)hardwareTitle {
    return @"孕橙智能基础体温计";
}

@end
