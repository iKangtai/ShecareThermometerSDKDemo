//
//  YCBindSuccessViewController.m
//  Shecare
//
//  Created by mac on 2019/11/29.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCBindSuccessViewController.h"

@interface YCBindSuccessViewController ()

@property (nonatomic, strong) UIImageView *sucImage;
@property (nonatomic, strong) UILabel *sucLbl;
@property (nonatomic, strong) UIButton *confirmBtn;

@end

@implementation YCBindSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavigationItem];
    [self setupUI];
}

- (void)setupNavigationItem {
    self.navigationItem.title = @"设备绑定";
    self.navigationItem.leftBarButtonItem = [YCUtility navigationBackItemWithTarget:self action:@selector(goBack:)];
}

-(void)setupUI {
    [self sucImage];
    [self sucLbl];
    [self confirmBtn];
}

- (void)goBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:true];
}

-(void)handleConfirmAction {
    [self.navigationController popToRootViewControllerAnimated:true];
}

#pragma mark - Lazy Load

-(UIImageView *)sucImage {
    if (_sucImage == nil) {
        _sucImage = [[UIImageView alloc] init];
        _sucImage.image = [UIImage imageNamed:@"device_binding_page_pic_success"];
        [self.view addSubview:_sucImage];
        [_sucImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(kTopHeight + 100);
        }];
    }
    return _sucImage;
}

-(UILabel *)sucLbl {
    if (_sucLbl == nil) {
        _sucLbl = [[UILabel alloc] init];
        _sucLbl.textColor = [UIColor mainColor];
        _sucLbl.font = [UIFont systemFontOfSize:18];
        _sucLbl.text = @"绑定成功！";
        [self.view addSubview:_sucLbl];
        [_sucLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(self.sucImage.mas_bottom).mas_offset(18);
        }];
    }
    return  _sucLbl;
}

-(UIButton *)confirmBtn {
    if (_confirmBtn == nil) {
        _confirmBtn = [YCGradientButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.layer.masksToBounds = true;
        _confirmBtn.layer.cornerRadius = 21;
        [_confirmBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        _confirmBtn.backgroundColor = [UIColor mainColor];
        [_confirmBtn addTarget:self action:@selector(handleConfirmAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_confirmBtn];
        [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
            make.bottom.mas_equalTo(- kBottomHeight - 40);
            make.width.mas_equalTo(220);
            make.centerX.mas_equalTo(0);
        }];
    }
    return _confirmBtn;
}

@end
