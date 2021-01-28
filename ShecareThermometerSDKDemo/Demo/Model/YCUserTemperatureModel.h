//
//  YCUserTemperatureModel.h
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15/11/5.
//  Copyright © 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YCUserTemperatureModel : NSObject

///  测量时间
@property (nonatomic, strong) NSDate *measureTime;
///  温度数值
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, copy) NSString *temperatureID;
///  用户存储时的温度类型，0 摄氏度 1 华氏度
@property (nonatomic, strong) NSNumber *type;

+ (instancetype)modelWithTemperature:(NSNumber *)temperature time:(NSDate *)time type:(NSNumber *)type temperatureID:(NSString *)temperatureID;

-(NSString *)temperatureString;

@end
