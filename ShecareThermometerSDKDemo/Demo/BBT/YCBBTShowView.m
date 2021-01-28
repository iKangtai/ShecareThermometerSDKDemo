//
//  YCBBTShowView.m
//  ShecareThermometerSDKDemo
//
//  Created by KyokuSei on 2021/1/26.
//

#import "YCBBTShowView.h"
#import "YCUserTemperatureModel.h"

@interface YCBBTShowView ()

@property (nonatomic, assign) BOOL triggered;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UIScrollView *tempScrollView;
@property (nonatomic, strong) YCGradientButton *confirmBtn;

@property (nonatomic, strong) NSArray <YCUserTemperatureModel *>*tempModels;

@end

@implementation YCBBTShowView

-(instancetype)initWithTempModels:(NSArray <YCUserTemperatureModel *>*)tempModels {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.tempModels = tempModels;
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.backgroundColor = RGBA(0, 0, 0, 0.6);
    [self contentView];
    [self titleLbl];
    [self confirmBtn];
    [self tempScrollView];
    [self setupScrollView];
}

-(void)setupScrollView {
    if (self.tempModels.count == 0) {
        return;
    }
    
    // 将传来的体温按时间降序排列，并按日期分组
    NSMutableArray *tempModelsM = self.tempModels.copy;
    NSArray *modelArr = [tempModelsM sortedArrayUsingComparator:^NSComparisonResult(YCUserTemperatureModel *obj1, YCUserTemperatureModel *obj2) {
        return [obj2.measureTime compare:obj1.measureTime];
    }];
    NSMutableArray *groupedModelArr = [NSMutableArray array];
    NSMutableArray *sameDateModelArr = [NSMutableArray array];
    __block YCUserTemperatureModel *lastUserModel;
    [modelArr enumerateObjectsUsingBlock:^(YCUserTemperatureModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (lastUserModel == nil) {
            [sameDateModelArr addObject:obj];
        } else {
            if ([obj.measureTime isDayEqualTo:lastUserModel.measureTime]) {
                [sameDateModelArr addObject:obj];
            } else {
                [groupedModelArr addObject:sameDateModelArr.copy];
                [sameDateModelArr removeAllObjects];
                [sameDateModelArr addObject:obj];
            }
        }
        lastUserModel = obj;
        if (idx == modelArr.count - 1) {
            [groupedModelArr addObject:sameDateModelArr.copy];
        }
    }];
    
    // 布局ScrollView
    CGFloat scrollViewH = 15 * 2 + groupedModelArr.count * 14 + tempModelsM.count * 14 + (groupedModelArr.count - 1) * 30 + tempModelsM.count * 20;
    self.tempScrollView.contentSize = CGSizeMake(kScreenWidth - 28 * 4, scrollViewH);
    __block CGFloat currentYOrigin = 0;
    [groupedModelArr enumerateObjectsUsingBlock:^(NSArray *modelIArr, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *tempDateLbl = [[UILabel alloc] init];
        tempDateLbl.font = [UIFont systemFontOfSize:14];
        tempDateLbl.textColor = [UIColor colorWithHex:0x444444];
        tempDateLbl.text = [((YCUserTemperatureModel *)modelIArr.firstObject).measureTime yyyyMMddDescString];
        [self.tempScrollView addSubview:tempDateLbl];
        [tempDateLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(17);
            make.top.mas_equalTo((idx == 0 ? 15 : 30) + currentYOrigin);
            make.height.mas_equalTo(14);
        }];
        currentYOrigin += ((idx == 0 ? 15 : 30) + 14);
        [modelIArr enumerateObjectsUsingBlock:^(YCUserTemperatureModel *modelI, NSUInteger idx, BOOL * _Nonnull stop) {
            UILabel *tempTimeLbl = [[UILabel alloc] init];
            tempTimeLbl.font = [UIFont systemFontOfSize:14];
            tempTimeLbl.textColor = [UIColor colorWithHex:0xB2B2B2];
            tempTimeLbl.text = [modelI.measureTime shortTimeString];
            [self.tempScrollView addSubview:tempTimeLbl];
            [tempTimeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(33);
                make.top.mas_equalTo(20 + currentYOrigin);
                make.width.mas_equalTo(75);
                make.height.mas_equalTo(14);
            }];
            UILabel *tempLbl = [[UILabel alloc] init];
            tempLbl.font = [UIFont systemFontOfSize:14];
            tempLbl.textColor = [UIColor colorWithHex:0x444444];
            tempLbl.text = [NSString stringWithFormat:@"%.2f℃", [modelI.temperature doubleValue]];
            [self.tempScrollView addSubview:tempLbl];
            [tempLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(tempTimeLbl.mas_centerY);
                make.left.mas_equalTo(tempTimeLbl.mas_right).offset(kScreenWidth - 28 * 4 - 120 - 75);
                make.height.mas_equalTo(14);
            }];
            currentYOrigin += (20 + 14);
        }];
    }];
}

-(void)handleConfirmAction:(UIButton *)sender {
    [self untrigger];
}

-(void)dealloc {
    NSLog(@"%@---%s", [self class], __FUNCTION__);
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
            make.height.mas_equalTo(320);
            make.centerY.mas_equalTo(0);
        }];
    }
    return _contentView;
}

-(UIScrollView *)tempScrollView {
    if (_tempScrollView == nil) {
        _tempScrollView = [[UIScrollView alloc] init];
        _tempScrollView.userInteractionEnabled = true;
        _tempScrollView.showsVerticalScrollIndicator = true;
        _tempScrollView.showsHorizontalScrollIndicator = false;
        [self.contentView addSubview:_tempScrollView];
        [_tempScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(28);
            make.right.mas_equalTo(-28);
            make.top.mas_equalTo(self.titleLbl.mas_bottom).mas_offset(15);
            make.bottom.mas_equalTo(self.confirmBtn.mas_top).mas_offset(-15);
        }];
    }
    return _tempScrollView;
}

-(UILabel *)titleLbl {
    if (_titleLbl == nil) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.textColor = [UIColor colorWithHex:0x33333];
        _titleLbl.font = [UIFont boldSystemFontOfSize:18];
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.text = @"温度传输成功";
        [self.contentView addSubview:_titleLbl];
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(30);
            make.height.mas_equalTo(20);
        }];
    }
    return _titleLbl;
}

-(YCGradientButton *)confirmBtn {
    if (_confirmBtn == nil) {
        _confirmBtn = [YCGradientButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.layer.masksToBounds = true;
        _confirmBtn.layer.cornerRadius = 21;
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(handleConfirmAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_confirmBtn];
        [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(220);
            make.height.mas_equalTo(40);
            make.bottom.mas_equalTo(-10);
        }];
    }
    return _confirmBtn;
}

@end
