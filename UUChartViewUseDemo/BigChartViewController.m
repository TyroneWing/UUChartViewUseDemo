//
//  BigChartViewController.m
//  UUChartViewUseDemo
//
//  Created by yi on 15/11/25.
//  Copyright © 2015年 yi. All rights reserved.
//

#import "BigChartViewController.h"


#define   kWIN_WIDTH  [[UIScreen mainScreen] bounds].size.width
#define   kWIN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface BigChartViewController ()<UUChartDataSource>
{
    UUChart *chartView;
    UIView *_legendView;
    CGFloat _xFloat;
    CGFloat _yFloat;
    CGFloat _height;
    NSArray *colorArray;
    CGFloat _min;
    CGFloat _max;
}
@end

@implementation BigChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self create];
}
//单击手势
-(void)dealTap:(UITapGestureRecognizer *)tap
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)create
{
    colorArray = @[ChartFirstColor,ChartSecondColor,ChartThirdColor,ChartFourthColor,ChartFifthColor,ChartSixthColor,ChartSeventhColor,UUGreen,UURed,UUBrown,[UIColor blueColor],[UIColor yellowColor],UUButtonGrey,UUDarkYellow];
    _min = 0.0;
    _max = 0.0;
    _xFloat = 0.0;
    _yFloat = 0.0;
    _height = 0.0;
    if ([[_dict allKeys] containsObject:@"data"]) {
        NSArray *dataArr = _dict[@"data"];
        for (NSArray *arr in dataArr) {
            for (NSString *dataStr in arr) {
                double y = [dataStr doubleValue];
                if (y > _max) {
                    _max = y;
                }
                if (y < _min) {
                    _min = y;
                }
            }
        }
    }
    
    [self createchartView];
}


- (void)createchartView
{
    if (chartView) {
        [chartView removeFromSuperview];
        chartView = nil;
    }
    if (_legendView) {
        [_legendView removeFromSuperview];
        _legendView = nil;
    }

    _legendView = [[UIView alloc] initWithFrame:CGRectMake(40, 10, [UIScreen mainScreen].bounds.size.height-60, _height)];
    NSArray *arr = _dict[@"legend"];
    int legendCount = (int)arr.count;
    if (legendCount > 0) {
        for (int i = 0; i < legendCount; i++) {
            
            UIView *legColorView = [[UIView alloc] init];
            legColorView.layer.cornerRadius = 3;
            legColorView.backgroundColor = colorArray[i];
            [_legendView addSubview:legColorView];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.selected = YES;
            btn.tag = 8000 + i;
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            UIFont *font = [UIFont fontWithName:@"Arial" size:16];
            btn.titleLabel.font = font;
            CGSize size = CGSizeMake(200,2000);
            [btn setTitle:arr[i] forState:UIControlStateSelected];
            [btn setTitle:arr[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            CGSize labelsize = [arr[i] sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
            
            if (_xFloat + labelsize.width +30 > kWIN_HEIGHT-40) {
                _xFloat = 0;
                _yFloat += labelsize.height+5;
            }
            btn.frame = CGRectMake(_xFloat+16*2, _yFloat, labelsize.width, labelsize.height);
            if (labelsize.height-15>0) {
                legColorView.frame = CGRectMake(_xFloat, _yFloat+(labelsize.height-15)/2, 15*2, 15);
            } else {
                legColorView.frame = CGRectMake(_xFloat, _yFloat-(15-labelsize.height)/2, 15*2, 15);
            }
            //            label.textColor = colorArray[i];
            [_legendView addSubview:btn];
            _xFloat += labelsize.width + 40;
            if (i == legendCount-1) {
                _height = _yFloat +labelsize.height+10;
            }
        }
    }
    _legendView.frame = CGRectMake(40, 10, [UIScreen mainScreen].bounds.size.height-60, _height);
    [self.view addSubview:_legendView];
    
    chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, _height+5, [UIScreen mainScreen].bounds.size.height-20, kWIN_WIDTH-_height-10)
                                              withSource:self
                                               withStyle:_type];
    chartView.showRange = YES;
    [self.view addSubview:chartView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dealTap:)];
    [chartView addGestureRecognizer:tap];
    [chartView strokeChart];
}
- (void)btnClick:(UIButton *)btn
{
    if (chartView.chartStyle == UUChartLineStyle) {
        
        if (btn.selected) {
            btn.selected = 0;
            CAShapeLayer *chartLine = chartView.lineChart.lineArray[btn.tag-8000];
            chartLine.lineWidth = 0;
            NSArray *a = chartView.lineChart.lineLabelArray[btn.tag-8000];
            for (UIView *view in a) {
                view.alpha = 0;
            }
            NSArray *b = chartView.lineChart.linePointArray[btn.tag-8000];
            for (UIView *pointView in b) {
                pointView.alpha = 0;
            }
        } else {
            btn.selected = 1;
            CAShapeLayer *chartLine = chartView.lineChart.lineArray[btn.tag-8000];
            chartLine.lineWidth = 2;
            NSArray *a = chartView.lineChart.lineLabelArray[btn.tag-8000];
            for (UIView *view in a) {
                view.alpha = 1;
            }
            NSArray *b = chartView.lineChart.linePointArray[btn.tag-8000];
            for (UIView *pointView in b) {
                pointView.alpha = 1;
            }
        }
    }
}
#pragma mark - @required
//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    NSArray *arr = _dict[@"item"];
    return arr;
}
//数值多重数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    return _dict[@"data"];
}

#pragma mark - @optional
//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return colorArray;
}
//显示数值范围
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    return CGRangeMake(_max+1, _min);
}


//标记数值区域
- (CGRange)UUChartMarkRangeInLineChart:(UUChart *)chart
{
    
    return CGRangeMake(25, 75);
}

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

//判断显示最大最小值(所有数值)
- (BOOL)UUChart:(UUChart *)chart ShowMaxMinAtIndex:(NSInteger)index
{
    return YES;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
