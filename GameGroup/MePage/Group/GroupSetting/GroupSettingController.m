//
//  GroupSettingController.m
//  GameGroup
//
//  Created by Apple on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupSettingController.h"
#import "MembersListViewController.h"
#import "MemberEditViewController.h"
#import "GroupInfoEditViewController.h"
#import "PublishBillboardViewController.h"
@interface GroupSettingController ()
{
    UILabel *groupNameLable;
    UILabel *msgHintLable;
    UIImageView *soundimageView;
}

@end

@implementation GroupSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"群组设置" withBackButton:YES];
    //群组消息提示
    
    UIScrollView *scV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth - startX-(KISHighVersion_7?0:20))];
    scV.scrollEnabled = YES;
    scV.contentSize=CGSizeMake(320, 500);
    [self.view addSubview:scV];
    
   
    
    UIView * itemone=[[UIView alloc] initWithFrame:CGRectMake(0, 20,320, 45)];
    UIButton * topBtn = [self getItemBtn:@"群组消息提示"];
    [topBtn addTarget:self action:@selector(hint:) forControlEvents:UIControlEventTouchUpInside];
    [itemone addSubview:topBtn];
    
    soundimageView=[[UIImageView alloc] initWithFrame:CGRectMake(250-25-10, 12.5, 25, 20)];
    soundimageView.image = KUIImage(@"nor_soundSong");
    soundimageView.backgroundColor = [UIColor clearColor];
    [itemone addSubview:soundimageView];
    
    msgHintLable = [[UILabel alloc]initWithFrame:CGRectMake(300-50, 12.5, 40, 20)];
    msgHintLable.backgroundColor = [UIColor clearColor];
    msgHintLable.textColor = kColorWithRGB(100,100,100, 0.7);
    msgHintLable.text = @"无声";
    msgHintLable.font =[ UIFont systemFontOfSize:12];
    [itemone addSubview:msgHintLable];
    [scV addSubview:itemone];
    
    // 我的群角色
    UIView * itemtwo=[[UIView alloc] initWithFrame:CGRectMake(0, 66,320, 45)];
    UIButton * twoBtn = [self getItemBtn:@"我的群角色"];
    [twoBtn addTarget:self action:@selector(role:) forControlEvents:UIControlEventTouchUpInside];
    [itemtwo addSubview:twoBtn];
    
    groupNameLable = [[UILabel alloc]initWithFrame:CGRectMake(250, 12.5, 50, 20)];
    groupNameLable.backgroundColor = [UIColor clearColor];
    groupNameLable.textColor = kColorWithRGB(100,100,100, 0.7);
    groupNameLable.text = @"marss";
    groupNameLable.font =[ UIFont systemFontOfSize:14];
    [itemtwo addSubview:groupNameLable];
    
    [scV addSubview:itemtwo];
    
    
    //邀请新成员
    UIView * itemthree=[[UIView alloc] initWithFrame:CGRectMake(0, 112,320, 45)];
    UIButton * threeBtn = [self getItemBtn:@"邀请新成员"];
    [threeBtn addTarget:self action:@selector(new:) forControlEvents:UIControlEventTouchUpInside];
    [itemthree addSubview:threeBtn];
    
    [scV addSubview:itemthree];
    
    //举报该群组
    UIView * itemfour=[[UIView alloc] initWithFrame:CGRectMake(0,213,320, 45)];
    UIButton * fourBtn = [self getItemBtn:@"举报该群组"];
    [fourBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [fourBtn addTarget:self action:@selector(report:) forControlEvents:UIControlEventTouchUpInside];
    [itemfour addSubview:fourBtn];
    
    [scV addSubview:itemfour];
    
    
    
    
    //发布群公告
    UIView * itemfive=[[UIView alloc] initWithFrame:CGRectMake(0,213,320, 45)];
    UIButton * fiveBtn = [self getItemBtn:@"发布群公告"];
    [fiveBtn addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
    [itemfive addSubview:fiveBtn];
    
    [scV addSubview:itemfive];
    
    
    //提示信息
    UILabel *explainLable = [[UILabel alloc]initWithFrame:CGRectMake(20,258,280, 50)];
    explainLable.backgroundColor = [UIColor clearColor];
    explainLable.textColor = kColorWithRGB(100,100,100, 0.7);
    explainLable.text = @"陌游群公告会在我的组织中有非常明显的提示，可以很容易的被群成员注意到.";
    explainLable.font =[ UIFont systemFontOfSize:12];
    explainLable.numberOfLines = 2 ;
    [scV addSubview:explainLable];
    
    
    //管理群成员
    UIView * itemsixe=[[UIView alloc] initWithFrame:CGRectMake(0,309,320, 45)];
    UIButton * sixeBtn = [self getItemBtn:@"管理群成员"];
    [sixeBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
    [sixeBtn addTarget:self action:@selector(managerGroup:) forControlEvents:UIControlEventTouchUpInside];
    [itemsixe addSubview:sixeBtn];
    
    [scV addSubview:itemsixe];
    
    //编辑群资料
    UIView * itemseven=[[UIView alloc] initWithFrame:CGRectMake(0,355,320, 45)];
    UIButton * sevenBtn = [self getItemBtn:@"编辑群资料"];
    [sevenBtn addTarget:self action:@selector(editGroupInfo:) forControlEvents:UIControlEventTouchUpInside];
    [itemseven addSubview:sevenBtn];
    
    [scV addSubview:itemseven];
    
   
    
    //离开该群,解散群
    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(10,300,300, 40)];
    [okButton setBackgroundImage:KUIImage(@"red_button_normal") forState:UIControlStateNormal];
    [okButton setBackgroundImage:KUIImage(@"red_button_click") forState:UIControlStateHighlighted];
    [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor clearColor];
    [okButton addTarget:self action:@selector(leave:) forControlEvents:UIControlEventTouchUpInside];
    [scV addSubview:okButton];
    
    NSString * groupMsgSettingState = [GameCommon getMsgSettingStateByGroupId:self.groupId];
    NSString * message = [self getCellMsgByState:groupMsgSettingState];
    [self setSettingMsg:message];
    

    
    if (self.shiptypeCount ==0) {//群主
        okButton.frame  = CGRectMake(10,421,300, 40);
        itemfour.hidden = NO;
       [okButton setTitle:@"解散该群" forState:UIControlStateNormal];
    }if (self.shiptypeCount ==1) {//管理员
        itemfive.hidden=YES;
         explainLable.hidden=YES;
         sixeBtn.hidden=YES;
         sevenBtn.hidden=YES;
        [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
    }if (self.shiptypeCount ==2) {//群成员
        itemfive.hidden=YES;
        explainLable.hidden=YES;
        sixeBtn.hidden=YES;
        sevenBtn.hidden=YES;
        [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
    }if (self.shiptypeCount ==3) {//陌生人
        itemfive.hidden=YES;
        explainLable.hidden=YES;
        sixeBtn.hidden=YES;
        sevenBtn.hidden=YES;
        [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
    }
    [self setInfo];
}

-(void)setSettingMsg:(NSString*)message
{
    CGSize textSize = [message sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping];
    msgHintLable.text = message;
    msgHintLable.frame = CGRectMake(300-textSize.width-5, 12.5, textSize.width, 20);
    soundimageView.frame=CGRectMake(300-textSize.width-5-5-25, 12.5, 25, 20);
}

-(NSString*)getCellMsgByState:(NSString*)groupMsgSettingState
{
    if ([groupMsgSettingState isEqualToString:@"0"]) {
        return @"接受推送消息并提示";
        
    }else  if ([groupMsgSettingState isEqualToString:@"1"]) {
        return @"不接受推送消息且不提示";
    }else  if ([groupMsgSettingState isEqualToString:@"2"]) {
        return @"不接受推送消息但提示";
    }
    return @"";
}
-(void)setInfo
{
    groupNameLable.text = @"艾欧尼亚－Marss";
    CGSize textSize = [groupNameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping];
     groupNameLable.frame=CGRectMake(300-textSize.width-10, 12, textSize.width, 20);
}

-(UIButton*)getItemBtn:(NSString*)titleText
{
    UIButton * ItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    [ItemBtn setBackgroundColor:[UIColor whiteColor]];
    [ItemBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [ItemBtn setTitle:titleText forState:UIControlStateNormal];
    ItemBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [ItemBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    ItemBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    ItemBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    ItemBtn.userInteractionEnabled = YES;
    
    UIImageView *rightimageView=[[UIImageView alloc] initWithFrame:CGRectMake(320-20, 16.5, 8, 12)];
    rightimageView.image = KUIImage(@"right_arrow");
    rightimageView.backgroundColor = [UIColor clearColor];
    [ItemBtn addSubview:rightimageView];
    return ItemBtn;
}
//群组消息设置
-(void)hint:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"接受推送消息并提示",@"不接受推送消息且不提示",@"不接受推送消息但提示", nil];
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
}
//举报该群组
-(void)report:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"敏感信息",@"欺诈信息",@"色情",@"非法活动", nil];
    [actionSheet showInView:self.view];
    
 
}

//发布群公告
-(void)publish:(id)sender
{
    PublishBillboardViewController *billboard = [[PublishBillboardViewController alloc]init];
    billboard.groupId = self.groupId;
    [self.navigationController pushViewController:billboard animated:YES];
}
//管理群成员
-(void)managerGroup:(id)sender
{
    MemberEditViewController *member = [[MemberEditViewController alloc]init];
    member.groupId = self.groupId;
    member.shiptype = self.shiptypeCount;
    [self.navigationController pushViewController:member animated:YES];
}
//编辑群资料
-(void)editGroupInfo:(id)sender
{
    GroupInfoEditViewController *memberEidt =[[ GroupInfoEditViewController alloc]init];
    memberEidt.groupId = self.groupId;
    [self.navigationController pushViewController:memberEidt animated:YES];
}


-(void)leave:(id)sender
{
    if (self.shiptypeCount ==0) {//群主
        [self dissolveAlert];
    }if (self.shiptypeCount ==1) {//管理员
        [self leaveAlert];
    }if (self.shiptypeCount ==2) {//群成员
        [self leaveAlert];
    }if (self.shiptypeCount ==3) {//陌生人
        [self leaveAlert];
    }
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
        
        NSString * groupMsgSettingState = [GameCommon getMsgSettingStateByGroupId:self.groupId];
        NSString * message = [self getCellMsgByState:groupMsgSettingState];
        [self setSettingMsg:message];
        
    }
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
        [[GroupManager singleton] changGroupState:self.groupId GroupState:@"0"];
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
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"您已经离开该群"delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alert.tag = 789;
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}



//设置群消息提示
-(void)settingMsgHint:(NSString*)state
{
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
