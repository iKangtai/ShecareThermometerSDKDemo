//
//  OTAManager.h
//  ShecareT
//
//  Created by MacBook Pro 2016 on 2020/8/26.
//  Copyright © 2020 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"
#import "ParameterStorage.h"
#import "SUOTAServiceManager.h"
#import "ShecareBLEThermometer.h"

NS_ASSUME_NONNULL_BEGIN

@interface OTAManager : NSObject {
    int step, nextStep;
    int expectedValue;
    
    int chunkSize;
    int blockStartByte;
    
    ParameterStorage *storage;
    SUOTAServiceManager *manager;
    NSMutableData *fileData;
    NSDate *uploadStart;
}

@property char memoryType;
@property int memoryBank;
@property UInt16 blockSize;

@property int i2cAddress;
@property char i2cSDAAddress;
@property char i2cSCLAddress;

@property char spiMOSIAddress;
@property char spiMISOAddress;
@property char spiCSAddress;
@property char spiSCKAddress;

///  是否正在更新固件
@property (assign, nonatomic) BOOL isOADing;

@property (nonatomic, weak) id<BLEThermometerOADDelegate> oadDelegate;

@property (nonatomic, strong) NSURL *fileURL;

- (void)handleOTAAction;

@end

NS_ASSUME_NONNULL_END
