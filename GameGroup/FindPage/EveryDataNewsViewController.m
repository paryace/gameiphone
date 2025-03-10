//
//  EveryDataNewsViewController.m
//  GameGroup
//
//  Created by admin on 14-3-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "EveryDataNewsViewController.h"
#import "TestViewController.h"
#import "OnceDynamicViewController.h"
#import "PhotoViewController.h"
#import "EGOImageView.h"
@interface EveryDataNewsViewController ()
{
    UITableView *m_myTableView;
    NSMutableArray *m_tableArray;
    NSInteger    *m_pageNum;
    NSMutableDictionary *dictDic;

}
@end

@implementation EveryDataNewsViewController

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
    m_pageNum =0;
    m_tableArray = [NSMutableArray array];
    [m_tableArray addObjectsFromArray:[DataStoreManager qureyAllNewsMessageWithGameid:self.gameid]];
    
   
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX-20, self.view.bounds.size.width, self.view.bounds.size.height-startX+20) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.rowHeight = 440;
    m_myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    m_myTableView.contentOffset = CGPointMake(0,m_myTableView.bounds.size.height*(m_tableArray.count-1));
    [self.view addSubview:m_myTableView];
    
    UILabel *headerView = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 320, 20 )];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.text = @"没有更多的新闻";
    headerView.font = [UIFont boldSystemFontOfSize:12];
    headerView.textColor = [UIColor grayColor];
    headerView.textAlignment = NSTextAlignmentCenter;
    m_myTableView.tableHeaderView = headerView;
    
    
    [self setTopViewWithTitle:@"" withBackButton:YES];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, KISHighVersion_7 ? 64 : 44)];
    titleLabel.center = CGPointMake(170, KISHighVersion_7 ? 42 : 22);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"每日一闻";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:titleLabel];
    
    EGOImageView *imageView = [[EGOImageView alloc]initWithFrame:CGRectMake(titleLabel.frame.origin.x-30, KISHighVersion_7 ? 27 : 7, 30, 30)];
    
    NSString * imageId =[GameCommon putoutgameIconWithGameId:self.gameid];
    imageView.imageURL = [ImageService getImageUrl4:imageId];
    [self.view addSubview:imageView];
    
    dictDic = [NSMutableDictionary dictionary];
	// Do any additional setup after loading the view.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_tableArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCell";
    DayNewsCell *cell = (DayNewsCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[DayNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.myCellDelegate = self;
    cell.tag =indexPath.row;
        NSDictionary *dic= [m_tableArray objectAtIndex:indexPath.row];
    NSString * time=KISDictionaryHaveKey(dic, @"time");
    cell.topTimeLabel.text =[self getDataWithTimeMiaoInterval: [GameCommon getNewStringWithId:
                                                                time]];
    cell.topTimeLabel.frame = CGRectMake((320-cell.topTimeLabel.text.length*12)/2, 5, cell.topTimeLabel.text.length*12, 20);
    
    NSString * imageids = KISDictionaryHaveKey(dic, @"userImg");
    cell.headImageBtn.imageURL = [ImageService getImageStr:imageids Width:80];
    
    cell.headImageBtn.tag = indexPath.row;
    [cell.headImageBtn addTarget:self action:@selector(enterToPerson:) forControlEvents:UIControlEventTouchUpInside];
    cell.nickNameLabel .text= KISDictionaryHaveKey(dic, @"nickname");
    
    cell.nickNameLabel.frame = CGRectMake(62, 18, cell.nickNameLabel.text.length*18, 15);
    cell.nickNameBtn.frame = cell.nickNameLabel.frame;
    [cell.nickNameBtn addTarget:self action:@selector(enterToPerson:) forControlEvents:UIControlEventTouchUpInside];
    cell.nickNameBtn.tag = indexPath.row;
    
    cell.bianzheLabel.frame = CGRectMake(cell.nickNameBtn.frame.size.width+64, 20, 70, 15);
        cell.signatureLabel.text = KISDictionaryHaveKey(dic, @"editorNote");
    
    NSString * imageId = KISDictionaryHaveKey(dic, @"img");
    cell.bigImageView.imageURL = [ImageService getImageUrl:imageId Width:540 Height:360];
    
    
        cell.authorLabel.text = KISDictionaryHaveKey(dic, @"imgQuote");
        cell.NumLabel.text =[self getDataWithTimeDataInterval: [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"time")]];
                             
    cell.timeLabel.text = [self getDataWithTimeInterval: [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"time")]];
        cell.titleLabel.text = KISDictionaryHaveKey(dic, @"title");
    
    if (cell.titleLabel.text.length>9) {
        cell.titleLabel.frame =CGRectMake(100, 280, 190, 45);
    }else {
        cell.titleLabel.frame =CGRectMake(100, 280, 190, 20);
    }
    cell.contentLabel.frame = CGRectMake(100, cell.titleLabel.frame.origin.y+cell.titleLabel.frame.size.height-5, 190, 70);
    
        cell.contentLabel.text = KISDictionaryHaveKey(dic, @"content");
    
    cell.topImageView.tag =1000 +indexPath.row;
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(void)toViewNewsWithCell:(DayNewsCell *)mycell
{
    OnceDynamicViewController* detailVC = [[OnceDynamicViewController alloc] init];
    detailVC.messageid = [GameCommon getNewStringWithId:KISDictionaryHaveKey([m_tableArray objectAtIndex:mycell.tag], @"messageId")];
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)enterToPerson:(UIButton *)sender
{
    TestViewController *tv =[[TestViewController alloc]init];
    tv.userId =[GameCommon getNewStringWithId:KISDictionaryHaveKey([m_tableArray objectAtIndex:sender.tag], @"userid")];
    [self.navigationController pushViewController:tv animated:YES];
}


#pragma mark----处理时间戳
- (NSString*)getDataWithTimeInterval:(NSString*)timeInterval
{
    if ([NSString stringWithFormat:@"%.f", [timeInterval doubleValue]].length < 10) {
        return timeInterval;
    }
    NSString* timeStr = [timeInterval substringToIndex:timeInterval.length-3];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];//location设置为中国
    [dateFormatter setDateFormat:@"MMM,YYYY"];
    
    double time = [timeStr doubleValue];
    NSLog(@"%@", [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]]);
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}


- (NSString*)getDataWithTimeDataInterval:(NSString*)timeInterval
{
    if ([NSString stringWithFormat:@"%.f", [timeInterval doubleValue]].length < 10) {
        return timeInterval;
    }
    NSString* timeStr = [timeInterval substringToIndex:timeInterval.length-3];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];//location设置为中国
    [dateFormatter setDateFormat:@"dd"];
    
    double time = [timeStr doubleValue];
    NSLog(@"%@", [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]]);
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
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
-(void)getBigImgWithCell:(DayNewsCell *)mycell
{
    NSMutableArray *array  = [NSMutableArray array];
    
    for (int i =0; i<m_tableArray.count; i++) {
        NSDictionary *dic = [m_tableArray objectAtIndex:i];
        [array addObject:KISDictionaryHaveKey(dic, @"img")];
    }
    
    
    PhotoViewController *photoVC = [[PhotoViewController alloc]initWithSmallImages:nil images:array indext:mycell.tag];
    [self presentViewController:photoVC animated:NO completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
