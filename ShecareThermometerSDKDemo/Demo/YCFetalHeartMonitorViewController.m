//
//  YCFetalHeartMonitorViewController.m
//  Shecare
//
//  Created by MacBook Pro 2016 on 2020/11/12.
//  Copyright © 2020 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCFetalHeartMonitorViewController.h"
#import "YCAudioFileHandler.h"
#import "ShecareThermometerSDKDemo-Bridging-Header.h"
#import "YCLeftAxisValueFormatter.h"
#import "YCFHRecordModel.h"
#import <SCBLESDK/SCBLESDK.h>

#define YC_TXY_TIMER_LENGTH 0.5
#define YC_TXY_VALUES_PER_MINUTE 120 // 每分钟显示、存储的胎心率数量
#define YC_TXY_RECORD_MIN_LENGTH 5 // 胎心记录时长，最少 5s
#define YC_TXY_MIN_FHR 60
#define YC_TXY_MAX_FHR 240

@interface YCFetalHeartMonitorViewController ()<ChartViewDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *fhrDataFrameCache;
@property (nonatomic, strong) NSMutableData *fhaDataFrameCache;
/// 用于存储蓝牙上传和手动标记的数据
@property (nonatomic, strong) NSMutableArray *chartDatas;
@property (nonatomic, assign) NSTimeInterval recordStartTimeInt;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isEnded;
/// 当前正在记录的 YCFHRecordModel ，用于存储被记录下来的数据
@property (nonatomic, strong) YCFHRecordModel *curRecordModel;

@property (nonatomic, strong) LineChartView *chartView;

@property (strong, nonatomic) UIView *bottomView;
@property (nonatomic, strong) UILabel *timeLbl;
@property (nonatomic, strong) UILabel *fetalMoveCountLbl;
@property (nonatomic, strong) UILabel *fhrLbl;
@property (nonatomic, strong) UIImageView *heartImg;
@property (nonatomic, strong) UIStackView *btnContainer;
@property (nonatomic, strong) YCGradientButton *fetalMoveBtn;
@property (nonatomic, strong) YCGradientButton *recordBtn;

@end

@implementation YCFetalHeartMonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initChartData];
    self.isRecording = false;
    self.isEnded = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appConnectThermometer:) name:kNotification_ThermometerConnectSuccessed object:nil];
    [self setupNavigationItem];
    [self setupUI];
}

-(void)initChartData {
    self.fhrDataFrameCache = [NSMutableArray array];
    self.fhaDataFrameCache = [NSMutableData data];
    self.chartDatas = [NSMutableArray arrayWithObject:[self getFirstChartsData]];
}

