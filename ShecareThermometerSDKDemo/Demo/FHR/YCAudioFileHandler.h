//
//  YCAudioFileHandler.h
//  Shecare
//
//  Created by MacBook Pro 2016 on 2020/11/13.
//  Copyright © 2020 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "YCSingleton.h"

NS_ASSUME_NONNULL_BEGIN

@interface YCAudioFileHandler : NSObject
SingletonH

+ (instancetype)getInstance;

@property (nonatomic, copy) NSString *recordFilePath;

/**
 * Write audio data to file.
 */
- (void)writeFileWithInNumBytes:(UInt32)inNumBytes
                   ioNumPackets:(UInt32 )ioNumPackets
                       inBuffer:(const void *)inBuffer
                   inPacketDesc:(const AudioStreamPacketDescription* _Nullable)inPacketDesc;

-(void)writeAudioData:(NSData *)data recordID:(NSString *)recordID;

-(void)writeAudioHeaderWithRecordID:(NSString *)recordID;

#pragma mark - Audio Queue
/**
 * Start / Stop record By Audio Queue.
 */
-(void)startVoiceRecordByAudioQueue:(AudioQueueRef)audioQueue
                  isNeedMagicCookie:(BOOL)isNeedMagicCookie
                          audioDesc:(AudioStreamBasicDescription)audioDesc
                           filePath:(NSString *)filePath;

-(void)stopVoiceRecordByAudioQueue:(AudioQueueRef)audioQueue
                   needMagicCookie:(BOOL)isNeedMagicCookie;


/**
 * Start / Stop record By Audio Converter.
 */
-(void)startVoiceRecordByAudioUnitByAudioConverter:(AudioConverterRef)audioConverter
                                   needMagicCookie:(BOOL)isNeedMagicCookie
                                         audioDesc:(AudioStreamBasicDescription)audioDesc
                                          filePath:(NSString *)filePath;

-(void)stopVoiceRecordAudioConverter:(AudioConverterRef)audioConverter
                     needMagicCookie:(BOOL)isNeedMagicCookie;


/**
 * Configure play file path
 */
- (void)configurePlayFilePath:(NSString *)filePath;


/**
 * read audio data from audio file
 * readPacketsNum: read packets num every time
 * return: read bytes.
 */
- (UInt32)readAudioFromFileBytesWithAudioDataRef:(void *)audioDataRef
                                      packetDesc:(AudioStreamPacketDescription*)packetDesc
                                  readPacketsNum:(UInt32)readPacketsNum;


/**
 * reset file for play
 */
- (void)resetFileForPlay;

@end

NS_ASSUME_NONNULL_END
