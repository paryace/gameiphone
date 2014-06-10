//
//  SearchGroupViewController.m
//  GameGroup
//
//  Created by Apple on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SearchGroupViewController.h"
#import "GroupCell.h"
#import "GroupInformationViewController.h"

@interface SearchGroupViewController ()
{
    UITableView * m_GroupTableView;
    NSMutableArray * m_groupArray;
}
@end

@implementation SearchGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"搜索群列表" withBackButton:YES];
    
    m_groupArray = [NSMutableArray array];
    
    m_GroupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height - startX) style:UITableViewStylePlain];
    m_GroupTableView.dataSource = self;
    m_GroupTableView.delegate = self;
    [self.view addSubview:m_GroupTableView];
    
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSMutableDictionary * cellDic = [m_groupArray objectAtIndex:indexPath.row];
    cell.headImageV.placeholderImage = KUIImage(@"people_man.png");
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
    cell.levelLable.text = [NSString stringWithFormat:@"%@%@",@"lv.",level];
    cell.cricleLable.text = KISDictionaryHaveKey(cellDic, @"info");
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSMutableDictionary * cellDic = [m_groupArray objectAtIndex:indexPath.row];
    //    KKChatController * kkchat = [[KKChatController alloc] init];
    //    kkchat.chatWithUser = KISDictionaryHaveKey(cellDic, @"groupId");
    //    kkchat.type = @"group";
    //    [self.navigationController pushViewController:kkchat animated:YES];
    
    
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
    gr.groupId = KISDictionaryHaveKey(cellDic, @"groupId");
    [self.navigationController pushViewController:gr animated:YES];
}


//获取群列表
-(void)getGroupListFromNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.conditiona forKey:@"param"];
    [paramDict setObject:@"0" forKey:@"firstResult"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"234" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray * groupList = responseObject;
            m_groupArray = groupList;
            [m_GroupTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
