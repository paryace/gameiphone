//
//  NewGroupSettingViewController.m
//  GameGroup
//
//  Created by Apple on 14-6-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewGroupSettingViewController.h"
#import "GroupSettingCell.h"
#import "MembersListViewController.h"
#import "MemberEditViewController.h"
#import "GroupInfoEditViewController.h"
#import "PublishBillboardViewController.h"
#import "EGOImageView.h"
#import "SoundSetCell.h"
#import "InvitationViewController.h"
typedef enum : NSUInteger {
    TypeNormal,
    TypeAdministrator
} GroupType;
@interface NewGroupSettingViewController ()
{
    UITableView*  m_myTableView;
    
    UILabel *msgHintLable;
    UIImageView *soundimageView;
    
    UITextField *groupNameLable;
    UIToolbar *toolbar;
    UIPickerView *m_rolePickView;
    NSMutableArray *m_roleArray;
}

@end

@implementation NewGroupSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"群组设置" withBackButton:YES];
    
     m_roleArray  = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-(KISHighVersion_7?0:20)) style:UITableViewStyleGrouped];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.showsHorizontalScrollIndicator = NO;
    m_myTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:m_myTableView];
    
    
    
    toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectServerNameOK:)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar.items = @[rb_server];
    
    m_rolePickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_rolePickView.dataSource = self;
    m_rolePickView.delegate = self;
    m_rolePickView.showsSelectionIndicator = YES;
    
    soundimageView=[[UIImageView alloc] initWithFrame:CGRectMake(250-25-10, 15, 25, 20)];
    soundimageView.image = KUIImage(@"nor_soundSong");
    soundimageView.backgroundColor = [UIColor clearColor];
    
    msgHintLable = [[UILabel alloc]initWithFrame:CGRectMake(320-25-8-50, 15, 40, 20)];
    msgHintLable.backgroundColor = [UIColor clearColor];
    msgHintLable.textColor = kColorWithRGB(100,100,100, 0.7);
    msgHintLable.text = @"无声";
    msgHintLable.font =[ UIFont systemFontOfSize:12];
    
    
    NSString * groupMsgSettingState = [GameCommon getMsgSettingStateByGroupId:self.groupId];
    if ([GameCommon isEmtity:groupMsgSettingState]) {
        groupMsgSettingState=@"0";
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[GameCommon getNewStringWithId:self.groupId]];
        [self settingMsgHint:@"0"];
    }
    NSString * message = [self getCellMsgByState:groupMsgSettingState];
    [self setSettingMsg:message];
    soundimageView.image= KUIImage([self getMsgIcon:groupMsgSettingState]);
    
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"Login...";
    hud.mode = MBProgressHUDModeDeterminate;
    [self.view addSubview:hud];
}

-(GroupType)groupType
{
    if (self.shiptypeCount ==0) {//群主
        return TypeAdministrator;
    }else if (self.shiptypeCount ==1) {//管理员
        return TypeAdministrator;
    }else if (self.shiptypeCount ==2) {//群成员
        return TypeNormal;
    }else if (self.shiptypeCount ==3) {//陌生人
        return TypeNormal;
    }else{
        return TypeNormal;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==2) {
        if ([self groupType]==TypeAdministrator) {
            return 40;
        }
        return 30;
    }else if (section ==3){
        return 20;
    }
    return 30;
}
#pragma mark 表格
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self groupType]==TypeAdministrator) {
        return 4;
    }
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 1;
            break;
        case 2:
        {
            if ([self groupType]==TypeAdministrator) {
                return 3;
            }
            return 1;
        }
            break;
        case 3:
            return 1;
            break;
        default:
            return 1;
            break;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* heardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    if (section==2) {
        if ([self groupType]==TypeAdministrator) {
            UILabel*   titleLabel =[self getHeadTitleLable];
            [heardView addSubview:titleLabel];
            return heardView;
        }
    }
    return nil;
}

