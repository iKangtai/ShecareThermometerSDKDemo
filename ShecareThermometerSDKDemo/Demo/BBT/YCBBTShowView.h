//
//  YCBBTShowView.h
//  ShecareThermometerSDKDemo
//
//  Created by KyokuSei on 2021/1/26.
//

#import <UIKit/UIKit.h>

@class YCUserTemperatureModel;

NS_ASSUME_NONNULL_BEGIN

@interface YCBBTShowView : UIView

-(instancetype)initWithTempModels:(NSArray <YCUserTemperatureModel *>*)tempModels;

-(void)show;

@end

NS_ASSUME_NONNULL_END
