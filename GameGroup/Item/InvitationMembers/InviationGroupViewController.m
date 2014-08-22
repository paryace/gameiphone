//
//  InviationGroupViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-25.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "InviationGroupViewController.h"
#import "InviationTeamCell.h"
@interface InviationGroupViewController ()
{
    NSMutableArray * m_dataArray;
    UITableView * m_myTableView;
    NSInteger  Row;
    UIAlertView * m_alert;
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
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    
    [self.view addSubview:hud];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getGroupListFromNet];
}
-(void)getGroupListFromNet
{
    [hud show:YES];
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
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSMutableArray class]]) {
            [m_dataArray addObjectsFromArray:responseObject];
            [m_myTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
        [hud hide: YES];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    InviationTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[InviationTeamCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
        NSMutableDictionary * cellDic = m_dataArray[indexPath.row];
        cell.headImageV.placeholderImage = KUIImage(@"group_icon");
        cell.headImageV.imageURL = [ImageService getImageStr:KISDictionaryHaveKey(cellDic, @"backgroundImg") Width:100];
        cell.nameLabel.text = KISDictionaryHaveKey(cellDic, @"groupName");
//        NSString * gameId = KISDictionaryHaveKey(cellDic, @"gameid");
//        NSString * level = KISDictionaryHaveKey(cellDic, @"level");
//        NSString * maxMemberNum = KISDictionaryHaveKey(cellDic, @"maxMemberNum");
//        NSString * currentMemberNum = KISDictionaryHaveKey(cellDic, @"currentMemberNum");
//        NSString * gameImageId = [GameCommon putoutgameIconWithGameId:gameId];
//        cell.gameImageV.image = KUIImage(@"clazz_icon.png");
//        cell.gameImageV.imageURL = [ImageService getImageStr:gameImageId Width:100];
//        cell.numberLable.text = [NSString stringWithFormat:@"%@%@%@",currentMemberNum,@"/",maxMemberNum];
//        cell.levelLable.text = [NSString stringWithFormat:@"%@",level];
//        cell.cricleLable.text = KISDictionaryHaveKey(cellDic, @"info");

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Row =indexPath.row;
    m_alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定邀请该群组成员么" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [m_alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSMutableDictionary * cellDic = m_dataArray[Row];

    if (buttonIndex ==1) {
        [self inviationGroupWithRoomId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(cellDic, @"groupId")]];

    }
}

#pragma mark ---邀请群组
-(void)inviationGroupWithRoomId:(NSString *)groupId
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:self.roomId forKey:@"roomId"];
    [paramDict setObject:groupId forKey:@"groupIds"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"287" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self saveGroupMsg:groupId];
        [self showMessageWindowWithContent:@"发送成功" imageType:0];
        [self.navigationController popViewControllerAnimated:YES];

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
    return 55.0f;
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

-(void)saveGroupMsg:(NSString*)groupId{
    NSString * typeValue = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"value")];
    NSString * roomName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"roomName")];
    NSString * msgType = @"groupchat";
    NSString * body = [NSString stringWithFormat:@"[%@] %@",typeValue,[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"description")]];
    NSString * targetGroupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"groupId")];
    NSString * description = [NSString stringWithFormat:@"邀请您加入%@的组队",roomName];
    NSString * img = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"img")];
    NSString * roomId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"roomId")];
    NSString * gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"gameId")];
    NSString * msg = [NSString stringWithFormat:@"[%@] %@",typeValue,[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"description")]];
    NSDictionary * payloadDic = [self createPayload:targetGroupId Description:description Img:img RoomId:roomId Type:@"teamInviteInGroup" Msg:msg Gameid:gameid];
    NSMutableDictionary * msgDIc = [payloadDic mutableCopy];
    
    [msgDIc setValue:[GameCommon getNewStringWithId:groupId] forKey:@"groupId"];
    
    [self sendGroupMessage:groupId msgType:msgType Body:body PayloadStr:[msgDIc JSONFragment]];
}

-(void)sendGroupMessage:(NSString*)groupId msgType:(NSString*)msgType Body:(NSString*)body PayloadStr:(NSString*)payloadStr{
    NSMutableDictionary * messageContent = [NSMutableDictionary dictionary];
    NSString* nowTime = [GameCommon getCurrentTime];
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    [messageContent setObject:@"you" forKey:@"sender"];
    [messageContent setObject:msgType forKey:@"msgType"];
    [messageContent setObject:body forKey:@"msg"];
    [messageContent setObject:uuid forKey:@"msgId"];
    [messageContent setObject:body forKey:@"payload"];
    [messageContent setObject:@"1" forKey:@"sayHiType"];
    [messageContent setObject:nowTime forKey:@"time"];
    [messageContent setObject:groupId forKey:@"groupId"];
    [messageContent setObject:groupId forKey:@"receiver"];
    [messageContent setObject:payloadStr forKey:@"payload"];
    [DataStoreManager storeTeamInviteInGroupMessage:messageContent];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:messageContent];
}

-(NSDictionary*)createPayload:(NSString*)targetGroupId Description:(NSString*)description Img:(NSString*)img RoomId:(NSString*)roomId Type:(NSString*)type Msg:(NSString*)msg Gameid:(NSString*)gameid{
    NSDictionary * dic = @{@"targetGroupId":targetGroupId,
                           @"description":description,
                           @"img": img,
                           @"roomId":roomId,
                           @"type":type,
                           @"msg":msg,
                           @"gameid":gameid};
    return dic;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
