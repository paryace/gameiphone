//
//  NewNearByViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-5-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewNearByViewController.h"
#import "NearByPhotoCell.h"
#import "LocationManager.h"
#import "TestViewController.h"
#import "MJRefresh.h"
#import "PhotoViewController.h"
#import "OnceDynamicViewController.h"
#import "ReplyViewController.h"
#import "NearByViewController.h"
@interface NewNearByViewController ()
{
    UICollectionView *m_photoCollectionView;
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;
    UITableView *m_myTableView;
    UICollectionViewFlowLayout *m_layout;
    NSMutableArray *m_dataArray;
    NSMutableArray *headImgArray;
    NSString *sexStr ;
    AppDelegate *app;
    NSInteger m_currPageCount;
    UILabel* titleLabel;
    NSString *cityCode;
    UILabel *nearBylabel;
    UILabel*            m_titleLabel;
    NSInteger           m_searchType;//3全部 0男 1女
    NSString *citydongtaiStr;
    UIButton *menuButton;
    NSMutableArray *wxSDArray;
    BOOL isSaveHcTopImg;
    BOOL isSaveHcListInfo;
    
    NSString *titleStr;
    UIActivityIndicatorView *m_loginActivity;
}
@end

@implementation NewNearByViewController

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
    isSaveHcListInfo = NO;
    isSaveHcTopImg = NO;
    [self setTopViewWithTitle:@"" withBackButton:YES];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, KISHighVersion_7 ? 20 : 0, 220, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleStr = @"附近";
    cityCode = @"";
    if ([[NSUserDefaults standardUserDefaults]objectForKey:NewNearByKey]) {
        NSString * type =[[NSUserDefaults standardUserDefaults]objectForKey:NewNearByKey];
        if ([type isEqualToString:@"0"]) {
            titleLabel.text = [titleStr stringByAppendingString:@"(男)"];
        }
        else if ([type isEqualToString:@"1"])
        {
            titleLabel.text = [titleStr stringByAppendingString:@"(女)"];
        }else
        {
            titleLabel.text = titleStr;
        }
    }else
    titleLabel.text = titleStr;
    

    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:titleLabel];

    menuButton=[UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [menuButton setBackgroundImage:KUIImage(@"menu_button_normal") forState:UIControlStateNormal];
    [menuButton setBackgroundImage:KUIImage(@"menu_button_click") forState:UIControlStateHighlighted];
    [self.view addSubview:menuButton];
    
    [menuButton addTarget:self action:@selector(menuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    m_currPageCount = 0;
    m_dataArray = [NSMutableArray new];
    headImgArray =[NSMutableArray array];
    wxSDArray = [NSMutableArray array];
    
    
    m_loginActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:m_loginActivity];
    [self changeActivityPositionWithTitle:titleLabel.text];
    //m_loginActivity.frame = CGRectMake(75, KISHighVersion_7?27:7, 20, 20);
    //m_loginActivity.center = CGPointMake(75, KISHighVersion_7?42:22);
    m_loginActivity.color = [UIColor whiteColor];
    m_loginActivity.activityIndicatorViewStyle =UIActivityIndicatorViewStyleWhite;
   // [m_loginActivity startAnimating];
    
    
    
    
    
    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];

    m_layout = [[UICollectionViewFlowLayout alloc]init];
    m_layout.minimumInteritemSpacing = 1;
    m_layout.minimumLineSpacing = 1;
    m_layout.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1);
    
    m_layout.itemSize = CGSizeMake(77, 77);
    CGFloat paddingY = 2;
    CGFloat paddingX = 2;
    m_layout.sectionInset = UIEdgeInsetsMake(paddingY, paddingX, paddingY, paddingX);
    m_layout.minimumLineSpacing = paddingY;
    m_photoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 320, 83) collectionViewLayout:m_layout];
    
    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSString *path  =[RootDocPath stringByAppendingString:@"/HC_NearByTopImg"];
    BOOL isTrue = [fileManager fileExistsAtPath:path];
    NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:path error:NULL];
    if (isTrue && [[fileAttr objectForKey:NSFileSize] unsignedLongLongValue] != 0) {
        headImgArray= [NSMutableArray arrayWithContentsOfFile:path];
    }
    
    //计算上半部分的高度
    if (headImgArray.count<1) {
        m_photoCollectionView.frame = CGRectMake(0, 0, 320, 0);
    }
    else if(headImgArray.count>0&&headImgArray.count<5)
    {
        m_photoCollectionView.frame = CGRectMake(0, 0, 320, 81);
    }
    else if (headImgArray.count>4&&headImgArray.count<9)
    {
        m_photoCollectionView.frame = CGRectMake(0, 0, 320,160);
    }
    else if(headImgArray.count>8&&headImgArray.count<13)
    {
        m_photoCollectionView.frame = CGRectMake(0, 0, 320, 239);
    }
    else{
        m_photoCollectionView.frame = CGRectMake(0, 0, 320, 334);
    }
    

    

    //m_myTableView.backgroundColor = UIColorFromRGBA(0x262930, 1);
    m_photoCollectionView.scrollEnabled = NO;
    m_photoCollectionView.delegate = self;
    m_photoCollectionView.dataSource = self;
    [m_photoCollectionView registerClass:[NearByPhotoCell class] forCellWithReuseIdentifier:@"ImageCell"];
    m_photoCollectionView.backgroundColor = UIColorFromRGBA(0x262930, 1);
    
    
    m_myTableView.backgroundColor = UIColorFromRGBA(0x262930, 1);
    m_myTableView.tableHeaderView = m_photoCollectionView;
    
