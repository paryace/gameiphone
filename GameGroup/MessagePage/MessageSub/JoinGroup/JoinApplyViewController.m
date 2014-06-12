//
//  JoinApplyViewController.m
//  GameGroup
//
//  Created by Apple on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "JoinApplyViewController.h"
#import "JoinApplyCell.h"
#import "CreateGroupMsgCell.h"
#import "SimpleMsgCell.h"
#import "GroupInformationViewController.h"

@interface JoinApplyViewController ()
{
    UITableView * m_ApplyTableView;
    NSMutableArray * m_applyArray;
}
@end

@implementation JoinApplyViewController

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
    [self setTopViewWithTitle:@"群消息列表" withBackButton:YES];
    m_applyArray = [NSMutableArray array];
    m_ApplyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height - startX) style:UITableViewStylePlain];
    m_ApplyTableView.backgroundColor = UIColorFromRGBA(0xfcfcfc, 1);
    m_ApplyTableView.separatorColor = [UIColor clearColor];
    m_ApplyTableView.dataSource = self;
    m_ApplyTableView.delegate = self;
    [self.view addSubview:m_ApplyTableView];
    [self getJoinGroupMsg];
}

-(void)getJoinGroupMsg
{
    m_applyArray = [DataStoreManager queryDSGroupApplyMsg];
    [m_ApplyTableView reloadData];
}
#pragma mark 表格
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_applyArray.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [m_applyArray objectAtIndex:indexPath.row];
    NSString * msgType = KISDictionaryHaveKey(dict, @"msgType");
    if ([msgType isEqualToString:@"joinGroupApplicationAccept"]
        ||[msgType isEqualToString:@"joinGroupApplicationReject"]
        ||[msgType isEqualToString:@"groupLevelUp"]
        ||[msgType isEqualToString:@"groupBillboard"]
        ||[msgType isEqualToString:@"disbandGroup"]) {
        return 100;
    }
    return 135;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [m_applyArray objectAtIndex:indexPath.row];
    NSString * msgType = KISDictionaryHaveKey(dict, @"msgType");
    NSString * groupName = KISDictionaryHaveKey(dict, @"groupName");
    NSString * nickname = KISDictionaryHaveKey(dict, @"nickname");
    NSString * msg = KISDictionaryHaveKey(dict, @"msg");
    NSString * backgroundImg = KISDictionaryHaveKey(dict, @"backgroundImg");
    NSString * userImg = KISDictionaryHaveKey(dict, @"userImg");
    NSString * state = KISDictionaryHaveKey(dict, @"state");
    NSString * msgContent = KISDictionaryHaveKey(dict, @"msgContent");
    NSString * senTime = KISDictionaryHaveKey(dict, @"senTime");
    //申请加入群
    if ([msgType isEqualToString:@"joinGroupApplication"]
        ||[msgType isEqualToString:@"friendJoinGroup"]) {
        
        static NSString *identifier = @"ApplicationCell";
        JoinApplyCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[JoinApplyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.groupImageDeleGate=self;
        cell.detailDeleGate=self;
        cell.tag = indexPath.row;
        if ([msgType isEqualToString:@"friendJoinGroup"]) {
            cell.agreeBtn.hidden=YES;
            cell.desAgreeBtn.hidden=YES;
            cell.ignoreBtn.hidden=YES;
            cell.stateLable.hidden=YES;
            cell.joinReasonLable.text = msgContent;
        }else{
            if ([state isEqualToString:@"0"]) {
                cell.agreeBtn.hidden=NO;
                cell.desAgreeBtn.hidden=NO;
                cell.ignoreBtn.hidden=NO;
                cell.stateLable.hidden=YES;
            }else if([state isEqualToString:@"1"]){
                cell.agreeBtn.hidden=YES;
                cell.desAgreeBtn.hidden=YES;
                cell.ignoreBtn.hidden=YES;
                cell.stateLable.hidden=NO;
                cell.stateLable.text=@"已同意";
            }else if([state isEqualToString:@"2"]){
                cell.agreeBtn.hidden=YES;
                cell.desAgreeBtn.hidden=YES;
                cell.ignoreBtn.hidden=YES;
                cell.stateLable.hidden=NO;
                cell.stateLable.text=@"已拒绝";
            }else if([state isEqualToString:@"3"]){
                cell.agreeBtn.hidden=YES;
                cell.desAgreeBtn.hidden=YES;
                cell.ignoreBtn.hidden=YES;
                cell.stateLable.hidden=NO;
                cell.stateLable.text=@"已忽略";
            }else if([state isEqualToString:@"4"]){
                cell.agreeBtn.hidden=YES;
                cell.desAgreeBtn.hidden=YES;
                cell.ignoreBtn.hidden=YES;
                cell.stateLable.hidden=NO;
                cell.stateLable.text=@"已被其他管理员同意（或者拒绝）";
            }
            cell.joinReasonLable.text = msg;
        }
        cell.userImageV.placeholderImage = KUIImage(@"placeholder.png");
        cell.userImageV.imageURL = [ImageService getImageStr:userImg Width:160];
        cell.userNameLable.text = nickname;
        [cell setGroupMsg:backgroundImg GroupName:groupName MsgTime:senTime];
        return cell;
    }
    //（通过，拒绝,群升级,好友加入群,解散群）
    else if ([msgType isEqualToString:@"joinGroupApplicationAccept"]
        ||[msgType isEqualToString:@"joinGroupApplicationReject"]
             ||[msgType isEqualToString:@"groupLevelUp"]
             ||[msgType isEqualToString:@"groupBillboard"]
             ||[msgType isEqualToString:@"disbandGroup"]) {
        
        static NSString *identifier = @"simpleApplicationCell";
        SimpleMsgCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[SimpleMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
         cell.groupImageDeleGate=self;
         cell.tag = indexPath.row;
        cell.contentLable.text=msgContent;
        [cell setGroupMsg:backgroundImg GroupName:groupName MsgTime:senTime];
        return cell;
    }
    
    //创建群，群审核通过，群审核失败
    else if ([msgType isEqualToString:@"groupApplicationUnderReview"]
             ||[msgType isEqualToString:@"groupApplicationAccept"]
             ||[msgType isEqualToString:@"groupApplicationReject"]) {
        
        static NSString *identifier = @"ApplicationUnderCell";
        CreateGroupMsgCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[CreateGroupMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
         cell.groupImageDeleGate=self;
        cell.detailDeleGate=self;
         cell.tag = indexPath.row;
        cell.contentLable.text=msgContent;
        if ([msgType isEqualToString:@"groupApplicationUnderReview"]) {
            cell.oneBtn.hidden=YES;
            cell.twoBtn.hidden=YES;
            cell.threeBtn.hidden=NO;
        }else if([msgType isEqualToString:@"groupApplicationReject"]){
            cell.oneBtn.hidden=YES;
            cell.twoBtn.hidden=YES;
            cell.threeBtn.hidden=YES;
        }else if([msgType isEqualToString:@"groupApplicationAccept"]){
            cell.oneBtn.hidden=NO;
            cell.twoBtn.hidden=NO;
            cell.threeBtn.hidden=YES;
        }
        [cell setGroupMsg:backgroundImg GroupName:groupName MsgTime:senTime];
        return cell;
    }else{
        static NSString *identifier = @"simpleApplicationCell";
        SimpleMsgCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[SimpleMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.groupImageDeleGate=self;
         cell.tag = indexPath.row;
        cell.contentLable.text=msgContent;
        [cell setGroupMsg:backgroundImg GroupName:groupName MsgTime:senTime];
        return cell;
    }
}
-(void)groupImageClick:(BaseGroupMsgCell*)sender
{
    NSMutableDictionary *dict = [m_applyArray objectAtIndex:sender.tag];
    NSString * groupId = KISDictionaryHaveKey(dict, @"groupId");
    GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
    gr.groupId =[GameCommon getNewStringWithId:groupId];
    [self.navigationController pushViewController:gr animated:YES];
}
//同意
-(void)agreeMsg:(JoinApplyCell*)sender
{
    [self msgEdit:@"1" Dic:[m_applyArray objectAtIndex:sender.tag]];
}
//拒绝
-(void)desAgreeMsg:(JoinApplyCell*)sender
{
    [self msgEdit:@"2" Dic:[m_applyArray objectAtIndex:sender.tag]];
}
//忽略
-(void)ignoreMsg:(JoinApplyCell*)sender
{
    NSMutableDictionary *dict = [m_applyArray objectAtIndex:sender.tag];
    if (![KISDictionaryHaveKey(dict, @"state") isEqualToString:@"0"]) {
        return;
    }
    [self changState:dict State:@"3"];
}
// 同意，拒绝申请
-(void)msgEdit:(NSString*)state Dic:(NSMutableDictionary*)dict
{
    NSString * applicationId = KISDictionaryHaveKey(dict, @"applicationId");
    NSString * clickstate = KISDictionaryHaveKey(dict, @"state");
    if (![clickstate isEqualToString:@"0"]) {
        return;
    }

    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:applicationId forKey:@"applicationId"];
    [paramDict setObject:state forKey:@"state"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"233" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self changState:dict State:state];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[self getSuccessMsg:state]delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            NSString* warn = [error objectForKey:kFailMessageKey];
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", warn] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}
//改变消息状态
-(void)changState:(NSMutableDictionary*)dict State:(NSString*)state
{
   
    for (NSMutableDictionary * clickDic in m_applyArray) {
        if ([KISDictionaryHaveKey(clickDic, @"userid") isEqualToString:KISDictionaryHaveKey(dict, @"userid")]
            &&[KISDictionaryHaveKey(clickDic, @"msgType") isEqualToString:KISDictionaryHaveKey(dict, @"msgType")]
            &&[KISDictionaryHaveKey(clickDic, @"state") isEqualToString:@"0"]
            &&[KISDictionaryHaveKey(clickDic, @"groupId") isEqualToString:KISDictionaryHaveKey(dict, @"groupId")]) {
            [clickDic setObject:state forKey:@"state"];
        }
    }
    [m_ApplyTableView reloadData];
    [DataStoreManager updateMsgState:KISDictionaryHaveKey(dict, @"userid") State:state MsgType:KISDictionaryHaveKey(dict, @"msgType") GroupId:KISDictionaryHaveKey(dict, @"groupId")];
   
}
-(NSString*)getSuccessMsg:(NSString*)state
{
    if ([state isEqualToString:@"1"]) {
        return @"您已经同意对方加入该群";
    }
    return  @"您已经拒绝对方加入该群";
}

//邀请新成员
-(void)inviteClick:(CreateGroupMsgCell*)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"邀请新成员"delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}
//群组小技巧
-(void)skillClick:(CreateGroupMsgCell*)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"群组小技巧"delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}
//查看进度
-(void)detailClick:(CreateGroupMsgCell*)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"查看进度"delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