-(UILabel*)getHeadTitleLable
{
    UILabel * contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 40)];
    contentLabel.backgroundColor = [UIColor clearColor];
    [contentLabel setTextAlignment:NSTextAlignmentLeft];
    [contentLabel setFont:[UIFont systemFontOfSize:12]];
    contentLabel.text = @"陌游群公告会在我的组织中有非常明显的提示，可以很容易的被群成员注意到.";
    [contentLabel setTextColor:[UIColor grayColor]];
    contentLabel.numberOfLines = 2;
    return contentLabel;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            static NSString *identifier = @"myCell00";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell ==nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *tlb = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 90, 20)];
            tlb.backgroundColor = [UIColor clearColor];
            tlb.textColor = [UIColor blackColor];
            tlb.text = @"群组消息提示";
            tlb.font =[ UIFont systemFontOfSize:14];
            [cell.contentView addSubview:tlb];
            
           [cell.contentView addSubview:soundimageView];
            [cell.contentView addSubview:msgHintLable];
            
            return cell;
        }else if (indexPath.row==1) {
            static NSString *cellinde = @"myCell01";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
            if (cell ==nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UILabel *tlb = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 90, 20)];
            tlb.backgroundColor = [UIColor clearColor];
            tlb.textColor = [UIColor blackColor];
            tlb.text = @"我的群角色";
            tlb.font =[ UIFont systemFontOfSize:14];
            [cell.contentView addSubview:tlb];
            
            groupNameLable = [[UITextField alloc]initWithFrame:CGRectMake(0, 15, 320-50, 20)];
            groupNameLable.backgroundColor = [UIColor clearColor];
            groupNameLable.textColor = kColorWithRGB(100,100,100, 0.7);
            groupNameLable.text = self.CharacterInfo;
            groupNameLable.textAlignment = NSTextAlignmentRight;
            groupNameLable.font =[ UIFont systemFontOfSize:12];
            groupNameLable.inputView = m_rolePickView;
            groupNameLable.inputAccessoryView = toolbar;
            [cell.contentView addSubview:groupNameLable];
        
            return cell;
        }
        else{
            static NSString *identifier = @"myCell02";
            GroupSettingCell *cell = (GroupSettingCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[GroupSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.titleLable.text = @"邀请新成员";
            return cell;
        }
        

    }else if (indexPath.section==1) {
        static NSString *identifier = @"myCell1";
        GroupSettingCell *cell = (GroupSettingCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[GroupSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.titleLable.text = @"发布群公告";
        cell.titleLable.textColor = kColorWithRGB(41, 164, 246, 1.0);
        if ([self groupType]==TypeNormal) {
            cell.titleLable.text = @"举报该群";
            cell.titleLable.textColor = [UIColor redColor];
        }
        return cell;
    }else if (indexPath.section==2) {
        
        if ([self groupType]==TypeAdministrator) {
            static NSString *identifier = @"myCell2";
            GroupSettingCell *cell = (GroupSettingCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[GroupSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row==0) {
                cell.titleLable.text = @"管理群成员";
            }else if (indexPath.row==1) {
                cell.titleLable.text = @"编辑群资料";
            }else if (indexPath.row ==2){
                cell.titleLable.text = @"添加群成员";
            }
            return cell;
        }
        static NSString *cellinde = @"myCell3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
        }
        //离开该群,解散群
        
        UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(0,5,KISHighVersion_7?320:300,50)];
        [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
        [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        okButton.backgroundColor = [UIColor clearColor];
        [okButton addTarget:self action:@selector(leave:) forControlEvents:UIControlEventTouchUpInside];
        cell.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:okButton];
        return cell;

    }else if (indexPath.section==3) {
        static NSString *cellinde = @"myCell4";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
        }
        //解散群
        cell.backgroundColor = [UIColor whiteColor];
        UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,KISHighVersion_7?320:300, 50)];
        [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        okButton.backgroundColor = [UIColor redColor];
        if (self.shiptypeCount ==1){
            [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
            [okButton addTarget:self action:@selector(leave:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [okButton setTitle:@"解散该群" forState:UIControlStateNormal];
            [okButton addTarget:self action:@selector(dissolve:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:okButton];
        
        return cell;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section==0) {
        if (indexPath.row==0) {//群组消息设置
            [self hint];
        }else if (indexPath.row ==2){
            [self new:nil];
        }

    }else if (indexPath.section==1) {
        if ([self groupType]==TypeNormal) {//举报
            [self report];
        }else if([self groupType]==TypeAdministrator){//发布公告
            [self publish];
        }
    }else if (indexPath.section==2) {
        if ([self groupType]==TypeAdministrator) {
            if (indexPath.row==0) {//管理成员
                [self managerGroup];
            }else if(indexPath.row==1){//编辑资料
                [self editGroupInfo];
            }else if (indexPath.row ==2){//添加群成员
                [self new:nil];
            }
        }
    }
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self getInfoForNetWithType:@"1"];
            break;
        case 1:
            [self getInfoForNetWithType:@"2"];
            break;
        case 2:
            [self getInfoForNetWithType:@"3"];
            break;
        case 3:
            [self getInfoForNetWithType:@"4"];
            break;
            
        default:
            break;
    }
}

-(void)getInfoForNetWithType:(NSString *)type
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.groupId forKey:@"groupId"];
    [paramDict setObject:type forKey:@"type"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"255" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self showMessageWindowWithContent:@"举报成功" imageType:0];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag = 789;
                [alert show];
            }
        }
        
    }];
}
//群组消息设置
-(void)hint
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"正常接收",@"关闭模式",@"无声模式", nil];
    alertView.tag = 1002;
    [alertView show];
}
//我的群角色
-(void)role:(id)sender
{
    
}
//邀请新成员
-(void)new:(id)sender
{
    InvitationViewController *inv = [[InvitationViewController alloc]init];
    inv.groupId = self.groupId;
    [self.navigationController pushViewController:inv animated:YES];
}

