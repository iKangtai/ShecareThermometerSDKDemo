//
//  YCAudioFileHandler.m
//  Shecare
//
//  Created by MacBook Pro 2016 on 2020/11/13.
//  Copyright © 2020 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCAudioFileHandler.h"

static const NSString *kModuleName = @"Audio File";

@interface YCAudioFileHandler ()
{
    AudioFileID m_recordFile;
    SInt64      m_recordCurrentPacket;      // current packet number in record file
    
    AudioFileID m_playFile;
    SInt64      m_playCurrentPacket;      // current read packet number in file
    CFURLRef    m_playFileURL;
}

@property (nonatomic, assign) BOOL isPlayFileWorking;

@end

@implementation YCAudioFileHandler
SingletonM

#pragma mark - Init
+ (instancetype)getInstance {
    return [[self alloc] init];
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super init];
        _isPlayFileWorking = NO;
    });
    return _instace;
}

#pragma mark - Public

#pragma mark Record
-(void)startVoiceRecordByAudioUnitByAudioConverter:(AudioConverterRef)audioConverter needMagicCookie:(BOOL)isNeedMagicCookie audioDesc:(AudioStreamBasicDescription)audioDesc filePath:(NSString *)filePath {
    self.recordFilePath = filePath;
    NSLog(@"%@:%s - record file path:%@",kModuleName,__func__,self.recordFilePath);
    
    // create the audio file
    m_recordFile = [self createAudioFileWithFilePath:self.recordFilePath
                                           AudioDesc:audioDesc];
    
    if (isNeedMagicCookie) {
        // add magic cookie contain header file info for VBR data
        [self copyEncoderCookieToFileByAudioConverter:audioConverter
                                               inFile:m_recordFile];
    }
}

-(void)stopVoiceRecordAudioConverter:(AudioConverterRef)audioConverter needMagicCookie:(BOOL)isNeedMagicCookie {
    if (isNeedMagicCookie) {
        // reconfirm magic cookie at the end.
        [self copyEncoderCookieToFileByAudioConverter:audioConverter
                                               inFile:m_recordFile];
    }
    
    AudioFileClose(m_recordFile);
    m_recordCurrentPacket = 0;
}

-(void)startVoiceRecordByAudioQueue:(AudioQueueRef)audioQueue isNeedMagicCookie:(BOOL)isNeedMagicCookie audioDesc:(AudioStreamBasicDescription)audioDesc filePath:(NSString *)filePath {
    self.recordFilePath = filePath;
    NSLog(@"%@:%s - record file path:%@",kModuleName,__func__,self.recordFilePath);
    
    // create the audio file
    m_recordFile = [self createAudioFileWithFilePath:self.recordFilePath
                                           AudioDesc:audioDesc];
    
    if (isNeedMagicCookie) {
        // add magic cookie contain header file info for VBR data
        [self copyEncoderCookieToFileByAudioQueue:audioQueue
                                           inFile:m_recordFile];
    }
}

-(void)stopVoiceRecordByAudioQueue:(AudioQueueRef)audioQueue needMagicCookie:(BOOL)isNeedMagicCookie {
    if (isNeedMagicCookie) {
        // reconfirm magic cookie at the end.
        [self copyEncoderCookieToFileByAudioQueue:audioQueue
                                           inFile:m_recordFile];
    }

    AudioFileClose(m_recordFile);
    m_recordCurrentPacket = 0;
}

- (void)writeFileWithInNumBytes:(UInt32)inNumBytes ioNumPackets:(UInt32)ioNumPackets inBuffer:(const void *)inBuffer inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc {
    if (!m_recordFile) {
        return;
    }
    
//    AudioStreamPacketDescription outputPacketDescriptions;
    OSStatus status = AudioFileWritePackets(m_recordFile,
                                            false,
                                            inNumBytes,
                                            inPacketDesc,
                                            m_recordCurrentPacket,
                                            &ioNumPackets,
                                            inBuffer);
    
    if (status == noErr) {
        m_recordCurrentPacket += ioNumPackets;  // 用于记录起始位置
    }else {
        NSLog(@"%@:%s - write file status = %d \n",kModuleName,__func__,(int)status);
    }
    
}

-(void)writeAudioData:(NSData *)data recordID:(NSString *)recordID {
    NSString *path = [YCUtility fhAudioWavPath:recordID];
    NSFileManager *fileMan = [NSFileManager defaultManager];
    if (![fileMan fileExistsAtPath:path]) {
        [fileMan createFileAtPath:path contents:nil attributes:nil];
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle closeFile];
}

