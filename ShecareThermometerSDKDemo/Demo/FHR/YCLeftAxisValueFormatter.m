//
//  YCLeftAxisValueFormatter.m
//  Shecare
//
//  Created by mac on 2020/1/15.
//  Copyright © 2020 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCLeftAxisValueFormatter.h"

@implementation YCFHMYAxisValueFormatter

-(NSString *)stringForYValue:(NSInteger)index original:(NSString *)original {
    NSInteger origNum = (NSInteger)(original.doubleValue * 10);
    if ((origNum - 100) % 500 == 0) {
        return [NSString stringWithFormat:@"%@", @(origNum / 10)];
    } else {
        return @"";
    }
}

@end


@implementation YCFHMXAxisValueFormatter

-(NSString *)stringForXValue:(NSInteger)index original:(NSString *)original viewPortHandler:(ChartViewPortHandler *)viewPortHandler {
    if (index > 0 && index % 120 == 0) {
        return [NSString stringWithFormat:@"%@min", @(index / 120)];
    } else {
        return @"";
    }
}

@end



@implementation YCFHMFillFormatter

-(CGFloat)getFillLinePositionWithDataSet:(id<ILineChartDataSet>)dataSet dataProvider:(id<LineChartDataProvider>)dataProvider {
    return 110.0;
}

@end
