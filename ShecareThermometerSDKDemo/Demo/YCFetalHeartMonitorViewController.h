//
//  YCFetalHeartMonitorViewController.h
//  Shecare
//
//  Created by MacBook Pro 2016 on 2020/11/12.
//  Copyright © 2020 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCFetalHeartMonitorViewController : UIViewController

/// 蓝牙上传的 胎心率 数据
@property (nonatomic, assign) NSInteger fhrData;
/// 蓝牙上传的 胎心音 数据
@property (nonatomic, strong) NSData *fhaData;

@end

NS_ASSUME_NONNULL_END