//举报该群组
-(void)report
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"敏感信息",@"欺诈信息",@"色情",@"非法活动", nil];
    [actionSheet showInView:self.view];
    
}
//发布群公告
-(void)publish
{
    PublishBillboardViewController *billboard = [[PublishBillboardViewController alloc]init];
    billboard.groupId = self.groupId;
    [self.navigationController pushViewController:billboard animated:YES];
}
//管理群成员
-(void)managerGroup
{
    MemberEditViewController *member = [[MemberEditViewController alloc]init];
    member.groupId = self.groupId;
    member.shiptype = self.shiptypeCount;
    [self.navigationController pushViewController:member animated:YES];
}
//编辑群资料
-(void)editGroupInfo
{
    GroupInfoEditViewController *memberEidt =[[ GroupInfoEditViewController alloc]init];
    memberEidt.groupId = self.groupId;
    [self.navigationController pushViewController:memberEidt animated:YES];
}

//离开
-(void)leave:(id)sender
{
  [self leaveAlert];
}
//解散
-(void)dissolve:(id)sender
{
    [self dissolveAlert];
}

#pragma mark -清空
- (void)leaveAlert
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要退出该群吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 345;
    [alert show];
}

- (void)dissolveAlert
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要解散该群吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 678;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 345) {
        if (buttonIndex ==1) {
            [self leaveGroup];
        }
    }
    else if(alertView.tag == 678){
        if (buttonIndex ==1) {
            [self dissolveGroup];
        }
    }
    else if (alertView.tag == 789)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if (alertView.tag ==1002)
    {
        if (buttonIndex ==1)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[GameCommon getNewStringWithId:self.groupId]];
            [self settingMsgHint:@"0"];
           
            
        }else if (buttonIndex ==2)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[GameCommon getNewStringWithId:self.groupId]];
            [self settingMsgHint:@"1"];
            
        }
        else if (buttonIndex ==3)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:[GameCommon getNewStringWithId:self.groupId]];
            [self settingMsgHint:@"2"];
        }
    }
}

-(NSString*)getMsgIcon:(NSString*)groupMsgSettingState
{
    if ([groupMsgSettingState isEqualToString:@"0"]) {
        return @"have_soundSong";
        
    }else  if ([groupMsgSettingState isEqualToString:@"1"]) {
        return @"close_receive";
    }else  if ([groupMsgSettingState isEqualToString:@"2"]) {
        return @"nor_soundSong";
    }
    return @"";
}
-(void)setSettingMsg:(NSString*)message
{
    CGSize textSize = [message sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping];
    msgHintLable.text = message;
    msgHintLable.frame = CGRectMake(290-textSize.width-5, 15, textSize.width, 20);
    soundimageView.frame=CGRectMake(290-textSize.width-5-5-25, 16.5, 17, 17);
}

