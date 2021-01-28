//
//  NSDate+Utilities.m
//  Thermometer
//
//  Created by songliu on 13-7-30.
//  Copyright (c) 2013年 X-Lab. All rights reserved.
//

#import "NSDate+YCUtilities.h"

@interface NSCalendar (YCUtilities)

+ (instancetype)gregorianCalendar;

@end

@implementation NSDate (YCUtilities)

- (NSDateComponents *)dateComponents {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    NSInteger unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitWeekday|NSCalendarUnitWeekOfYear|NSCalendarUnitWeekOfMonth|NSCalendarUnitNanosecond;
    NSDateComponents *comp = [calendar components:unitFlag fromDate:self];
    comp.nanosecond = 0;
    
    return comp;
}

- (NSInteger)year {
    return [[self dateComponents] year];
}

- (NSInteger)month {
    return [[self dateComponents] month];
}

- (NSInteger)day {
    return [[self dateComponents] day];
}

- (NSInteger)weekday {
    return [[self dateComponents] weekday];
}

- (NSInteger)weekOfYear {
    return [[self dateComponents] weekOfYear];
}

- (NSInteger)hour {
    return [[self dateComponents] hour];
}

- (NSInteger)minute {
    return [[self dateComponents] minute];
}

- (NSInteger)second {
    return [[self dateComponents] second];
}

#pragma mark - date return

- (NSDate *)dayBeginning {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    //  需要去掉 纳秒 的影响
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:self];
    components.hour = 0;
    return [calendar dateFromComponents:components];
}

- (NSDate *)dayEnding {
    return [[self dayBeginning] dateByAddingTimeInterval:24 * 3600];
}

- (NSDate *)dayCenter {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:self];
    components.hour = 12;
    return [calendar dateFromComponents:components];
}

- (NSDate *)weekBegin {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday|NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear|NSCalendarUnitHour fromDate:self];
    if (components.weekday == 1) {
        return self.dayCenter;
    }
    NSDateComponents *firstDayOfWeek = [[NSDateComponents alloc] init];
    firstDayOfWeek.hour = 12;
    firstDayOfWeek.weekday = 1;
    firstDayOfWeek.weekOfYear = components.weekOfYear;
    firstDayOfWeek.yearForWeekOfYear = components.yearForWeekOfYear;
    return [calendar dateFromComponents:firstDayOfWeek];
}

- (NSDate *)weekEnd {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday|NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear|NSCalendarUnitHour fromDate:self];
    if (components.weekday == 7) {
        return self.dayCenter;
    }
    NSDateComponents *lastDayOfWeek = [[NSDateComponents alloc] init];
    lastDayOfWeek.hour = 12;
    lastDayOfWeek.weekday = 7;
    lastDayOfWeek.weekOfYear = components.weekOfYear;
    lastDayOfWeek.yearForWeekOfYear = components.yearForWeekOfYear;
    return [calendar dateFromComponents:lastDayOfWeek];
}

- (NSDate *)monday {
    NSDate *beginningOfWeek = nil;
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    [calendar rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&beginningOfWeek
                 interval:NULL forDate:self];
    return [beginningOfWeek dateByAddingTimeInterval:24*3600];
}

- (NSDate *)nextMonday {
    NSDate *beginningOfWeek = nil;
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    [calendar rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&beginningOfWeek
                 interval:NULL forDate:self];
    return [beginningOfWeek dateByAddingTimeInterval:24*8*3600];
}

- (NSDate *)firstDayOfMonth {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth| NSCalendarUnitDay fromDate:self];
    components.day = 1;
    return [calendar dateFromComponents:components];
}

- (NSDate *)lastDayOfMonth {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    components.month++;
    components.day = 0;
    return [calendar dateFromComponents:components];
}

- (NSDate *)firstDayOfLastMonth {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    components.day = 1;
    components.month -= 1;
    if (components.month <= 0) {
        components.month = 12;
        components.year -= 1;
    }
    
    return [calendar dateFromComponents:components];
}

- (NSDate *)firstDayOfNextMonth {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    components.day = 1;
    components.month += 1;
    if (components.month > 12) {
        components.month = 1;
        components.year += 1;
    }
    
    return [calendar dateFromComponents:components];
}

- (NSDate *)dateToToday {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    NSDateComponents *dateComps = [calendar components:(NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:self];
    
    return [calendar dateByAddingComponents:dateComps toDate:[[NSDate date] dayBeginning] options:0];
}

#pragma mark - bool return

- (BOOL)isDayEqualTo:(NSDate *)theOtherDate {
    return [self.dayCenter isEqualToDate:theOtherDate.dayCenter];
}

- (BOOL)isMonthEqualTo:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    NSDateComponents *components1 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self];
    NSDateComponents *components2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
    return (components1.year == components2.year) && (components1.month == components2.month);
}

- (BOOL)isYearEqualTo:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    NSDateComponents *components1 = [calendar components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [calendar components:NSCalendarUnitYear fromDate:date];
    return components1.year == components2.year;
}

