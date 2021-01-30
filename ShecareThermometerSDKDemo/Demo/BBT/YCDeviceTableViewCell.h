//
//  YCDeviceTableViewCell.h
//  ShecareThermometerSDKDemo
//
//  Created by KyokuSei on 2021/1/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCDeviceTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLbl;

@property (nonatomic, strong) UILabel *macAddressLbl;

@property (nonatomic, strong) UILabel *firmwareLbl;

@property (nonatomic, strong) UIImageView *deviceImgV;



@end

NS_ASSUME_NONNULL_END
