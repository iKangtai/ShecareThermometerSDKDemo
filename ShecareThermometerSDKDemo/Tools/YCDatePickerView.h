//
//  YCDatePickerView.h
//  Shecare
//
//  Created by songliu on 13-8-10.
//  Copyright (c) 2013年 X-Lab. All rights reserved.
//

#import "YCPickerView.h"


@interface YCDatePickerView : YCPickerView

@property (nonatomic, strong) UIDatePicker *datePicker;
///  完成选择的回调
@property (nonatomic, copy) void (^finishSelect)(YCDatePickerView *pickerView);
///  取消选择的回调
@property (copy, nonatomic) void (^cancelSelect)(void);

+ (instancetype)timePickerWithMaxTime:(NSDate *)maxTime minTime:(NSDate *)minTime;
///  日期选择器，maxDate 和 minDate 传入 nil，表示不限制
+ (instancetype)datePickerWithMaxDate:(NSDate *)maxDate minDate:(NSDate *)minDate;
+ (instancetype)dateTimePickerWithMaxDate:(NSDate *)maxDate minDate:(NSDate *)minDate;

@end

