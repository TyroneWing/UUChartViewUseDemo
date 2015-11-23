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
    [self startDowmloadData:13];
    [self startDowmloadareaWarningData];
//    [self addBtn];
}

- (void)startDowmloadData:(int)time
{
    NSString *url = [NSString stringWithFormat:@"http://112.74.195.125:8080/capi/statistics/water/averageByMpCustom/6/1/2015-11-%02d/2015-11-19",time];
//    NSString *url = @"http://112.74.195.125:8080/capi/statistics/mp/areaWarning";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        _chartDict = dict;
        
        NSLog(@"----%@",dict);
        NSIndexSet *nd=[[NSIndexSet alloc]initWithIndex:0];
        [_tableView reloadSections:nd withRowAnimation:UITableViewRowAnimationAutomatic];
     
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


- (void)startDowmloadareaWarningData
{
    NSString *url = @"http://112.74.195.125:8080/capi/statistics/mp/areaWarning";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFCompoundResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        _barChartDict = dict;
        
        NSLog(@"_barChartDict = %@",dict);
        NSLog(@"----%@",dict);
        NSIndexSet *nd=[[NSIndexSet alloc]initWithIndex:1];
//        [_tableView reloadSections:nd withRowAnimation:UITableViewRowAnimationAutomatic];
        [_tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)addBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(300, 300, 100, 100);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [_tableView addSubview:btn];
}

- (void)btnClick
{
    [self startDowmloadData:5];
}

-(void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
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
    
    NSLog(@"%d --- %p",indexPath.row,cell);
    cell.indexPath = indexPath;
    if (indexPath.row == 0) {
        cell.dict = _chartDict;
    } else if (indexPath.row == 1) {
        cell.dict = _barChartDict;
    }
    
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
    label.font = [UIFont systemFontOfSize:30];
    label.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.3];
    label.text = section ? @"Bar":@"Line";
    label.textColor = [UIColor colorWithRed:0.257 green:0.650 blue:0.478 alpha:1.000];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
