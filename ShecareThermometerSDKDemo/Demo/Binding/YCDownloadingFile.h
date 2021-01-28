//
//  YCDownloadingFile.h
//  Shecare
//
//  Created by ikangtai on 16/2/24.
//  Copyright © 2016年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YCDownloadingFile : NSObject

/**
 *  @brief  简单的多任务下载文件，用在下载OAD的硬件
 *
 *  @param urls               要现在的文件的链接地址
 *  @param progressBlock      下载的进度
 *  @param completionBlock    已经成功的回调
 *  @param downloadErrorBlock 失败的回调
 */
- (void) downloadWithUrl:(NSArray *)urls progressBlock:(void (^)(unsigned long long completeBytes, unsigned long long totalBytes))progressBlock completionBlock:(void (^)(NSString *curUrl, int curIndex, int totalUrlCount, NSData *downloadData))completionBlock downloadError:(void (^)(NSString *curUrl, int curIndex, int totalUrlCount, NSError *error))downloadErrorBlock;

@end