-(void)setupUI {
    [self setupChartView]; // 初始化图表
    [self btnContainer];
    [self fhrLbl];
    [self timeLbl];
    [self fetalMoveCountLbl];
    [self heartImg];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 关闭屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

- (void)dealloc {
    if (self.isRecording && self.curRecordModel != nil) {
        [[YCAudioFileHandler getInstance] writeAudioHeaderWithRecordID:self.curRecordModel.recordID];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

- (void)setupNavigationItem {
    NSString *imgName = @"fetal_favorite_nav_ic_unconnected";
    if ([self isConnected]) {
        imgName = @"fetal_favorite_nav_ic_connected";
    }
    UIImage *img = [[UIImage imageNamed:imgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *bleItem = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = bleItem;
}

-(void)setFhrData:(NSInteger)fhrData {
    _fhrData = fhrData;
    
    if (self.isEnded) {
        return;
    }
    // 受 胎动 数据的影响，不能使用收到的蓝牙胎心率数据来计数。改用定时器
    [self.fhrDataFrameCache addObject:@(fhrData)];
    
    if (self.timer == nil) {
        // 开始显示数据
        [self startTimer];
    }
}

-(void)handleTimer {
    NSInteger sum = 0;
    NSInteger count = 0;
    for (NSNumber *numI in self.fhrDataFrameCache) {
        // 避免胎心仪没有测到数据时，发送的 0 影响平均值
        if (numI.integerValue > 0) {
            sum += numI.integerValue;
            count++;
        }
    }
    NSInteger avgFHR = (count > 0) ? (sum / count) : 0;
    [self.fhrDataFrameCache removeAllObjects];
//    YCInfo(@"FHR %@", @(avgFHR));
    [self showFHRData:avgFHR];
    
    if (avgFHR <= 0) {
        self.heartImg.hidden = true;
        self.fhrLbl.text = @"— — —";
    } else {
        self.heartImg.hidden = false;
        self.fhrLbl.text = [NSString stringWithFormat:@"%@", @(avgFHR)];
        [self startHeartAnimate];
    }
    if (self.isRecording) {
        // 存入数据库
        [self syncNewValueToDB:avgFHR isNew:false];
        // 存入音频
        if (self.fhaDataFrameCache.length > 0) {
            [[YCAudioFileHandler getInstance] writeAudioData:self.fhaDataFrameCache recordID:self.curRecordModel.recordID];
            self.fhaDataFrameCache = [NSMutableData data];
        } else {
            // 一帧胎心音的长度为 800；定时器 500ms 执行一次，相当于 10帧
            NSMutableData *emptyData = [NSMutableData dataWithLength:800 * 10];
            [[YCAudioFileHandler getInstance] writeAudioData:emptyData recordID:self.curRecordModel.recordID];
        }
        
        if (self.curRecordModel.duration.intValue > 15 * 60) {
            [YCAlertController showAlertWithBody:@"单次胎心记录最长时间为15分钟，胎心记录已为您保存成功，如需再次记录请点击开始记录按钮进行记录" finished:nil];
            [self handleFinishRecord:self.recordBtn];
        }
    }
}

-(void)syncNewValueToDB:(NSInteger)avgFHR isNew:(BOOL)isNew {
    if (self.curRecordModel == nil || isNew) {
        self.curRecordModel = [YCFHRecordModel modelWithValues:@[@(avgFHR)] moves:@[]];
    } else {
        [self.curRecordModel addNewValue:avgFHR];
    }
    NSInteger duration = self.curRecordModel.duration.integerValue;
    self.timeLbl.text = [NSString stringWithFormat:@"%02lu:%02lu", duration / 60, duration % 60];
    
//    [[YCRecordCenter sharedCenter] syncFHRecordsToDB:@[self.curRecordModel] finished:^{
//    }];
}

-(void)syncNewMoveToDB:(NSInteger)index isNew:(BOOL)isNew {
    if (self.curRecordModel == nil || isNew) {
        self.curRecordModel = [YCFHRecordModel modelWithValues:@[] moves:@[@(index)]];
    } else {
        [self.curRecordModel addNewMove:index];
    }
    
//    [[YCRecordCenter sharedCenter] syncFHRecordsToDB:@[self.curRecordModel] finished:^{
//    }];
}

-(void)setFhaData:(NSData *)fhaData {
    _fhaData = fhaData;
    
    if (self.isEnded) {
        return;
    }
//    YCInfo(@"FHA %@", fhaData);
    if (fhaData != nil) {
//        // 播放
////        [self.auPlayer addBufferToWorkQueueWithAudioData:(void *)fhaData.bytes size:(int)fhaData.length userData:NULL];
////        [self playData:fhaData];
//        [self.player playWithData:fhaData];
    }
    if (self.isRecording) {
        if (fhaData == nil) {
            // fhaData 固定长度 800
            NSMutableData *fhaDataM = [NSMutableData dataWithLength:800];
            fhaData = fhaDataM.copy;
        }
        // 音频数据存入缓存
        [self.fhaDataFrameCache appendData:fhaData];
    }
}

-(LineChartDataSet *)dataSetWithYVals:(NSArray <ChartDataEntry *>*)yVals {
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithYVals:yVals label:@"chart_txy"];
    set.lineWidth = 4.0 / [UIScreen mainScreen].scale;
    set.drawCirclesEnabled = false;
    set.drawCircleHoleEnabled = false;
    set.drawValuesEnabled = false;
    set.highlightEnabled = false;
    set.drawFilledEnabled = false;
    if (yVals.firstObject.value < YC_TXY_MIN_FHR || yVals.lastObject.value < YC_TXY_MIN_FHR || (yVals.firstObject.value - yVals.lastObject.value) > 10) {
        set.colors = @[[UIColor clearColor]];
    } else {
        set.colors = @[[UIColor mainColor]];
    }
    set.drawSteppedEnabled = false;
    return set;
}

-(LineChartDataSet *)backgroundDataSetWithColor:(UIColor *)color count:(NSUInteger)count {
    NSMutableArray *topBKArrM = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        ChartDataEntry *topEntry = [[ChartDataEntry alloc] initWithValue:160 xIndex:i];
        [topBKArrM addObject:topEntry];
    }
    LineChartDataSet *bkSet = [[LineChartDataSet alloc] initWithYVals:topBKArrM.copy];
    bkSet.lineWidth = 0;
    bkSet.colors = @[color]; //折线颜色
    bkSet.drawCirclesEnabled = false;
    bkSet.drawCircleHoleEnabled = false;
    bkSet.drawValuesEnabled = false;
    bkSet.highlightEnabled = false;
    bkSet.drawFilledEnabled = true;//是否填充颜色
    bkSet.fillFormatter = [[YCFHMFillFormatter alloc] init]; // fillFormatter 里设置了背景色区域下限 110
    bkSet.fillColor = color;
    return bkSet;
}

-(LineChartDataSet *)fetalMoveDataSetWithIndex:(NSUInteger)index {
    NSUInteger count = 6;
    UIColor *color = [UIColor mainColor];
    NSMutableArray *topBKArrM = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = index; i < index + count; i++) {
        ChartDataEntry *topEntry = [[ChartDataEntry alloc] initWithValue:38 xIndex:i];
        [topBKArrM addObject:topEntry];
    }
    LineChartDataSet *bkSet = [[LineChartDataSet alloc] initWithYVals:topBKArrM.copy];
    bkSet.lineWidth = 0;
    bkSet.colors = @[color]; //折线颜色
    bkSet.drawCirclesEnabled = false;
    bkSet.drawCircleHoleEnabled = false;
    bkSet.drawValuesEnabled = false;
    bkSet.highlightEnabled = false;
    bkSet.drawFilledEnabled = true;//是否填充颜色
    bkSet.fillColor = color;
    return bkSet;
}

/// 绘制 “开始” 竖线
-(LineChartDataSet *)startDataSetWithIndex:(NSUInteger)index {
    UIColor *color = [UIColor colorWithHex:0x67A3FF];
    ChartDataEntry *topEntry = [[ChartDataEntry alloc] initWithValue:YC_TXY_MAX_FHR xIndex:index];
    ChartDataEntry *topEntry2 = [[ChartDataEntry alloc] initWithValue:YC_TXY_MAX_FHR xIndex:index+2];
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithYVals:@[topEntry, topEntry2]];
    set.lineWidth = 0;
    set.colors = @[color]; //折线颜色
    set.drawCirclesEnabled = false;
    set.drawCircleHoleEnabled = false;
    set.drawValuesEnabled = false;
    set.highlightEnabled = false;
    set.drawFilledEnabled = true;//是否填充颜色
    set.fillColor = color;
    return set;
}

-(NSMutableDictionary *)getFirstChartsData {
    NSMutableDictionary *curDatas = [NSMutableDictionary dictionary];
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    curDatas[@"startTime"] = @(startTime);
    curDatas[@"values"] = [NSMutableArray array];
    curDatas[@"moves"] = [NSMutableArray array];
    return curDatas;
}

-(NSArray <NSNumber *>*)defaultChartData {
    NSMutableArray *valuesM = [NSMutableArray array];
    // 一开始就给数组添加 3min 的初始数据，避免首次加载的曲线页 “空白”
    for (int i = 0; i < YC_TXY_VALUES_PER_MINUTE * 3; i++) {
        [valuesM addObject:@-1];
    }
    return valuesM.copy;
}

-(void)showFHRData:(NSInteger)fhr {
    NSMutableDictionary *curDatas = self.chartDatas.lastObject;
    if (curDatas == nil) {
        return;
    }
    NSMutableArray *curValues = curDatas[@"values"];
    [curValues addObject:@(fhr)];
    
    [self setupChartView];
}

- (void)setupChartView {
    NSArray *datas = self.chartDatas.copy;
    NSMutableArray <LineChartDataSet *>*dataSets = [NSMutableArray array];
    // xVals 必须是字符串数组
    NSMutableArray <NSString *>*xVals = [NSMutableArray array];
    
    // 初始化曲线
    NSArray <NSNumber *>*defaultDatas = [self defaultChartData];
    for (int i = 0; i < defaultDatas.count - 1; i++) {
        ChartDataEntry *lEntry = [[ChartDataEntry alloc] initWithValue:defaultDatas[i].doubleValue xIndex:i];
        ChartDataEntry *rEntry = [[ChartDataEntry alloc] initWithValue:defaultDatas[i + 1].doubleValue xIndex:i + 1];
        
        [dataSets addObject:[self dataSetWithYVals:@[lEntry, rEntry]]];
        [xVals addObject:[NSString stringWithFormat:@"%@", @(i)]];
    }
    
    NSInteger startIdx = 0;
    for (int j = 0; j < datas.count; j++) {
        NSDictionary *dictI = datas[j];
        // 胎心率曲线
        NSArray <NSNumber *>*values = dictI[@"values"];
        if (j > 0) {
            // 两段数据不连续
            NSDictionary *preDict = datas[j - 1];
            NSTimeInterval preTimeInt = [preDict[@"startTime"] doubleValue];
            NSTimeInterval curTimeInt = [dictI[@"startTime"] doubleValue];
            startIdx = (NSInteger)(curTimeInt - preTimeInt) * 2; // 1s 两个数据
        }
        int i = 0;
        if (values.count > 0) {
            for (i = 0; i < values.count - 1; i++) {
                ChartDataEntry *lEntry = [[ChartDataEntry alloc] initWithValue:values[i].doubleValue xIndex:startIdx + i];
                ChartDataEntry *rEntry = [[ChartDataEntry alloc] initWithValue:values[i + 1].doubleValue xIndex:startIdx + i + 1];
                
                [dataSets addObject:[self dataSetWithYVals:@[lEntry, rEntry]]];
                NSString *idx = [NSString stringWithFormat:@"%@", @(startIdx + i)];
                if (![xVals containsObject:idx]) {
                    [xVals addObject:idx];
                }
            }
        }
        NSString *endIdx = [NSString stringWithFormat:@"%@", @(startIdx + i + 1)];
        if (![xVals containsObject:endIdx]) {
            [xVals addObject:endIdx];
        }
        // 胎动数据点
        NSArray <NSNumber *>*moves = dictI[@"moves"];
        for (NSNumber *numI in moves) {
            LineChartDataSet *moveSet = [self fetalMoveDataSetWithIndex:numI.integerValue];
            [dataSets addObject:moveSet];
        }
    }
    if (self.isRecording && datas.count > 0) {
        NSDictionary *dictI = datas[0];
        NSTimeInterval curTimeInt = [dictI[@"startTime"] doubleValue];
        // 记录 “开始”。同一时间内，曲线上只显示一个记录，暂不存在显示多个记录的情况
        NSInteger stIdx = (NSInteger)(self.recordStartTimeInt - curTimeInt) * 2; // 1s 两个数据
        if (stIdx <= 2) {
            stIdx = 2;
        }
        [dataSets addObject:[self startDataSetWithIndex:stIdx]];
    }
    // 填充背景色
    LineChartDataSet *topBKSet = [self backgroundDataSetWithColor:[UIColor colorWithHex:0x81B2FE alpha:0.3] count:xVals.count];
    [dataSets addObject:topBKSet];
    
//    [self.chartView zoomAndCenterViewAnimatedWithScaleX:360/300.0 scaleY:0.0f xIndex:0 yValue:0.0f axis:AxisDependencyLeft duration:DBL_MIN];
    // 通过设置 zoom，动态更新 X 轴长度，从而保证随着数据量变大，曲线长度越来越长，而不是 “在一个固定长度内一直累加数据”；
    // 每次设置 zoom 都需要除以旧的 scaleX，从而避免 scale 叠加造成比例错误
    [self.chartView zoom:xVals.count / 300.0 / self.chartView.scaleX scaleY:0.0];
    [self.chartView.data notifyDataChanged];
    [self.chartView notifyDataSetChanged];
    self.chartView.data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets.copy];
}

