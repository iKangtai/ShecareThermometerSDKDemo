//
//  YCDeviceTableViewCell.m
//  ShecareThermometerSDKDemo
//
//  Created by KyokuSei on 2021/1/30.
//

#import "YCDeviceTableViewCell.h"

@interface YCDeviceTableViewCell()

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIImageView *arrowView;

@end

@implementation YCDeviceTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self titleLbl];
    [self macAddressLbl];
    [self firmwareLbl];
    [self deviceImgV];
    [self lineView];
    [self arrowView];
}

-(UIImageView *)deviceImgV {
    if (_deviceImgV == nil) {
        _deviceImgV = [[UIImageView alloc] init];
        _deviceImgV.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_deviceImgV];
        [_deviceImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(20);
            make.top.mas_equalTo(8);
            make.bottom.mas_equalTo(-8);
            make.width.mas_equalTo(54);
        }];
    }
    return _deviceImgV;
}

-(UILabel *)titleLbl {
    if (_titleLbl == nil) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.font = [UIFont systemFontOfSize:18];
        _titleLbl.textColor = [UIColor mainColor];
        [self.contentView addSubview:_titleLbl];
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(84);
            make.top.mas_equalTo(10);
        }];
    }
    return _titleLbl;
}

-(UILabel *)macAddressLbl {
    if (_macAddressLbl == nil) {
        _macAddressLbl = [[UILabel alloc] init];
        _macAddressLbl.font = [UIFont systemFontOfSize:12];
        _macAddressLbl.textColor = [UIColor textColor];
        [self.contentView addSubview:_macAddressLbl];
        [_macAddressLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(84);
            make.top.mas_equalTo(self.titleLbl.mas_bottom).mas_offset(3);
        }];
    }
    return _macAddressLbl;
}

-(UILabel *)firmwareLbl {
    if (_firmwareLbl == nil) {
        _firmwareLbl = [[UILabel alloc] init];
        _firmwareLbl.font = [UIFont systemFontOfSize:12];
        _firmwareLbl.textColor = [UIColor textColor];
        [self.contentView addSubview:_firmwareLbl];
        [_firmwareLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(84);
            make.top.mas_equalTo(self.macAddressLbl.mas_bottom).mas_offset(13);
        }];
    }
    return _firmwareLbl;
}

-(UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHex:0xF0F2F5];
        [self.contentView addSubview:_lineView];
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(1);
        }];
    }
    return _lineView;
}

-(UIImageView *)arrowView {
    if (_arrowView == nil) {
        _arrowView = [[UIImageView alloc] init];
        _arrowView.image = [UIImage imageNamed:@"cr_indicator"];
        [self.contentView addSubview:_arrowView];
        [_arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(-8);
        }];
    }
    return _arrowView;
}

@end
