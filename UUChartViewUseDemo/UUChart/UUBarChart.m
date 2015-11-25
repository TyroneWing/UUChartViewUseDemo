//
//  UUBarChart.m
//  UUChartDemo
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUBarChart.h"
#import "UUChartLabel.h"
#import "UUBar.h"

//柱状图柱子个数
#define barCount  5

@interface UUBarChart ()
{
    UIScrollView *myScrollView;
}
@end

@implementation UUBarChart {
    NSHashTable *_chartLabelsForX;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        myScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(UUYLabelwidth, 0, frame.size.width-UUYLabelwidth, frame.size.height)];
        myScrollView.showsHorizontalScrollIndicator = NO;
        myScrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:myScrollView];
    }
    return self;
}

-(void)setYValues:(NSArray *)yValues
{
    _yValues = yValues;
    [self setYLabels:yValues];
}

-(void)setYLabels:(NSArray *)yLabels
{
    NSInteger max = 0;
    NSInteger min = 1000000000;
    for (NSArray * ary in yLabels) {
        for (NSString *valueString in ary) {
            NSInteger value = [valueString integerValue];
            if (value > max) {
                max = value;
            }
            if (value < min) {
                min = value;
            }
        }
    }
    if (max < 5) {
        max = 5;
    }
    if (self.showRange) {
        _yValueMin = (int)min;
    }else{
        _yValueMin = 0;
    }
    _yValueMax = (int)max;
    
    if (_chooseRange.max!=_chooseRange.min) {
        _yValueMax = _chooseRange.max;
        _yValueMin = _chooseRange.min;
    }

    float level = (_yValueMax-_yValueMin) /4.0;
    CGFloat chartCavanHeight = self.frame.size.height - UULabelHeight*3;
    CGFloat levelHeight = chartCavanHeight /4.0;
    
    for (int i=0; i<5; i++) {
        UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake(0.0,chartCavanHeight-i*levelHeight+5, UUYLabelwidth, UULabelHeight)];
        int va = (int)((level*i+_yValueMin)*10);
        if (va%10 == 0) {
            label.text = [NSString stringWithFormat:@"%d",(int)(level * i+_yValueMin)];
        } else {
            label.text = [NSString stringWithFormat:@"%.1f",level * i+_yValueMin];
        }
        label.adjustsFontSizeToFitWidth = YES;
		[self addSubview:label];
    }
    
    //画横线
    for (int i=0; i<5; i++) {
        if ([_ShowHorizonLine[i] integerValue]>0) {
            
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(UUYLabelwidth,UULabelHeight+i*levelHeight)];
            [path addLineToPoint:CGPointMake(self.frame.size.width,UULabelHeight+i*levelHeight)];
            [path closePath];
            shapeLayer.path = path.CGPath;
            shapeLayer.strokeColor = [[[UIColor blackColor] colorWithAlphaComponent:0.05] CGColor];
            shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
            shapeLayer.lineWidth = 1;
            [self.layer addSublayer:shapeLayer];
        }
    }

}

-(void)setXLabels:(NSArray *)xLabels
{
    if( !_chartLabelsForX ){
        _chartLabelsForX = [NSHashTable weakObjectsHashTable];
    }
    
    _xLabels = xLabels;
    NSInteger num;
    if (xLabels.count>=barCount) {
        num = barCount;
    }
//    else if (xLabels.count<=4){
//        num = 4;
//    }
    else{
        num = xLabels.count;
    }
    _xLabelWidth = myScrollView.frame.size.width/num;
    for (int i=0; i<xLabels.count; i++) {
        UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake((i *  _xLabelWidth ), self.frame.size.height - (UULabelHeight*2-2), _xLabelWidth, UULabelHeight*2-2)];
        label.text = xLabels[i];
        label.numberOfLines = 0;

        label.font = [UIFont systemFontOfSize:10];
        label.adjustsFontSizeToFitWidth = YES;
        [myScrollView addSubview:label];
        [_chartLabelsForX addObject:label];
    }
    
    float max = (([xLabels count]-1)*_xLabelWidth + chartMargin)+_xLabelWidth;
    if (myScrollView.frame.size.width < max-10) {
        myScrollView.contentSize = CGSizeMake(max, self.frame.size.height);
    } else {
        //画竖线
        for (int i=0; i<xLabels.count+1; i++) {
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(UUYLabelwidth+i*_xLabelWidth,UULabelHeight)];
            [path addLineToPoint:CGPointMake(UUYLabelwidth+i*_xLabelWidth,self.frame.size.height-2*UULabelHeight)];
            [path closePath];
            shapeLayer.path = path.CGPath;
            shapeLayer.strokeColor = [[[UIColor blackColor] colorWithAlphaComponent:0.1] CGColor];
            shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
            shapeLayer.lineWidth = 1;
            [self.layer addSublayer:shapeLayer];
        }
    }
}