#pragma mark - 接收到通知时的响应方法

- (void)appConnectThermometer:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupNavigationItem];
        if ([self isConnected]) {
            // 每连接成功 1 次，开始一段新记录
            NSMutableDictionary *curDatas = [self getFirstChartsData];
            [self.chartDatas addObject:curDatas];
            if (self.isRecording) {
                // 更新 Record Model
                [self syncNewValueToDB:0 isNew:true];
            }
        } else {
            // 断开连接，且当前记录时长已满足最小值，自动停止记录
            if (self.isRecording && self.curRecordModel.duration.intValue >= YC_TXY_RECORD_MIN_LENGTH) {
                [self handleFinishRecord:self.recordBtn];
                [YCAlertController showAlertWithBody:@"断开连接，自动停止记录" finished:nil];
            }
        }
    });
}

-(NSArray *)validValues:(NSArray *)values {
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(NSNumber * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.integerValue >= 0;
    }];
    return [values filteredArrayUsingPredicate:pred];
}

-(void)handleFetalMoveAction:(UIButton *)sender {
    if (![self isConnected]) {
        [YCAlertController showAlertWithBody:@"设备链接中，请稍后记录" finished:nil];
        return;
    }
    NSMutableDictionary *curDatas = self.chartDatas.lastObject;
    if (curDatas == nil) {
        return;
    }
    if (self.timer == nil) {
        // 开始显示数据
        [self startTimer];
    }
    NSMutableArray <NSNumber *>*values = curDatas[@"values"];
    NSMutableArray <NSNumber *>*moves = curDatas[@"moves"];
    NSArray *validValues = [self validValues:values];
    // 5s 内只能记录一次胎动
    if (moves.lastObject != nil && validValues.count - moves.lastObject.integerValue < 5) {
        [YCAlertController showAlertWithBody:@"5秒记录一次胎动" finished:nil];
        return;
    }
    [moves addObject:@(validValues.count)];
    [self setupChartView];
    if (self.isRecording) {
        [self syncNewMoveToDB:validValues.count isNew:false];
    }
    self.fetalMoveCountLbl.text = [NSString stringWithFormat:@"%@", @(moves.count)];
}

