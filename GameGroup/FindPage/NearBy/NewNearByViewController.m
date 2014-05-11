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
@interface NewNearByViewController ()
{
    UICollectionView *m_photoCollectionView;
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;
    UITableView *m_myTableView;
    UICollectionViewFlowLayout *m_layout;
    NSMutableArray *array;
    NSMutableArray *headImgArray;
    NSString *sexStr ;
    AppDelegate *app;
    NSInteger m_currPageCount;
    UILabel* titleLabel;
    NSString *m_lat;
    NSString *m_lon;
    NSString *cityCode;
    UILabel *nearBylabel;
    UILabel*            m_titleLabel;
    NSInteger           m_searchType;//3全部 0男 1女
    NSString *citydongtaiStr;
    UIButton *menuButton;
    NSMutableArray *wxSDArray;
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
    
    [self setTopViewWithTitle:@"" withBackButton:YES];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, KISHighVersion_7 ? 20 : 0, 220, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"附近";
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
    array = [NSMutableArray array];
    headImgArray =[NSMutableArray array];
    wxSDArray = [NSMutableArray array];
    
    
    
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
    m_photoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 320, 245) collectionViewLayout:m_layout];
//    m_myTableView.backgroundColor = [UIColor grayColor];
    m_photoCollectionView.scrollEnabled = NO;
    m_photoCollectionView.delegate = self;
    m_photoCollectionView.dataSource = self;
    [m_photoCollectionView registerClass:[NearByPhotoCell class] forCellWithReuseIdentifier:@"ImageCell"];
    m_photoCollectionView.backgroundColor = [UIColor clearColor];
    m_myTableView.tableHeaderView = m_photoCollectionView;
    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    hud.labelText = @"获取中...";
    [self.view addSubview:hud];
    
    [self addheadView];
    [self addFootView];
    
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
        m_titleLabel.text = @"附近的玩家(男)";
    }
    else if (buttonIndex == 1) {//女
        m_searchType = 1;
        m_titleLabel.text = @"附近的玩家(女)";
    }
    else//全部
    {
        m_titleLabel.text = @"附近的玩家";
        m_searchType = 2;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)m_searchType] forKey:NearByKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self getInfoWithNet];
    [self getTopImageFromNet];
}



