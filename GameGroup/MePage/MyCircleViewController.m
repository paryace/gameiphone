//
//  MyCircleViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-4-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MyCircleViewController.h"
#import "CircleWithMeViewController.h"
#import "OnceDynamicViewController.h"
#import "EGOImageView.h"
#import "MyCircleCell.h"
@interface MyCircleViewController ()
{
    UITableView *m_myTableView;
    UILabel *nickNameLabel;
    EGOImageView *headImageView;
    EGOImageView *topImgaeView;
    NSMutableArray *dataArray;
    NSInteger *PageNum;
}
@end

@implementation MyCircleViewController

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
    
    [self setTopViewWithTitle:@"朋友圈" withBackButton:YES];
    
    PageNum =0;
    dataArray = [NSMutableArray array];
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX) style:UITableViewStylePlain];
    m_myTableView.rowHeight = 130;
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:m_myTableView];
    
    UIView *topVIew =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 300)];
    topVIew.backgroundColor  =[UIColor whiteColor];
    m_myTableView.tableHeaderView = topVIew;
    topImgaeView = [[EGOImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 250)];
    topImgaeView.placeholderImage = KUIImage(@"ceshibg.jpg");
    
    [topVIew addSubview:topImgaeView];
    
    nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(138, 210, 85, 30)];
    nickNameLabel.text =self.nickNmaeStr;
    nickNameLabel.layer.cornerRadius = 5;
    nickNameLabel.layer.masksToBounds=YES;
    nickNameLabel.textColor = [UIColor whiteColor];
    nickNameLabel.backgroundColor =[UIColor clearColor];
    nickNameLabel.textAlignment = NSTextAlignmentRight;
    [topVIew addSubview:nickNameLabel];
    
    headImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(236, 206, 80, 80)];
    headImageView.placeholderImage = KUIImage(@"placeholder");
    headImageView.imageURL = [NSURL URLWithString:[GameCommon isNewOrOldWithImage:[GameCommon getHeardImgId:self.imageStr] width:80 hieght:80 a:80]];
    headImageView.layer.cornerRadius = 5;
    headImageView.layer.masksToBounds=YES;

    [topVIew addSubview:headImageView];
    
    [self getInfoFromNet];
}





-(void)getInfoFromNet
{
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:self.userId forKey:@"userid"];
    [paramDic setObject:@"0" forKey:@"pageIndex"];
    [paramDic setObject:@"20" forKey:@"maxSize"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"192" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
  
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            topImgaeView.imageURL = [NSURL URLWithString:[GameCommon isNewOrOldWithImage:KISDictionaryHaveKey(responseObject, @"coverImg")]];
            
            [[NSUserDefaults standardUserDefaults]setObject:KISDictionaryHaveKey(responseObject, @"coverImg") forKey:@"friendCircle_topImg_wx"];
            [dataArray addObjectsFromArray:KISDictionaryHaveKey(responseObject, @"dynamicMsgList")];
            [m_myTableView reloadData];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];
 
    
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier =@"cell";
    MyCircleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[MyCircleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    NSDictionary *dic = [dataArray objectAtIndex:indexPath.row];
    NSDictionary *dict= [NSDictionary dictionary];
    if (indexPath.row>0) {
        dict = [dataArray objectAtIndex:indexPath.row-1];
    }
    if ([[self getDataWithTimeDataInterval:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")]]isEqualToString:[self getDataWithTimeDataInterval:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]]]&&[[GameCommon getNewStringWithId:[self getDataWithTimeInterval:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]]] isEqualToString:[self getDataWithTimeInterval:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")]]]) {
        cell.dataLabel.hidden = YES;
        cell.monthLabel.hidden = YES;
    }else{
        cell.dataLabel.hidden = NO;
        cell.monthLabel.hidden = NO;
    cell.dataLabel.text =[self getDataWithTimeDataInterval:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];
    cell.monthLabel.text = [self getDataWithTimeInterval:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];
    }

    NSArray* arr = [KISDictionaryHaveKey(dic, @"img") componentsSeparatedByString:@","];

    if ([KISDictionaryHaveKey(dic, @"img")isEqualToString:@""]||[KISDictionaryHaveKey(dic, @"img")isEqualToString:@" "]) {
        cell.imgCountLabel.hidden = YES;
        cell.thumbImageView.hidden =YES;
        cell.commentStr = KISDictionaryHaveKey(dic, @"msg");
        [cell refreshCell];

        //cell.titleLabel.center = CGPointMake(cell.titleLabel.center.x, cell.center.y);
        cell.titleLabel.font = [UIFont systemFontOfSize:13];
        cell.titleLabel.backgroundColor = UIColorFromRGBA(0xf0f1f3, 1);
        cell.titleLabel.numberOfLines = 0;
        
    }else{
        if ([[arr lastObject]isEqualToString:@""]||[[arr lastObject]isEqualToString:@" "]) {
            [(NSMutableArray*)arr removeLastObject];
        }
        cell.imgCountLabel.hidden = NO;
        cell.thumbImageView.hidden =NO;
    //    cell.titleLabel.center = CGPointMake(cell.titleLabel.center.x, cell.titleLabel.center.y);
        cell.titleLabel.frame = CGRectMake(155, 0, 155, 70);
        cell.titleLabel.font = [UIFont systemFontOfSize:12];
        cell.titleLabel.backgroundColor = [UIColor clearColor];
        cell.titleLabel.numberOfLines = 3;
    }

    cell.imgCountLabel.text = [NSString stringWithFormat:@"(共%d张)",arr.count];
    
    cell.thumbImageView.imageURL = [NSURL URLWithString:[GameCommon isNewOrOldWithImage:[GameCommon getHeardImgId:KISDictionaryHaveKey(dic, @"img")] width:140 hieght:140 a:140 ]];
    
   // [cell getImageWithCount:KISDictionaryHaveKey(dic, @"img")];
    cell.titleLabel.text = KISDictionaryHaveKey(dic, @"msg");
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [dataArray objectAtIndex:indexPath.row];
    
    OnceDynamicViewController *detailVC = [[OnceDynamicViewController alloc]init];
    detailVC.messageid = KISDictionaryHaveKey(dict, @"id");
    //    detailVC.urlLink = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"urlLink")];
    
    
    detailVC.timeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")];
    [self.navigationController pushViewController:detailVC animated:YES];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSDictionary *dic = [dataArray objectAtIndex:indexPath.row];
    if ([KISDictionaryHaveKey(dic, @"img")isEqualToString:@""]||[KISDictionaryHaveKey(dic, @"img")isEqualToString:@" "]) {
        CGSize size = [MyCircleCell getContentHeigthWithStr:KISDictionaryHaveKey(dic, @"msg")];
        if (size.height<50) {
            return 50;
        }else{
        return size.height;
        }
    }else{
        return 100;
    }
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
