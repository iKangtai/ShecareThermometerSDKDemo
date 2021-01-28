//
//  YCUserTemperatureModel.m
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15/11/5.
//  Copyright © 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCUserTemperatureModel.h"

@interface YCUserTemperatureModel()<NSCoding>

@end

@implementation YCUserTemperatureModel

- (instancetype)initWithTemperature:(NSNumber *)temperature time:(NSDate *)time type:(NSNumber *)type temperatureID:(NSString *)temperatureID {
    if (self = [super init]) {
        self.temperature = temperature;
        self.measureTime = time;
        self.type = type;
        self.temperatureID = temperatureID;
    }
    return self;
}

+ (instancetype)modelWithTemperature:(NSNumber *)temperature time:(NSDate *)time type:(NSNumber *)type temperatureID:(NSString *)temperatureID {
    return [[self alloc] initWithTemperature:temperature time:time type:type temperatureID: temperatureID];
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.temperature forKey:@"temperature"];
    [coder encodeObject:self.measureTime forKey:@"measureTime"];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.temperatureID forKey:@"temperatureID"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.temperature = [coder decodeObjectForKey:@"macAddress"];
        self.measureTime = [coder decodeObjectForKey:@"measureTime"];
        self.type = [coder decodeObjectForKey:@"type"];
        self.temperatureID = [coder decodeObjectForKey:@"temperatureID"];
    }
    return self;
}

-(NSString *)temperatureString {
    if (self.temperature == nil) {
        return @"";
    }
    float tempValue = [self.temperature doubleValue];
    return [NSString stringWithFormat:@"%.2f℃", tempValue];
}

@end