//    hud = [[MBProgressHUD alloc]initWithView:self.view];
//    hud.labelText = @"获取中...";
//    [self.view addSubview:hud];
    
    [self addheadView];
    [self addFootView];
    
      NSString *path1  =[RootDocPath stringByAppendingString:@"/HC_NearByInfoList"];
    BOOL isTrue1 = [fileManager fileExistsAtPath:path1];
    NSDictionary *fileAttr1 = [fileManager attributesOfItemAtPath:path1 error:NULL];
    if (isTrue1 && [[fileAttr1 objectForKey:NSFileSize] unsignedLongLongValue] != 0) {
        m_dataArray= [NSMutableArray arrayWithContentsOfFile:path1];
    }
    
    [self getLocationForNet];
    

    citydongtaiStr = @"附近的动态";
    // Do any additional setup after loading the view.
    
}


- (void)menuButtonClick:(UIButton *)sender
{
//    if(isGetNetSuccess ==NO)
//    {
//        [self showMessageWithContent:@"正在处理上次请求" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
//    }else{
    
        UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"筛选条件"
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:Nil
                                      otherButtonTitles:@"只看男", @"只看女", @"看全部", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheet showInView:self.view];
   // }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    // [m_tabelData removeAllObjects];
    // [m_myTableView reloadData];
    
    m_currPageCount = 0;
    if (buttonIndex == 0) {//男
        m_searchType = 0;
        titleLabel.text =[titleStr stringByAppendingString:@"(男)"];
    }
    else if (buttonIndex == 1) {//女
        m_searchType = 1;
        titleLabel.text =[titleStr stringByAppendingString:@"(女)"];
    }
    else//全部
    {
        titleLabel.text = titleStr;
        m_searchType = 2;
    }
    [self changeActivityPositionWithTitle:titleLabel.text];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)m_searchType] forKey:NewNearByKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self getInfoWithNet];
    [self getTopImageFromNet];
}



