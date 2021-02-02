//
//  CommonAppDelegate.h
//  Shecare
//
//  Created by mac on 2019/12/27.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SCBLESDK/SCBLESDK.h>

NS_ASSUME_NONNULL_BEGIN

@class YCMessageModel;
@interface YCCommonAppDelegate : NSObject

+(YCCommonAppDelegate *)shared;

-(void)prepareAppWithOptions:(NSDictionary *)launchOptions;

///  开始扫描、连接设备
-(void)startScan;


@end

NS_ASSUME_NONNULL_END