-(void)handleRecordAction:(UIButton *)sender {
    if (sender.selected) {
        if (self.curRecordModel.duration.intValue < YC_TXY_RECORD_MIN_LENGTH) {
            [YCAlertController showAlertWithBody:@"单次胎心记录时间最短5秒，请稍后结束记录" finished:nil];
            return;
        }
        [YCAlertController showAlertWithTitle:@"温馨提示" message:@"确定要结束记录吗？" cancelHandler:^(UIAlertAction * _Nonnull action) {
        } confirmHandler:^(UIAlertAction * _Nonnull action) {
            [self handleFinishRecord:sender];
        }];
    } else {
        if (![self isConnected]) {
            [YCAlertController showAlertWithBody:@"设备链接中，请稍后记录" finished:nil];
            return;
        }
        sender.selected = !sender.selected;
        self.isRecording = sender.selected;
        // 第二次记录，从 0 开始
        if (true == self.isEnded) {
            [self initChartData];
            [self setupChartView];
        }
        self.isEnded = false;
        self.recordStartTimeInt = [[NSDate date] timeIntervalSince1970];
        if (self.timer == nil) {
            [self startTimer];
        }
    }
}

-(void)handleFinishRecord:(UIButton *)sender {
    NSString *saveID = self.curRecordModel.recordID;
    [[YCAudioFileHandler getInstance] writeAudioHeaderWithRecordID:saveID];
    dispatch_async(dispatch_get_main_queue(), ^{
        sender.selected = !sender.selected;
        self.isRecording = sender.selected;
        self.isEnded = true;
        // 清空 Chart 且不再绘制，再次点击 “开始记录” 时才重新开始绘制
        [self stopTimer];
        [self initChartData];
        [self setupChartView];

        // 结束记录时，若没有胎心数据的输入…………
        if (self.curRecordModel.averageFhr.doubleValue < YC_TXY_MIN_FHR) {
            return;
        }

        NSString *path = [YCUtility fhAudioWavPath:saveID];
        NSData *audioData = [NSData dataWithContentsOfFile:path];
        // 音频文件不存在
        if (audioData == nil) {
            NSLog(@"Error: Audio file does not exists!");
            return;
        }
        
        // 上传数据到服务器，用于客服分析
        SCBLEFHRecordModel *model = [[SCBLEFHRecordModel alloc] init];
        model.audioData = audioData;
        NSString *ext = [path componentsSeparatedByString:@"."].lastObject ?: @"wav";
        model.fileExtension = ext;
        model.recordId = self.curRecordModel.recordID;
        model.duration = [NSString stringWithFormat:@"%@", self.curRecordModel.duration];
        model.title = @"孕9周5天"; // 此处应传真实值
        model.recordTime = self.curRecordModel.createTime;
        model.averageFhr = [NSString stringWithFormat:@"%@", self.curRecordModel.averageFhr];
        model.quickening = [NSString stringWithFormat:@"%@", self.curRecordModel.quickening];
        model.history = self.curRecordModel.history;
        
        [[SCBLEThermometer sharedThermometer] uploadFetalHeartRecord:model];
    });
}

