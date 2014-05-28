//
//  DataNewsViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-5-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "DataNewsViewController.h"
#import "DataNewsCell.h"
#import "EveryDataNewsViewController.h"
@interface DataNewsViewController ()
{
    NSMutableArray *m_dataArray;
    UITableView *m_myTableView;
}
@end

@implementation DataNewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"每日一闻" withBackButton:YES];
    
    m_dataArray = (NSMutableArray *)[DataStoreManager qureyFirstOfgame];
    m_myTableView =[[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    m_myTableView.rowHeight = 164;
    m_myTableView.delegate = self;
    m_myTableView.dataSource =self;
    m_myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    m_myTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_myTableView];
    
    // Do any additional setup after loading the view.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    DataNewsCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[DataNewsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    
    cell.gameIconImg.imageURL =[ NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")]]];
    cell.bigImg.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"content"), @"img")]];
    cell.titleLabel.text = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"content"), @"title");
    cell.timeLabel.text =[self getDataWithTimeMiaoInterval: [GameCommon getNewStringWithId: KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"content"), @"time")]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *dic =[ m_dataArray objectAtIndex:indexPath.row];
    EveryDataNewsViewController *ever = [[EveryDataNewsViewController alloc]init];
    ever.gameid =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")];
    [self.navigationController pushViewController:ever animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSString*)getDataWithTimeMiaoInterval:(NSString*)timeInterval
{
    if ([NSString stringWithFormat:@"%.f", [timeInterval doubleValue]].length < 10) {
        return timeInterval;
    }
    NSString* timeStr = [timeInterval substringToIndex:timeInterval.length-3];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];//location设置为中国
    [dateFormatter setDateFormat:@"HH:mm"];
    
    double time = [timeStr doubleValue];
    NSLog(@"%@", [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]]);
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
