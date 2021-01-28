//
//  YCInputBBTView.m
//  Shecare
//
//  Created by mac on 2019/4/22.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCInputBBTView.h"
#import "YCInputBBTTextField.h"
#import "YCDatePickerView.h"

@interface YCInputBBTView ()

@property (nonatomic, assign) BOOL triggered;
@property (strong, nonatomic) UITextField *textField;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) YCGradientButton *saveBtn;
@property (nonatomic, strong) UILabel *chooseTimeLbl;
@property (nonatomic, strong) UILabel *dateLbl;
@property (nonatomic, strong) UILabel *timeLbl;
@property (nonatomic, strong) NSDate *inputMeasureTime;
@property (nonatomic, strong) YCInputBBTTextField *inputBBTTF;
@property (nonatomic, strong) YCDatePickerView *timePicker;
@property (nonatomic, strong) YCDatePickerView *datePicker;
@property (nonatomic, strong) UILabel *errorLbl;

@end

@implementation YCInputBBTView

-(instancetype)init {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        [self setupUI];
        self.inputMeasureTime = [NSDate date];
    }
    return self;
}

-(void)setInputMeasureTime:(NSDate *)inputMeasureTime {
    _inputMeasureTime = inputMeasureTime;
    
    NSString *dateStr = [NSString stringWithFormat:@"%@", [inputMeasureTime yyyyMMddDescString]];
    self.dateLbl.text = dateStr;
    
    NSString *timeStr = [NSString stringWithFormat:@"%@", [inputMeasureTime shortTimeString]];
    NSMutableAttributedString *timeStrM = [[NSMutableAttributedString alloc] initWithString:timeStr];
    [timeStrM appendAttributedString:[[NSAttributedString alloc] initWithString:@" ▼" attributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithHex:0xBFBFBF],
        NSFontAttributeName: [UIFont systemFontOfSize:10]
    }]];
    self.timeLbl.attributedText = timeStrM.copy;
}

-(NSInteger)numberCountWithText:(NSString *)text {
    if ([text hasPrefix:@"1"]) {
        return 5;
    }
    return 4;
}

-(CGFloat)bbtValue {
    CGFloat result = 0.0;
    NSUInteger numLength = [self numberCountWithText:self.textField.text];
    for (int i = 0; i < numLength; i++) {
        if (self.textField.text.length > i) {
            NSString *subStrI = [self.textField.text substringWithRange:NSMakeRange(i, 1)];
            int numberI = [subStrI intValue];
            result += numberI * pow(10, numLength - 1 - i);
        }
    }
    return result * 0.01;
}

-(void)setupUI {
    self.backgroundColor = RGBA(0, 0, 0, 0.6);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardInput:) name:UITextFieldTextDidChangeNotification object:nil];
    
    [self textField];
    [self contentView];
    [self saveBtn];
    [self dateLbl];
    [self errorLbl];
    [self inputBBTTF];
    
    // 点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressInAlertViewGesture:)];
    [self addGestureRecognizer:tapGesture];
}

-(void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self.textField becomeFirstResponder];
}

-(void)removeFromSuperview {
    [super removeFromSuperview];
}

// 点击其他区域关闭弹窗
- (void)handletapPressInAlertViewGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded){
        CGPoint location = [sender locationInView:nil];
        if (![_contentView pointInside:[_contentView convertPoint:location fromView:_contentView.window] withEvent:nil]) {
            [self handleCloseAction];
        }
    }
}

-(void)handleCloseAction {
    [self untrigger];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

#pragma mark - Notification

-(void)handleKeyboardInput:(NSNotification *)notification {
    UITextField *tf = notification.object;
    NSString *curStr = [tf.text stringByReplacingOccurrencesOfString:@"_" withString:@""];
    if (curStr.length > [self numberCountWithText:curStr]) {
        tf.text = [curStr substringToIndex:4];
    } else {
        tf.text = curStr;
    }
    [self.inputBBTTF reloadDataWithText:tf.text length:[self numberCountWithText:tf.text]];
    if (false == self.errorLbl.hidden) {
        self.errorLbl.text = @"";
        self.errorLbl.hidden = true;
        [self.errorLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.bottom.mas_equalTo(self.saveBtn.mas_top).mas_offset(-8);
            make.top.mas_equalTo(self.inputBBTTF.mas_bottom).mas_offset(20);
            make.height.mas_equalTo(0);
        }];
        [self.textField reloadInputViews];
    }
}

