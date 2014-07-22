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
#import "MessageCell.h"
@interface DataNewsViewController ()
{
    NSMutableArray *m_dataArray;
    UITableView *m_myTableView;
}
@end

@implementation DataNewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"每日一闻" withBackButton:YES];
     self.view.backgroundColor=UIColorFromRGBA(0xf7f7f7, 1);
    m_dataArray = (NSMutableArray *)[DataStoreManager qureyFirstOfgame];
    m_myTableView =[[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    m_myTableView.rowHeight = 70;
    m_myTableView.delegate = self;
    m_myTableView.dataSource =self;
    m_myTableView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    [GameCommon setExtraCellLineHidden:m_myTableView];
    [self.view addSubview:m_myTableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    MessageCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
    }
     cell.settingState.hidden=YES;
    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    NSDictionary *dict = KISDictionaryHaveKey(dic, @"content");
    NSString * gameId=KISDictionaryHaveKey(dic, @"gameid");
    NSString * imageId=[GameCommon putoutgameIconWithGameId:gameId];
    cell.headImageV.imageURL = [ImageService getImageUrl4:imageId];
    cell.nameLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"title")];
    cell.contentLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"editorNote")];
    cell.timeLabel.text = [self getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"time")]];
    
    
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
- (NSString*)getTimeWithMessageTime:(NSString*)messageTime
{
    NSString* currentString = [GameCommon getCurrentTime];
    if (messageTime.length < 10 || currentString.length < 10) {
        return @"未知";
    }
    NSString* curStr = [currentString substringToIndex:messageTime.length-3];
    NSString* mesStr = [messageTime substringToIndex:messageTime.length-3];
    
    double theCurrentT = [curStr doubleValue];
    double theMessageT = [mesStr doubleValue];
    
    if (((int)(theCurrentT-theMessageT))<60) {
        return @"1分钟以前";
    }
    if (((int)(theCurrentT-theMessageT))<60*59) {
        return [NSString stringWithFormat:@"%.f分钟以前",((theCurrentT-theMessageT)/60+1)];
    }
    if (((int)(theCurrentT-theMessageT))<60*60*24) {
        return [NSString stringWithFormat:@"%.f小时以前",((theCurrentT-theMessageT)/3600)==0?1:((theCurrentT-theMessageT)/3600)];
    }
    if (((int)(theCurrentT-theMessageT))<60*60*48) {
        return @"昨天";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *messageDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    return [messageDateStr substringFromIndex:5];
}

@end