-(void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:YC_TXY_TIMER_LENGTH target:self selector:@selector(handleTimer) userInfo:nil repeats:true];
    // Timer 的 Add 和 Remove 需要在同一个 Thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    });
}

-(void)stopTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.timer isValid]) {
            [self.timer invalidate];
        }
        self.timer = nil;
    });
}

#pragma mark - Lazy Load

-(LineChartView *)chartView {
    if (_chartView == nil) {
        _chartView = [[LineChartView alloc] init];
        _chartView.delegate = self;
        _chartView.backgroundColor = [UIColor whiteColor];
        _chartView.noDataText = @"No data";
        _chartView.noDataTextDescription = @"You need to provide data for the chart.";
        //  设置交互样式
        _chartView.scaleXEnabled = false;
        _chartView.scaleYEnabled = false;
        _chartView.doubleTapToZoomEnabled = false;
        _chartView.pinchZoomEnabled = false;
        _chartView.dragEnabled = true;
        _chartView.dragDecelerationEnabled = true;
        _chartView.dragDecelerationFrictionCoef = 0.9f;
        _chartView.descriptionText = @"";
        _chartView.maxVisibleValueCount = 300;
        
        [self setXAxis];
        [self setYAxis];
        //  去掉默认的 “折线图描述及图例样式”
        [self.chartView.legend setCustomWithColors:@[[UIColor clearColor]]
                                            labels:@[@" "]];
        
        [self.view addSubview:_chartView];
        [_chartView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view).insets(self.chartInsets);
        }];
    }
    return _chartView;
}

