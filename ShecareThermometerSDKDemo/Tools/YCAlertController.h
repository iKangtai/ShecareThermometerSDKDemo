//
//  YCAlertController.h
//  Shecare
//
//  Created by 罗培克 on 16/5/15.
//  Copyright © 2016年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCAlertController : UIAlertController

///  是否自动 dismiss
@property (assign, nonatomic) BOOL autoDismiss;

///  普通弹窗（自定义按钮文字）
+ (void)showAlertWithTitle:(NSString * _Nullable)title
                   message:(NSString * _Nullable)message
               cancelTitle:(NSString * _Nullable)cancelTitle
              confirmTitle:(NSString * _Nullable)confirmTitle
             cancelHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))cancelHandler
            confirmHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))confirmHandler;

///  普通弹窗
+ (void)showAlertWithTitle:(NSString * _Nullable)title
          message:(NSString * _Nullable)message
    cancelHandler:(void (^ __nullable)(UIAlertAction * _Nonnull action))cancelHandler
   confirmHandler:(void (^ __nullable)(UIAlertAction * _Nonnull action))confirmHandler;

///  显示警告框（防止重复弹出）
+ (void)showAlertWithBody:(NSString * _Nullable)body finished:(void (^ __nullable)(UIAlertAction * _Nonnull action))confirmHandler;

@end

NS_ASSUME_NONNULL_END
