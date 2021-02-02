//
//  YCConnectLoadingView.m
//  Shecare
//
//  Created by mac on 2019/4/23.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCConnectLoadingView.h"
#import <Masonry/Masonry.h>
#import <SCBLESDK/SCBLESDK.h>

static NSString *connectLoadingAnimeKey = @"ycconnect.loading.rotationAnimation";

@interface YCConnectTimeoutView : UIView

@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *methodLbl;
@property (nonatomic, copy) NSArray <NSString *>*methods;
@property (nonatomic, assign) BOOL animaStoped;

@end

@implementation YCConnectTimeoutView

-(instancetype)init {
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.animaStoped = false;
    [self titleLbl];
    [self containerView];
    [self methodLbl];
}

-(void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        self.animaStoped = true;
    } else {
        self.animaStoped = false;
        [self startAnimation];
    }
}

-(NSString *)nextMethods {
    if (IS_EMPTY_STRING(self.methodLbl.text)) {
        return self.methods.firstObject;
    }
    NSUInteger curIdx = [self.methods indexOfObject:self.methodLbl.text];
    if (self.methods.count - 1 == curIdx) {
        return self.methods.firstObject;
    }
    return self.methods[curIdx + 1];
}

-(void)startAnimation {
    if (self.animaStoped) {
        return;
    }
    self.methodLbl.text = [self nextMethods];
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_centerY).mas_offset(4);
        make.centerX.mas_equalTo(0);
    }];
    CGRect oriBounds = self.methodLbl.bounds;
//    CGRect newBounds = CGRectMake(0, -oriBounds.size.height, oriBounds.size.width, oriBounds.size.height);
    [UIView animateWithDuration:3.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.methodLbl.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -oriBounds.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             self.methodLbl.transform = CGAffineTransformIdentity;
                             [self startAnimation];
                         }
                     }];
    
}

#pragma mark - Lazy Load

-(UILabel *)titleLbl {
    if (_titleLbl == nil) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.text = @"设备连接缓慢？";
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.numberOfLines = 0;
        _titleLbl.font = [UIFont systemFontOfSize:18];
        _titleLbl.textColor = [UIColor textColor];
        [self addSubview:_titleLbl];
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_centerY).mas_offset(-4);
            make.centerX.mas_equalTo(0);
        }];
    }
    return _titleLbl;
}

-(UIView *)containerView {
    if (_containerView == nil) {
        _containerView = [[UIView alloc] init];
        _containerView.layer.masksToBounds = true;
        [self addSubview:_containerView];
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_centerY).mas_offset(4);
            make.centerX.mas_equalTo(0);
        }];
    }
    return _containerView;
}

-(UILabel *)methodLbl {
    if (_methodLbl == nil) {
        _methodLbl = [[UILabel alloc] init];
        _methodLbl.textAlignment = NSTextAlignmentCenter;
        _methodLbl.font = [UIFont systemFontOfSize:14];
        _methodLbl.textColor = [UIColor grayTextColor];
        _methodLbl.numberOfLines = 0;
        _methodLbl.layer.masksToBounds = true;
        _methodLbl.adjustsFontSizeToFitWidth = true;
        [self.containerView addSubview:_methodLbl];
        [_methodLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 8, 0, 8));
        }];
    }
    return _methodLbl;
}

-(NSArray <NSString *>*)methods {
    return @[@"1）重启体温计\n", @"2）确认体温计\n没有误进入历史模式", @" 3）可能电量太低，\n换个电池试试"]; // 所有字符串都是两行，保证他们的高度相等
}

@end

@interface YCConnectLoadingView()

@property (nonatomic, strong) UIImageView *loadingImageV;
@property (nonatomic, strong) UILabel *statusLbl;
@property (nonatomic, strong) UIImageView *deviceImgV;
@property (nonatomic, strong) YCConnectTimeoutView *timeoutV;

@end

@implementation YCConnectLoadingView

-(instancetype)init {
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    [self loadingImageV];
    [self statusLbl];
    [self deviceImgV];
    [self timeoutV];
}

