//
//  YCInputBBTTextField.h
//  Shecare
//
//  Created by mac on 2019/4/22.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCInputBBTTextField : UIView

///  根据 text 更新 UI
-(void)reloadDataWithText:(NSString *)text length:(NSUInteger)length;

///  当前的字符串值
-(NSString *)currentNumbers;
-(NSString *)currentNumbersFilledWithZero;
///  当前的浮点数值
-(CGFloat)value;

@end

@interface YCInputTimeTextField : UIView

-(instancetype)initWithFrame:(CGRect)frame time:(NSDate *)time;

@property (nonatomic, strong) NSDate *time;

@end

NS_ASSUME_NONNULL_END