#pragma mark ---
#pragma mark ---- 网络请求
-(void)getLocationForNet
{
    [m_loginActivity startAnimating];
    if (app.reach.currentReachabilityStatus ==NotReachable) {
        return;
    }
    else{
        [[LocationManager sharedInstance] startCheckLocationWithSuccess:^(double lat, double lon) {
            [[TempData sharedInstance] setLat:lat Lon:lon];
            isSaveHcTopImg = YES;
            isSaveHcListInfo = YES;
            [self getTopImageFromNet];
            [self getInfoWithNet];
        } Failure:^{
            [m_loginActivity stopAnimating];
        [self showAlertViewWithTitle:@"提示" message:@"定位失败，请确认设置->隐私->定位服务中陌游的按钮为打开状态" buttonTitle:@"确定"];
        }
         ];
    }
}
-(void)getTopImageFromNet
{
    [m_loginActivity startAnimating];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:NewNearByKey]) {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:NewNearByKey]) {
            NSString * type =[[NSUserDefaults standardUserDefaults]objectForKey:NewNearByKey];
            if ([type isEqualToString:@"0"]) {
                [paramDic setObject:@"0" forKey:@"gender"];
            }
            else if ([type isEqualToString:@"1"])
            {
                [paramDic setObject:@"1" forKey:@"gender"];
            }else
            {
                [paramDic setObject:@"" forKey:@"gender"];
            }
        }
    }
    [paramDic setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLat]] forKey:@"latitude"];
    [paramDic setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLon]] forKey:@"longitude"];
    [paramDic setObject:cityCode?cityCode:@"" forKey:@"cityCode"];
    [paramDic setObject:@"1" forKey:@"gameid"];
    
    
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"204" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [m_loginActivity stopAnimating];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [headImgArray removeAllObjects];
            [headImgArray addObjectsFromArray:responseObject];
            if (headImgArray.count==12) {
                [headImgArray removeLastObject];
            }
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"seeMore.jpg",@"img", nil];
            
            [headImgArray addObject:dic];
            if (headImgArray.count<1) {
                m_photoCollectionView.frame = CGRectMake(0, 0, 320, 0);
            }
            else if(headImgArray.count>0&&headImgArray.count<5)
            {
                m_photoCollectionView.frame = CGRectMake(0, 0, 320, 81);
            }
            else if (headImgArray.count>4&&headImgArray.count<9)
            {
                m_photoCollectionView.frame = CGRectMake(0, 0, 320,160);
            }
            else if(headImgArray.count>8&&headImgArray.count<13)
            {
                m_photoCollectionView.frame = CGRectMake(0, 0, 320, 239);
            }
            else{
                m_photoCollectionView.frame = CGRectMake(0, 0, 320, 334);
            }
            
            CGRect frame = m_myTableView.tableHeaderView.frame;
            frame.size.height =m_photoCollectionView.bounds.size.height;
            UIView *view = m_myTableView. tableHeaderView;
            view.frame = frame;
            m_myTableView.tableHeaderView = view;

            [m_photoCollectionView reloadData];
            
            if (isSaveHcTopImg) {
                NSString *filePath = [RootDocPath stringByAppendingString:@"/HC_NearByTopImg"];
                [headImgArray writeToFile:filePath atomically:YES];
                isSaveHcTopImg = NO;
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [m_loginActivity stopAnimating];
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

-(void)getInfoWithNet
{
    [hud show:YES];
    [m_loginActivity startAnimating];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"205" forKey:@"method"];
    [paramDic setObject:cityCode?cityCode:@"" forKey:@"cityCode"];
    [paramDic setObject:@(m_currPageCount) forKey:@"pageIndex"];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:NewNearByKey]) {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:NewNearByKey]) {
            NSString * type =[[NSUserDefaults standardUserDefaults]objectForKey:NewNearByKey];
            if ([type isEqualToString:@"0"]) {
                [paramDic setObject:@"0" forKey:@"gender"];
            }
            else if ([type isEqualToString:@"1"])
            {
                [paramDic setObject:@"1" forKey:@"gender"];
            }else
            {
                [paramDic setObject:@"" forKey:@"gender"];
            }
        }
    }
    
      [paramDic setObject:@"20" forKey:@"maxSize"];
    [paramDic setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLat]] forKey:@"latitude"];
    [paramDic setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLon]] forKey:@"longitude"];
    [paramDic setObject:@"1" forKey:@"gameid"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [m_loginActivity stopAnimating];
//        if ([responseObject isKindOfClass:[NSArray class]]) {
            if (m_currPageCount ==0) {
                [m_dataArray removeAllObjects];
                if ([responseObject isKindOfClass:[NSArray class]]) {
                    [m_dataArray addObjectsFromArray:responseObject];
                    for (int i =0; i <m_dataArray.count; i++) {
                        m_dataArray[i] = [self contentAnalyzer:m_dataArray[i] withReAnalyzer:NO];
                    }
                
                
                    if (isSaveHcListInfo) {
                        NSString *filePath = [RootDocPath stringByAppendingString:@"/HC_NearByInfoList"];
                        [m_dataArray writeToFile:filePath atomically:YES];
                        isSaveHcListInfo = NO;
                    }
                }
                
            }else{
                if ([responseObject isKindOfClass:[NSArray class]]) {
                    NSMutableArray *arr  = [NSMutableArray array];
                    NSArray *arrays = [NSArray arrayWithArray:responseObject];
                    for (int i =0; i<arrays.count; i++) {
                        [arr addObject:[self contentAnalyzer:arrays[i] withReAnalyzer:NO]];
                    }
                    [m_dataArray addObjectsFromArray:arr];
                }
            }
            m_currPageCount ++;
            [m_myTableView reloadData];
            [m_footer endRefreshing];
            [m_header endRefreshing];
//        }
        [hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [m_loginActivity stopAnimating];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                
            }
        }
        [m_footer endRefreshing];
        [m_header endRefreshing];

        [hud hide:YES];
    }];
    
}

