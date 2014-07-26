//
//  NewsViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-27.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsGetTitleCell.h"
#import "OnceDynamicViewController.h"
#import "SendNewsViewController.h"
#import "SendArticleViewController.h"
#import "MyProfileViewController.h"
#import "TestViewController.h"
#import "ReplyViewController.h"
@interface NewsViewController ()
{
    NSInteger   m_currentPage;
    
    NSMutableArray*  m_newsArray;
    
    PullUpRefreshView      *refreshView;

    UITableView*     m_myTableView;
    
    SRRefreshView   *_slimeView;
    
    BOOL            isRefresh;
    NSIndexPath *indexPaths;
    UIAlertView *alertView1;
}
@end

@implementation NewsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (isRefresh) {
        [_slimeView setLoadingWithexpansion];

        m_currentPage = 0;
        [self getNewsDataByNet];
        
        isRefresh = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    m_currentPage = 0;
    
    isRefresh = YES;//进来刷新
    
    m_newsArray = [[NSMutableArray alloc] init];
    
    if (self.myViewType == ME_NEWS_TYPE) {
        [self setTopViewWithTitle:@"我的动态" withBackButton:YES];
        
        [self getDataWithMyStore];
        
        UIButton *addButton=[UIButton buttonWithType:UIButtonTypeCustom];
        addButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
        [addButton setBackgroundImage:KUIImage(@"add_news_normal") forState:UIControlStateNormal];
        [addButton setBackgroundImage:KUIImage(@"add_news_click") forState:UIControlStateHighlighted];
        [self.view addSubview:addButton];
        [addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if(self.myViewType == FRIEND_NEWS_TYPE)
    {
        [self setTopViewWithTitle:@"好友动态" withBackButton:YES];
        UIButton *addButton=[UIButton buttonWithType:UIButtonTypeCustom];
        addButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
        [addButton setBackgroundImage:KUIImage(@"add_news_normal") forState:UIControlStateNormal];
        [addButton setBackgroundImage:KUIImage(@"add_news_click") forState:UIControlStateHighlighted];
        [self.view addSubview:addButton];
        [addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];

        
        [self getDataWithFriendStore];
    }
    else if(self.myViewType == ONEPERSON_NEWS_TYPE)//某个好友的
    {
        [self setTopViewWithTitle:@"个人动态" withBackButton:YES];
    }
    
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX - (KISHighVersion_7?0:20))];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];
    
    refreshView = [[PullUpRefreshView alloc] initWithFrame:CGRectMake(0, kScreenHeigth - startX-(KISHighVersion_7?0:20), 320, REFRESH_HEADER_HEIGHT)];//上拉加载
    [m_myTableView addSubview:refreshView];
    refreshView.pullUpDelegate = self;
    refreshView.myScrollView = m_myTableView;
    [refreshView stopLoading:YES];
    [refreshView setRefreshViewFrame];
    
    _slimeView = [[SRRefreshView alloc] init];
    _slimeView.delegate = self;
    _slimeView.upInset = 0;
    _slimeView.slimeMissWhenGoingBack = NO;
    _slimeView.slime.bodyColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    _slimeView.slime.skinColor = [UIColor whiteColor];
    _slimeView.slime.lineWith = 1;
    _slimeView.slime.shadowBlur = 4;
    _slimeView.slime.shadowColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    [m_myTableView addSubview:_slimeView];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"查询中...";
}

- (void)backButtonClick:(id)sender
{
    if (self.myViewType == ME_NEWS_TYPE) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:haveMyNews];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if(self.myViewType == FRIEND_NEWS_TYPE)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:haveFriendNews];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if(self.myViewType == ONEPERSON_NEWS_TYPE)
    {
        
    }
    [[GameCommon shareGameCommon] displayTabbarNotification];
    [self.navigationController popViewControllerAnimated:YES];
}
//网络获取自己发表参与的内容
- (void)getDataWithMyStore
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * dMyNews = [DSMyNewsList MR_findAllInContext:localContext];
        for (DSMyNewsList* news in dMyNews) {
            NSLog(@"dMyNews%@",dMyNews);
            NSDictionary* commentDic = [NSDictionary dictionaryWithObject:news.commentObj forKey:@"msg"];
            NSMutableDictionary* tempDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            news.newsId, @"id",
                                            news.heardImgId, @"userimg",
                                            news.bigTitle, @"title",
                                            news.msg, @"msg",
                                            news.detailPageId,@"detailPageId",
                                            news.createDate, @"createDate",
                                            news.nickName, @"nickname",
                                            news.type, @"type",
                                            commentDic, @"commentObj",
                                            news.urlLink, @"urlLink",
                                            news.img, @"thumb",
                                            news.zannum, @"zannum",
                                            news.userid, @"userid",
                                            news.username, @"username",
                                            news.showTitle, @"showtitle",
                                            news.superstar, @"superstar",nil];
            [m_newsArray addObject:tempDic];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
