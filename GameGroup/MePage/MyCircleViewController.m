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
#import "TestViewController.h"
#import "EGOImageView.h"
#import "EGOImageButton.h"
#import "MyCircleCell.h"
#import "MJRefresh.h"
@interface MyCircleViewController ()
{
    UITableView *m_myTableView;
    UILabel *nickNameLabel;
    EGOImageButton *headImageView;
    EGOImageButton *topImgaeView;
    NSMutableArray *dataArray;
    NSInteger *PageNum;
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;
    int m_currPageCount;
    
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
    
    

    PageNum =0;
    dataArray = [NSMutableArray array];
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height) style:UITableViewStylePlain];
    m_myTableView.rowHeight = 130;
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:m_myTableView];
    
    [self setTopViewWithTitle:@"个人动态" withBackButton:YES];
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"published_circle_normal") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"published_circle_click") forState:UIControlStateHighlighted];
    [shareButton addTarget:self action:@selector(publishInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    
    NSString *uid =[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID];
    
    if ([self.userId intValue] ==[uid intValue]) {
        shareButton.hidden =NO;
    }else{
        shareButton.hidden =YES;
    }

    
    //顶部图片
    UIView *topVIew =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 370)];
    topVIew.backgroundColor  =[UIColor whiteColor];
    m_myTableView.tableHeaderView = topVIew;
    topImgaeView = [[EGOImageButton alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];
//    [topImgaeView addTarget:self action:@selector(enterPersonPage:) forControlEvents:UIControlEventTouchUpInside];
    topImgaeView.backgroundColor = [UIColor darkGrayColor];
    
    [topVIew addSubview:topImgaeView];
    
    //黑白渐变Label以突出文字
    UIImageView *topunderBgImageView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 280, 320, 40)];
    topunderBgImageView.image = KUIImage(@"underbg");
    [topVIew addSubview:topunderBgImageView];
    
    
    //    昵称
 
    CGSize nickLabelsize =[self.nickNmaeStr sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
    
    UILabel *underNickLabel = [[UILabel alloc]initWithFrame:CGRectMake(220-nickLabelsize.width, 281, nickLabelsize.width, 30)];
    underNickLabel.text =self.nickNmaeStr;
    underNickLabel.textColor = [UIColor blackColor];
    underNickLabel.backgroundColor =[UIColor clearColor];
    underNickLabel.textAlignment = NSTextAlignmentRight;
    [topVIew addSubview:underNickLabel];
    
    nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(220-nickLabelsize.width, 280, nickLabelsize.width, 30)];
    nickNameLabel.text =self.nickNmaeStr;
    nickNameLabel.textColor = [UIColor whiteColor];
    nickNameLabel.backgroundColor =[UIColor clearColor];
    nickNameLabel.textAlignment = NSTextAlignmentRight;
    [topVIew addSubview:nickNameLabel];
    
    //头像
    headImageView = [[EGOImageButton alloc]initWithFrame:CGRectMake(230, 276, 80, 80)];
    headImageView.placeholderImage = KUIImage(@"placeholder");
   // [headImageView addTarget:self action:@selector(enterPersonPage:) forControlEvents:UIControlEventTouchUpInside];
    headImageView.layer.cornerRadius = 5;
    headImageView.layer.masksToBounds=YES;
    
    
    NSString *imgStr =[DataStoreManager queryFirstHeadImageForUser_userManager:self.userId];
    if ([imgStr isEqualToString:@""]||[imgStr isEqualToString:@" "]) {
        headImageView.imageURL = nil;
    }else{
    headImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[NSString stringWithFormat:@"%@/160/160",imgStr]]];
    }
    [topVIew addSubview:headImageView];
    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    hud.labelText = @"加载中...";
    [self.view addSubview:hud];
    
    [self addheadView];
    [self addFootView];
    [self getInfoFromNet];
}


-(void)enterPersonPage:(id)sender
{
    TestViewController* VC = [[TestViewController alloc] init];
    
    VC.userId =self.userId;
    VC.nickName =self.nickNmaeStr;
    VC.isChatPage = NO;
    [self.navigationController pushViewController:VC animated:YES];

}

