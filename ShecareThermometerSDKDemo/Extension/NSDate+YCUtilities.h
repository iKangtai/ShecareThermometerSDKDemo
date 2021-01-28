//
//  NSDate+Utilities.h
//  Thermometer
//
//  Created by songliu on 13-7-30.
//  Copyright (c) 2013年 X-Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (YCUtilities)

@property (assign, nonatomic, readonly) NSInteger year;
@property (assign, nonatomic, readonly) NSInteger month;
@property (assign, nonatomic, readonly) NSInteger day;
@property (assign, nonatomic, readonly) NSInteger weekday;  //  （周日 == 1）
@property (assign, nonatomic, readonly) NSInteger weekOfYear;
@property (assign, nonatomic, readonly) NSInteger hour;
@property (assign, nonatomic, readonly) NSInteger minute;
@property (assign, nonatomic, readonly) NSInteger second;

#pragma mark - date return

///  返回当前日期 开始 的时间
- (NSDate *)dayBeginning;
///  返回当前日期 结束 的时间
- (NSDate *)dayEnding;
///  返回当前日期 “中午12点” 的时间
- (NSDate *)dayCenter;
///  返回当前日期星期 开始 的时间
- (NSDate *)weekBegin;
///  返回当前日期星期 结束 的时间
- (NSDate *)weekEnd;
///  返回当前日期的 星期一
- (NSDate *)monday;
///  返回当前日期 下一个月的 星期一
- (NSDate *)nextMonday;
///  返回当前日期的 月初
- (NSDate *)firstDayOfMonth;
///  返回当前日期的 月末
- (NSDate *)lastDayOfMonth;
///  返回当前日期 上一个月的 月初
- (NSDate *)firstDayOfLastMonth;
///  返回当前日期 下一个月的 月初
- (NSDate *)firstDayOfNextMonth;
///  get the date in today with the same min & sec as self.
- (NSDate *)dateToToday;

#pragma mark - bool return

///  判断两个日期是否是同一天
- (BOOL)isDayEqualTo:(NSDate *)date;
///  判断两个日期是同一个月的
- (BOOL)isMonthEqualTo:(NSDate *)date;
///  判断两个日期是同一年的
- (BOOL)isYearEqualTo:(NSDate *)date;
///  判断一个日期是否是将来的日期
- (BOOL)isFutureDate;

#pragma mark - integer return

///  计算当前日期月份有多少天
- (NSInteger)daysOfMonth;
///  当前日期所在的月份第一天是周几（周日 == 1）
- (NSInteger)firstDayWeekOfCurMonth;
///  获取距离 anotherDay 的天数（单位：天）
- (NSInteger)daysWithAnotherDate:(NSDate *)date;

#pragma mark - string return

///  get the "1990年09月10日" "Jun 1, 1989" like date string
- (NSString *)yyyyMMddDescString;
///  get the `12月9日/Dec 9` like date string.
- (NSString *)mmmdString;
///  get the 12:09 like time string of the current date.
- (NSString *)HHmmString;
///  get the 12:09 like time string of the current date and local.
- (NSString *)shortTimeString;
///  get the 12:09:30 like time string of the current date.
- (NSString *)HHmmssString;
///  get the "1990.9.9" like date string
- (NSString *)yyyyMdDotString;
///  get the 2015-09-11 like time string of the current date.
- (NSString *)yyyyMMddString;
///  get the 2015-9-1 like time string of the current date.
- (NSString *)yyyyMMddWithoutZeroString;
///  get the weekday string.
- (NSString *)weekdayString;
///  get the `2019年3月` like string.
- (NSString *)yyyyMMMString;
///  get the `19年3月` like string.
- (NSString *)yyMMMString;
///  get the 1908-12-09 12:09:08 like string.
- (NSString *)yyyyMMddHHmmssString;
///  get the 08-12-09 12:09 like string.
- (NSString *)yyMMddHHmmString;
///  get the month short name string
- (NSString *)monthShortNameString;
///  Get date and time string with a given formatter
- (NSString *)stringWithFormatter:(NSString *)formatterStr;

#pragma mark - class methods

///  get required weekday and the date in today with the same min & sec as self
+ (NSDate *)dateWeeklyWithAlarmTime:(NSDate *)alarmTime RepeatWeekday:(NSInteger)repeatWeekday;
///  get the date from the  1901-09-12 12:15:14 style String
+ (NSDate *)dateWithyyyyMMddHHmmssString: (NSString *)yyyyMMddHHmmss;
///  计算两个日期间的年龄
+ (NSInteger)calculateAgeFromDate:(NSDate *)date1 toDate:(NSDate *)date2;

@end

///  单例，避免频繁生成对象，影响性能

@interface NSDateFormatter (YCUtilities)

+ (instancetype)shareDateFormatter;

@end