//获取好友的发表内容
- (void)getDataWithFriendStore
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * dFriendsNews = [DSFriendsNewsList MR_findAllInContext:localContext];
        for (DSFriendsNewsList* news in dFriendsNews) {
            
            NSLog(@"dFriendNews%@",dFriendsNews);
            NSDictionary* commentDic = [NSDictionary dictionaryWithObject:news.commentObj forKey:@"msg"];
            NSMutableDictionary* tempDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            news.newsId, @"id",
                                            news.heardImgId, @"userimg",
                                            news.bigTitle, @"title",
                                            news.msg, @"msg",
                                            news.detailPageId, @"detailPageId",
                                            news.createDate, @"createDate",
                                            news.nickName, @"nickname",
                                            news.type, @"type",
                                            commentDic, @"commentObj",
                                            news.urlLink, @"urlLink",
                                            news.img, @"thumb",
                                            news.zannum, @"zannum",
                                            news.userid, @"userid",
                                            news.username, @"username",
                                            news.showTitle, @"showtitle",
                                            news.superstar, @"superstar",nil];
            [m_newsArray addObject:tempDic];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
//获取系统推送内容
- (void)getNewsDataByNet
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.userId forKey:@"userid"];
    [paramDict setObject:[NSString stringWithFormat:@"%d", m_currentPage] forKey:@"pageIndex"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    switch (self.myViewType) {
        case ME_NEWS_TYPE:
            [postDict setObject:@"131" forKey:@"method"];
            break;
        case FRIEND_NEWS_TYPE:
            [postDict setObject:@"132" forKey:@"method"];
            break;
        case ONEPERSON_NEWS_TYPE:
            [postDict setObject:@"131" forKey:@"method"];
            break;
        default:
            break;
    }
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        NSLog(@"responseObject1%@",responseObject);
        if (![responseObject isKindOfClass:[NSArray class]]) {
            [refreshView stopLoading:YES];
            [_slimeView endRefresh];
            return;
        }
        if (m_currentPage == 0) {//默认展示存储的
            
            [self refreshNewsListStore:responseObject];
            [m_newsArray removeAllObjects];
        }
        m_currentPage ++;//从0开始
        
        [m_newsArray addObjectsFromArray:responseObject];
       
        [m_myTableView reloadData];
        
        [refreshView stopLoading:NO];
        [refreshView setRefreshViewFrame];
        
        [_slimeView endRefresh];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [refreshView stopLoading:NO];
        [_slimeView endRefresh];
        [refreshView setRefreshViewFrame];

        [hud hide:YES];
    }];
}

- (void)refreshNewsListStore:(NSArray*)tempArray
{
    switch (self.myViewType) {
        case ME_NEWS_TYPE:
        {
            [DataStoreManager cleanMyNewsList];
            
            dispatch_queue_t queue = dispatch_queue_create("com.living.game", NULL);
            dispatch_async(queue, ^{
                for (NSDictionary * dict in tempArray) {
                    [DataStoreManager saveMyNewsWithData:dict];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                });
            });
        }break;
        case FRIEND_NEWS_TYPE:
        {
            [DataStoreManager cleanFriendsNewsList];
            
            dispatch_queue_t queue = dispatch_queue_create("com.living.game", NULL);
            dispatch_async(queue, ^{
                for (NSDictionary * dict in tempArray) {
                    [DataStoreManager saveFriendsNewsWithData:dict];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            });
        } break;
        default:
            break;
    }
   
}

#pragma mark 修改
-(void)dynamicListAddOneDynamic:(NSDictionary*)dynamic
{
//    [m_newsArray insertObject:dynamic atIndex:0];
//    [m_newsArray removeLastObject];//防止加载重复最后一条
//    
//    [m_myTableView reloadData];
    isRefresh = YES;
}
#define mark --评论后回调
-(void)dynamicListJustReload
{
    isRefresh = YES;
}
#pragma mark - add
- (void)addButtonClick:(id)sender
{
//    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"选择类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:Nil otherButtonTitles:@"发表动态", @"发表文章",nil];
//    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//    [sheet showInView:self.view];
    SendNewsViewController* sendNews = [[SendNewsViewController alloc] init];
    sendNews.delegate = self;
    sendNews.isComeFromMe = YES;
    [self.navigationController pushViewController:sendNews animated:YES];
}

