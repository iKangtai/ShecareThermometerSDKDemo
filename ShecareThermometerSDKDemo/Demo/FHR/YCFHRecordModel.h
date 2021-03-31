//
//  YCFHRecordModel.h
//  Shecare
//
//  Created by MacBook Pro 2016 on 2020/11/18.
//  Copyright © 2020 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCFHRecordModel : NSObject

@property (nullable, nonatomic, copy) NSString *recordID;
/// 记录时长，单位 s
@property (nullable, nonatomic, copy) NSNumber *duration;
@property (nullable, nonatomic, copy) NSString *audio;
@property (nullable, nonatomic, copy) NSDate *createTime;
@property (nullable, nonatomic, copy) NSDate *gmtUpdateTime;
@property (nullable, nonatomic, copy) NSNumber *averageFhr;
@property (nullable, nonatomic, copy) NSNumber *quickening;
@property (nullable, nonatomic, copy) NSString *history;
@property (nullable, nonatomic, copy) NSNumber *syncType;
@property (nullable, nonatomic, copy) NSString *userAccount;
@property (nullable, nonatomic, copy) NSNumber *deleted;

- (NSDictionary *)modelToDict;

-(NSArray <NSNumber *>*)addNewValue:(NSInteger)fhr;
-(void)addNewMove:(NSInteger)index;

+(instancetype)modelWithValues:(NSArray *)values moves:(NSArray *)moves;

+(NSArray <YCFHRecordModel *>* _Nonnull)modelsWithDicts:(NSArray <NSDictionary *>*)dicts;

+(NSArray <NSDictionary *>*)modelsToDicts:(NSArray <YCFHRecordModel *>*)models;

@end

NS_ASSUME_NONNULL_END
