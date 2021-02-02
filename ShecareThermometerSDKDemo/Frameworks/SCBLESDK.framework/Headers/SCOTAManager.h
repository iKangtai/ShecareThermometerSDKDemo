//
//  SCOTAManager.h
//  SCBLESDK
//
//  Created by MacBook Pro 2016 on 2020/8/26.
//  Copyright © 2020 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCBLEDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCOTAManager : NSObject 

///  是否正在更新固件
@property (assign, nonatomic) BOOL isOTAing;

@property (nonatomic, weak) id<BLEThermometerOADDelegate> oadDelegate;

@property (nonatomic, strong) NSURL *fileURL;

- (void)handleOTAAction;

@end

NS_ASSUME_NONNULL_END
