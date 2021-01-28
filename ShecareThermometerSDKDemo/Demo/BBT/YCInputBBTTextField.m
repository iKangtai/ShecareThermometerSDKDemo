//
//  YCInputBBTTextField.m
//  Shecare
//
//  Created by mac on 2019/4/22.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCInputBBTTextField.h"
#import <Masonry/Masonry.h>

@interface YCInputNumberCell : UICollectionViewCell

@property (nonatomic, copy) NSString *number;
@property (strong, nonatomic) UILabel *textLbl;
@property (strong, nonatomic) UIView *underLineView;

@end

@implementation YCInputNumberCell

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    [self textLbl];
    [self underLineView];
}

-(void)setNumber:(NSString *)number {
    _number = number;
    
    // “_” 表示 该位置未输入
    NSString *newNum = [number stringByReplacingOccurrencesOfString:@"_" withString:@""];
//    self.underLineView.hidden = !IS_EMPTY_STRING(newNum);
    self.underLineView.hidden = [newNum isEqualToString:@"."];
    self.textLbl.text = newNum;
}

#pragma mark - Lazy Load

-(UILabel *)textLbl {
    if (_textLbl == nil) {
        _textLbl = [[UILabel alloc] init];
        _textLbl.textAlignment = NSTextAlignmentCenter;
        _textLbl.font = [UIFont systemFontOfSize:16];
        _textLbl.textColor = [UIColor textColor];
        [self.contentView addSubview:_textLbl];
        [_textLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.mas_width);
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(-2);
            make.top.mas_equalTo(0);
        }];
    }
    return _textLbl;
}

-(UIView *)underLineView {
    if (_underLineView == nil) {
        _underLineView = [[UIView alloc] init];
        _underLineView.backgroundColor = [UIColor colorWithHex:0x979797];
        [self.contentView addSubview:_underLineView];
        [_underLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(9);
            make.bottom.mas_equalTo(self.textLbl.mas_bottom);
            make.centerX.mas_equalTo(self.textLbl.mas_centerX);
            make.height.mas_equalTo(1);
        }];
    }
    return _underLineView;
}

@end

@interface YCInputTimeCell : UICollectionViewCell

@property (nonatomic, copy) NSString *number;
@property (strong, nonatomic) UILabel *textLbl;
@property (strong, nonatomic) UIView *underLineView;

@end

@implementation YCInputTimeCell

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    [self textLbl];
    [self underLineView];
}

-(void)setNumber:(NSString *)number {
    _number = number;
    
    // “_” 表示 该位置未输入
    NSString *newNum = [number stringByReplacingOccurrencesOfString:@"_" withString:@""];
    self.textLbl.text = newNum;
    if ([number isEqualToString:@":"]) {
        self.underLineView.hidden = true;
    } else {
        self.underLineView.hidden = false;
    }
}

#pragma mark - Lazy Load

-(UILabel *)textLbl {
    if (_textLbl == nil) {
        _textLbl = [[UILabel alloc] init];
        _textLbl.textAlignment = NSTextAlignmentCenter;
        _textLbl.font = [UIFont systemFontOfSize:16];
        _textLbl.textColor = [UIColor textColor];
        [self.contentView addSubview:_textLbl];
        [_textLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.mas_width);
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(-2);
            make.top.mas_equalTo(0);
        }];
    }
    return _textLbl;
}

-(UIView *)underLineView {
    if (_underLineView == nil) {
        _underLineView = [[UIView alloc] init];
        _underLineView.backgroundColor = [UIColor colorWithHex:0x979797];
        [self.contentView addSubview:_underLineView];
        [_underLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(9);
            make.bottom.mas_equalTo(self.textLbl.mas_bottom).mas_offset(2);
            make.centerX.mas_equalTo(self.textLbl.mas_centerX);
            make.height.mas_equalTo(1);
        }];
    }
    return _underLineView;
}

@end



static NSString *inputBBTTFReuseID = @"YCInputBBTTFReuseID";

@interface YCInputBBTTextField()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *contentView;
@property (strong, nonatomic) NSArray <NSString *>*numbers;

@end

@implementation YCInputBBTTextField

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    [self contentView];
    self.layer.masksToBounds = false;
    self.numbers = [self numbersWithText:@"" length:4];
}

-(void)dealloc {
    NSLog(@"%@--%s", self.class, __func__);
}

-(void)reloadDataWithText:(NSString *)text length:(NSUInteger)length {
    self.numbers = [self numbersWithText:text length:length];
    [self.contentView reloadData];
}

-(NSArray *)numbersWithText:(NSString *)text length:(NSUInteger)length {
    NSMutableArray *resultM = [NSMutableArray array];
    for (int i = 0; i < text.length; i++) {
        NSString *subI = [text substringWithRange:NSMakeRange(i, 1)];
        if (subI != nil) {
            [resultM addObject:subI];
        }
    }
    for (int i = 0; i < length - text.length; i++) {
        [resultM addObject:@"_"];
    }
    [resultM addObject:@"℃"];
    [resultM insertObject:@"." atIndex:resultM.count - 3];
    return resultM.copy;
}

