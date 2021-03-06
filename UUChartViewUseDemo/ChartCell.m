//
//  ChartCell.m
//  UUChartViewUseDemo
//
//  Created by yi on 15/11/18.
//  Copyright © 2015年 yi. All rights reserved.
//

#import "ChartCell.h"
#import "UUChart.h"

#define   kWIN_WIDTH  [[UIScreen mainScreen] bounds].size.width
#define   kWIN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface ChartCell ()<UUChartDataSource>
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

@implementation ChartCell

- (void)awakeFromNib {
    // Initialization code
    
}
- (void)setDict:(NSDictionary *)dict
{
    colorArray = @[ChartFirstColor,ChartSecondColor,ChartThirdColor,ChartFourthColor,ChartFifthColor,ChartSixthColor,ChartSeventhColor,UUGreen,UURed,UUBrown,[UIColor blueColor],[UIColor yellowColor],UUButtonGrey,UUDarkYellow];
    _min = 0.0;
    _max = 0.0;
    _xFloat = 0.0;
    _yFloat = 0.0;
    _height = 0.0;
    _dict = dict;
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

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
//        [self createchartView];
    }
    return self;
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
    _legendView.userInteractionEnabled = YES;
    [self.contentView addSubview:_legendView];
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

            UIFont *font = [UIFont fontWithName:@"Arial" size:12];
            btn.titleLabel.font = font;
            CGSize size = CGSizeMake(200,2000);
            [btn setTitle:arr[i] forState:UIControlStateSelected];
            [btn setTitle:arr[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//            label.text = arr[i];
            CGSize labelsize = [arr[i] sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
            
            if (_xFloat + labelsize.width +25 > kWIN_WIDTH-40) {
                _xFloat = 0;
                _yFloat += labelsize.height+5;
            }
            btn.frame = CGRectMake(_xFloat+16, _yFloat, labelsize.width, labelsize.height );
            if (labelsize.height-10>0) {
                legColorView.frame = CGRectMake(_xFloat, _yFloat+(labelsize.height-10)/2, 15, 10);
            } else {
                legColorView.frame = CGRectMake(_xFloat, _yFloat-(10-labelsize.height)/2, 15, 10);
                
            }
            //            label.textColor = colorArray[i];
            [_legendView addSubview:btn];
            _xFloat += labelsize.width + 25;
            if (i == legendCount-1) {
                _height = _yFloat +labelsize.height+10;
            }
        }
    }
    _legendView.frame = CGRectMake(40, 10, [UIScreen mainScreen].bounds.size.width-60, _height);
    
    chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, _height, [UIScreen mainScreen].bounds.size.width-20, 150)
                                              withSource:self
                                               withStyle:_indexPath.row==1?UUChartBarStyle:UUChartLineStyle];
    /**
     当柱状图风格为UUChartBarStyle时修改 strokeChart 函数可以修改柱状图样式
     */
//    chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 60, [UIScreen mainScreen].bounds.size.width-20, 150)
//                                              withSource:self
//                                               withStyle:UUChartBarStyle];

    //创建一个单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dealTap:)];
    [chartView addGestureRecognizer:tap];
    chartView.showRange = YES;
    [self.contentView addSubview:chartView];
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

//单击手势
-(void)legendLabelTap:(UITapGestureRecognizer *)tap
{
    
    if (chartView.chartStyle == UUChartLineStyle) {

        CAShapeLayer *chartLine = chartView.lineChart.lineArray[tap.view.tag-8000];
        chartLine.lineWidth = 0;
        NSArray *a = chartView.lineChart.lineLabelArray[tap.view.tag-8000];
        for (UIView *view in a) {
            view.alpha = 0;
        }
        NSArray *b = chartView.lineChart.linePointArray[tap.view.tag-8000];
        for (UIView *pointView in b) {
            pointView.alpha = 0;
        }
    }
    
}

//单击手势
-(void)dealTap:(UITapGestureRecognizer *)tap
{
    if (self.tapBlock) {
        self.tapBlock();
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