NSData* WavFileHeader(long totalAudioLen, long totalDataLen, long longSampleRate,int channels, long byteRate) {
    Byte  header[44];
    header[0] = 'R';  // RIFF/WAVE header
    header[1] = 'I';
    header[2] = 'F';
    header[3] = 'F';
    header[4] = (Byte) (totalDataLen & 0xff);  //file-size (equals file-size - 8)
    header[5] = (Byte) ((totalDataLen >> 8) & 0xff);
    header[6] = (Byte) ((totalDataLen >> 16) & 0xff);
    header[7] = (Byte) ((totalDataLen >> 24) & 0xff);
    header[8] = 'W';  // Mark it as type "WAVE"
    header[9] = 'A';
    header[10] = 'V';
    header[11] = 'E';
    header[12] = 'f';  // Mark the format section 'fmt ' chunk
    header[13] = 'm';
    header[14] = 't';
    header[15] = ' ';
    header[16] = 16;   // 4 bytes: size of 'fmt ' chunk, Length of format data.  Always 16
    header[17] = 0;
    header[18] = 0;
    header[19] = 0;
    header[20] = 1;  // format = 1 ,Wave type PCM
    header[21] = 0;
    header[22] = (Byte) channels;  // channels
    header[23] = 0;
    header[24] = (Byte) (longSampleRate & 0xff);
    header[25] = (Byte) ((longSampleRate >> 8) & 0xff);
    header[26] = (Byte) ((longSampleRate >> 16) & 0xff);
    header[27] = (Byte) ((longSampleRate >> 24) & 0xff);
    header[28] = (Byte) (byteRate & 0xff);
    header[29] = (Byte) ((byteRate >> 8) & 0xff);
    header[30] = (Byte) ((byteRate >> 16) & 0xff);
    header[31] = (Byte) ((byteRate >> 24) & 0xff);
//    header[32] = (Byte) (2 * 16 / 8); // block align
    header[32] = (Byte) (1 * 16 / 8); // block align
    header[33] = 0;
    header[34] = 16; // bits per sample
    header[35] = 0;
    header[36] = 'd'; //"data" marker
    header[37] = 'a';
    header[38] = 't';
    header[39] = 'a';
    header[40] = (Byte) (totalAudioLen & 0xff);  //data-size (equals file-size - 44).
    header[41] = (Byte) ((totalAudioLen >> 8) & 0xff);
    header[42] = (Byte) ((totalAudioLen >> 16) & 0xff);
    header[43] = (Byte) ((totalAudioLen >> 24) & 0xff);
    return [[NSData alloc] initWithBytes:header length:44];;
}

-(void)writeAudioHeaderWithRecordID:(NSString *)recordID {
    NSString *path = [YCUtility fhAudioWavPath:recordID];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data == nil) {
        return;
    }
    long byteRate = 16 * 8000 * 1 / 8;
    // Why "* 2" ???
    NSData *header = WavFileHeader(data.length, data.length + 44 - 8, 8000, 1, byteRate);
    NSMutableData *dataM = [NSMutableData dataWithData:header];
    [dataM appendData:data];
    // overwriting any existing file at path
    [dataM.copy writeToFile:path atomically:true];
}

#pragma mark  Play
- (void)configurePlayFilePath:(NSString *)filePath {
    char path[256];
    [filePath getCString:path maxLength:sizeof(path) encoding:NSUTF8StringEncoding];
    self->m_playFileURL = CFURLCreateFromFileSystemRepresentation (
                                                                   NULL,
                                                                   (const UInt8 *)path,
                                                                   strlen (path),
                                                                   false
                                                                   );
}

- (UInt32)readAudioFromFileBytesWithAudioDataRef:(void *)audioDataRef packetDesc:(AudioStreamPacketDescription*)packetDesc readPacketsNum:(UInt32)readPacketsNum {
    if (!self.isPlayFileWorking) {
        self.isPlayFileWorking = YES;
        OSStatus status;
        status = AudioFileOpenURL(self->m_playFileURL,
                                  kAudioFileReadPermission,
                                  kAudioFileCAFType,
                                  &self->m_playFile);
        if (status != noErr) {
            NSLog(@"open file failed: %d", (int)status);
        }
    }
    
    UInt32 bytesRead = 0;
    UInt32 numPackets = readPacketsNum;
    OSStatus status = AudioFileReadPackets(m_playFile,
                                  false,
                                  &bytesRead,
                                  packetDesc,
                                  m_playCurrentPacket,
                                  &numPackets,
                                  audioDataRef);
    
    if (status != noErr) {
        NSLog(@"read packet failed: %d", (int)status);
    }
    
    if (bytesRead > 0) {
        m_playCurrentPacket += numPackets;
    }else {
        [self resetFileForPlay];
    }
    
    return bytesRead;
}

