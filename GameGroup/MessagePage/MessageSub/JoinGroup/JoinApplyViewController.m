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
    [self setTopViewWithTitle:@"申请列表" withBackButton:YES];
    
    m_applyArray = [NSMutableArray array];
    m_ApplyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height - startX) style:UITableViewStylePlain];
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
    //申请加入群消息
    if ([msgType isEqualToString:@"joinGroupApplication"]) {
        
        static NSString *identifier = @"ApplicationCell";
        JoinApplyCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[JoinApplyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailDeleGate=self;
        cell.tag = indexPath.row;
        if ([state isEqualToString:@"0"]) {
            cell.agreeBtn.selected=NO;
            cell.desAgreeBtn.selected=NO;
            cell.ignoreBtn.selected=NO;
        }else if([state isEqualToString:@"1"]){
            cell.agreeBtn.selected=YES;
            cell.desAgreeBtn.selected=NO;
            cell.ignoreBtn.selected=NO;
        }else if([state isEqualToString:@"2"]){
            cell.agreeBtn.selected=NO;
            cell.desAgreeBtn.selected=YES;
            cell.ignoreBtn.selected=NO;
        }else if([state isEqualToString:@"3"]){
            cell.agreeBtn.selected=NO;
            cell.desAgreeBtn.selected=NO;
            cell.ignoreBtn.selected=YES;
        }
        cell.groupImageV.placeholderImage = KUIImage(@"placeholder.png");
        cell.groupImageV.imageURL = [ImageService getImageStr:backgroundImg Width:160];
        cell.groupCreateTimeLable.text = [NSString stringWithFormat:@"%@", [self getMsgTime:senTime]];
        cell.groupNameLable.text = groupName;
        cell.userImageV.placeholderImage = KUIImage(@"placeholder.png");
        cell.userImageV.imageURL = [ImageService getImageStr:userImg Width:160];
        cell.userNameLable.text = nickname;
        cell.joinReasonLable.text = msg;
        
        CGSize nameSize = [cell.groupCreateTimeLable.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
        cell.groupCreateTimeLable.frame=CGRectMake(300-nameSize.width-5, 7, nameSize.width, 20);
        return cell;
    }
    //简单cell（通过，拒绝）
    else if ([msgType isEqualToString:@"joinGroupApplicationAccept"]
        ||[msgType isEqualToString:@"joinGroupApplicationReject"]) {
        
        static NSString *identifier = @"simpleApplicationCell";
        SimpleMsgCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[SimpleMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.groupImageV.placeholderImage = KUIImage(@"placeholder.png");
        cell.groupImageV.imageURL = [ImageService getImageStr:backgroundImg Width:160];
        cell.groupCreateTimeLable.text = [NSString stringWithFormat:@"%@", [self getMsgTime:senTime]];
        cell.groupNameLable.text = groupName;
        cell.contentLable.text=msgContent;
        return cell;
    }
    
    //创建群消息
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
        cell.detailDeleGate=self;
        cell.groupImageV.placeholderImage = KUIImage(@"placeholder.png");
        cell.groupImageV.imageURL = [ImageService getImageStr:backgroundImg Width:160];
        cell.groupCreateTimeLable.text = [NSString stringWithFormat:@"%@", [self getMsgTime:senTime]];
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
        
        return cell;
    }else{
        return nil;
    }
}
//格式化时间
-(NSString*)getMsgTime:(NSString*)senderTime
{
    NSString *time = [senderTime substringToIndex:10];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSString* strNowTime = [NSString stringWithFormat:@"%d",(int)nowTime];
    NSString* strTime = [NSString stringWithFormat:@"%d",[time intValue]];
    return [GameCommon getTimeWithChatStyle:strNowTime AndMessageTime:strTime];
}

//同意
-(void)agreeMsg:(JoinApplyCell*)sender
{
    NSInteger index  =  sender.tag ;
    NSMutableDictionary *dict = [m_applyArray objectAtIndex:index];
    NSString * applicationId = KISDictionaryHaveKey(dict, @"applicationId");
    NSString * msgId = KISDictionaryHaveKey(dict, @"msgId");
    NSString * state = KISDictionaryHaveKey(dict, @"state");
    if (![state isEqualToString:@"0"]) {
        return;
    }
    [self msgEdit:@"1" ApplicationId:applicationId MsgId:msgId];
}
//拒绝
-(void)desAgreeMsg:(JoinApplyCell*)sender
{
    NSInteger index  =  sender.tag ;
    NSMutableDictionary *dict = [m_applyArray objectAtIndex:index];
    NSString * applicationId = KISDictionaryHaveKey(dict, @"applicationId");
    NSString * msgId = KISDictionaryHaveKey(dict, @"msgId");
    NSString * state = KISDictionaryHaveKey(dict, @"state");
    if (![state isEqualToString:@"0"]) {
        return;
    }
    [self msgEdit:@"2" ApplicationId:applicationId MsgId:msgId];
}
//忽略
-(void)ignoreMsg:(JoinApplyCell*)sender
{
    NSInteger index  =  sender.tag ;
    NSMutableDictionary *dict = [m_applyArray objectAtIndex:index];
    NSString * msgId = KISDictionaryHaveKey(dict, @"msgId");
    NSString * state = KISDictionaryHaveKey(dict, @"state");
    if (![state isEqualToString:@"0"]) {
        return;
    }
    [DataStoreManager updateMsgState:msgId State:@"3"];
    [self getJoinGroupMsg];
}
// 同意，拒绝申请
-(void)msgEdit:(NSString*)state ApplicationId:(NSString*)applicationId MsgId:(NSString*)msgId
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:applicationId forKey:@"applicationId"];
    [paramDict setObject:state forKey:@"state"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"233" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        [DataStoreManager updateMsgState:msgId State:state];
        for (NSMutableDictionary * clickDic in m_applyArray) {
            if ([KISDictionaryHaveKey(clickDic, @"msgId") isEqualToString:msgId]) {
                [clickDic setObject:state forKey:@"state"];
                [self getJoinGroupMsg];
                [m_ApplyTableView reloadData];
            }
        }
        
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"您已经同意加入群的申请"delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}


-(void)inviteClick:(CreateGroupMsgCell*)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"邀请"delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

-(void)skillClick:(CreateGroupMsgCell*)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"帮助"delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

-(void)detailClick:(CreateGroupMsgCell*)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"查看详情"delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
