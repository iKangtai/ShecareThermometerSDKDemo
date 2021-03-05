//
//  NSJSONSerialization+YCExtension.m
//  Shecare
//
//  Created by mac on 2019/12/27.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "NSJSONSerialization+YCExtension.h"

@implementation NSJSONSerialization(YCExtension)

+(NSDictionary *)dictionaryWithString:(NSString *)string {
    // IS_EMPTY_STRING 内部有 “去除首尾空格” 后字符串是否为空的判断
    if (IS_EMPTY_STRING(string)) {
        return nil;
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length == 0) {
        return nil;
    }
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (nil == error) {
        return result;
    } else {
        NSLog(@"Error: %@", error);
        return nil;
    }
}

+(NSArray *)arrayWithString:(NSString *)string {
    // IS_EMPTY_STRING 内部有 “去除首尾空格” 后字符串是否为空的判断
    if (IS_EMPTY_STRING(string)) {
        return nil;
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length == 0) {
        return nil;
    }
    NSError *error = nil;
    NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (nil == error) {
        return result;
    } else {
        NSLog(@"Error: %@", error);
        return nil;
    }
}

+(NSString *)stringWithDictionary:(NSDictionary *)dict {
    NSError *error = nil;
    NSData *dictData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    if (nil == error) {
        return [[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding];
    } else {
        NSLog(@"Error: %@", error);
        return nil;
    }
}

@end
