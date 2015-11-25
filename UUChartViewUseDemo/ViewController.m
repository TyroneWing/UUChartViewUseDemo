//
//  ViewController.m
//  UUChartViewUseDemo
//
//  Created by yi on 15/11/18.
//  Copyright © 2015年 yi. All rights reserved.
//

#import "ViewController.h"
#import "ChartCell.h"
#import <AFNetworking.h>
#define   kWIN_WIDTH  [[UIScreen mainScreen] bounds].size.width
#define   kWIN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#import "BigChartViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableDictionary *_chartDict;
    NSMutableDictionary *_barChartDict;

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _chartDict = [[NSMutableDictionary alloc] init];
    _barChartDict = [[NSMutableDictionary alloc] init];

    [self createTableView];
    [self startDowmloadData:12];
    [self startDowmloadareaWarningData];
    
}

- (void)startDowmloadData:(int)time
{
    NSString *url = [NSString stringWithFormat:@"http://112.74.195.125:8080/capi/statistics/water/averageByMpCustom/6/1/2015-11-%02d/2015-11-25",time];
//    NSString *url = @"http://112.74.195.125:8080/capi/statistics/mp/areaWarning";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        _chartDict = dict;
        
//        NSIndexSet *nd=[[NSIndexSet alloc]initWithIndex:0];
//        [_tableView reloadSections:nd withRowAnimation:UITableViewRowAnimationAutomatic];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


- (void)startDowmloadareaWarningData
{
    NSString *url = @"http://112.74.195.125:8080/capi/statistics/mp/areaWarning";
//    NSString *url =@"http://112.74.195.125:8080/capi/statistics/mp/highRisk";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        _barChartDict = dict;
        
//        NSIndexSet *nd=[[NSIndexSet alloc]initWithIndex:1];
//        [_tableView reloadSections:nd withRowAnimation:UITableViewRowAnimationAutomatic];
//        [_tableView reloadData];
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:1 inSection:0];
        [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}



- (void)btnClick
{
    [self startDowmloadData:arc4random()%10+10];
}

-(void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWIN_WIDTH, kWIN_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
    
}




#pragma mark - UITableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ChartCell";
    
    ChartCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[ChartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.indexPath = indexPath;
    if (indexPath.row == 0) {
        cell.dict = _chartDict;
    } else if (indexPath.row == 1) {
        cell.dict = _barChartDict;
    }
    
    [cell setTapBlock:^{
        BigChartViewController *bigChartVC = [[BigChartViewController alloc] init];
        bigChartVC.dict = cell.dict;
        bigChartVC.type = cell.indexPath.row;
        [self.navigationController pushViewController:bigChartVC animated:YES];
        
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 250;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , 30);
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:20];
    label.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.3];
    label.text = @"LineChart And BarChart";
    label.textColor = [UIColor colorWithRed:0.257 green:0.650 blue:0.478 alpha:1.000];
    label.textAlignment = NSTextAlignmentCenter;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 30);
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"Reload" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [label addSubview:btn];
    label.userInteractionEnabled = YES;
    return label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
