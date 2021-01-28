//
//  YCAlertController.m
//  Shecare
//
//  Created by 罗培克 on 16/5/15.
//  Copyright © 2016年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCAlertController.h"
#import "YCViewController+Extension.h"

@implementation YCAlertController

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
               cancelTitle:(NSString *)cancelTitle
              confirmTitle:(NSString *)confirmTitle
             cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler
            confirmHandler:(void (^ __nullable)(UIAlertAction *action))confirmHandler {
    YCAlertController *alertC = [YCAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelHandler != nil) {
        UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelHandler];
        [alertC addAction:cancelAct];
    }
    
    UIAlertAction *confirmAct = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:confirmHandler];
    [alertC addAction:confirmAct];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //  避免重复弹出同一个弹窗
        //  判断 “是否是重复弹窗” 的代码必须和 presentVC 的放在同一个线程里，否则多线程运行问题可能造成 “无法避免重复弹窗”
        UIViewController *currentVC = [UIViewController currentViewController];
        if ([currentVC isKindOfClass:[YCAlertController class]]) {
            YCAlertController *currentAlertC = (YCAlertController *)currentVC;
            if ([currentAlertC.title isEqualToString:title] && [currentAlertC.message isEqualToString:message]) {
                return;
            }
        }
        
        NSLog(@"Show alert with title :%@, message: %@", title, message);
        [currentVC presentViewController:alertC animated:YES completion:nil];
    });
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
             cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler
            confirmHandler:(void (^ __nullable)(UIAlertAction *action))confirmHandler {
    [self showAlertWithTitle:title
                     message:message
                 cancelTitle:@"取消"
                confirmTitle:@"确定"
               cancelHandler:cancelHandler
              confirmHandler:confirmHandler];
}

+ (void)showAlertWithBody:(NSString *)body finished:(void (^ __nullable)(UIAlertAction *action))confirmHandler {
    NSString *title = @"温馨提示";
    YCAlertController *alertC = [YCAlertController alertControllerWithTitle:title message:body preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAct = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:confirmHandler];
    [alertC addAction:alertAct];
    alertC.autoDismiss = false;
    NSLog(@"Show alert with message: %@", body);
    dispatch_async(dispatch_get_main_queue(), ^{
        //  避免重复弹出同一个弹窗
        //  判断 “是否是重复弹窗” 的代码必须和 presentVC 的放在同一个线程里，否则多线程运行问题可能造成 “无法避免重复弹窗”
        UIViewController *currentVC = [UIViewController currentViewController];
        if ([currentVC isKindOfClass:[YCAlertController class]]) {
            YCAlertController *currentAlertC = (YCAlertController *)currentVC;
            if ([currentAlertC.title isEqualToString:title] && [currentAlertC.message isEqualToString:body]) {
                return;
            }
        }
        [currentVC presentViewController:alertC animated:YES completion:nil];
    });
}

@end