-(UIEdgeInsets)chartInsets {
    return UIEdgeInsetsMake(0, 5, 170, 5);
}

-(void)setXAxis {
    //  设置X轴样式
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.axisLineWidth = 1.0 / [UIScreen mainScreen].scale;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:14];
    xAxis.spaceBetweenLabels = 0;
    xAxis.drawGridLinesEnabled = true;
    [xAxis setLabelsToSkip:YC_TXY_VALUES_PER_MINUTE * 0.5 - 1];
    xAxis.axisLineColor = [UIColor colorWithHex:0xE8E8E8];
    xAxis.labelTextColor = [UIColor textColor];
    xAxis.gridLineWidth = xAxis.axisLineWidth;
    xAxis.gridColor = xAxis.axisLineColor;
    xAxis.labelAlignedLineEnabled = true;
    xAxis.bottomLineCount = 0;
    YCFHMXAxisValueFormatter *formatter = [[YCFHMXAxisValueFormatter alloc] init];
    xAxis.valueFormatter = formatter;
}

-(NSArray <NSNumber *>*)yAxisDatas {
    NSInteger minFHR = YC_TXY_MIN_FHR;
    NSInteger maxFHR = YC_TXY_MAX_FHR;
    NSMutableArray *resultM = [NSMutableArray array];
    NSInteger pointer = maxFHR;
    while (pointer >= minFHR) {
        [resultM addObject:@(pointer)];
        pointer -= 10;
    }
    return resultM.copy;
}