-(void)getInfoFromNet
{
    [hud show:YES];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:self.userId forKey:@"userid"];
    [paramDic setObject:[NSString stringWithFormat:@"%d",m_currPageCount] forKey:@"pageIndex"];
    [paramDic setObject:@"20" forKey:@"maxSize"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"192" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
  
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSString *strImg = KISDictionaryHaveKey(responseObject, @"coverImg");
            NSString *strImgID = [NSString stringWithFormat:BaseImageUrl@"%@",strImg];
            topImgaeView.imageURL = [NSURL URLWithString:strImgID];
            
           // [[NSUserDefaults standardUserDefaults]setObject:KISDictionaryHaveKey(responseObject, @"coverImg") forKey:@"friendCircle_topImg_wx"];
            if (m_currPageCount==0) {
                [dataArray removeAllObjects];
                [dataArray addObjectsFromArray:KISDictionaryHaveKey(responseObject, @"dynamicMsgList")];
                
            }else{
                [dataArray addObjectsFromArray:KISDictionaryHaveKey(responseObject, @"dynamicMsgList")];
            }
            m_currPageCount++;
            [m_header endRefreshing];
            [m_footer endRefreshing];
            [m_myTableView reloadData];
            [hud  hide:YES];
        
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
//    if ([self.imageStr isEqualToString:@""]||[self.imageStr isEqualToString:@" "]) {
//        cell.headImageView.imageURL = nil;
//    }else{
//     headImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseImageUrl,[GameCommon getHeardImgId:self.imageStr],@"/160/160"]];
//    }
    if ([[self getDataWithTimeDataInterval:
          [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")]]
         isEqualToString:
         [self getDataWithTimeDataInterval:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]]]
        &&
        [[GameCommon getNewStringWithId:[self getDataWithTimeInterval:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]]]
         isEqualToString:
         [self getDataWithTimeInterval:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")]]])
    {
        cell.dataLabel.hidden = YES;
        cell.monthLabel.hidden = YES;
    }
    
    else
    
    {
        cell.dataLabel.hidden = NO;
        cell.monthLabel.hidden = NO;
    cell.dataLabel.text =[self getDataWithTimeDataInterval:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];
    cell.monthLabel.text = [self getDataWithTimeInterval:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];
    }

    
    NSArray* arr = [KISDictionaryHaveKey(dic, @"img") componentsSeparatedByString:@","];
    if (([[arr lastObject]isEqualToString:@""]||[[arr lastObject]isEqualToString:@" "])&&arr.count>1) {
        [(NSMutableArray*)arr removeLastObject];
    }

    
    if ([KISDictionaryHaveKey(dic, @"img")isEqualToString:@""]||[KISDictionaryHaveKey(dic, @"img")isEqualToString:@" "])
    //文字
    {
        cell.imgCountLabel.hidden = YES;
        cell.thumbImageView.hidden =YES;
        cell.commentStr = KISDictionaryHaveKey(dic, @"msg");
      //  [cell refreshCell];

            cell.titleLabel.frame = CGRectMake(80, 5, 225,40);
        
        //cell.titleLabel.center = CGPointMake(cell.titleLabel.center.x, cell.center.y);
        cell.titleLabel.font = [UIFont systemFontOfSize:13];
        cell.titleLabel.backgroundColor = UIColorFromRGBA(0xf0f1f3, 1);
        cell.titleLabel.text = KISDictionaryHaveKey(dic, @"msg");

        cell.titleLabel.numberOfLines = 2;
        
    }
    //图片
    else{
        
        cell.imgCountLabel.hidden = NO;
        cell.thumbImageView.hidden =NO;
    //    cell.titleLabel.center = CGPointMake(cell.titleLabel.center.x, cell.titleLabel.center.y);
        cell.titleLabel.frame = CGRectMake(155, 0, 155, 70);
        cell.titleLabel.font = [UIFont systemFontOfSize:12];
        cell.titleLabel.text = KISDictionaryHaveKey(dic, @"msg");

        cell.titleLabel.backgroundColor = [UIColor clearColor];
        cell.titleLabel.numberOfLines = 3;
    }

    cell.imgCountLabel.text = [NSString stringWithFormat:@"(共%d张)",arr.count];
    
    cell.thumbImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseImageUrl,[GameCommon getHeardImgId:KISDictionaryHaveKey(dic, @"img")],@"/140/140"]];
    
   // [cell getImageWithCount:KISDictionaryHaveKey(dic, @"img")];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [dataArray objectAtIndex:indexPath.row];
    
    OnceDynamicViewController *detailVC = [[OnceDynamicViewController alloc]init];
    detailVC.messageid = KISDictionaryHaveKey(dict, @"id");
    //    detailVC.urlLink = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"urlLink")];
    
    detailVC.delegate = self;
    detailVC.timeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")];
    [self.navigationController pushViewController:detailVC animated:YES];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSDictionary *dic = [dataArray objectAtIndex:indexPath.row];
    if ([KISDictionaryHaveKey(dic, @"img")isEqualToString:@""]||[KISDictionaryHaveKey(dic, @"img")isEqualToString:@" "]) {
        return 50;
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

#pragma mark ---addRefreshHeadview and refreshFootView
//添加下拉刷新
-(void)addheadView
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = m_myTableView;
    
    header.scrollView = m_myTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        m_currPageCount = 0;
        [self getInfoFromNet];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
  //  [header beginRefreshing];
    m_header = header;
}

//添加上拉加载更多
-(void)addFootView
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    CGRect headerRect = footer.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    footer.arrowImage.frame = headerRect;
    footer.activityView.center = footer.arrowImage.center;
    footer.scrollView = m_myTableView;
    
    footer.scrollView = m_myTableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self getInfoFromNet];
    };
    m_footer = footer;
}
-(void)publishInfo:(UIButton *)sender
{
    SendNewsViewController* sendNews = [[SendNewsViewController alloc] init];
    sendNews.delegate = self;
    sendNews.isComeFromMe = YES;
    sendNews.delegate = self;
    [self.navigationController pushViewController:sendNews animated:YES];
    
}
-(void)dynamicListAddOneDynamic:(NSDictionary*)dynamic
{
    m_currPageCount = 0;
    [self getInfoFromNet];
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