-(void)handleSaveAction:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"保存"]) { // Save
        if (self.bbtValue > kMaxTemperatureC || self.bbtValue < kMinTemperatureC) {
            self.errorLbl.text = [NSString stringWithFormat: @"孕橙无法帮你保存%.2f℃的体温,因为正常的体温范围为%d~%d℃", self.bbtValue, (int)kMinTemperatureC, (int)kMaxTemperatureC];
            self.errorLbl.hidden = false;
            [self.errorLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(20);
                make.right.mas_equalTo(-20);
                make.bottom.mas_equalTo(self.saveBtn.mas_top).mas_offset(-8);
                make.top.mas_equalTo(self.inputBBTTF.mas_bottom).mas_offset(20);
            }];
            [self.textField reloadInputViews];
        } else {
            // 保存温度
        }
    }
}


-(void)handleEditTimeAction:(UITapGestureRecognizer *)gesture {
    [self.textField resignFirstResponder];
    self.timePicker.title = @"选择时间";
    [self.timePicker trigger];
}

-(void)handleEditDateAction:(UITapGestureRecognizer *)gesture {
    [self.textField resignFirstResponder];
    self.datePicker.title = @"选择时间";
    [self.datePicker trigger];
}

-(void)handleEditBBTAction:(UITapGestureRecognizer *)gesture {
    [self.timePicker untrigger];
    [self.datePicker untrigger];
    [self.textField becomeFirstResponder];
}

-(void)show {
    if (!self.triggered) {
        [self trigger];
    } else {
        [self untrigger];
    }
}

-(void)trigger {
    if (self.superview == nil) {
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows){
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            
            if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                [window addSubview:self];
                break;
            }
        }
        //  如果遍历所有 window 仍然没有把视图加载上去，直接使用 KeyWindow
        if (self.superview == nil) {
            [KEY_WINDOW addSubview:self];
        }
    } else {
        [self.superview bringSubviewToFront:self];
    }
    [self.textField becomeFirstResponder];
    self.triggered = true;
}

-(void)untrigger {
    self.triggered = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Lazy Load

-(UITextField *)textField {
    if (_textField == nil) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 100, 10, 5)];
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.tintColor = [UIColor clearColor];
        _textField.textColor = [UIColor clearColor];
        [self addSubview:_textField];
    }
    return _textField;
}

-(UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.masksToBounds = true;
        _contentView.layer.cornerRadius = 10;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(28);
            make.right.mas_equalTo(-28);
            make.height.mas_equalTo(218);
            make.centerY.mas_equalTo(0);
        }];
    }
    return _contentView;
}

-(UILabel *)chooseTimeLbl {
    if (_chooseTimeLbl == nil) {
        _chooseTimeLbl = [[UILabel alloc] init];
        _chooseTimeLbl.text = @"选择时间:";
        _chooseTimeLbl.textColor = [UIColor textColor];
        _chooseTimeLbl.font = [UIFont systemFontOfSize:16];
    }
    return _chooseTimeLbl;
}

-(UILabel *)dateLbl {
    if (_dateLbl == nil) {
        // 借助 contentV 实现 自动居中
        UIView *contentV = [[UIView alloc] init];
        [self.contentView addSubview:contentV];
        [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.top.mas_equalTo(38);
        }];
        
        [contentV addSubview:self.chooseTimeLbl];
        [self.chooseTimeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.leading.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        
        _dateLbl = [[UILabel alloc] init];
        _dateLbl.textColor = [UIColor textColor];
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEditDateAction:)];
        _dateLbl.userInteractionEnabled = true;
        [_dateLbl addGestureRecognizer:tapG];
        [contentV addSubview:_dateLbl];
        [_dateLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.chooseTimeLbl.mas_centerY);
            make.leading.mas_equalTo(self.chooseTimeLbl.mas_trailing).mas_offset(0);
            make.height.mas_equalTo(28);
        }];
        
        _timeLbl = [[UILabel alloc] init];
        _timeLbl.textColor = [UIColor textColor];
        UITapGestureRecognizer *tapG2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEditTimeAction:)];
        _timeLbl.userInteractionEnabled = true;
        [_timeLbl addGestureRecognizer:tapG2];
        [contentV addSubview:_timeLbl];
        [_timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.chooseTimeLbl.mas_centerY);
            make.leading.mas_equalTo(_dateLbl.mas_trailing).mas_offset(8);
            make.height.mas_equalTo(28);
            make.trailing.mas_equalTo(0);
        }];
    }
    return _dateLbl;
}

