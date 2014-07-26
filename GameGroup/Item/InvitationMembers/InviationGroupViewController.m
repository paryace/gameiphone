//
//  InviationGroupViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-25.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "InviationGroupViewController.h"
#import "GroupCell.h"
@interface InviationGroupViewController ()
{
    NSMutableArray * m_dataArray;
    UITableView * m_myTableView;
}
@end

@implementation InviationGroupViewController

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
    
    [self setTopViewWithTitle:@"群组" withBackButton:YES];
    
    
    m_dataArray = [NSMutableArray array];
    m_myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];
    
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getGroupListFromNet];
}
-(void)getGroupListFromNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:self.roomId forKey:@"roomId"];
    [paramDict setObject:@"0" forKey:@"firstResult"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"286" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSMutableArray class]]) {
            [m_dataArray addObjectsFromArray:responseObject];
            [m_myTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[GroupCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
        NSMutableDictionary * cellDic = m_dataArray[indexPath.row];
        cell.headImageV.placeholderImage = KUIImage(@"group_icon");
        cell.headImageV.imageURL = [ImageService getImageStr:KISDictionaryHaveKey(cellDic, @"backgroundImg") Width:100];
        cell.nameLabel.text = KISDictionaryHaveKey(cellDic, @"groupName");
        NSString * gameId = KISDictionaryHaveKey(cellDic, @"gameid");
        NSString * level = KISDictionaryHaveKey(cellDic, @"level");
        NSString * maxMemberNum = KISDictionaryHaveKey(cellDic, @"maxMemberNum");
        NSString * currentMemberNum = KISDictionaryHaveKey(cellDic, @"currentMemberNum");
        NSString * gameImageId = [GameCommon putoutgameIconWithGameId:gameId];
        cell.gameImageV.image = KUIImage(@"clazz_icon.png");
        cell.gameImageV.imageURL = [ImageService getImageStr:gameImageId Width:100];
        cell.numberLable.text = [NSString stringWithFormat:@"%@%@%@",currentMemberNum,@"/",maxMemberNum];
        cell.levelLable.text = [NSString stringWithFormat:@"%@",level];
        cell.cricleLable.text = KISDictionaryHaveKey(cellDic, @"info");

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary * cellDic = m_dataArray[indexPath.row];

    [self inviationGroupWithRoomId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(cellDic, @"groupId")]];
}

-(void)inviationGroupWithRoomId:(NSString *)roomId
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:roomId forKey:@"roomId"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"287" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self showMessageWindowWithContent:@"发送成功" imageType:0];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
    }];

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"我的群组";
            break;
        case 1:
            return @"其他";
            break;
    
        default:
            break;
    }
    return nil;
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