- (void)resetFileForPlay {
    OSStatus status = AudioFileClose(m_playFile);
    if (status != noErr) {
        NSLog(@"close file failed: %d", (int)status);
    }
    self.isPlayFileWorking = NO;
    m_playCurrentPacket = 0;
}

#pragma mark - Private
#pragma mark File Path

- (AudioFileID)createAudioFileWithFilePath:(NSString *)filePath AudioDesc:(AudioStreamBasicDescription)audioDesc {
    CFURLRef url            = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)filePath, NULL);
    NSLog(@"%@:%s - record file path:%@",kModuleName,__func__,filePath);
    
    AudioFileID audioFile;
    // create the audio file
    OSStatus status = AudioFileCreateWithURL(url,
                                             kAudioFileCAFType,
                                             &audioDesc,
                                             kAudioFileFlags_EraseFile,
                                             &audioFile);
    if (status != noErr) {
        NSLog(@"%@:%s - AudioFileCreateWithURL Failed, status:%d", kModuleName,__func__,(int)status);
    }
    
    CFRelease(url);
    
    return audioFile;
}

#pragma mark Magic Cookie
- (void)copyEncoderCookieToFileByAudioQueue:(AudioQueueRef)inQueue inFile:(AudioFileID)inFile {
    OSStatus result = noErr;
    UInt32 cookieSize;
    
    result = AudioQueueGetPropertySize (
                                        inQueue,
                                        kAudioQueueProperty_MagicCookie,
                                        &cookieSize
                                        );
    if (result == noErr) {
        char* magicCookie = (char *) malloc (cookieSize);
        result =AudioQueueGetProperty (
                                       inQueue,
                                       kAudioQueueProperty_MagicCookie,
                                       magicCookie,
                                       &cookieSize
                                       );
        if (result == noErr) {
            result = AudioFileSetProperty (
                                           inFile,
                                           kAudioFilePropertyMagicCookieData,
                                           cookieSize,
                                           magicCookie
                                           );
            if (result == noErr) {
                NSLog(@"%@:%s - set Magic cookie successful.",kModuleName,__func__);
            }else {
                NSLog(@"%@:%s - set Magic cookie failed.",kModuleName,__func__);
            }
        }else {
            NSLog(@"%@:%s - get Magic cookie failed.",kModuleName,__func__);
        }
        free (magicCookie);
            
    }else {
        NSLog(@"%@:%s - Magic cookie: get size failed.",kModuleName,__func__);
    }

}

-(void)copyEncoderCookieToFileByAudioConverter:(AudioConverterRef)audioConverter inFile:(AudioFileID)inFile {
    // Grab the cookie from the converter and write it to the destination file.
    UInt32 cookieSize = 0;
    OSStatus error = AudioConverterGetPropertyInfo(audioConverter, kAudioConverterCompressionMagicCookie, &cookieSize, NULL);
    
    if (error == noErr && cookieSize != 0) {
        char *cookie = (char *)malloc(cookieSize * sizeof(char));
        error        = AudioConverterGetProperty(audioConverter, kAudioConverterCompressionMagicCookie, &cookieSize, cookie);
        
        if (error == noErr) {
            error = AudioFileSetProperty(inFile, kAudioFilePropertyMagicCookieData, cookieSize, cookie);
            if (error == noErr) {
                UInt32 willEatTheCookie = false;
                error = AudioFileGetPropertyInfo(inFile, kAudioFilePropertyMagicCookieData, NULL, &willEatTheCookie);
                if (error == noErr) {
                    NSLog(@"%@:%s - Writing magic cookie to destination file: %u   cookie:%d \n",kModuleName,__func__, (unsigned int)cookieSize, willEatTheCookie);
                }else {
                    NSLog(@"%@:%s - Could not Writing magic cookie to destination file status:%d \n",kModuleName,__func__,(int)error);
                }
            } else {
                NSLog(@"%@:%s - Even though some formats have cookies, some files don't take them and that's OK,set cookie status:%d \n",kModuleName,__func__,(int)error);
            }
        } else {
            NSLog(@"%@:%s - Could not Get kAudioConverterCompressionMagicCookie from Audio Converter!\n status:%d ",kModuleName,__func__,(int)error);
        }
        
        free(cookie);
    }else {
        // If there is an error here, then the format doesn't have a cookie - this is perfectly fine as som formats do not.
        NSLog(@"%@:%s - cookie status:%d, %d \n",kModuleName,__func__,(int)error, cookieSize);
    }
}


@end
