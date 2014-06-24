//
//  GroupListViewController.m
//  GameGroup
//
//  Created by Marss on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupListViewController.h"
#import "GroupCell.h"
#import "KKChatController.h"
#import "JoinGroupViewController.h"
#import "GroupInformationViewController.h"
#import "GroupSettingController.h"

@interface GroupListViewController ()
{
    UITableView * m_GroupTableView;
    NSMutableArray * m_groupArray;
    
}
@end

@implementation GroupListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getGroupListFromNet];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"群列表" withBackButton:YES];
    
    m_groupArray = [NSMutableArray array];

    m_GroupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height - startX) style:UITableViewStylePlain];
    m_GroupTableView.dataSource = self;
    m_GroupTableView.delegate = self;
    [self.view addSubview:m_GroupTableView];
    
    [self getGroupList];
    [self getGroupListFromNet];
}
#pragma mark 表格
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_groupArray count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * stringCell3 = @"cell";
    GroupCell * cell = [tableView dequeueReusableCellWithIdentifier:stringCell3];
    if (!cell) {
        cell = [[GroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell3];
    }
    NSMutableDictionary * cellDic = [m_groupArray objectAtIndex:indexPath.row];
    cell.headImageV.placeholderImage = KUIImage(@"group_icon");
    cell.headImageV.imageURL = [ImageService getImageUrl4:KISDictionaryHaveKey(cellDic, @"backgroundImg")];
    cell.nameLabel.text = KISDictionaryHaveKey(cellDic, @"groupName");
    NSString * gameId = KISDictionaryHaveKey(cellDic, @"gameid");
    NSString * level = KISDictionaryHaveKey(cellDic, @"level");
    NSString * maxMemberNum = KISDictionaryHaveKey(cellDic, @"maxMemberNum");
    NSString * currentMemberNum = KISDictionaryHaveKey(cellDic, @"currentMemberNum");
    NSString * gameImageId = [GameCommon putoutgameIconWithGameId:gameId];
    cell.gameImageV.image = KUIImage(@"clazz_00.png");
    cell.gameImageV.imageURL = [ImageService getImageUrl4:gameImageId];
    cell.numberLable.text = [NSString stringWithFormat:@"%@%@%@",currentMemberNum,@"/",maxMemberNum];
    cell.levelLable.text = [NSString stringWithFormat:@"%@",level];
    cell.cricleLable.text = KISDictionaryHaveKey(cellDic, @"info");
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
     NSMutableDictionary * cellDic = [m_groupArray objectAtIndex:indexPath.row];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
    gr.groupId = KISDictionaryHaveKey(cellDic, @"groupId");
    [self.navigationController pushViewController:gr animated:YES];
}

-(void)getGroupList
{
    m_groupArray = [DataStoreManager queryGroupInfoList];
    [m_GroupTableView reloadData];
}

//获取群列表
-(void)getGroupListFromNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.userId forKey:@"userid"];
    [paramDict setObject:@"0" forKey:@"firstResult"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"259" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray * groupList = responseObject;
            m_groupArray = groupList;
            [m_GroupTableView reloadData];
            
//            for (NSMutableDictionary * groupInfo in responseObject) {
//                [DataStoreManager saveDSGroupList:groupInfo];
//            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
