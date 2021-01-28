//
//  YCDatePickerView.m
//  Shecare
//
//  Created by songliu on 13-8-10.
//  Copyright (c) 2013年 X-Lab. All rights reserved.
//

#import "YCDatePickerView.h"

@implementation YCDatePickerView

+(instancetype)timePickerWithMaxTime:(NSDate *)maxTime minTime:(NSDate *)minTime {
    YCDatePickerView *dateP = [[self alloc] initWithDatePickerModel:UIDatePickerModeTime];
    dateP.datePicker.maximumDate = maxTime;
    dateP.datePicker.minimumDate = minTime;
    dateP.cancelSelect = nil;
    return dateP;
}

+(instancetype)datePickerWithMaxDate:(NSDate *)maxDate minDate:(NSDate *)minDate {
    YCDatePickerView *dateP = [[self alloc] initWithDatePickerModel:UIDatePickerModeDate];
    dateP.datePicker.maximumDate = maxDate;
    dateP.datePicker.minimumDate = minDate;
    dateP.cancelSelect = nil;
    return dateP;
}

+(instancetype)dateTimePickerWithMaxDate:(NSDate *)maxDate minDate:(NSDate *)minDate {
    YCDatePickerView *dateP = [[self alloc] initWithDatePickerModel:UIDatePickerModeDateAndTime];
    dateP.datePicker.maximumDate = maxDate;
    dateP.datePicker.minimumDate = minDate;
    dateP.cancelSelect = nil;
    return dateP;
}

- (id)initWithDatePickerModel:(UIDatePickerMode)datePickerModel {
    if (self = [super initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kPickerViewHeight)]) {
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kPickerViewHeight)];
        [self addSubview:self.contentView];
        
        [self.datePicker setDatePickerMode:datePickerModel];
    }
    return self;
}

-(UIDatePicker *)datePicker {
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, kTopBarHeight, kScreenWidth, kPickerViewHeight - kTopBarHeight)];
        if (@available(iOS 13.4, *)) {
            _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        _datePicker.locale = [NSLocale currentLocale];
        [_datePicker setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_datePicker];
        _datePicker.translatesAutoresizingMaskIntoConstraints = false;
        [_datePicker.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:kTopBarHeight].active = true;
        [_datePicker.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:0].active = true;
        [_datePicker.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:0].active = true;
        [_datePicker.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:0].active = true;
    }
    return _datePicker;
}

- (void)confirmBtnClick:(UIBarButtonItem *)sender {
    [super confirmBtnClick:sender];
    
    // 保证输出结果不 “超限”
    if ([self.datePicker.date compare:self.datePicker.maximumDate] == NSOrderedDescending) {
        self.datePicker.date = self.datePicker.maximumDate;
    }
    if ([self.datePicker.date compare:self.datePicker.minimumDate] == NSOrderedAscending) {
        self.datePicker.date = self.datePicker.minimumDate;
    }
    
    if (self.finishSelect != nil) {
        self.finishSelect(self);
    }
    [self untrigger];
}

-(void)cancelBtnClick {
    [super cancelBtnClick];
    
    if (self.cancelSelect != nil) {
        self.cancelSelect();
    }
    [self untrigger];
}

-(void)dealloc {
    NSLog(@"----%@--%s", [self class], __FUNCTION__);
}

@end
