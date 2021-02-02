//
//  YCPickerView.h
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15/10/10.
//  Copyright © 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTopBarHeight   44
#define kPickerViewHeight (216+kTopBarHeight)

@interface YCPickerView : UIView

///  是否能够 tapToUntrigger
@property (nonatomic, assign) BOOL canTapToUntrigger;
///  标题
@property (copy, nonatomic) NSString *title;
///  内容视图
@property (nonatomic, strong) UIView *contentView;

///  Method to trigger the animation
-(void)trigger;
///  Method to untrigger the animation
-(void)untrigger;

- (void)cancelBtnClick;

- (void)confirmBtnClick:(UIBarButtonItem *)sender;

- (NSArray <UIButton *>*)addHealthProfileButtonsWithTitles:(NSArray <NSString *>*)titles target:(id)target action:(SEL)action;

@end