-(void)setColors:(NSArray *)colors
{
	_colors = colors;
}

- (void)setChooseRange:(CGRange)chooseRange
{
    _chooseRange = chooseRange;
}

//柱状图（一柱状图或者二柱状图）
-(void)strokeChart
{
    CGFloat chartCavanHeight = self.frame.size.height - UULabelHeight*3;
    for (int i=0; i<_yValues.count; i++) {
        if (i==2)
            return;
        NSArray *childAry = _yValues[i];
        for (int j=0; j<childAry.count; j++) {
            NSString *valueString = childAry[j];
            float value = [valueString floatValue];
            float grade = ((float)value-_yValueMin) / ((float)_yValueMax-_yValueMin);
            UUBar * bar = [[UUBar alloc] initWithFrame:CGRectMake((j+(_yValues.count==1?0.1:0.05))*_xLabelWidth +i*_xLabelWidth * 0.47, UULabelHeight, _xLabelWidth * (_yValues.count==1?0.8:0.45), chartCavanHeight)];
            bar.barColor = [_colors objectAtIndex:i];
            bar.grade = grade;
            [myScrollView addSubview:bar];
            bar.alpha = 1.0;
            if (value != 0.0) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(bar.frame.origin.x,(1 - grade) * bar.frame.size.height - 1 ,bar.frame.size.width,10)];
                label.textColor = [_colors objectAtIndex:i];
                label.font = [UIFont systemFontOfSize:12];
                label.textAlignment = NSTextAlignmentCenter;
                label.text = [NSString stringWithFormat:@"%g",value];
                label.adjustsFontSizeToFitWidth = YES;
                [myScrollView addSubview:label];
            }
        }
    }
}

////多柱状图
//-(void)strokeChart
//{
//#pragma mark - 只能两组柱状图
//    CGFloat chartCavanHeight = self.frame.size.height - UULabelHeight*3;
//	
//    for (int i=0; i<_yValues.count; i++) {
//        NSArray *childAry = _yValues[i];
//        for (int j=0; j<childAry.count; j++) {
//            NSString *valueString = childAry[j];
//            float value = [valueString floatValue];
//            float grade = ((float)value-_yValueMin) / ((float)_yValueMax-_yValueMin);
//            UUBar * bar = [[UUBar alloc] initWithFrame:CGRectMake(j*_xLabelWidth +i*_xLabelWidth/_yValues.count, UULabelHeight, _xLabelWidth/_yValues.count, chartCavanHeight)];
//            bar.barColor = [_colors objectAtIndex:i];
//            bar.grade = grade;
//            [myScrollView addSubview:bar];
//            bar.alpha = 1.0;
//            if (value != _chooseRange.min) {
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(bar.frame.origin.x,(1 - grade) * bar.frame.size.height ,bar.frame.size.width,10)];
//            label.textColor = [_colors objectAtIndex:i];
//            label.font = [UIFont systemFontOfSize:12];
//            label.textAlignment = NSTextAlignmentCenter;
//            label.text = [NSString stringWithFormat:@"%g",value];
//            label.adjustsFontSizeToFitWidth = YES;
//            [myScrollView addSubview:label];
//            }
//        }
//    }
//}

- (NSArray *)chartLabelsForX
{
    return [_chartLabelsForX allObjects];
}


- (void)setShowHorizonLine:(NSMutableArray *)ShowHorizonLine
{
    _ShowHorizonLine = ShowHorizonLine;
}


@end