-(YCInputBBTTextField *)inputBBTTF {
    if (_inputBBTTF == nil) {
        UILabel *bbtLbl = [[UILabel alloc] init];
        bbtLbl.text = @"基础体温:";
        bbtLbl.textColor = [UIColor textColor];
        bbtLbl.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:bbtLbl];
        [bbtLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.chooseTimeLbl.mas_bottom).mas_equalTo(30);
            make.leading.mas_equalTo(self.chooseTimeLbl.mas_leading);
        }];
        
        _inputBBTTF = [[YCInputBBTTextField alloc] init];
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEditBBTAction:)];
        _inputBBTTF.userInteractionEnabled = true;
        [_inputBBTTF addGestureRecognizer:tapG];
        [self.contentView addSubview:_inputBBTTF];
        [_inputBBTTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(bbtLbl.mas_trailing).mas_offset(0);
            make.centerY.mas_equalTo(bbtLbl.mas_centerY);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(28);
        }];
    }
    return _inputBBTTF;
}

-(NSDate *)joinDate:(NSDate *)date time:(NSDate *)time {
    NSCalendar *gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSDateComponents *timeComponents = [gregorian components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:time];
    dateComponents.hour = timeComponents.hour;
    dateComponents.minute = timeComponents.minute;
    dateComponents.second = timeComponents.second;
    return [gregorian dateFromComponents:dateComponents];
}

-(YCDatePickerView *)timePicker {
    if (_timePicker == nil) {
        NSDate *maxTime = [[NSDate date] dayEnding];
        NSDate *minTime = [[NSDate date] dayBeginning];
        _timePicker = [YCDatePickerView timePickerWithMaxTime:maxTime minTime:minTime];
        _timePicker.datePicker.date = [self joinDate:[NSDate date] time:self.inputMeasureTime];
        YCWeakSelf(self)
        _timePicker.finishSelect = ^(YCDatePickerView *picker) {
            YCStrongSelf(self)
            self.inputMeasureTime = [self joinDate:self.inputMeasureTime time:picker.datePicker.date];
        };
    }
    return _timePicker;
}

-(YCDatePickerView *)datePicker {
    if (_datePicker == nil) {
        NSDate *maxTime = [NSDate date];
        NSDate *minTime = [NSDate dateWithTimeIntervalSince1970:kMinValidTimeInterval];
        _datePicker = [YCDatePickerView datePickerWithMaxDate:maxTime minDate:minTime];
        _datePicker.datePicker.date = self.inputMeasureTime;
        YCWeakSelf(self)
        _datePicker.finishSelect = ^(YCDatePickerView *picker) {
            YCStrongSelf(self)
            self.inputMeasureTime = [self joinDate:picker.datePicker.date time:self.inputMeasureTime];
        };
    }
    return _datePicker;
}

-(UILabel *)errorLbl {
    if (_errorLbl == nil) {
        _errorLbl = [[UILabel alloc] init];
        _errorLbl.textColor = [UIColor colorWithHex:0x7F7F7F];
        _errorLbl.font = [UIFont systemFontOfSize:14];
        _errorLbl.numberOfLines = 0;
        _errorLbl.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_errorLbl];
        [_errorLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.bottom.mas_equalTo(self.saveBtn.mas_top).mas_offset(-8);
            make.top.mas_equalTo(self.inputBBTTF.mas_bottom).mas_offset(20);
            make.height.mas_equalTo(1);
        }];
    }
    return _errorLbl;
}

-(YCGradientButton *)saveBtn {
    if (_saveBtn == nil) {
        _saveBtn = [YCGradientButton buttonWithType:UIButtonTypeCustom];
        _saveBtn.layer.masksToBounds = true;
        _saveBtn.layer.cornerRadius = 21;
        [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_saveBtn addTarget:self action:@selector(handleSaveAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_saveBtn];
        [_saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(220);
            make.height.mas_equalTo(42);
            make.bottom.mas_equalTo(-20);
        }];
    }
    return _saveBtn;
}

@end