//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 0) {
//        SendNewsViewController* sendNews = [[SendNewsViewController alloc] init];
//        sendNews.delegate = self;
//        [self.navigationController pushViewController:sendNews animated:YES];
//    }
//    else if(1 == buttonIndex)
//    {
//        SendArticleViewController* sendNews = [[SendArticleViewController alloc] init];
//        sendNews.delegate = self;
//        [self.navigationController pushViewController:sendNews animated:YES];
//    }
//}

#pragma mark - table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_newsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCell";
    NewsGetTitleCell *cell = (NewsGetTitleCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[NewsGetTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary* tempDic = [m_newsArray objectAtIndex:indexPath.row];
    
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"type")] isEqualToString:@"3"]&&[KISDictionaryHaveKey(tempDic, @"userid")isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        cell.delBtn.hidden = NO;
    }else{
        cell.delBtn.hidden = YES;
    }
    cell.delBtn.tag = indexPath.row;
    [cell.delBtn addTarget:self action:@selector(delMyInfo:) forControlEvents:UIControlEventTouchUpInside];
    indexPaths = indexPath;

    if ([KISDictionaryHaveKey(tempDic, @"destUser") isKindOfClass:[NSDictionary class]]) {//目标 别人评论了我
        NSDictionary* destDic = KISDictionaryHaveKey(tempDic, @"destUser");
        
//        NSString* imageName = [GameCommon getHeardImgId:KISDictionaryHaveKey(destDic, @"userimg")];
//        if ([imageName isEqualToString:@""]||[imageName isEqualToString:@" "]) {
//            cell.headImageV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
//            cell.headImageV.imageURL = nil;
//        }else{
//            if (imageName) {
//                NSURL * theUrl = [NSURL URLWithString:[[BaseImageUrl stringByAppendingString:imageName] stringByAppendingString:@"/80"]];
//                cell.headImageV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
//                cell.headImageV.imageURL = theUrl;
//            }else
//            {
//                cell.headImageV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
//                cell.headImageV.imageURL = nil;
//            }
//        }
        cell.headImageV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
        NSString * userImageIds= KISDictionaryHaveKey(destDic, @"userimg");
        cell.headImageV.imageURL = [ImageService getImageStr:userImageIds Width:80];
        
        
        
        
        //[DataStoreManager queryRemarkNameForUser:self.userId]
        NSString *nickName = [GameCommon getNewStringWithId:[DataStoreManager queryRemarkNameForUser:KISDictionaryHaveKey(destDic, @"userid")]];
        
//        NSString * nickName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(destDic, @"alias")];
        if ([nickName isEqualToString:@""]) {
            nickName = KISDictionaryHaveKey(destDic, @"nickname");
        }
        cell.nickNameLabel.text = [KISDictionaryHaveKey(destDic, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]] ? @"我" : nickName;
        if ([KISDictionaryHaveKey(destDic, @"userid") isEqualToString:@"10000"]) {
            cell.authImage.hidden = NO;
            cell.authImage.image = KUIImage(@"red_auth");
            cell.nickNameLabel.textColor = kColorWithRGB(255, 58, 48, 1.0);
        }
        else if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(destDic, @"superstar")] isEqualToString:@"1"])//superstar
        {
            cell.authImage.hidden = NO;
            cell.authImage.image = KUIImage(@"v_auth");
            cell.nickNameLabel.textColor = kColorWithRGB(84, 178, 64, 1.0);
        }
        else
        {
            cell.authImage.hidden = YES;
            cell.authImage.image = nil;
            cell.nickNameLabel.textColor = kColorWithRGB(51, 51, 200, 1.0);
        }
    }
    else
    {
        cell.headImageV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
        
        NSString * uImageIds=KISDictionaryHaveKey(tempDic, @"userimg");
        cell.headImageV.imageURL = [ImageService getImageStr:uImageIds Width:80];
        
//        NSString* imageName = [GameCommon getHeardImgId:KISDictionaryHaveKey(tempDic, @"userimg")];
//        if([imageName isEqualToString:@""]||[imageName isEqualToString:@" "])
//        {
//            cell.headImageV.imageURL = nil;
//
//        }else{
//            NSURL * theUrl = [NSURL URLWithString:[[BaseImageUrl stringByAppendingString:imageName] stringByAppendingString:@"/80"]];
//            
//            //        UIImage *getImage = [[EGOImageLoader sharedImageLoader]imageForURL:theUrl shouldLoadWithObserver:nil];//拿到缓存图片
//            //        if (getImage != nil) {
//            //            cell.headImageV.image = getImage;
//            //        }
//            //        else
//            if (imageName) {
//                cell.headImageV.imageURL = theUrl;
//            }else
//            {
//                cell.headImageV.imageURL = nil;
//            }
//        
//        }
        
        
        
        
        
        
        
//        NSString * nickName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"alias")];
        NSString *nickName = [GameCommon getNewStringWithId:[DataStoreManager queryRemarkNameForUser:KISDictionaryHaveKey(tempDic, @"userid")]];

        if ([nickName isEqualToString:@""]) {
            nickName = KISDictionaryHaveKey(tempDic, @"nickname");
        }
        cell.nickNameLabel.text = [KISDictionaryHaveKey(tempDic, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]] ? @"我" :nickName;
        
        if ([KISDictionaryHaveKey(tempDic, @"userid") isEqualToString:@"10000"]) {
            cell.authImage.hidden = NO;
            cell.authImage.image = KUIImage(@"red_auth");
            cell.nickNameLabel.textColor = kColorWithRGB(255, 58, 48, 1.0);
        }
        else if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"superstar")] isEqualToString:@"1"])//superstar
        {
            cell.authImage.hidden = NO;
            cell.authImage.image = KUIImage(@"v_auth");
            cell.nickNameLabel.textColor = kColorWithRGB(84, 178, 64, 1.0);
        }
        else
        {
            cell.authImage.hidden = YES;
            cell.authImage.image = nil;
            cell.nickNameLabel.textColor = kColorWithRGB(51, 51, 200, 1.0);
        }
    }
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"type")] isEqualToString:@"3"]) {
        cell.typeLabel.text = @"发表了该内容";
    }
    else if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"type")] isEqualToString:@"4"]) {
        cell.typeLabel.text = KISDictionaryHaveKey(tempDic, @"showtitle");
    }
    else if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"type")] isEqualToString:@"5"]) {
        cell.typeLabel.text = KISDictionaryHaveKey(tempDic, @"showtitle");
    }
    else if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"type")] isEqualToString:@"7"])
    {
        cell.typeLabel.text = KISDictionaryHaveKey(tempDic, @"showtitle");
    }
    NSString* tit = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"title")] isEqualToString:@""] ? KISDictionaryHaveKey(tempDic, @"msg") : KISDictionaryHaveKey(tempDic, @"title");
    cell.bigTitle.text = tit;
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"title")] isEqualToString:@""]) {
        cell.contentBgImage.hidden = YES;
    }
    else
    {
        cell.contentBgImage.hidden = NO;
    }

    cell.timeLabel.text = [self getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"createDate")]];
    
    
    
    NSString* zanStr = [self getZanLabelWithNum:[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"zannum")]];
    cell.zanLabel.text = zanStr;
    cell.zanLabel.hidden = [zanStr isEqualToString:@"0"];
    
    cell.rowIndex = indexPath.row;
    
    
    NSString * imageId=KISDictionaryHaveKey(tempDic, @"thumb");
    
    
