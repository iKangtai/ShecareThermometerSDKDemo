//
//  YCPickerView.m
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15/10/10.
//  Copyright © 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCPickerView.h"
#import <Masonry/Masonry.h>
#import "YCButton+Extension.h"

@interface YCPickerView ()

@property (nonatomic, weak) UIToolbar *topBar;
@property (nonatomic, assign) BOOL triggered;

@end

@implementation YCPickerView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:KEY_WINDOW.bounds]) {
        self.alpha = 0.0f;
        self.backgroundColor = [UIColor blackColor];
        self.triggered = NO;
        self.canTapToUntrigger = YES;
    }
    return self;
}

-(void)setTitle:(NSString *)title {
    _title = title;
    
    if (self.topBar.superview != nil) {
        [self.topBar removeFromSuperview];
    }
    
    UIToolbar *topBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopBarHeight)];
    topBar.barStyle = UIBarStyleDefault;
    topBar.translucent = false;
    topBar.barTintColor = [UIColor whiteColor];
    
    UIBarButtonItem *leftMarginItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftMarginItem.width = 15.0;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnClick)];
    leftItem.tintColor = [UIColor grayTextColor];
    UIBarButtonItem *leftSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIFont *titleFont = [UIFont systemFontOfSize:18];
    CGSize titleSize = [title sizeWithConstrainedToWidth:CGFLOAT_MAX fromFont:titleFont lineSpace:0];
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleSize.width + 20, titleSize.height)];
    titleLbl.textColor = [UIColor textColor];  // 这里使用修改 UIBarButtonItem.tintColor 的方法，无效！！！
    titleLbl.text = title;
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.adjustsFontSizeToFitWidth = true;
    UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:titleLbl];
    
    UIBarButtonItem *rightSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmBtnClick:)];
    rightItem.tintColor = [UIColor mainColor];
    UIBarButtonItem *rightMarginItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightMarginItem.width = 15.0;
    
    topBar.items = @[leftMarginItem, leftItem, leftSpaceItem, titleItem, rightSpaceItem, rightItem, rightMarginItem];
    self.topBar = topBar;
    [self.contentView addSubview:topBar];
}

- (void)cancelBtnClick {
    
}

- (void)confirmBtnClick:(UIBarButtonItem *)sender {
    
}

-(void)trigger {
    if (!self.triggered) {        
        if (self.superview == nil) {
            NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
            for (UIWindow *window in frontToBackWindows){
                BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
                BOOL windowIsVisible = !window.hidden && window.alpha > 0;
                BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
                
                if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                    [window addSubview:self.contentView];
                    [window insertSubview:self belowSubview:self.contentView];
                    break;
                }
            }
            //  如果遍历所有 window 仍然没有把视图加载上去，直接使用 KeyWindow
            if (self.superview == nil) {
                [KEY_WINDOW addSubview:self.contentView];
                [KEY_WINDOW insertSubview:self belowSubview:self.contentView];
            }
        } else {
            [self.superview bringSubviewToFront:self];
            [self.contentView.superview bringSubviewToFront:self.contentView];
        }
        
        CGFloat contentH = self.contentView.frame.size.height;
        [UIView animateWithDuration:0.2 animations:^{
            self.contentView.frame = CGRectMake(0, kScreenHeight-contentH, kScreenWidth, contentH);
        }];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0.4f;
        }];
        
        [UIView animateWithDuration:0.4 delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:2.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        
        } completion:^(BOOL finished) {
            if (finished) {
                if (self.canTapToUntrigger) {
                    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelBtnClick)];
                    [self addGestureRecognizer:tapGes];
                }
            }
        }];
        
        self.triggered = YES;
    } else {
        [self untrigger];
    }
}

-(void)untrigger {
    self.triggered = NO;
    CGFloat contentH = self.contentView.frame.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, contentH);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.contentView removeFromSuperview];
            [self removeFromSuperview];
        }];
    }];
}

-(NSArray <UIButton *>*)addHealthProfileButtonsWithTitles:(NSArray<NSString *> *)titles target:(id)target action:(SEL)action {
    NSMutableArray *buttons = [NSMutableArray array];
    UIView *btnView = [[UIView alloc] init];
    [self.contentView addSubview:btnView];
    
    CGFloat left = 20;
    CGFloat marginH = 14;
    CGFloat marginV = 20;
    CGFloat btnInnerMargin = 10;
    CGFloat top = marginV;
    CGFloat btnH = 40;
    CGFloat totalW = 0;
    CGSize maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    for (NSString *titleI in titles) {
        UIButton *btnI = [UIButton healthProfilePickerButton];
        [btnI setTitle:titleI forState:UIControlStateNormal];
        [btnI addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        CGSize titleSizeI = [titleI sizeWithBoundingSize:maxSize andFont:btnI.titleLabel.font];
        CGFloat btnWI = titleSizeI.width + btnInnerMargin * 2;
        if (left + btnWI + marginH > kScreenWidth) {
            top += marginV + btnH;
            left = 20;
        }
        [btnView addSubview:btnI];
        [btnI mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(left);
            make.width.mas_equalTo(btnWI);
            make.height.mas_equalTo(btnH);
            make.top.mas_equalTo(top);
        }];
        left += btnWI + marginH;
        totalW = (left > totalW) ? (left - marginH) : totalW;
        [buttons addObject:btnI];
    }
    
    [btnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(kTopBarHeight);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(totalW + 20);
    }];
    //  更新 Content 高度
    self.contentView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, top + marginV + btnH + kTopBarHeight);
    return buttons.copy;
}

@end