-(void)setYAxis {
    //  设置Y轴样式
    ChartYAxis *leftAxis = _chartView.leftAxis;
    [leftAxis setLabelCount:self.yAxisDatas.count force:true];
    leftAxis.drawTopYLabelEntryEnabled = true;
    leftAxis.axisMinValue = self.yAxisDatas.lastObject.doubleValue;
    leftAxis.axisMaxValue = self.yAxisDatas.firstObject.doubleValue;
    leftAxis.axisLineWidth = 1.0 / [UIScreen mainScreen].scale;
    leftAxis.axisLineColor = _chartView.xAxis.axisLineColor;
//    leftAxis.drawLabelsEnabled = false;
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.labelTextColor = [UIColor textColor];
    leftAxis.labelFont = [UIFont systemFontOfSize:14];
    leftAxis.gridLineWidth = leftAxis.axisLineWidth;
    leftAxis.gridColor = leftAxis.axisLineColor;
    leftAxis.drawGridLinesEnabled = true;
    leftAxis.bottomLineCount = 0;
    YCFHMYAxisValueFormatter *formatter = [[YCFHMYAxisValueFormatter alloc] init];
    leftAxis.valueFormatter = formatter;
    
    _chartView.rightAxis.enabled = false;
}

-(UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(170);
        }];
    }
    return _bottomView;
}

-(UILabel *)timeLbl {
    if (_timeLbl == nil) {
        _timeLbl = [[UILabel alloc] init];
        _timeLbl.text = @"00:00";
        _timeLbl.font = [UIFont systemFontOfSize:18];
        _timeLbl.textColor = [UIColor mainColor];
        _timeLbl.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:_timeLbl];
        [_timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(60);
            make.bottom.mas_equalTo(self.fhrLbl.mas_top).mas_offset(0);
            make.centerX.mas_equalTo(self.bottomView.mas_leading).mas_offset(66);
        }];
        
        UILabel *unitLbl = [[UILabel alloc] init];
        unitLbl.text = @"记录时长";
        unitLbl.font = [UIFont systemFontOfSize:14];
        unitLbl.textColor = [UIColor textColor];
        [self.bottomView addSubview:unitLbl];
        [unitLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_timeLbl.mas_centerX);
            make.bottom.mas_equalTo(_timeLbl.mas_top).mas_offset(-8);
        }];
    }
    return _timeLbl;
}

-(UILabel *)fetalMoveCountLbl {
    if (_fetalMoveCountLbl == nil) {
        _fetalMoveCountLbl = [[UILabel alloc] init];
        _fetalMoveCountLbl.text = @"0";
        _fetalMoveCountLbl.font = [UIFont systemFontOfSize:18];
        _fetalMoveCountLbl.textColor = [UIColor mainColor];
        _fetalMoveCountLbl.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:_fetalMoveCountLbl];
        [_fetalMoveCountLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(60);
            make.centerY.mas_equalTo(self.timeLbl.mas_centerY).mas_offset(0);
            make.centerX.mas_equalTo(self.bottomView.mas_trailing).mas_offset(-66);
        }];
        
        UILabel *unitLbl = [[UILabel alloc] init];
        unitLbl.text = @"胎动次数";
        unitLbl.font = [UIFont systemFontOfSize:14];
        unitLbl.textColor = [UIColor textColor];
        [self.bottomView addSubview:unitLbl];
        [unitLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_fetalMoveCountLbl.mas_centerX);
            make.bottom.mas_equalTo(_fetalMoveCountLbl.mas_top).mas_offset(-8);
        }];
    }
    return _fetalMoveCountLbl;
}

-(UILabel *)fhrLbl {
    if (_fhrLbl == nil) {
        _fhrLbl = [[UILabel alloc] init];
        _fhrLbl.font = [UIFont systemFontOfSize:36];
        _fhrLbl.textColor = [UIColor mainColor];
        _fhrLbl.text = @"— — —";
        _fhrLbl.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:_fhrLbl];
        [_fhrLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(120);
            make.bottom.mas_equalTo(self.btnContainer.mas_top).mas_offset(-4);
            make.centerX.mas_equalTo(0);
            make.height.mas_equalTo(50);
        }];
        
        UILabel *unitLbl = [[UILabel alloc] init];
        unitLbl.text = @"次/分钟";
        unitLbl.font = [UIFont systemFontOfSize:14];
        unitLbl.textColor = [UIColor textColor];
        [self.bottomView addSubview:unitLbl];
        [unitLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(_fhrLbl.mas_trailing);
            make.centerY.mas_equalTo(_fhrLbl.mas_centerY).mas_offset(2);
        }];
    }
    return _fhrLbl;
}

