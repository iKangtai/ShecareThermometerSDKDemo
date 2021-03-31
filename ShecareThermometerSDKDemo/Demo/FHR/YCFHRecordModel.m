//
//  YCFHRecordobject.m
//  Shecare
//
//  Created by MacBook Pro 2016 on 2020/11/18.
//  Copyright © 2020 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCFHRecordModel.h"
#import "NSJSONSerialization+YCExtension.h"

@implementation YCFHRecordModel

-(instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        //  从服务器下载的记录
        self.syncType = @(1);
        self.recordID = dict[@"uniqueId"];
        self.createTime = [NSDate dateWithTimeIntervalSince1970:[dict[@"recordCreateTime"] longLongValue]];
        self.gmtUpdateTime = [NSDate dateWithTimeIntervalSince1970:[dict[@"gmtUpdateTime"] longLongValue]];
        self.deleted = @([dict[@"disabled"] boolValue]);
        self.history = dict[@"history"];
        self.quickening = @([dict[@"quickening"] integerValue]);
        self.averageFhr = @([dict[@"averageFhr"] integerValue]);
        self.audio = dict[@"audio"];
        self.duration = @([dict[@"duration"] integerValue]);
        self.userAccount = @"demo@example.com";
    }
    return self;
}

+(instancetype)modelWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

-(instancetype)initWithValues:(NSArray *)values moves:(NSArray *)moves {
    if (self = [super init]) {
        self.syncType = @(0);
        self.recordID = [YCUtility generateUniqueIdentifier];
        self.deleted = @(0);
        self.history = [self historyWithValues:values moves:moves];
        self.userAccount = @"demo@example.com";
        self.createTime = [NSDate date];
    }
    return self;
}

-(NSString *)historyWithValues:(NSArray *)values moves:(NSArray *)moves {
    NSMutableDictionary *records = [NSMutableDictionary dictionary];
    records[@"v"] = values;
    records[@"qn"] = moves;
    return [NSJSONSerialization stringWithDictionary:records];
}

+(YCFHRecordModel *)modelWithValues:(NSArray *)values moves:(NSArray *)moves {
    return [[self alloc] initWithValues:values moves:moves];
}

+(NSArray <YCFHRecordModel *>*)modelsWithDicts:(NSArray<NSDictionary *> *)dicts {
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:dicts.count];
    for (NSDictionary *dict in dicts) {
        YCFHRecordModel *rModel = [self modelWithDict:dict];
        [arrayM addObject:rModel];
    }
    return arrayM.copy;
}

- (NSDictionary *)modelToDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.recordID forKey:@"uniqueId"];
    [dict setValue:@((long)[self.createTime timeIntervalSince1970]) forKey:@"recordCreateTime"];
//    [dict setValue:@([self.gmtUpdateTime timeIntervalSince1970]) forKey:@"gmtUpdateTime"];
    [dict setValue:self.history forKey:@"history"];
    [dict setValue:self.audio forKey:@"audio"];
//    NSDictionary *valDict = [NSJSONSerialization dictionaryWithString:self.history];
//    NSArray *values = valDict[@"v"];
//    NSArray *moves = valDict[@"qn"];
//    [dict setValue:@(values.count) forKey:@"duration"];
//    [dict setValue:@([self calcAverageFhr:values]) forKey:@"averageFhr"];
//    [dict setValue:@(moves.count) forKey:@"quickening"];
    [dict setValue:(self.duration ?: @0) forKey:@"duration"];
    [dict setValue:(self.averageFhr ?: @0) forKey:@"averageFhr"];
    [dict setValue:(self.quickening ?: @0) forKey:@"quickening"];
    [dict setValue:self.deleted forKey:@"disabled"];
    return dict.copy;
}

-(NSInteger)calcAverageFhr:(NSArray *)values {
    NSInteger sum = 0;
    NSInteger count = 0;
    for (NSNumber *numI in values) {
        if (numI.integerValue > 0) {
            sum += numI.integerValue;
            count++;
        }
    }
    return count == 0 ? 0 : (sum / count);
}

+(NSArray<NSDictionary *> *)modelsToDicts:(NSArray<YCFHRecordModel *> *)models {
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:models.count];
    
    for (YCFHRecordModel *model in models) {
        NSDictionary *dict = [model modelToDict];
        [arrayM addObject:dict];
    }
    return arrayM.copy;
}

-(NSArray <NSNumber *>*)addNewValue:(NSInteger)fhr {
    NSDictionary *valDict = [NSJSONSerialization dictionaryWithString:self.history];
    NSMutableArray *valuesM = [NSMutableArray arrayWithArray:valDict[@"v"]];
    [valuesM addObject:@(fhr)];
    NSArray *moves = valDict[@"qn"];
    NSArray *result = valuesM.copy;
    self.history = [self historyWithValues:result moves:moves];
    self.duration = @(result.count / 2 + 1);
    self.averageFhr = @([self calcAverageFhr:result]);
    return result;
}

-(void)addNewMove:(NSInteger)index {
    NSDictionary *valDict = [NSJSONSerialization dictionaryWithString:self.history];
    NSMutableArray *movesM = [NSMutableArray arrayWithArray:valDict[@"qn"]];
    [movesM addObject:@(index)];
    NSArray *values = valDict[@"v"];
    self.history = [self historyWithValues:values moves:movesM.copy];
    self.quickening = @(movesM.count);
}

@end
