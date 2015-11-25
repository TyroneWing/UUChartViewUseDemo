//
//  ChartCell.h
//  UUChartViewUseDemo
//
//  Created by yi on 15/11/18.
//  Copyright © 2015年 yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartCell : UITableViewCell
@property (nonatomic,strong) NSDictionary *dict;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic, copy) void (^tapBlock)();
@end