- (BOOL)isFutureDate {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    NSDateComponents *dateComps1 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    NSDateComponents *dateComps2 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    if (dateComps1.year > dateComps2.year) {
        return YES;
    } else if (dateComps1.year == dateComps2.year) {
        if (dateComps1.month > dateComps2.month) {
            return YES;
        } else if (dateComps1.month == dateComps2.month) {
            if (dateComps1.day > dateComps2.day) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - integer return

- (NSInteger)daysOfMonth {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    calendar.firstWeekday = 1;
    calendar.minimumDaysInFirstWeek = 7;
    
    NSRange dateRange = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    return dateRange.length;
}

- (NSInteger)firstDayWeekOfCurMonth {
    return [self firstDayOfMonth].weekday;
}

- (NSInteger)daysWithAnotherDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    //  需要去掉 时分秒 的影响
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                               fromDate:[date dayCenter]
                                                 toDate:[self dayCenter]
                                                options:0];
    return components.day;
}

#pragma mark - string return

- (NSString *)yyyyMMddDescString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    formatter.formatterBehavior = NSDateFormatterBehavior10_4;
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    return [formatter stringFromDate:self];
}

- (NSString *)shortTimeString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    formatter.formatterBehavior = NSDateFormatterBehavior10_4;
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    return [formatter stringFromDate:self];
}

- (NSString *)mmmdString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMMd" options:0 locale:[NSLocale localeWithLocaleIdentifier:@"zh"]];
    return [formatter stringFromDate:self];
}

- (NSString *)HHmmString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = @"HH:mm";
    
    return [formatter stringFromDate:self];
}

- (NSString *)HHmmssString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = @"HH:mm:ss";
    
    return [formatter stringFromDate:self];
}

- (NSString *)yyyyMdDotString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = @"yyyy.M.d";
    
    return [formatter stringFromDate:self];
}

- (NSString *)yyyyMMddString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    return [formatter stringFromDate:self];
}

- (NSString *)yyyyMMddWithoutZeroString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = @"yyyy-M-d";
    
    return [formatter stringFromDate:self];
}

- (NSString *)weekdayString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = @"EEEE";
    return [formatter stringFromDate:self];
}

- (NSString *)yyyyMMMString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyyMMM" options:0 locale:formatter.locale];
    return [formatter stringFromDate:self];
}

- (NSString *)yyMMMString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyMMM" options:0 locale:formatter.locale];
    return [formatter stringFromDate:self];
}

- (NSString *)yyyyMMddHHmmssString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    return [formatter stringFromDate:self];
}

- (NSString *)yyMMddHHmmString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = @"yyMMddHHmm";
    
    return [formatter stringFromDate:self];
}

- (NSString *)monthShortNameString {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM" options:0 locale:formatter.locale];
    return [formatter stringFromDate:self];
}

-(NSString *)stringWithFormatter:(NSString *)formatterStr {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:formatterStr options:0 locale:formatter.locale];
    return [formatter stringFromDate:self];
}

#pragma mark - class methods

+ (NSDate *)dateWeeklyWithAlarmTime:(NSDate *)alarmTime RepeatWeekday:(NSInteger)repeatWeekday {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    NSDateComponents *nowComp = [calendar components:(NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:now];
    
    NSInteger nowTimeCount = nowComp.hour*60*60 + nowComp.minute*60 + nowComp.second;
    NSInteger alarmTimeCount = alarmTime.hour*60*60 + alarmTime.minute*60 + alarmTime.second;
    
    NSInteger delayTime = (repeatWeekday - nowComp.weekday)*24*60*60 + alarmTimeCount;
    if ((repeatWeekday < nowComp.weekday) || ((repeatWeekday == nowComp.weekday) && (alarmTimeCount < nowTimeCount))) {
        delayTime += 7*24*60*60;
    }
    
    return [[now dayBeginning] dateByAddingTimeInterval:delayTime];
}

+ (NSDate *)dateWithyyyyMMddHHmmssString:(NSString *)yyyyMMddHHmmss {
    NSDateFormatter *formatter = [NSDateFormatter shareDateFormatter];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    return [formatter dateFromString:yyyyMMddHHmmss];
}

+ (NSInteger)calculateAgeFromDate:(NSDate *)date1 toDate:(NSDate *)date2 {
    NSCalendar *calendar = [NSCalendar gregorianCalendar];
    unsigned int unitFlags = NSCalendarUnitYear;
    NSDateComponents *components = [calendar components:unitFlags fromDate:date1 toDate:date2 options:0];
    NSInteger years = [components year];
    return years;
}

@end


@implementation NSDateFormatter (YCUtilities)

+ (instancetype)shareDateFormatter {
    // 这里如果使用 [NSThread currentThread].threadDictionary 实现 “线程单例”，则后续更新 locale 的时候，需要每个线程都独立更新
    static NSDateFormatter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSDateFormatter alloc] init];
        instance.locale = [NSLocale currentLocale];
    });
    return instance;
}

@end

const NSString *ycDateGregorianCalendar = @"YCDateGregorianCalendar";

@implementation NSCalendar (YCUtilities)

+ (instancetype)gregorianCalendar {
    NSMutableDictionary *threadDict = [NSThread currentThread].threadDictionary;
    NSCalendar *result = [threadDict objectForKey:ycDateGregorianCalendar];
    if (result == nil) {
        result = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        [threadDict setObject:result forKey:ycDateGregorianCalendar];
    }
    return result;
}

@end
