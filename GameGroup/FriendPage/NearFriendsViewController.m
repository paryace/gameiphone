//
//  NearFriendsViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-5-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NearFriendsViewController.h"
#import "PersonTableCell.h"
#import "TestViewController.h"
@interface NearFriendsViewController ()
{
    UITableView *m_myTableView;
    NSMutableArray *m_dataArray;
    UILabel* m_titleLabel;
}
@end

@implementation NearFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"" withBackButton:YES];
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, KISHighVersion_7 ? 20 : 0, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
    m_titleLabel.text = @"附近的朋友";
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:m_titleLabel];

    
    //数据初始化
    m_dataArray = [NSMutableArray array];
    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSString *path  =[RootDocPath stringByAppendingString:@"/nearFriendsList"];
    BOOL isTrue = [fileManager fileExistsAtPath:path];
    NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:path error:NULL];
    if (isTrue && [[fileAttr objectForKey:NSFileSize] unsignedLongLongValue] != 0) {
        m_dataArray= [NSMutableArray arrayWithContentsOfFile:path];
    }

    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];
    
    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"加载中...";
    
    
    [self getInfoWithNet];
    
    // Do any additional setup after loading the view.
}

-(void)getInfoWithNet
{
    [hud show:YES];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLat]] forKey:@"latitude"];
    [paramDict setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLon]] forKey:@"longitude"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"213" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict
                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              [hud hide:YES];
                              if ([responseObject isKindOfClass:[NSArray class]]) {
                                  [m_dataArray removeAllObjects];
                                  [m_dataArray addObjectsFromArray:responseObject];
                                  
                                  NSString *filePath  =[RootDocPath stringByAppendingString:@"/nearFriendsList"];
                                  [m_dataArray writeToFile:filePath atomically:YES];
                              }
                              [m_myTableView reloadData];
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


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * stringCell3 = @"cell";
    PersonTableCell * cell = [tableView dequeueReusableCellWithIdentifier:stringCell3];
    if (!cell) {
        cell = [[PersonTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell3];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dict = [m_dataArray objectAtIndex:indexPath.row];
    
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"gender")] isEqualToString:@"0"]) {//男♀♂
        cell.ageLabel.text = [@"♂ " stringByAppendingString:[GameCommon getNewStringWithId:[dict objectForKey:@"age"]]];
        cell.ageLabel.backgroundColor = kColorWithRGB(33, 193, 250, 1.0);
        cell.headImageV.placeholderImage = [UIImage imageNamed:@"people_man.png"];
    }
    else
    {
        cell.ageLabel.text = [@"♀ " stringByAppendingString:[GameCommon getNewStringWithId:[dict objectForKey:@"age"]]];
        cell.ageLabel.backgroundColor = kColorWithRGB(238, 100, 196, 1.0);
        cell.headImageV.placeholderImage = [UIImage imageNamed:@"people_woman.png"];
    }
    
    NSString * uImageId=KISDictionaryHaveKey(dict, @"img");
    cell.headImageV.imageURL = [ImageService getImageStr:uImageId Width:80];
    
    
    cell.nameLabel.text = [dict objectForKey:@"nickname"];
    cell.distLabel.text = [KISDictionaryHaveKey(dict, @"titleName") isEqualToString:@""] ? @"暂无头衔" : KISDictionaryHaveKey(dict, @"titleName");
    cell.distLabel.textColor = [GameCommon getAchievementColorWithLevel:[KISDictionaryHaveKey(dict, @"rarenum") integerValue]];
    
    cell.timeLabel.text = [GameCommon getTimeAndDistWithTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"updateUserLocationDate")] Dis:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"distance")]];
    
    if ([KISDictionaryHaveKey(dict, @"shiptype")isEqualToString:@"1"]) {
        cell.shiptypeLabel.text = @"好友";
    }else if([KISDictionaryHaveKey(dict, @"shiptype")isEqualToString:@"2"]){
        cell.shiptypeLabel.text = @"关注";
    }else{
        cell.shiptypeLabel.text = @"粉丝";
    }
    [cell refreshCell];
    NSArray * gameidss=[GameCommon getGameids:[dict objectForKey:@"gameids"]];
    [cell setGameIconUIView:gameidss];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    TestViewController *detailVC = [[TestViewController alloc]init];
    
    NSDictionary *dict = [m_dataArray objectAtIndex:indexPath.row];
    
    NSString *shiptype = KISDictionaryHaveKey(dict, @"shiptype");
    

    if ([shiptype intValue]==1) {
        detailVC.viewType = VIEW_TYPE_FansPage1;
    }
    else if ([shiptype intValue]==2)
    {
        detailVC.viewType = VIEW_TYPE_AttentionPage1;
    }
    
    detailVC.achievementStr = [KISDictionaryHaveKey(dict, @"achievement") isEqualToString:@""] ? @"暂无头衔" : KISDictionaryHaveKey(dict, @"achievement");
    detailVC.achievementColor =KISDictionaryHaveKey(dict, @"achievementLevel") ;
    detailVC.sexStr =  KISDictionaryHaveKey(dict, @"sex");
    
    detailVC.titleImage =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"img")] ;
    
    detailVC.ageStr = [GameCommon getNewStringWithId:[dict objectForKey:@"age"]];
    detailVC.constellationStr =KISDictionaryHaveKey(dict, @"constellation");
    NSLog(@"vc.VC.constellationStr%@",detailVC.constellationStr);
    
    detailVC.userId = KISDictionaryHaveKey(dict, @"userid");
    detailVC.nickName = KISDictionaryHaveKey(dict, @"displayName");
    detailVC.timeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"updateUserLocationDate")];
    detailVC.jlStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"distance")];
    detailVC.createTimeStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createTime")];
    if([KISDictionaryHaveKey(dict, @"active")intValue]==2){
        detailVC.isActiveAc =YES;
    }
    else{
        detailVC.isActiveAc =NO;
    }
    
    detailVC.isChatPage = NO;
    [self.navigationController pushViewController:detailVC animated:YES];

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
