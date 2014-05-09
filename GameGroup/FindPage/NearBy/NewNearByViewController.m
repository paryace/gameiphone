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
#import "CityViewController.h"
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
    
    [self setTopViewWithTitle:@"附近" withBackButton:YES];
    m_currPageCount = 0;
    array = [NSMutableArray array];
    headImgArray =[NSMutableArray array];
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
    m_myTableView.backgroundColor = [UIColor grayColor];
    m_photoCollectionView.scrollEnabled = NO;
    m_photoCollectionView.delegate = self;
    m_photoCollectionView.dataSource = self;
    [m_photoCollectionView registerClass:[NearByPhotoCell class] forCellWithReuseIdentifier:@"ImageCell"];
    m_photoCollectionView.backgroundColor = [UIColor clearColor];
    m_myTableView.tableHeaderView = m_photoCollectionView;
    
    [self addheadView];
    [self addFootView];
    
    [self getLocationForNet];
    
    // Do any additional setup after loading the view.
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
    sexStr =@"1";
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [paramDic setObject:sexStr?sexStr:@"" forKey:@"gender"];
    [paramDic setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLat]] forKey:@"latitude"];
    [paramDic setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLon]] forKey:@"longitude"];
    [paramDic setObject:@"1" forKey:@"gameid"];
    
    
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"204" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [headImgArray removeAllObjects];
            [headImgArray addObjectsFromArray:responseObject];
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
    sexStr = @"1";
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"205" forKey:@"method"];
    [paramDic setObject:@(m_currPageCount) forKey:@"pageIndex"];
    [paramDic setObject:@"" forKey:@"gender"];
    [paramDic setObject:@"20" forKey:@"maxSize"];
    [paramDic setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLat]] forKey:@"latitude"];
    [paramDic setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLon]] forKey:@"longitude"];
    [paramDic setObject:@"1" forKey:@"gameid"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            if (m_currPageCount ==0) {
                [array removeAllObjects];
                [array addObjectsFromArray:responseObject];
            }else{
                [array addObjectsFromArray:responseObject];
            }
            m_currPageCount ++;
            [m_footer endRefreshing];
            [m_header endRefreshing];
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
    
    NSDictionary *dict = [array objectAtIndex:indexPath.row];
    
    
    cell.nickNameLabel.text = KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"nickname");
    cell.headImgBtn.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseImageUrl,[GameCommon getHeardImgId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img")],@"/80/80"]];
    cell.timeLabel.text = [self getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")]];

    NSString *urlLink = KISDictionaryHaveKey(dict, @"urlLink");
    
    //开始正文布局
    //动态
    if ([urlLink isEqualToString:@" "]||[urlLink isEqualToString:@""]||urlLink ==nil) {
        cell.shareView.hidden = YES;
        cell.shareInfoLabel.hidden = YES;
        cell.shareImageView.hidden = YES;
        
        CGSize size = [NewNearByCell getContentHeigthWithStr:KISDictionaryHaveKey(dict, @"msg")];
        cell.titleLabel.frame = CGRectMake(60, 30, 250, size.height+5);
        cell.titleLabel.text = KISDictionaryHaveKey(dict, @"msg");
        
        NSMutableString *imgStr = KISDictionaryHaveKey(dict, @"img");
        if ([imgStr isEqualToString:@""]||[imgStr isEqualToString:@" "]) {
            cell.photoCollectionView.hidden = YES;
            cell.timeLabel.frame = CGRectMake(60, size.height+35, 100, 30);

        }else{
        NSString *str = [imgStr substringFromIndex:imgStr.length];
        NSString *str2;
        if ([str isEqualToString:@","]) {
            str2= [imgStr substringToIndex:imgStr.length-1];
        }
        else {
            str2 = imgStr;
        }
        cell.photoArray = [imgStr componentsSeparatedByString:@","];
        if ([[cell.photoArray lastObject]isEqualToString:@""]||[[cell.photoArray lastObject]isEqualToString:@" "]) {
            [(NSMutableArray*)cell.photoArray removeLastObject];
        }
        cell.photoCollectionView.hidden = NO;
        cell.photoCollectionView.frame =  CGRectMake(60,size.height+35, 250, 80*(cell.photoArray.count-1)+80);
        cell.timeLabel.frame = CGRectMake(60, size.height+35+80*(cell.photoArray.count-1)/3+80, 100, 30);

        }
    }else{
        cell.shareView.hidden = NO;
        cell.shareInfoLabel.hidden =NO;
        cell.shareImageView.hidden = NO;
        
        CGSize size =[NewNearByCell getContentHeigthWithStr:KISDictionaryHaveKey(dict, @"title")];
        cell.titleLabel.text = KISDictionaryHaveKey(dict, @"title");
        cell.textLabel.frame  = CGRectMake(60, 30, 250, size.height+5);
        
        cell.shareView.frame = CGRectMake(60, 40, 250, 50);
        cell.shareImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/80/80",BaseImageUrl,[GameCommon getHeardImgId:KISDictionaryHaveKey(dict, @"img")]]];
        cell.shareInfoLabel.text = KISDictionaryHaveKey(dict, @"msg");
        cell.timeLabel.frame = CGRectMake(60, size.height+35+55, 100, 30);

    }
    /*
     commentNum = 8;
     createDate = 1399613035000;
     id = 233793;
     img = "";
     isZan = 0;
     msg = "\U795e\U4e4b\U5f7c\U5cb8\U7684\Uff0c\U6765\U8fd9\U91cc\U70b9\U8d5e\Uff0c\U7b7e\U5230\U4e86\Uff0c\U968f\U673a\U53d1\U5956\U52b1\U3002\U516c\U4f1a\U5185\U90e8\U7684\U90fd\U4e92\U52a0\U4e00\U4e0b\U597d\U53cb\Uff01\Uff01";
     title = " ";
     urlLink = " ";
     user =         {
     alias = " ";
     img = "3274035,2443069,3274037,3195442,3195868,3195871,3195889,3200796,";
     nickname = "\U5f7c\U5cb8\Uff5c\U50be\U57ce";
     shiptype = unkown;
     superstar = 0;
     userid = 00000077;
     username = 15151813171;
     };
     zanNum = 10;
     },
     */
    return cell;
  
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 320, 40)];
    view.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 180, 40)];
    label.text  = @"北京附近的动态";
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:13];
    [view addSubview:label];
    
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
    float currheight = 0.0;
    NSDictionary *dic = [array objectAtIndex:indexPath.row];
    NSString *urllink = KISDictionaryHaveKey(dic, @"urlLink");
    if ([urllink isEqualToString:@""]||[urllink isEqualToString:@" "]) {
        CGSize size = [NewNearByCell getContentHeigthWithStr:KISDictionaryHaveKey(dic, @"msg")];
        currheight +=size.height+35;
        NSString *imgStr = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"img")];
        if ([imgStr isEqualToString:@""]||[imgStr isEqualToString:@" "]) {
        
        }else{
            NSString *str = [imgStr substringFromIndex:imgStr.length];
            NSString *str2;
            if ([str isEqualToString:@","]) {
                str2= [imgStr substringToIndex:imgStr.length-1];
            }
            else {
                str2 = imgStr;
            }
            NSArray *photoArray = [imgStr componentsSeparatedByString:@","];
            if ([[photoArray lastObject]isEqualToString:@""]||[[photoArray lastObject]isEqualToString:@" "]) {
                [(NSMutableArray*)photoArray removeLastObject];
            }
            currheight +=(photoArray.count-1)*80/3+80;
        }
    }
    else{
        CGSize size = [NewNearByCell getContentHeigthWithStr:KISDictionaryHaveKey(dic, @"title")];
        currheight +=size.height+35;
        currheight+=50;
    }
    currheight+=40;
    return currheight;
    currheight =0;
}

-(void)enterCitisePage:(UIButton *)sender
{
    CityViewController *cityVC = [[CityViewController alloc]init];
    [self.navigationController pushViewController:cityVC animated:YES];
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
