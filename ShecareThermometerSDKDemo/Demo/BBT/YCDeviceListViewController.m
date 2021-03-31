//
//  YCDeviceListViewController.m
//  Shecare
//
//  Created by MacBook Pro 2016 on 2020/7/15.
//  Copyright © 2020 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCDeviceListViewController.h"
#import "YCUserHardwareInfoModel.h"
#import "YCDeviceInfoViewController.h"
#import "YCDeviceTableViewCell.h"
#import "YCBindViewController.h"

static NSString *deviceListVCReuseID = @"YCDeviceTypeReuseCellId";

@interface YCDeviceListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *deviceModelInfos;

@end

@implementation YCDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"我的设备";
    [self setupNavigationItem];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.deviceModelInfos = [YCUtility bindedDeviceModels];
    [self setupUI];
}

-(void)setupNavigationItem {
    self.navigationItem.leftBarButtonItem = [YCUtility navigationBackItemWithTarget:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"绑定新设备" style:UIBarButtonItemStylePlain target:self action:@selector(handleBindAction:)];
}

-(void)setupUI {
    if (self.deviceModelInfos.count == 0) {
        self.tableView.hidden = true;
    } else {
        self.tableView.hidden = false;
        [self.tableView reloadData];
    }
}

-(void)handleBindAction:(UIBarButtonItem *)sender {
    YCBindViewController *targetVC = [[YCBindViewController alloc] init];
    [self.navigationController pushViewController:targetVC animated:true];
}

-(void)back {
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    YCUserHardwareInfoModel *model = self.deviceModelInfos[indexPath.row];
    YCDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:deviceListVCReuseID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.deviceImgV.image = [model hardwareImg];
    cell.titleLbl.text = [model hardwareTitle];
    cell.macAddressLbl.text = [NSString stringWithFormat:@"MAC 地址: %@", model.macAddress];
    cell.firmwareLbl.text = [NSString stringWithFormat:@"版本号: %@", model.hardwareVersion];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YCUserHardwareInfoModel *model = self.deviceModelInfos[indexPath.row];
    YCDeviceInfoViewController *vc = [[YCDeviceInfoViewController alloc] initWithModel:model];
    [self.navigationController pushViewController:vc animated:true];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceModelInfos.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 83;
}

#pragma mark - Lazy Load

-(UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = false;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.bounces = false;
        [_tableView registerClass:[YCDeviceTableViewCell class] forCellReuseIdentifier:deviceListVCReuseID];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(kBottomHeight);
        }];
    }
    return _tableView;
}

@end