//    NSString* imgStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"thumb")];
//    NSURL * titleImage = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@/30",imgStr]];
    if (![GameCommon isEmtity:imageId] && ![imageId isEqualToString:@"null"]) {
        cell.havePic.hidden = NO;
//        cell.havePic.imageURL = titleImage;
        cell.havePic.imageURL = [ImageService getImageUrl3:imageId Width:30];
    }
    else{
        cell.havePic.hidden = YES;
    }
    cell.myDelegate = self;
    
    [cell refreshCell];
    
    return cell;
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

- (NSString*)getZanLabelWithNum:(NSString*)zannum
{
    double zanDouble = [zannum doubleValue];
    double newZan = zanDouble;
    if (zanDouble > 1000) {
        newZan = zanDouble/1000;
        return [NSString stringWithFormat:@"%.fK", newZan];
    }
    return [NSString stringWithFormat:@"%.f", newZan];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* tempDict = [m_newsArray objectAtIndex:indexPath.row];
 
    OnceDynamicViewController* detailVC = [[OnceDynamicViewController alloc] init];
    detailVC.messageid = KISDictionaryHaveKey(tempDict, @"id");
//    detailVC.urlLink = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"urlLink")];
    
//    NSString* imageName = [GameCommon getHeardImgId:KISDictionaryHaveKey(tempDict, @"userimg")];
//    detailVC.imgStr =[BaseImageUrl stringByAppendingString:imageName];
    
    
    
    NSString * imageIds = KISDictionaryHaveKey(tempDict, @"userimg");
    detailVC.imgStr = [ImageService getImageString:imageIds];
    
    
    detailVC.nickNameStr = [KISDictionaryHaveKey(tempDict, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]] ? @"我" :KISDictionaryHaveKey(tempDict, @"nickname");

    
    detailVC.timeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"createDate")];
   // detailVC.touxianStr = [GameCommon getHeardImgId:KISDictionaryHaveKey(destDic, @"userimg")];
    detailVC.zanStr =[self getZanLabelWithNum:[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"zannum")]];
    
    detailVC.delegate = self;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)delMyInfo:(UIButton *)sender
{
    
    alertView1 = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否确认删除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView1.tag = sender.tag;
    [alertView1 show];
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1) {
        NSDictionary *dic = [m_newsArray objectAtIndex:alertView1.tag];
        
        [self getUserInfoByNetWithMsgid:KISDictionaryHaveKey(dic, @"id")];
        [m_newsArray removeObjectAtIndex:alertView.tag];
        [m_myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPaths] withRowAnimation:NO];
        [m_myTableView reloadData];
    }

}