-(NSString*)getCellMsgByState:(NSString*)groupMsgSettingState
{
    if ([groupMsgSettingState isEqualToString:@"0"]) {
        return @"正常接收";
        
    }else  if ([groupMsgSettingState isEqualToString:@"1"]) {
        return @"关闭模式";
    }else  if ([groupMsgSettingState isEqualToString:@"2"]) {
        return @"无声模式";
    }
    return @"";
}

//解散群
-(void)dissolveGroup
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.groupId forKey:@"groupId"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"246" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        [DataStoreManager deleteThumbMsgWithSender:self.groupId];//删除消息列表
        [DataStoreManager deleteGroupMsgWithSenderAndSayType:self.groupId];//删除聊天记录
//        [DataStoreManager deleteGroupInfoByGoupId:self.groupId];//删除群信息
        [DataStoreManager deleteJoinGroupApplicationByGroupId:self.groupId];// 删除群通知
         [[GroupManager singleton] changGroupState:self.groupId GroupState:@"1" GroupShipType:@"3"];//改变本地群的状态
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"您已经解散该群"delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alert.tag = 789;
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}


//离开群
-(void)leaveGroup
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.groupId forKey:@"groupId"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"247" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        [self changGroupState];
        
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"您已经离开该群"delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alert.tag = 789;
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}
//
-(void)changGroupState
{
    NSDictionary * dic = @{@"groupId":self.groupId,@"state":@"2"};
    [DataStoreManager deleteThumbMsgWithSender:self.groupId];//删除消息列表
    [DataStoreManager deleteGroupMsgWithSenderAndSayType:self.groupId];//删除聊天记录
//    [DataStoreManager deleteGroupInfoByGoupId:self.groupId];//删除群信息
    [DataStoreManager deleteJoinGroupApplicationByGroupId:self.groupId];// 删除群通知
    [[GroupManager singleton] changGroupState:self.groupId GroupState:@"2" GroupShipType:@"3"];//改变本地群的状态
    [[NSNotificationCenter defaultCenter]postNotificationName:kKickOffGroupGroup object:nil userInfo:dic];
}
//设置群消息提示
-(void)settingMsgHint:(NSString*)state
{
    NSString * message = [self getCellMsgByState:state];
    [self setSettingMsg:message];
    soundimageView.image= KUIImage([self getMsgIcon:state]);
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.groupId forKey:@"groupId"];
    [paramDict setObject:state forKey:@"state"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"240" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}




#pragma mark 选择器
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return m_roleArray.count;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
{
    NSDictionary *dic = [m_roleArray objectAtIndex:row];
    UIView *customView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    EGOImageView *imageView = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 5, 20, 20)];
    imageView.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")]];
    [customView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 30)];
    label.text = [NSString stringWithFormat:@"%@-%@-%@",KISDictionaryHaveKey(dic, @"realm"),KISDictionaryHaveKey(dic, @"value1"),KISDictionaryHaveKey(dic, @"name")];
    [customView addSubview:label];
    return customView;
    
}

-(void)selectServerNameOK:(id)sender
{
    if ([m_roleArray count] != 0) {
        NSDictionary *dict =[m_roleArray objectAtIndex:[m_rolePickView selectedRowInComponent:0]];
        groupNameLable.text = [NSString stringWithFormat:@"%@-%@",KISDictionaryHaveKey(dict, @"realm"),KISDictionaryHaveKey(dict, @"name")];
        NSMutableDictionary *dic =[NSMutableDictionary dictionaryWithObjectsAndKeys:KISDictionaryHaveKey(dict, @"id"),@"characterId",self.groupId,@"groupId",KISDictionaryHaveKey(dict, @"gameid"),@"gameid", nil];
        [self getCardWithNetWithDic:dic];
        
        [groupNameLable resignFirstResponder];
    }
}

-(void)getCardWithNetWithDic:(NSMutableDictionary *)dic
{
    [hud show:YES];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"256" forKey:@"method"];
    [postDict setObject:dic forKey:@"params"];
    
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        [self showMessageWindowWithContent:@"修改成功" imageType:0];
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
