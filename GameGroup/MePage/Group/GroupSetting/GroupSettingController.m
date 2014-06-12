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
#import "PublishBillboardViewController.h"

@interface GroupSettingController ()
{
    UILabel *groupNameLable;
    UILabel *msgHintLable;
}

@end

@implementation GroupSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"群组设置" withBackButton:YES];
    //群组消息提示
    
    
    UIView * itemone=[[UIView alloc] initWithFrame:CGRectMake(0, startX+20,320, 45)];
    UIButton * topBtn = [self getItemBtn:@"群组消息提示"];
    [topBtn addTarget:self action:@selector(hint:) forControlEvents:UIControlEventTouchUpInside];
    [itemone addSubview:topBtn];
    
    UIImageView *soundimageView=[[UIImageView alloc] initWithFrame:CGRectMake(250-25-10, 12.5, 25, 20)];
    soundimageView.image = KUIImage(@"nor_soundSong");
    soundimageView.backgroundColor = [UIColor clearColor];
    [itemone addSubview:soundimageView];
    
    msgHintLable = [[UILabel alloc]initWithFrame:CGRectMake(300-50, 12.5, 40, 20)];
    msgHintLable.backgroundColor = [UIColor clearColor];
    msgHintLable.textColor = kColorWithRGB(100,100,100, 0.7);
    msgHintLable.text = @"无声";
    msgHintLable.font =[ UIFont systemFontOfSize:12];
    [itemone addSubview:msgHintLable];
    
    UIImageView *topimageView=[[UIImageView alloc] initWithFrame:CGRectMake(300, 16.5, 8, 12)];
    topimageView.image = KUIImage(@"right_arrow");
    topimageView.backgroundColor = [UIColor clearColor];
    [itemone addSubview:topimageView];
    
    [self.view addSubview:itemone];
    
    // 我的群角色
    UIView * itemtwo=[[UIView alloc] initWithFrame:CGRectMake(0, startX+66,320, 45)];
    UIButton * twoBtn = [self getItemBtn:@"我的群角色"];
    [twoBtn addTarget:self action:@selector(role:) forControlEvents:UIControlEventTouchUpInside];
    [itemtwo addSubview:twoBtn];
    
    UIImageView *twoimageView=[[UIImageView alloc] initWithFrame:CGRectMake(300, 16.5, 8, 12)];
    twoimageView.image = KUIImage(@"right_arrow");
    twoimageView.backgroundColor = [UIColor clearColor];
    [itemtwo addSubview:twoimageView];
    
    groupNameLable = [[UILabel alloc]initWithFrame:CGRectMake(250, 12.5, 50, 20)];
    groupNameLable.backgroundColor = [UIColor clearColor];
    groupNameLable.textColor = kColorWithRGB(100,100,100, 0.7);
    groupNameLable.text = @"marss";
    groupNameLable.font =[ UIFont systemFontOfSize:14];
    [itemtwo addSubview:groupNameLable];
    
    [self.view addSubview:itemtwo];
    
    
    //邀请新成员
    UIView * itemthree=[[UIView alloc] initWithFrame:CGRectMake(0, startX+112,320, 45)];
    UIButton * threeBtn = [self getItemBtn:@"邀请新成员"];
    [threeBtn addTarget:self action:@selector(new:) forControlEvents:UIControlEventTouchUpInside];
    [itemthree addSubview:threeBtn];
    
    UIImageView *threeimageView=[[UIImageView alloc] initWithFrame:CGRectMake(320-20, 16.5, 8, 12)];
    threeimageView.image = KUIImage(@"right_arrow");
    threeimageView.backgroundColor = [UIColor clearColor];
    [itemthree addSubview:threeimageView];
    
    [self.view addSubview:itemthree];
    
    //举报该群组
    UIView * itemfour=[[UIView alloc] initWithFrame:CGRectMake(0,startX+213,320, 45)];
    UIButton * fourBtn = [self getItemBtn:@"举报该群组"];
    [fourBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [fourBtn addTarget:self action:@selector(report:) forControlEvents:UIControlEventTouchUpInside];
    [itemfour addSubview:fourBtn];

    UIImageView *fourimageView=[[UIImageView alloc] initWithFrame:CGRectMake(320-20, 16.5, 8, 12)];
    fourimageView.image = KUIImage(@"right_arrow");
    fourimageView.backgroundColor = [UIColor clearColor];
    [itemfour addSubview:fourimageView];
    
    
    [self.view addSubview:itemfour];
    
    
    
    
    //发布群公告
    UIView * itemfive=[[UIView alloc] initWithFrame:CGRectMake(0,startX+213,320, 45)];
    UIButton * fiveBtn = [self getItemBtn:@"发布群公告"];
    [fiveBtn addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
    [itemfive addSubview:fiveBtn];
    
    [self.view addSubview:itemfive];
    
    
    //提示信息
    UILabel *explainLable = [[UILabel alloc]initWithFrame:CGRectMake(20,startX+258,280, 50)];
    explainLable.backgroundColor = [UIColor clearColor];
    explainLable.textColor = kColorWithRGB(100,100,100, 0.7);
    explainLable.text = @"陌游群公告会在我的组织中有非常明显的提示，可以很容易的被群成员注意到.";
    explainLable.font =[ UIFont systemFontOfSize:12];
    explainLable.numberOfLines = 2 ;
    [self.view addSubview:explainLable];
    
    
    //管理群成员
    UIView * itemsixe=[[UIView alloc] initWithFrame:CGRectMake(0,startX+309,320, 45)];
    UIButton * sixeBtn = [self getItemBtn:@"管理群成员"];
    [sixeBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
    [sixeBtn addTarget:self action:@selector(managerGroup:) forControlEvents:UIControlEventTouchUpInside];
    [itemsixe addSubview:sixeBtn];
    
    [self.view addSubview:itemsixe];
    
    //编辑群资料
    UIView * itemseven=[[UIView alloc] initWithFrame:CGRectMake(0,startX+355,320, 45)];
    UIButton * sevenBtn = [self getItemBtn:@"编辑群资料"];
    [sevenBtn addTarget:self action:@selector(editGroupInfo:) forControlEvents:UIControlEventTouchUpInside];
    [itemseven addSubview:sevenBtn];
    
    [self.view addSubview:itemseven];
    
   
    
    //离开该群,解散群
    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(20,startX+290,280, 40)];
    [okButton setBackgroundImage:KUIImage(@"red_button_normal") forState:UIControlStateNormal];
    [okButton setBackgroundImage:KUIImage(@"red_button_click") forState:UIControlStateHighlighted];
    [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor clearColor];
    [okButton addTarget:self action:@selector(leave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okButton];
    
    if (self.shiptypeCount ==0) {//群主
        okButton.frame  = CGRectMake(20,startX+421,280, 40);
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
-(void)setInfo
{
    groupNameLable.text = @"艾欧尼亚－Marss";
    CGSize textSize = [groupNameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping];
     groupNameLable.frame=CGRectMake(300-textSize.width-10, 12, textSize.width, 20);
}

-(UIButton*)getItemBtn:(NSString*)titleText
{
    UIButton * ItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    [ItemBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [ItemBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [ItemBtn setTitle:titleText forState:UIControlStateNormal];
    ItemBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [ItemBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    ItemBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    ItemBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    ItemBtn.userInteractionEnabled = YES;
    return ItemBtn;
}
//群组消息设置
-(void)hint:(id)sender
{
   
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"nil" otherButtonTitles:@"敏感信息",@"欺诈信息",@"色情",@"非法活动", nil];
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
    MembersListViewController *member = [[MembersListViewController alloc]init];
    member.groupId = self.groupId;
    [self.navigationController pushViewController:member animated:YES];
}
//编辑群资料
-(void)editGroupInfo:(id)sender
{
    
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
    }else if(alertView.tag == 678){
        if (buttonIndex ==1) {
            [self dissolveGroup];
        }
    }else if (alertView.tag == 789)
    {
        [self.navigationController popViewControllerAnimated:YES];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