#pragma mark ---
#pragma mark ---- 网络请求
-(void)getLocationForNet
{
    
    if (app.reach.currentReachabilityStatus ==NotReachable) {
        return;
    }
    else{
        [[LocationManager sharedInstance] startCheckLocationWithSuccess:^(double lat, double lon) {
            [[TempData sharedInstance] setLat:lat Lon:lon];
            m_lat =[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLat]];
            m_lon = [NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLon]];
            [self getTopImageFromNet];
            [self getInfoWithNet];
        } Failure:^{
        [self showAlertViewWithTitle:@"提示" message:@"定位失败，请确认设置->隐私->定位服务中陌游的按钮为打开状态" buttonTitle:@"确定"];
        }
         ];
    }
}
-(void)getTopImageFromNet
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    switch (m_searchType) {
        case 0:
            [paramDic setObject:@"0" forKey:@"gender"];
      
            break;
        case 1:
            [paramDic setObject:@"1" forKey:@"gender"];
     
            break;
        case 2:
            [paramDic setObject:@"" forKey:@"gender"];
   
            break;
    
        default:
            break;
    }
    [paramDic setObject:m_lat forKey:@"latitude"];
    [paramDic setObject:m_lon forKey:@"longitude"];
    [paramDic setObject:cityCode?cityCode:@"" forKey:@"cityCode"];
    [paramDic setObject:@"1" forKey:@"gameid"];
    
    
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"204" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [headImgArray removeAllObjects];
            [headImgArray addObjectsFromArray:responseObject];
            if (headImgArray.count<1) {
                m_photoCollectionView.frame = CGRectMake(0, 0, 320, 0);
            }
            else if(headImgArray.count>1&&headImgArray.count<5)
            {
                m_photoCollectionView.frame = CGRectMake(0, 0, 320, 83);
            }
            else if (headImgArray.count>4&&headImgArray.count<9)
            {
                m_photoCollectionView.frame = CGRectMake(0, 0, 320,170);
            }
            else if(headImgArray.count>8&&headImgArray.count<13)
            {
                m_photoCollectionView.frame = CGRectMake(0, 0, 320, 252);
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

-(void)getInfoWithNet
{
    [hud show:YES];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"205" forKey:@"method"];
    [paramDic setObject:cityCode?cityCode:@"" forKey:@"cityCode"];
    [paramDic setObject:@(m_currPageCount) forKey:@"pageIndex"];
    
    switch (m_searchType) {
        case 0:
            [paramDic setObject:@"0" forKey:@"gender"];
            
            break;
        case 1:
            [paramDic setObject:@"1" forKey:@"gender"];
            
            break;
        case 2:
            [paramDic setObject:@"" forKey:@"gender"];
            
            break;
            
        default:
            break;
    }
    [paramDic setObject:@"20" forKey:@"maxSize"];
    [paramDic setObject:m_lat forKey:@"latitude"];
    [paramDic setObject:m_lon forKey:@"longitude"];
    [paramDic setObject:@"1" forKey:@"gameid"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            if (m_currPageCount ==0) {
                [array removeAllObjects];
                [array addObjectsFromArray:responseObject];
                for (int i =0; i <array.count; i++) {
                    array[i] = [self contentAnalyzer:array[i] withReAnalyzer:NO];
                }
            }else{
                NSMutableArray *arr  = [NSMutableArray array];
                NSArray *arrays = [NSArray arrayWithArray:responseObject];
                for (int i =0; i<arrays.count; i++) {
                    [arr addObject:[self contentAnalyzer:arrays[i] withReAnalyzer:NO]];
                }
                [array addObjectsFromArray:arr];
            }
            m_currPageCount ++;
            [m_footer endRefreshing];
            [m_header endRefreshing];
            [m_myTableView reloadData];
        }
        [hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
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
    cell.photoView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseImageUrl,imgStr,@"/160/160"]];
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d",indexPath.row);
    NSDictionary *dict =[headImgArray objectAtIndex:indexPath.row];
    TestViewController *testVC = [[TestViewController alloc]init];
    testVC.nickName =[GameCommon getNewStringWithId: KISDictionaryHaveKey(dict, @"nickname")];
    testVC.userId = [GameCommon getNewStringWithId: KISDictionaryHaveKey(dict, @"userid")];
    [self.navigationController pushViewController:testVC animated:YES];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return array.count;
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
    NSDictionary *dict = [array objectAtIndex:indexPath.row];
    
    cell.nickNameLabel.text = KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"nickname");
    m_currmagY += cell.nickNameLabel.frame.size.height+cell.nickNameLabel.frame.origin.y;   //加上nickName的高度

    cell.headImgBtn.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseImageUrl,[GameCommon getHeardImgId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img")],@"/80/80"]];
    cell.timeLabel.text = [self getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")]];

    
    if (([KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"shiptype")isEqualToString:@"unkown"]||[KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"shiptype")isEqualToString:@"3"])&&![KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"userid")isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        cell.focusButton.hidden = NO;
        if ([KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"shiptype")isEqualToString:@"unkown"]) {
            [cell.focusButton setTitle:@"+关注" forState:UIControlStateNormal];
        }else{
            [cell.focusButton setTitle:@"+好友" forState:UIControlStateNormal];
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
            
            cell.timeLabel.frame = CGRectMake(60,m_currmagY+10, 120, 30);
            cell.zanButton.frame = CGRectMake(180, m_currmagY+10, 70, 30);
            cell.commentBtn.frame = CGRectMake(250, m_currmagY+10, 70, 30);

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
            cell.timeLabel.frame = CGRectMake(60,m_currmagY, 120, 30);
            cell.zanButton.frame = CGRectMake(180, m_currmagY, 70, 30);
            cell.commentBtn.frame = CGRectMake(250, m_currmagY, 70, 30);
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
        
        cell.timeLabel.frame = CGRectMake(60,m_currmagY+10, 120, 30);
        cell.zanButton.frame = CGRectMake(180, m_currmagY+10, 70, 30);
        cell.commentBtn.frame = CGRectMake(250, m_currmagY+10, 70, 30);

        m_currmagY  = cell.timeLabel.frame.origin.y + cell.timeLabel.frame.size.height;
    }
    
    
    return cell;
  
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 320, 40)];
    view.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    nearBylabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 180, 40)];
    nearBylabel.text  =citydongtaiStr;
    nearBylabel.textColor = [UIColor grayColor];
    nearBylabel.font = [UIFont systemFontOfSize:13];
    [view addSubview:nearBylabel];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(220, 0, 100, 40)];
    [button setTitle:@"城市漫游" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button addTarget:self action:@selector(enterCitisePage:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [view addSubview:button];
    return view;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //用分析器初始化m_dataArray
    NSMutableDictionary *dict =[array objectAtIndex:indexPath.row];
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
    m_lat = KISDictionaryHaveKey(dic, @"latitude");
    m_lon = KISDictionaryHaveKey(dic, @"longitude");
    cityCode = KISDictionaryHaveKey(dic, @"cityCode");
    titleLabel.text = KISDictionaryHaveKey(dic, @"city");
    citydongtaiStr = [NSString stringWithFormat:@"%@附近的动态",KISDictionaryHaveKey(dic,@"city")];
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
    NSDictionary *dict = [array objectAtIndex:myCell.tag];
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
    NSDictionary *dic = [array objectAtIndex:myCell.tag];
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
    
    NSDictionary *dic = [array objectAtIndex:myCell.tag];
    
    
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
            [DataStoreManager changshiptypeWithUserId:KISDictionaryHaveKey(KISDictionaryHaveKey([array objectAtIndex:myCell.tag], @"user"), @"userid") type:KISDictionaryHaveKey(responseObject, @"shiptype")];
        }
        
        [wxSDArray removeAllObjects];
        [wxSDArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"sayHello_wx_info_id"]];
        
        if (![wxSDArray containsObject:KISDictionaryHaveKey(KISDictionaryHaveKey([array objectAtIndex:myCell.tag], @"user"), @"userid")]) {
            [self getSayHelloWithID:KISDictionaryHaveKey(KISDictionaryHaveKey([array objectAtIndex:myCell.tag], @"user"), @"userid")];
        }
        myCell.focusButton.hidden =YES;
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
