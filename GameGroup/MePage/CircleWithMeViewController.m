//
//  CircleWithMeViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-4-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CircleWithMeViewController.h"
#import "TestViewController.h"
#import "OnceDynamicViewController.h"
#import "CircleMeCell.h"
#import "SendNewsViewController.h"
#import "MJRefresh.h"
#import "DSCircleWithMe.h"
@interface CircleWithMeViewController ()
{
    UITableView *m_myTableView;
    NSMutableArray *dataArray;
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;
    NSInteger m_currentPage;
}
@end

@implementation CircleWithMeViewController

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
    
    [self setTopViewWithTitle:@"消息" withBackButton:YES];
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-42, KISHighVersion_7?27:7, 37, 30)];
//    [shareButton setBackgroundImage:KUIImage(@"share_normal.png") forState:UIControlStateNormal];
//    [shareButton setBackgroundImage:KUIImage(@"share_normal.png") forState:UIControlStateHighlighted];
    [shareButton setTitle:@"发表" forState:UIControlStateNormal];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(publishInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    dataArray = [NSMutableArray array];
    m_currentPage = 0;
    dataArray = (NSMutableArray *)[DataStoreManager queryallDynamicAboutMe];

    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.rowHeight =80;
    [self.view addSubview:m_myTableView];

    //[self addheadView];
    //[self addFootView];
  //  [self getInfoFromNet];
    
    // Do any additional setup after loading the view.
}

-(void)publishInfo:(UIButton *)sender
{
    SendNewsViewController* sendNews = [[SendNewsViewController alloc] init];
    sendNews.delegate = self;
    sendNews.isComeFromMe = YES;
    [self.navigationController pushViewController:sendNews animated:YES];

}


-(void)getInfoFromNet
{
    
    
    
//    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [paramDic setObject:self.userId forKey:@"userid"];
//    [paramDic setObject:[NSString stringWithFormat:@"%d",m_currentPage] forKey:@"pageIndex"];
//    [paramDic setObject:@"20" forKey:@"maxSize"];
//    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
//    [dict setObject:paramDic forKey:@"params"];
//    [dict setObject:@"191" forKey:@"method"];
//    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
//    
    
//    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if ([responseObject isKindOfClass:[NSArray class]]) {
//            if (m_currentPage==0) {
//                [dataArray removeAllObjects];
//                [dataArray addObjectsFromArray:responseObject];
//
//            }else{
//                [dataArray addObjectsFromArray:responseObject];
//            }
//            m_currentPage++;
//            [m_header endRefreshing];
//            [m_footer endRefreshing];
//            [m_myTableView reloadData];
//        }
//        
//        
//    } failure:^(AFHTTPRequestOperation *operation, id error) {
//        [m_header endRefreshing];
//        [m_footer endRefreshing];
//        if ([error isKindOfClass:[NSDictionary class]]) {
//            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
//            {
//                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//                [alert show];
//            }
//        }
//        [hud hide:YES];
//    }];
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    CircleMeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[CircleMeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
     DSCircleWithMe *dCircle = [dataArray objectAtIndex:indexPath.row];
    
    if ([dCircle.headImg isEqualToString:@""]||[dCircle.headImg isEqualToString:@" "]) {
        cell.headImgBtn.imageURL = nil;
    }else{
        cell.headImgBtn.imageURL = [NSURL URLWithString:[GameCommon isNewOrOldWithImage:[GameCommon getHeardImgId:dCircle.headImg] width:80 hieght:80 a:@"80"]];
    }
    
    [cell.headImgBtn addTarget:self action:@selector(enterPersonInfoPage:) forControlEvents:UIControlEventTouchUpInside];
    cell.headImgBtn.tag = indexPath.row;
    cell.nickNameLabel.text =dCircle.nickname;
    
    if ([dCircle.myMsgImg isEqualToString:@""]||[dCircle.myMsgImg isEqualToString:@" "]) {
        cell.contentsLabel.hidden = NO;
        cell.contentImageView.hidden = YES;
        NSString *str = [NSString stringWithFormat:@"%@",dCircle.comment];
        CGSize titleSize = [str sizeWithFont:cell.contentsLabel.font constrainedToSize:CGSizeMake(60, 60) lineBreakMode:NSLineBreakByCharWrapping];
        cell.contentsLabel.frame = CGRectMake(CGRectGetMinX(cell.contentsLabel.frame), CGRectGetMinY(cell.contentsLabel.frame), titleSize.width, titleSize.height);
        cell.contentsLabel.text = dCircle.comment;
        
    }else{
        cell.contentsLabel.hidden =YES;
        cell.contentImageView.hidden = NO;
        cell.contentImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:dCircle.myMsgImg]]];

    }
    
    
    if ([dCircle.myType intValue]==4) {
        cell.titleLabel.text = @"赞了该内容";
        cell.commentStr = @"赞了该内容";
    }
    else if ([dCircle.myType intValue]==5){
        cell.titleLabel.text =dCircle.comment;
        cell.commentStr=dCircle.comment;
    }
    cell.timeLabel.text = [self getTimeWithMessageTime:[GameCommon getNewStringWithId:dCircle.createDate]];
    
    [cell refreshCell];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [dataArray objectAtIndex:indexPath.row];
    
    OnceDynamicViewController *detailVC = [[OnceDynamicViewController alloc]init];
    detailVC.messageid = KISDictionaryHaveKey(dict, @"messageId");
    //    detailVC.urlLink = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"urlLink")];
    
    NSString* imageName = [GameCommon getHeardImgId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img")];
    
    detailVC.imgStr =[BaseImageUrl stringByAppendingString:imageName];
    detailVC.nickNameStr = [KISDictionaryHaveKey(dict, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]] ? @"我" :KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"nickname");
    
    
    detailVC.timeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")];
    // detailVC.touxianStr = [GameCommon getHeardImgId:KISDictionaryHaveKey(destDic, @"userimg")];
   // detailVC.zanStr =[self getZanLabelWithNum:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"zannum")]];
    

    [self.navigationController pushViewController:detailVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float heigth = [CircleMeCell getContentHeigthWithStr:KISDictionaryHaveKey([dataArray objectAtIndex:indexPath.row], @"comment")] + 50;
    return heigth < 80 ? 80 : heigth;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//待添加网络删除数据
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        [dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];

    }
}

-(void)enterPersonInfoPage:(UIButton *)sender
{
    TestViewController *tsVC = [[TestViewController alloc]init];
    NSDictionary *dict = [dataArray objectAtIndex:sender.tag];
    tsVC.userId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"userid")];
    tsVC.nickName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"nickname")];
    
    [self.navigationController pushViewController:tsVC animated:YES];
    
}
- (NSString*)getTimeWithMessageTime:(NSString*)messageTime
{
    NSString* currentString = [GameCommon getCurrentTime];
    if (messageTime.length < 10 || currentString.length < 10) {
        return @"未知";
    }
    // NSString * finalTime;
    NSString* curStr = [currentString substringToIndex:messageTime.length-3];
    NSString* mesStr = [messageTime substringToIndex:messageTime.length-3];
    
    double theCurrentT = [curStr doubleValue];
    double theMessageT = [mesStr doubleValue];
    
    NSLog(@"%f--%f",theCurrentT,theMessageT);
    NSLog(@"++%f",theCurrentT-theMessageT);
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
        m_currentPage = 0;
        [self getInfoFromNet];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
     [header beginRefreshing];
    m_header = header;
}
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
