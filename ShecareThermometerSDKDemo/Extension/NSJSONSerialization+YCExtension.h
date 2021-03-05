//
//  NSJSONSerialization+YCExtension.h
//  Shecare
//
//  Created by mac on 2019/12/27.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSJSONSerialization(YCExtension)

+ (nullable NSDictionary *)dictionaryWithString:(NSString *)string;

+ (nullable NSArray *)arrayWithString:(NSString *)string;

+ (nullable NSString *)stringWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