#pragma mark----
#pragma marl ====照片墙    collectionView delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return headImgArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NearByPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    NSDictionary *dict =[headImgArray objectAtIndex:indexPath.row];
    
    NSString *imgStr =[NSString stringWithFormat:@"%@",[GameCommon getHeardImgId:KISDictionaryHaveKey(dict, @"img")]];
    
    if ([imgStr isEqualToString:@""]||[imgStr isEqualToString:@""]) {
        cell.photoView.imageURL = nil;
    }else{
        if ([imgStr isEqualToString:@"seeMore.jpg"]) {
            cell.photoView.imageURL = nil;
            cell.photoView.hidden = YES;
            cell.moreImageView.hidden = NO;
            cell.moreImageView.image = KUIImage(@"seeMore.jpg");
        }
        else{
            cell.photoView.hidden = NO;
            cell.moreImageView.hidden = YES;
            cell.photoView.placeholderImage = KUIImage(@"placehoder");
            cell.photoView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseImageUrl,imgStr,@"/160/160"]];
        }
    }
    
    if ([KISDictionaryHaveKey(dict, @"gender")intValue]==0)
    {
        cell.sexImageView.image = KUIImage(@"gender_boy");
    }else
    {
        cell.sexImageView.image = KUIImage(@"gender_girl");
    }
    if (indexPath.row ==headImgArray.count-1)
    {
        cell.lestView.hidden = YES;
    }
    else
    {
        cell.lestView.hidden = NO;
    }
    
    NSString *distrance =KISDictionaryHaveKey(dict, @"distance");
    double dis = [distrance doubleValue];
    double gongLi = dis/1000;
    
    NSString* allStr = @"";
    if (gongLi < 0 || gongLi == 9999) {//距离-1时 存的9999000
        allStr =@"未知";
    }
    else
    {
        if(gongLi>999)
            allStr = [NSString stringWithFormat:@"%.0fkm",gongLi];
        else
            allStr = [NSString stringWithFormat:@"%.2fkm",gongLi];
    }
    cell.distanceLabel.text = allStr;
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d",indexPath.row);
    if (indexPath.row ==headImgArray.count-1) {
        NearByViewController *nearBy = [[NearByViewController alloc]init];
        nearBy.cityCode =[NSString stringWithFormat:@"%@",[GameCommon getNewStringWithId:cityCode]];
        nearBy.titleStr =[NSString stringWithFormat:@"%@",titleStr];
        [self.navigationController pushViewController:nearBy animated:YES];
    }
    else{
    NSDictionary *dict =[headImgArray objectAtIndex:indexPath.row];
    TestViewController *testVC = [[TestViewController alloc]init];
    testVC.nickName =[GameCommon getNewStringWithId: KISDictionaryHaveKey(dict, @"nickname")];
    testVC.userId = [GameCommon getNewStringWithId: KISDictionaryHaveKey(dict, @"userid")];
    [self.navigationController pushViewController:testVC animated:YES];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (m_dataArray.count>0) {
        m_myTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    else
    {
        m_myTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }
    return m_dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    NewNearByCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[NewNearByCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    float m_currmagY =0;

    cell.myCellDelegate = self;
    cell.tag = indexPath.row;
    NSDictionary *dict = [m_dataArray objectAtIndex:indexPath.row];
    
    if ([KISDictionaryHaveKey(dict, @"isZan")intValue] ==1) {
        [cell.zanButton setBackgroundImage:KUIImage(@"zan_cancle_nearBy") forState:UIControlStateNormal];
   //     [cell.zanButton setBackgroundImage:KUIImage(@"cancle_zan_click") forState:UIControlStateNormal];
    }else{
        [cell.zanButton setBackgroundImage:KUIImage(@"NearByZan") forState:UIControlStateNormal];
//        [cell.zanButton setBackgroundImage:KUIImage(@"zan_circle_click") forState:UIControlStateHighlighted];
    }
    
    
    
    cell.nickNameLabel.text = KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"nickname");
    m_currmagY += cell.nickNameLabel.frame.size.height+cell.nickNameLabel.frame.origin.y;   //加上nickName的高度

    cell.headImgBtn.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseImageUrl,[GameCommon getHeardImgId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img")],@"/80/80"]];
    cell.timeLabel.text = [self getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")]];

    if (([KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"shiptype")isEqualToString:@"unkown"]||[KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"shiptype")isEqualToString:@"3"])&&![KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"userid")isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        cell.focusButton.hidden = NO;
        if ([KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"shiptype")isEqualToString:@"unkown"]) {
            [cell.focusButton setBackgroundImage:KUIImage(@"guanzhu") forState:UIControlStateNormal];
        }else{
           [cell.focusButton setBackgroundImage:KUIImage(@"NearByAddFriend")forState:UIControlStateNormal];
        }
    }else{
        cell.focusButton.hidden = YES;
    }
    
    NSString *urlLink = KISDictionaryHaveKey(dict, @"urlLink");
    
    //开始正文布局
    //动态
    
    if ([urlLink isEqualToString:@" "]||[urlLink isEqualToString:@""]||urlLink ==nil) {
        cell.shareView.hidden = YES;
        cell.shareInfoLabel.hidden = YES;
        cell.shareImageView.hidden = YES;
        [cell.titleLabel setEmojiText:KISDictionaryHaveKey(dict, @"msg")];
        
        //动态的高度
        float height1 = [KISDictionaryHaveKey(dict, @"titleLabelHieght") floatValue];
        cell.titleLabel.frame = CGRectMake(60, 30, 250, height1);
        m_currmagY += height1;
        
        
        //无图动态
        if ([KISDictionaryHaveKey(dict, @"img") isEqualToString:@""]||[KISDictionaryHaveKey(dict, @"img") isEqualToString:@" "]) {
            cell.photoCollectionView.hidden =YES;
            
            cell.timeLabel.frame = CGRectMake(60,m_currmagY+10, 80, 30);
            cell.zanButton.frame = CGRectMake(180, m_currmagY+14, 40, 22);
            cell.commentBtn.frame = CGRectMake(260, m_currmagY+14, 40, 22);
        }
        //有图动态
        else{
            NSArray *imgArray = KISDictionaryHaveKey(dict, @"imgArray");
            cell.photoArray = imgArray;
            cell.photoCollectionView.hidden = NO;
            
            float imgHeight = [KISDictionaryHaveKey(dict, @"imgHieght") floatValue];
            cell.photoCollectionView.frame = CGRectMake(60, m_currmagY, 250,imgHeight);
            m_currmagY += imgHeight;
            
            CGFloat paddingY = 2;
            CGFloat paddingX = 2;
            cell.layout.sectionInset = UIEdgeInsetsMake(paddingY, paddingX, paddingY, paddingX);
            cell.layout.minimumLineSpacing = paddingY;
            
            [cell.photoCollectionView reloadData];
            cell.timeLabel.frame = CGRectMake(60,m_currmagY, 80, 30);
            cell.zanButton.frame = CGRectMake(180, m_currmagY+5, 40, 22);
            cell.commentBtn.frame = CGRectMake(260, m_currmagY+5, 40, 22);
            //删除按钮 - 自己的文章
            }
        
        m_currmagY=cell.timeLabel.frame.origin.y + cell.timeLabel.frame.size.height;
    }
    //后台文章 - URLlink有内容的
    else
    {
        cell.shareView.hidden = NO;
        cell.shareInfoLabel.hidden = NO;
        cell.shareImageView.hidden = NO;
        cell.photoCollectionView.hidden =YES;
        cell.titleLabel.text = KISDictionaryHaveKey(dict, @"title");
        
        float titleLabelHeight;
        //文章高度
        titleLabelHeight = [KISDictionaryHaveKey(dict, @"titleLabelHieght") floatValue];
        cell.titleLabel.frame = CGRectMake(60, 30, 250, titleLabelHeight);
        cell.shareView.frame = CGRectMake(60, titleLabelHeight+35, 250, 50);
        //titleLabelHeight +=5;
        m_currmagY += titleLabelHeight +50;
        
        //去除掉首尾的空白字符和换行字符
        NSString *str = KISDictionaryHaveKey(dict, @"msg");
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        cell.shareInfoLabel.text =str;
        
        
        [cell.shareView addTarget:self action:@selector(enterInfoPage:) forControlEvents:UIControlEventTouchUpInside];
        cell.shareView.tag = indexPath.row;
        
        //无图文章
        if ([KISDictionaryHaveKey(dict, @"img")isEqualToString:@""]||[KISDictionaryHaveKey(dict, @"img")isEqualToString:@" "]) {
            cell.shareImageView.imageURL =nil;
            cell.shareImageView.hidden =YES;
            cell.shareInfoLabel.frame = CGRectMake(5, 5, 245, 40);
            cell.shareInfoLabel.numberOfLines =2;
        }else{  //有图文章
            cell.shareImageView.hidden =NO;
            cell.shareImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:KISDictionaryHaveKey(dict, @"img")]];
            cell.shareInfoLabel.frame = CGRectMake(60, 5, 190, 40);
            cell.shareInfoLabel.numberOfLines = 2;
        }
        
        cell.timeLabel.frame = CGRectMake(60,m_currmagY+10, 80, 30);
        cell.zanButton.frame = CGRectMake(180, m_currmagY+15, 40, 22);
        cell.commentBtn.frame = CGRectMake(260, m_currmagY+15, 40, 22);

        m_currmagY  = cell.timeLabel.frame.origin.y + cell.timeLabel.frame.size.height;
    }
    return cell;
  
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    OnceDynamicViewController *once =[[ OnceDynamicViewController alloc]init];
    once.messageid =KISDictionaryHaveKey(dic, @"id");
    [self.navigationController pushViewController:once animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 320, 40)];
    view.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    
    UIImageView *imageVIew =[[ UIImageView alloc]initWithFrame:CGRectMake(10, 4, 32, 32)];
    imageVIew.image = KUIImage(@"compass");
    [view addSubview:imageVIew];
    
    nearBylabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, 180, 40)];
    nearBylabel.text  =citydongtaiStr;
    nearBylabel.textColor = [UIColor grayColor];
    nearBylabel.font = [UIFont systemFontOfSize:13];
    [view addSubview:nearBylabel];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(220, 0, 100, 39)];
    [button setTitle:@"城市漫游 >" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button addTarget:self action:@selector(enterCitisePage:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [view addSubview:button];
    
    UIView  * underView = [[UIView alloc]initWithFrame:CGRectMake(0, 39, 320, 1)];
    underView.backgroundColor = UIColorFromRGBA(0xc1c1c1, 1);
    [view addSubview:underView];
    
    return view;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //用分析器初始化m_dataArray
    NSMutableDictionary *dict =[m_dataArray objectAtIndex:indexPath.row];
    [self contentAnalyzer:dict withReAnalyzer:NO];
    float currnetY = [KISDictionaryHaveKey(dict, @"cellHieght") floatValue];
    
    //以动态id为键存放每个cell的高度到集合里
  //  NSNumber *number = [NSNumber numberWithFloat:currnetY];
  //  [cellhightarray setObject:number forKey:KISDictionaryHaveKey(dict, @"id")];
    return currnetY;
}

-(void)enterCitisePage:(UIButton *)sender
{
    CityViewController *cityVC = [[CityViewController alloc]init];
    cityVC.mydelegate = self;
    [self.navigationController pushViewController:cityVC animated:YES];
}

-(void)pushCityNumTonextPageWithDictionary:(NSDictionary *)dic{

    cityCode = KISDictionaryHaveKey(dic, @"cityCode");
    titleStr =[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"city")];
    
   if ([[NSUserDefaults standardUserDefaults]objectForKey:NewNearByKey])
   {
       if ([[NSUserDefaults standardUserDefaults]objectForKey:NewNearByKey]) {
           NSString * type =[[NSUserDefaults standardUserDefaults]objectForKey:NewNearByKey];
           if ([type isEqualToString:@"0"]) {
               titleLabel.text = [titleStr stringByAppendingString:@"(男)"];
           }
           else if ([type isEqualToString:@"1"])
           {
               titleLabel.text = [titleStr stringByAppendingString:@"(女)"];
           }else
           {
               titleLabel.text = titleStr;
           }
       }
   }else{
       titleLabel.text = titleStr;
   }
    [self changeActivityPositionWithTitle:titleLabel.text];
    citydongtaiStr = [NSString stringWithFormat:@"%@附近的动态",KISDictionaryHaveKey(dic,@"city")];
    m_currPageCount =0;
    [self getInfoWithNet];
    [self getTopImageFromNet];
}
#pragma mark --getTime //时间戳方法
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
        [self getInfoWithNet];
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
        [self getInfoWithNet];
    };
    m_footer = footer;
}
- (void)bigImgWithCircle:(NewNearByCell*)myCell WithIndexPath:(NSInteger)row
{
    NSLog(@"点击查看大图");
    NSDictionary *dict = [m_dataArray objectAtIndex:myCell.tag];
    NSArray *array1 = [NSArray  array];
    
    NSString *imgStr =KISDictionaryHaveKey(dict, @"img");
    NSString *str;
    if ([imgStr isEqualToString:@""] || [imgStr isEqualToString:@" "]) {
        str = @"";
    }else{
        str = [imgStr substringFromIndex:imgStr.length-1];
        NSString *str2;
        if ([str isEqualToString:@","]) {
            str2= [imgStr substringToIndex:imgStr.length-1];
        }
        else {
            str2 = imgStr;
        }
        array1 = [NSArray array];
        array1 = [str2 componentsSeparatedByString:@","];
    }
    PhotoViewController * pV = [[PhotoViewController alloc] initWithSmallImages:nil images:array1 indext:row];
    [self presentViewController:pV animated:NO completion:^{
    }];
    
}