-(UIImageView *)heartImg {
    if (_heartImg == nil) {
        _heartImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fetal_favorite_beating_heart_pic_big"]];
        _heartImg.hidden = true;
        [self.bottomView addSubview:_heartImg];
        [_heartImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(24);
            make.height.mas_equalTo(24);
            make.centerX.mas_equalTo(self.fhrLbl.mas_leading).mas_offset(-40);
            make.centerY.mas_equalTo(self.fhrLbl.mas_centerY).mas_offset(0);
        }];
    }
    return _heartImg;
}

-(void)startHeartAnimate {
    CGFloat newW = self.heartImg.frame.size.width == 24 ? 34 : (self.heartImg.frame.size.width == 34 ? 24 : 0);
    if (newW > 0) {
        [UIView animateWithDuration:YC_TXY_TIMER_LENGTH animations:^{
            [self.heartImg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(newW);
                make.height.mas_equalTo(newW);
            }];
        }];
    }
}

-(UIStackView *)btnContainer {
    if (_btnContainer == nil) {
        _btnContainer = [[UIStackView alloc] initWithArrangedSubviews:@[self.fetalMoveBtn, self.recordBtn]];
        _btnContainer.axis = UILayoutConstraintAxisHorizontal; // 水平方向布局
        _btnContainer.alignment = UIStackViewAlignmentFill; // 描述和 axis 垂直的元素之间的布局关系
        _btnContainer.distribution = UIStackViewDistributionFillEqually; // 描述和 axis 方向一致的元素之间的布局关系
        _btnContainer.spacing = 30.0;
        [self.bottomView addSubview:_btnContainer];
        [_btnContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(30);
            make.trailing.mas_equalTo(-30);
            make.bottom.mas_equalTo(-24);
            make.height.mas_equalTo(42);
        }];
    }
    return _btnContainer;
}

-(YCGradientButton *)fetalMoveBtn {
    if (_fetalMoveBtn == nil) {
        _fetalMoveBtn = [YCGradientButton buttonWithType:UIButtonTypeCustom];
        _fetalMoveBtn.frame = CGRectMake(0, 0, 136, 42);
        [_fetalMoveBtn addTarget:self action:@selector(handleFetalMoveAction:) forControlEvents:UIControlEventTouchUpInside];
        [_fetalMoveBtn setTitle:@"胎动标记" forState:UIControlStateNormal];
        _fetalMoveBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_fetalMoveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _fetalMoveBtn.layer.masksToBounds = true;
        _fetalMoveBtn.layer.cornerRadius = 21.0;
    }
    return _fetalMoveBtn;
}

-(YCGradientButton *)recordBtn {
    if (_recordBtn == nil) {
        _recordBtn = [YCGradientButton buttonWithType:UIButtonTypeCustom];
        _recordBtn.frame = CGRectMake(0, 0, 136, 42);
        [_recordBtn addTarget:self action:@selector(handleRecordAction:) forControlEvents:UIControlEventTouchUpInside];
        [_recordBtn setTitle:@"开始记录" forState:UIControlStateNormal];
        [_recordBtn setTitle:@"结束记录" forState:UIControlStateSelected];
        _recordBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _recordBtn.layer.masksToBounds = true;
        _recordBtn.layer.cornerRadius = 21.0;
    }
    return _recordBtn;
}

-(void)setIsRecording:(BOOL)isRecording {
    if (isRecording == true) {
        self.curRecordModel = [YCFHRecordModel modelWithValues:@[] moves:@[]];
    }
    
    _isRecording = isRecording;
}

-(BOOL)isConnected {
    return [SCBLEThermometer sharedThermometer].activePeripheral != nil
        && [[SCBLEThermometer sharedThermometer].activePeripheral.name isEqualToString:TXY_NAME];
}

@end
