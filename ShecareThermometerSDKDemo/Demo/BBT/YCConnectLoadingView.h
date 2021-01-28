//
//  YCConnectLoadingView.h
//  Shecare
//
//  Created by mac on 2019/4/23.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YCConnectStatus) {
    YCConnectStatusConnecting,
    YCConnectStatusTimeout,
    YCConnectStatusFailed,
    YCConnectStatusConnected,
    YCConnectStatusUploaded
};

NS_ASSUME_NONNULL_BEGIN

@interface YCConnectLoadingView : UIView

@property (nonatomic, assign) YCConnectStatus connectStatus;

@end

NS_ASSUME_NONNULL_END