-(void)enterPersonPageWithCell:(NewNearByCell *)myCell
{
    NSDictionary *dic = [m_dataArray objectAtIndex:myCell.tag];
    TestViewController *test = [[TestViewController alloc]init];
    test.userId = KISDictionaryHaveKey(KISDictionaryHaveKey(dic,@"user"), @"userid");
    test.nickName = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"nickname");
    [self.navigationController pushViewController: test animated:YES];
}

#pragma mark Content分析器
- (NSMutableDictionary *)contentAnalyzer:(NSMutableDictionary *)contentDict withReAnalyzer:(BOOL)reAnalyzer;
{
    if ([[contentDict allKeys]containsObject:@"Analyzed"] && [KISDictionaryHaveKey(contentDict, @"Analyzed") boolValue] && !reAnalyzer ) {  //如果已经分析过
        return contentDict;
    }
    
    float cellHeight = 0.0f; //行高
    
    //昵称
    cellHeight += 30;
    
    //正文高度
    if([[contentDict allKeys]containsObject:@"titleLabelHieght"] &&!reAnalyzer)
    {
        cellHeight += [KISDictionaryHaveKey(contentDict, @"titleLabelHieght") floatValue];
    }
    else{
        
        NSString *urlLink = KISDictionaryHaveKey(contentDict, @"urlLink");
        if ([urlLink isEqualToString:@" "]||[urlLink isEqualToString:@""]||urlLink ==nil){
            //普通正文
            NSString *str = KISDictionaryHaveKey(contentDict, @"msg");
            str = [UILabel getStr:str];
            CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(245, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            [contentDict setObject:@(size.height) forKey:@"titleLabelHieght"];
            cellHeight += size.height;
            //图片
            if([[contentDict allKeys]containsObject:@"imgHieght"] &&!reAnalyzer)
            {
                cellHeight +=[KISDictionaryHaveKey(contentDict, @"imgHieght") floatValue];
            }
            else{
                if([KISDictionaryHaveKey(contentDict, @"img") isEqualToString:@""]||[KISDictionaryHaveKey(contentDict, @"img") isEqualToString:@" "])
                {
                    //无图
                    cellHeight += 0;
                    
                    [contentDict setObject:@(0) forKey:@"imgHieght"];
                }
                else
                {
                    //有图， 先解析出图片数组
                    NSMutableString *imgStr = KISDictionaryHaveKey(contentDict, @"img");
                    NSString *str = [imgStr substringFromIndex:imgStr.length];
                    NSString *str2;
                    if ([str isEqualToString:@","]) {
                        str2= [imgStr substringToIndex:imgStr.length-1];
                    }
                    else {
                        str2 = imgStr;
                    }
                    NSArray *collArray = [imgStr componentsSeparatedByString:@","];
                    
                    if ([[collArray lastObject]isEqualToString:@""]||[[collArray lastObject]isEqualToString:@" "]) {
                        [(NSMutableArray*)collArray removeLastObject];
                    }
                    [contentDict setObject:collArray forKey:@"imgArray"];
                    
                    //根据图片数组接卸图片所占高度
                    int i = (collArray.count-1)/3;
                    float imgViewHeight = i*80+80; //图片的高度
                    imgViewHeight += (i+1)*2; //图片的padding, 为2
                    [contentDict setObject:@(imgViewHeight) forKey:@"imgHieght"];
                    
                    cellHeight +=imgViewHeight;
                }
            }

        }
        else {
            //分享的链接 URL
            NSString *strTitle = KISDictionaryHaveKey(contentDict, @"title");
            NSString *strMsg = KISDictionaryHaveKey(contentDict, @"msg");
            NSLog(@"strTitle:%@",strTitle);
            NSLog(@"strMsg:%@",strMsg);
            CGSize size1 = [strTitle sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(245, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            NSNumber* titleLabelHieght = [NSNumber numberWithFloat:size1.height];
            [contentDict setObject:titleLabelHieght forKey:@"titleLabelHieght"];
            cellHeight += size1.height + 50;
        }
    }
    
    //时间label, 删除按钮与btn_more  50
    cellHeight += 50;
    
    //查看更多评论label
    [contentDict setObject:@(cellHeight) forKey:@"cellHieght"];
    
    bool Analyzed = YES;
    [contentDict setObject:@(Analyzed) forKey:@"Analyzed"];
    return contentDict;
}

-(void)changeShiptypeWithCell:(NewNearByCell *)myCell
{
    
    NSDictionary *dic = [m_dataArray objectAtIndex:myCell.tag];
    
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"userid") forKey:@"frienduserid"];
    if ([KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"shiptype")isEqualToString:@"unkown"]) {
        [paramDict setObject:@"2" forKey:@"type"];
    }else if ([KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"shiptype")isEqualToString:@"3"]){
        [paramDict setObject:@"1" forKey:@"type"];
    }
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"109" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            [DataStoreManager changshiptypeWithUserId:KISDictionaryHaveKey(KISDictionaryHaveKey([m_dataArray objectAtIndex:myCell.tag], @"user"), @"userid") type:KISDictionaryHaveKey(responseObject, @"shiptype")];
        }
        for (int i = 0 ;i<m_dataArray.count;i++) {
            NSMutableDictionary *dicTemp = [m_dataArray objectAtIndex:i];
            NSMutableDictionary *dicUser =KISDictionaryHaveKey(dicTemp, @"user");
            if ([KISDictionaryHaveKey(KISDictionaryHaveKey(dicTemp, @"user"), @"userid")isEqualToString:
                 KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"userid")]) {
                
                [dicUser setObject:KISDictionaryHaveKey(responseObject, @"shiptype") forKey:@"shiptype"];
                [m_dataArray replaceObjectAtIndex:i withObject:dicTemp];
            }
        }
        [wxSDArray removeAllObjects];
        [wxSDArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"sayHello_wx_info_id"]];
        
        if (![wxSDArray containsObject:KISDictionaryHaveKey(KISDictionaryHaveKey([m_dataArray objectAtIndex:myCell.tag], @"user"), @"userid")]) {
            [self getSayHelloWithID:KISDictionaryHaveKey(KISDictionaryHaveKey([m_dataArray objectAtIndex:myCell.tag], @"user"), @"userid")];
        }
        myCell.focusButton.hidden =YES;
        [m_myTableView reloadData];
        [self showMessageWindowWithContent:@"添加成功" imageType:0];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];

}
-(void)getSayHelloWithID:(NSString *)userid
{
    
    [self DetectNetwork];
    
    NSMutableDictionary * postDict1 = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:userid forKey:@"touserid"];
    [postDict1 addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict1 setObject:@"153" forKey:@"method"];
    [postDict1 setObject:paramDict forKey:@"params"];
    
    [postDict1 setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStrNoController:BaseClientUrl Parameters:postDict1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [wxSDArray addObject:userid];
        [DataStoreManager storeThumbMsgUser:userid type:@"1"];
        
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"sayHello_wx_info_id"];
        [[NSUserDefaults standardUserDefaults]setObject:wxSDArray forKey:@"sayHello_wx_info_id"];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
    
}

