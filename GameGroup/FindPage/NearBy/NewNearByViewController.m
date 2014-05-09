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

@interface NewNearByViewController ()
{
    UICollectionView *m_photoCollectionView;
    UITableView *m_myTableView;
    UICollectionViewFlowLayout *m_layout;
    NSMutableArray *array;
    NSString *sexStr ;
    AppDelegate *app;
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
    
    array = [NSMutableArray array];
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
    
    [paramDic setObject:sexStr?sexStr:@"" forKey:@"gender"];
    
    
    
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"204" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"199" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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

#pragma mark----
#pragma marl ====照片墙    collectionView delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 12;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //1879694,2448474,2448473 1514066  "782355,782432,782713,782778,782845,782923,782979,783141  474358 3204696

    NearByPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.photoView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseImageUrl,[array objectAtIndex:indexPath.row],@"/160/160"]];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d",indexPath.row);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 12;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    NewNearByCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[NewNearByCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.nickNameLabel.text = @"漂亮妹纸";
    cell.titleLabel.text = @"测试中";
    cell.photoArray = array;
    cell.photoCollectionView.frame = CGRectMake(60, 50, 250, 250);
    [cell.photoCollectionView reloadData];
    cell.headImgBtn.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",BaseImageUrl,[array objectAtIndex:indexPath.row],@"/80/80"]];
    
    cell.timeLabel.frame = CGRectMake(60, 310, 100, 30);
    cell.timeLabel.text = [NSString stringWithFormat:@"%d小时前",indexPath.row+1];
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
    return 340;
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