-(NSString *)currentNumbers {
    NSMutableString *resultM = [NSMutableString string];
    for (NSString *strI in self.numbers) {
        if (!IS_EMPTY_STRING(strI) && ![strI isEqualToString:@"."] && ![strI isEqualToString:@"℃"] && ![strI isEqualToString:@"℉"]) {
            [resultM appendString:strI];
        }
    }
    return resultM.copy;
}

-(NSString *)currentNumbersFilledWithZero {
    NSMutableString *resultM = [NSMutableString string];
    for (NSString *strI in self.numbers) {
        if ([strI isEqualToString:@"_"]) {
            [resultM appendString:@"0"];
        } else if (!IS_EMPTY_STRING(strI) && ![strI isEqualToString:@"."] && ![strI isEqualToString:@"℃"] && ![strI isEqualToString:@"℉"]) {
            [resultM appendString:strI];
        }
    }
    return resultM.copy;
}

-(CGFloat)value {
    NSMutableString *resultM = [NSMutableString string];
    for (NSString *strI in self.numbers) {
        if ([strI isEqualToString:@"_"]) {
            [resultM appendString:@"0"];
        } else if (!IS_EMPTY_STRING(strI) && ![strI isEqualToString:@"℃"] && ![strI isEqualToString:@"℉"]) {
            [resultM appendString:strI];
        }
    }
    return [resultM.copy doubleValue];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numbers.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *number = self.numbers[indexPath.item];
    YCInputNumberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:inputBBTTFReuseID forIndexPath:indexPath];
    cell.number = number;
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *number = self.numbers[indexPath.item];
    if ([number isEqualToString:@"."]) {
        return CGSizeMake(8, 28);
    } else if ([number isEqualToString:@"℃"] || [number isEqualToString:@"℉"]) {
        return CGSizeMake(24, 28);
    } else {
        return CGSizeMake(12, 28);
    }
}

#pragma mark - Lazy Load

-(UICollectionViewFlowLayout *)layout {
    if (_layout == nil) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.sectionInset = UIEdgeInsetsZero;
        _layout.minimumInteritemSpacing = 3.0;
    }
    return _layout;
}

-(UICollectionView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _contentView.backgroundColor = [UIColor whiteColor];
        [_contentView registerClass:[YCInputNumberCell class] forCellWithReuseIdentifier:inputBBTTFReuseID];
        _contentView.delegate = self;
        _contentView.dataSource = self;
        _contentView.scrollEnabled = false;
        _contentView.layer.masksToBounds = false;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(90);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
    return _contentView;
}

@end


static NSString *inputTimeTFReuseID = @"YCInputTimeTFReuseID";

@interface YCInputTimeTextField()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *contentView;
@property (strong, nonatomic) NSArray <NSString *>*numbers;

@end

@implementation YCInputTimeTextField

-(instancetype)initWithFrame:(CGRect)frame time:(NSDate *)time {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        self.time = time;
    }
    return self;
}

-(void)setupUI {
    [self contentView];
    self.layer.masksToBounds = false;
}

-(void)dealloc {
    NSLog(@"%@--%s", self.class, __func__);
}

-(void)setTime:(NSDate *)time {
    _time = time;
    self.numbers = [self numbersWithText:[NSString stringWithFormat:@"%02ld%02ld", time.hour, time.minute] length:4];
    [self.contentView reloadData];
}

-(NSArray *)numbersWithText:(NSString *)text length:(NSUInteger)length {
    NSMutableArray *resultM = [NSMutableArray array];
    for (int i = 0; i < text.length; i++) {
        NSString *subI = [text substringWithRange:NSMakeRange(i, 1)];
        if (subI != nil) {
            [resultM addObject:subI];
        }
    }
    for (int i = 0; i < length - text.length; i++) {
        [resultM addObject:@"_"];
    }
    [resultM insertObject:@":" atIndex:resultM.count - 2];
    return resultM.copy;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numbers.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *number = self.numbers[indexPath.item];
    YCInputTimeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:inputTimeTFReuseID forIndexPath:indexPath];
    cell.number = number;
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *number = self.numbers[indexPath.item];
    if ([number isEqualToString:@":"]) {
        return CGSizeMake(8, 28);
    } else {
        return CGSizeMake(12, 28);
    }
}

#pragma mark - Lazy Load

-(UICollectionViewFlowLayout *)layout {
    if (_layout == nil) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.sectionInset = UIEdgeInsetsZero;
        _layout.minimumInteritemSpacing = 3.0;
    }
    return _layout;
}

-(UICollectionView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _contentView.backgroundColor = [UIColor whiteColor];
        [_contentView registerClass:[YCInputTimeCell class] forCellWithReuseIdentifier:inputTimeTFReuseID];
        _contentView.delegate = self;
        _contentView.dataSource = self;
        _contentView.scrollEnabled = false;
        _contentView.layer.masksToBounds = false;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(90);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
    return _contentView;
}

@end
