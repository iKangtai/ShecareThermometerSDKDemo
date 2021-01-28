//
//  YCDownloadingFile.m
//  Shecare
//
//  Created by ikangtai on 16/2/24.
//  Copyright © 2016年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCDownloadingFile.h"
#import <AFNetworking/AFURLSessionManager.h>

@interface YCDownloadingFile()

@property (retain, nonatomic) NSArray *downloadingUrls;
@property (assign, nonatomic) int downloadIndex;
@property (assign, nonatomic) BOOL isBeginDownload;
@property (nonatomic, copy) void (^progressBlock)(unsigned long long downloadedBytes, unsigned long long totalBytes);
@property (nonatomic, copy) void (^completionBlock)(NSString *curUrl, int curIndex, int totalUrlCount, NSData *downloadData);
@property (nonatomic, copy) void (^downloadErrorBlock)(NSString *curUrl, int curIndex, int totalUrlCount, NSError *error);
@property (nonatomic, strong) NSURL *currentURL;

@end


@implementation YCDownloadingFile

- (void)downloadWithUrl:(NSArray *)urls progressBlock:(void (^)(unsigned long long, unsigned long long))progressBlock completionBlock:(void (^)(NSString *, int, int, NSData *))completionBlock downloadError:(void (^)(NSString *, int, int, NSError *))downloadErrorBlock {
    self.downloadIndex      = -1;
    self.isBeginDownload    = NO;
    
    self.progressBlock = progressBlock;
    self.downloadingUrls = urls;
    self.completionBlock = completionBlock;
    self.downloadErrorBlock = downloadErrorBlock;
    self.currentURL = nil;
    
    [self makeUrlConnection];
}

- (void)makeUrlConnection {
    self.downloadIndex ++;
    
    if (!self.isBeginDownload) {
        if (self.downloadIndex == self.downloadingUrls.count) {
            self.isBeginDownload = YES;
            
            self.downloadIndex = 0;
        }
    }
    
    NSString *curStr = [self.downloadingUrls objectAtIndex:self.downloadIndex];
    NSURL *curURL = [NSURL URLWithString:curStr];
    if (curURL == nil || ![curURL scheme] || ![curURL host]) {
        if (self.downloadErrorBlock) {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: @"unsupported URL",
                NSURLErrorFailingURLStringErrorKey: curStr
            };
            NSError *urlErr = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnsupportedURL userInfo:userInfo];
            self.downloadErrorBlock(curStr, self.downloadIndex, (int)self.downloadingUrls.count, urlErr);
        }
        if (self.downloadIndex < self.downloadingUrls.count - 1) {
            [self makeUrlConnection];
        }
        return;
    }
    self.currentURL = curURL;
    AFURLSessionManager *downloadManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDownloadTask *downloadTask = [downloadManager downloadTaskWithRequest:[NSURLRequest requestWithURL:self.currentURL] progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error == nil) {
            NSString *urlStr = [self.currentURL absoluteString];
            NSData *data = [NSData dataWithContentsOfURL:filePath];
            if (self.completionBlock) {
                self.completionBlock(urlStr, self.downloadIndex, (int)self.downloadingUrls.count, data);
            }
            NSLog(@"OAD Download Succeed! filePath: %@", filePath);
            if (self.downloadIndex < self.downloadingUrls.count - 1) {
                [self makeUrlConnection];
            }
        } else {
            NSLog(@"Error: %@", error);
            if (self.downloadErrorBlock) {
                self.downloadErrorBlock([self.currentURL absoluteString], self.downloadIndex, (int)self.downloadingUrls.count, error);
            }
        }
    }];
    [downloadTask resume];
}

@end