- (void)getUserInfoByNetWithMsgid:(NSString *)msgId
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:msgId forKey:@"messageId"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"177" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                
            }
        }
    }];
}


-(void)CellHeardButtonClick:(int)rowIndex
{
    NSDictionary* tempDict = [m_newsArray objectAtIndex:rowIndex];
    if ([KISDictionaryHaveKey(tempDict, @"destUser") isKindOfClass:[NSDictionary class]]) {//目标 别人评论了我
        NSDictionary* destDic = KISDictionaryHaveKey(tempDict, @"destUser");
//        if ([KISDictionaryHaveKey(destDic, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
//            MyProfileViewController * myP = [[MyProfileViewController alloc] init];
//            [self.navigationController pushViewController:myP animated:YES];
//        }
//        else
//        {
        
        
            TestViewController* detailV = [[TestViewController alloc] init];
        
            detailV.userId = KISDictionaryHaveKey(destDic, @"userid");
            detailV.nickName = KISDictionaryHaveKey(destDic, @"nickname");
            detailV.isChatPage = NO;
            [self.navigationController pushViewController:detailV animated:YES];
//        }
    }
    else
    {
//        if ([KISDictionaryHaveKey(tempDict, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
//            MyProfileViewController * myP = [[MyProfileViewController alloc] init];
//            [self.navigationController pushViewController:myP animated:YES];
//        }
//        else
//        {
            TestViewController* detailV = [[TestViewController alloc] init];
            detailV.userId = KISDictionaryHaveKey(tempDict, @"userid");
            detailV.nickName = KISDictionaryHaveKey(tempDict, @"nickname");
            detailV.isChatPage = NO;
            [self.navigationController pushViewController:detailV animated:YES];
//        }
    }
}

- (void)CellOneButtonClick:(int)rowIndex
{
//    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"type")] isEqualToString:@"5"])//评论
//    {
        NSDictionary* tempDict = [m_newsArray objectAtIndex:rowIndex];

        ReplyViewController* VC = [[ReplyViewController alloc] init];
        VC.messageid = KISDictionaryHaveKey(tempDict, @"id");
        VC.isHaveArticle = YES;
        VC.delegate = self;
        [self.navigationController pushViewController:VC animated:YES];
//    }
}

#pragma mark  scrollView  delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (m_myTableView.contentSize.height < m_myTableView.frame.size.height) {
        refreshView.viewMaxY = 0;
    }
    else
        refreshView.viewMaxY = m_myTableView.contentSize.height - m_myTableView.frame.size.height;
    [refreshView viewdidScroll:scrollView];
    
    [_slimeView scrollViewDidScroll];
}


#pragma mark pull up refresh
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(scrollView == m_myTableView)
    {
        [refreshView viewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView == m_myTableView)
    {
        [refreshView didEndDragging:scrollView];
        
        [_slimeView scrollViewDidEndDraging];
    }
}

- (void)PullUpStartRefresh:(PullUpRefreshView *)refreshView
{
    NSLog(@"start");

    [self getNewsDataByNet];
}

#pragma mark - slimeRefresh delegate
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
//    [self performSelector:@selector(endRefresh)
//               withObject:nil
//               afterDelay:2
//                  inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    m_currentPage = 0;
    
    [self getNewsDataByNet];
}

-(void)endRefresh
{
    [_slimeView endRefreshFinish:^{

    }];
}
-(void)dealloc
{
    alertView1.delegate = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
