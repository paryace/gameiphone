//
//  GroupSettingController.m
//  GameGroup
//
//  Created by Apple on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupSettingController.h"
#import "MembersListViewController.h"
@interface GroupSettingController ()

@end

@implementation GroupSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"群组设置" withBackButton:YES];
    //群组消息提示
    UIView * itemone=[[UIView alloc] initWithFrame:CGRectMake(0, startX+20,320, 45)];
    UIButton * topBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    [topBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [topBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [topBtn setTitle:@"群组消息提示" forState:UIControlStateNormal];
    topBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [topBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    topBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    topBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    topBtn.userInteractionEnabled = YES;
    [topBtn addTarget:self action:@selector(hint:) forControlEvents:UIControlEventTouchUpInside];
    [itemone addSubview:topBtn];
    
    UIImageView *soundimageView=[[UIImageView alloc] initWithFrame:CGRectMake(320-20-34, 12.5, 25, 20)];
    soundimageView.image = KUIImage(@"nor_soundSong");
    soundimageView.backgroundColor = [UIColor clearColor];
    [itemone addSubview:soundimageView];
    
    UIImageView *topimageView=[[UIImageView alloc] initWithFrame:CGRectMake(320-20, 16.5, 8, 12)];
    topimageView.image = KUIImage(@"right_arrow");
    topimageView.backgroundColor = [UIColor clearColor];
    [itemone addSubview:topimageView];
    
    [self.view addSubview:itemone];
    
    // 我的群角色
    UIView * itemtwo=[[UIView alloc] initWithFrame:CGRectMake(0, startX+66,320, 45)];
    UIButton * twoBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    [twoBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [twoBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [twoBtn setTitle:@"我的群角色" forState:UIControlStateNormal];
    twoBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [twoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    twoBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    twoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    twoBtn.userInteractionEnabled = YES;
    [twoBtn addTarget:self action:@selector(role:) forControlEvents:UIControlEventTouchUpInside];
    [itemtwo addSubview:twoBtn];
    
    UIImageView *twoimageView=[[UIImageView alloc] initWithFrame:CGRectMake(300, 16.5, 8, 12)];
    twoimageView.image = KUIImage(@"right_arrow");
    twoimageView.backgroundColor = [UIColor clearColor];
    [itemtwo addSubview:twoimageView];
    
    UILabel *groupNameLable = [[UILabel alloc]initWithFrame:CGRectMake(250, 12.5, 50, 20)];
    groupNameLable.backgroundColor = [UIColor clearColor];
    groupNameLable.textColor = kColorWithRGB(100,100,100, 0.7);
    groupNameLable.text = @"marss";
    groupNameLable.font =[ UIFont systemFontOfSize:12];
    [itemtwo addSubview:groupNameLable];
    
    [self.view addSubview:itemtwo];
    
    
    //邀请新成员
    UIView * itemthree=[[UIView alloc] initWithFrame:CGRectMake(0, startX+112,320, 45)];
    UIButton * threeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    [threeBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [threeBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [threeBtn setTitle:@"邀请新成员" forState:UIControlStateNormal];
    threeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [threeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    threeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    threeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    threeBtn.userInteractionEnabled = YES;
    [threeBtn addTarget:self action:@selector(new:) forControlEvents:UIControlEventTouchUpInside];
    [itemthree addSubview:threeBtn];
    
    UIImageView *threeimageView=[[UIImageView alloc] initWithFrame:CGRectMake(320-20, 16.5, 8, 12)];
    threeimageView.image = KUIImage(@"right_arrow");
    threeimageView.backgroundColor = [UIColor clearColor];
    [itemthree addSubview:threeimageView];
    
    [self.view addSubview:itemthree];
    
    //举报该群组
    UIView * itemfour=[[UIView alloc] initWithFrame:CGRectMake(0,startX+223,320, 45)];
    UIButton * fourBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    [fourBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [fourBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [fourBtn setTitle:@"举报该群组" forState:UIControlStateNormal];
    fourBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [fourBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    fourBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    fourBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    fourBtn.userInteractionEnabled = YES;
    [fourBtn addTarget:self action:@selector(report:) forControlEvents:UIControlEventTouchUpInside];
    [itemfour addSubview:fourBtn];

    UIImageView *fourimageView=[[UIImageView alloc] initWithFrame:CGRectMake(320-20, 16.5, 8, 12)];
    fourimageView.image = KUIImage(@"right_arrow");
    fourimageView.backgroundColor = [UIColor clearColor];
    [itemfour addSubview:fourimageView];
    
    
    [self.view addSubview:itemfour];
    
    
    
    
    //发布群公告
    UIView * itemfive=[[UIView alloc] initWithFrame:CGRectMake(0,startX+223,320, 45)];
    UIButton * fiveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    [fiveBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [fiveBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [fiveBtn setTitle:@"发布群公告" forState:UIControlStateNormal];
    fiveBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [fiveBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    fiveBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    fiveBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    fiveBtn.userInteractionEnabled = YES;
    [fiveBtn addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
    [itemfive addSubview:fiveBtn];
    
    [self.view addSubview:itemfive];
    
    
    //
    UILabel *explainLable = [[UILabel alloc]initWithFrame:CGRectMake(20,startX+268,280, 50)];
    explainLable.backgroundColor = [UIColor clearColor];
    explainLable.textColor = kColorWithRGB(100,100,100, 0.7);
    explainLable.text = @"陌游群公告会在我的组织中有非常明显的提示，可以很容易的被群成员注意到.";
    explainLable.font =[ UIFont systemFontOfSize:12];
    explainLable.numberOfLines = 2 ;
    [self.view addSubview:explainLable];
    
    
    //管理群成员
    UIView * itemsixe=[[UIView alloc] initWithFrame:CGRectMake(0,startX+319,320, 45)];
    UIButton * sixeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    [sixeBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [sixeBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [sixeBtn setTitle:@"管理群成员" forState:UIControlStateNormal];
    sixeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [sixeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    sixeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    sixeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    sixeBtn.userInteractionEnabled = YES;
    [sixeBtn addTarget:self action:@selector(managerGroup:) forControlEvents:UIControlEventTouchUpInside];
    [itemsixe addSubview:sixeBtn];
    
    [self.view addSubview:itemsixe];
    
    //编辑群资料
    UIView * itemseven=[[UIView alloc] initWithFrame:CGRectMake(0,startX+365,320, 45)];
    UIButton * sevenBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    [sevenBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [sevenBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [sevenBtn setTitle:@"编辑群资料" forState:UIControlStateNormal];
    sevenBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [sevenBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    sevenBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    sevenBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    sevenBtn.userInteractionEnabled = YES;
    [sevenBtn addTarget:self action:@selector(editGroupInfo:) forControlEvents:UIControlEventTouchUpInside];
    [itemseven addSubview:sevenBtn];
    
    [self.view addSubview:itemseven];
    
   
    
    //离开该群,解散群
    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(20,startX+300,280, 40)];
    [okButton setBackgroundImage:KUIImage(@"red_button_normal") forState:UIControlStateNormal];
    [okButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor clearColor];
    [okButton addTarget:self action:@selector(leave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okButton];
    
    if (self.shiptypeCount ==0) {//群主
        okButton.frame  = CGRectMake(20,startX+431,280, 40);
        itemfour.hidden = NO;
        [fourBtn setTitle:@"群成员管理" forState:UIControlStateNormal];
       [okButton setTitle:@"解散该群" forState:UIControlStateNormal];
    }if (self.shiptypeCount ==1) {//管理员
        itemfive.hidden=YES;
         explainLable.hidden=YES;
         sixeBtn.hidden=YES;
         sevenBtn.hidden=YES;
        [fourBtn setTitle:@"群成员管理" forState:UIControlStateNormal];
        [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
    }if (self.shiptypeCount ==2) {//群成员
        itemfive.hidden=YES;
        explainLable.hidden=YES;
        sixeBtn.hidden=YES;
        sevenBtn.hidden=YES;
        [fourBtn setTitle:@"举报该群" forState:UIControlStateNormal];
        [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
    }if (self.shiptypeCount ==3) {//陌生人
        itemfive.hidden=YES;
        explainLable.hidden=YES;
        sixeBtn.hidden=YES;
        sevenBtn.hidden=YES;
        [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
    }
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
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"您已经解散该群"delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
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
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"您已经离开该群"delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