-(void)loading {
    if ([self.loadingImageV.layer.animationKeys containsObject:connectLoadingAnimeKey]) {
        return;
    }
    
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 6;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [self.loadingImageV.layer addAnimation:rotationAnimation forKey:connectLoadingAnimeKey];
}

-(void)uploading:(int)interval {
    // 只有 Connected 才显示 Loading
    if (YCConnectStatusConnected == self.connectStatus) {
        NSMutableString *animeStr = [NSMutableString string];
        for (int i = 0; i < interval % 4; i++) {
            [animeStr appendString:@"."];
        }
        self.statusLbl.text = [NSString stringWithFormat:@"数据上传中，请稍候%@", animeStr];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self uploading:interval + 1];
        });
    }
}

-(void)loaded {
    if ([self.loadingImageV.layer.animationKeys containsObject:connectLoadingAnimeKey]) {
        [self.loadingImageV.layer removeAnimationForKey:connectLoadingAnimeKey];
    }
}

-(void)setConnectStatus:(YCConnectStatus)connectStatus {
    _connectStatus = connectStatus;
    
    switch (connectStatus) {
        case YCConnectStatusConnecting:
            self.loadingImageV.image = [UIImage imageNamed:@"content_img_connection"];
            self.loadingImageV.tintColor = nil;
            self.deviceImgV.hidden = true;
            self.statusLbl.text = @"设备连接中";
            self.timeoutV.hidden = true;
            [self loading];
            break;
        case YCConnectStatusFailed:
            self.loadingImageV.image = [[UIImage imageNamed:@"content_img_connected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.loadingImageV.tintColor = [UIColor grayTextColor];
            self.deviceImgV.hidden = true;
            self.statusLbl.text = @"设备未连接";
            self.timeoutV.hidden = true;
            [self loaded];
            break;
        case YCConnectStatusConnected: {
            self.loadingImageV.image = [UIImage imageNamed:@"content_img_connected"];
            self.loadingImageV.tintColor = nil;
            self.timeoutV.hidden = true;
            [self loaded];
            self.statusLbl.text = @"设备连接成功";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.statusLbl.text = @"";
                self.deviceImgV.hidden = false;
                self.deviceImgV.image = [UIImage imageNamed:@"tiwenji_3"];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.deviceImgV.hidden = true;
                [self uploading:0];
            });
        }
            break;
        case YCConnectStatusTimeout:
            self.deviceImgV.hidden = true;
            self.statusLbl.text = @"";
            self.timeoutV.hidden = false;
            break;
        case YCConnectStatusUploaded: {
            self.deviceImgV.image = [UIImage imageNamed:@"tiwenji_3"];
            self.loadingImageV.image = [UIImage imageNamed:@"content_img_connected"];
            self.timeoutV.hidden = true;
            self.statusLbl.text = @"";
            self.deviceImgV.hidden = false;
        }
        default:
            break;
    }
}

#pragma mark - Lazy Load

-(UIImageView *)loadingImageV {
    if (_loadingImageV == nil) {
        _loadingImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"content_img_connection"]];
        [self addSubview:_loadingImageV];
        [_loadingImageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _loadingImageV;
}

-(UILabel *)statusLbl {
    if (_statusLbl == nil) {
        _statusLbl = [[UILabel alloc] init];
        _statusLbl.text = @"设备连接中";
        _statusLbl.textColor = [UIColor textColor];
        _statusLbl.font = [UIFont systemFontOfSize:18];
        [self addSubview:_statusLbl];
        [_statusLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(CGPointZero);
        }];
    }
    return _statusLbl;
}

-(UIImageView *)deviceImgV {
    if (_deviceImgV == nil) {
        _deviceImgV = [[UIImageView alloc] init];
        _deviceImgV.hidden = true;
        [self addSubview:_deviceImgV];
        [_deviceImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(CGPointZero);
        }];
    }
    return _deviceImgV;
}

-(YCConnectTimeoutView *)timeoutV {
    if (_timeoutV == nil) {
        _timeoutV = [[YCConnectTimeoutView alloc] init];
        _timeoutV.hidden = true;
        [self addSubview:_timeoutV];
        [_timeoutV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _timeoutV;
}

@end