-(void)didClickToComment:(NewNearByCell *)myCell
{
    NSDictionary *dic = [m_dataArray objectAtIndex:myCell.tag];
    ReplyViewController *rep = [[ReplyViewController alloc]init];
    rep.messageid = KISDictionaryHaveKey(dic,@"id");
    [self.navigationController pushViewController:rep animated:YES];

}

-(void)didClickToZan:(NewNearByCell *)myCell
{
    NSMutableDictionary *dic = [m_dataArray objectAtIndex:myCell.tag];
    NSMutableDictionary *commentUser = [NSMutableDictionary dictionary];
    [commentUser setObject:@"" forKey:@"img"];
    [commentUser setObject:[DataStoreManager queryNickNameForUser:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]] forKey:@"nickname"];
    [commentUser setObject:@"0" forKey:@"superstar"];
    [commentUser setObject:@"" forKey:@"userid"];
    [commentUser setObject:@"" forKey:@"username"];
    
    
    NSString *isZan = KISDictionaryHaveKey(dic, @"isZan");
    if ([isZan intValue]==0) {//假如是未赞状态
        [self showMessageWindowWithContent:@"赞已成功" imageType:0];
        [myCell.zanButton setBackgroundImage:KUIImage(@"zan_cancle_nearBy") forState:UIControlStateNormal];
        [dic setObject:@"1" forKey:@"isZan"];
        //请求网络点赞
        [self postZanWithMsgId:KISDictionaryHaveKey(dic, @"id") IsZan:YES];
    }else{//假如是已经赞的状态
        [self showMessageWindowWithContent:@"已取消" imageType:0];
        [myCell.zanButton setBackgroundImage:KUIImage(@"zan_circle_normal") forState:UIControlStateNormal];
        [dic setObject:@"0" forKey:@"isZan"];
        //请求网络取消
        [self postZanWithMsgId:KISDictionaryHaveKey(dic, @"id") IsZan:NO];
    }
}
//上传赞
-(void)postZanWithMsgId:(NSString *)msgid IsZan:(BOOL)isZan
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:msgid forKey:@"messageId"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"185" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    
    
    
    
    if (app.reach.currentReachabilityStatus ==NotReachable) {
//        NSString* uuid = [[GameCommon shareGameCommon] uuid];
//        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
//                             msgid,@"msgId",
//                             uuid,@"uuid",nil];
//        [DataStoreManager saveOfflineZanWithDic:dic];
    }
    else{
        
        [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [m_myTableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, id error) {
            [m_myTableView reloadData];
            if ([error isKindOfClass:[NSDictionary class]]) {
                if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
                {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }
            }
        }];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//根据标题的长度更改UIActivity的位置
-(void)changeActivityPositionWithTitle:(NSString *)title
{
    CGSize size = [title sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(220, 30)];
    //文字的左起位置
    float title_left_x = 160 - size.width/2;
    if (title_left_x<50) {  //不会超过左边界
        title_left_x = 50;
    }
    //UIActivity的位置
    m_loginActivity.frame = CGRectMake(title_left_x-20, KISHighVersion_7?27:7, 20, 20);
    m_loginActivity.center = CGPointMake(title_left_x-20, KISHighVersion_7?42:22);
    
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
