//
//  GroupSettingController.m
//  GameGroup
//
//  Created by Apple on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupSettingController.h"

@interface GroupSettingController ()

@end

@implementation GroupSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"群组设置" withBackButton:YES];
    
    UIView * itemone=[[UIView alloc] initWithFrame:CGRectMake(0, startX+20,320, 45)];
    UIButton * topBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    [topBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [topBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [topBtn setTitle:@"群组消息提示" forState:UIControlStateNormal];
    topBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [topBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
    topBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    topBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    topBtn.userInteractionEnabled = YES;
    [topBtn addTarget:self action:@selector(hint:) forControlEvents:UIControlEventTouchUpInside];
    [itemone addSubview:topBtn];
    UIImageView *topimageView=[[UIImageView alloc] initWithFrame:CGRectMake(320-20, 16, 8, 12)];
    topimageView.image = KUIImage(@"right_arrow");
    topimageView.backgroundColor = [UIColor clearColor];
    [itemone addSubview:topimageView];
    [self.view addSubview:itemone];
    
    
    UIView * itemtwo=[[UIView alloc] initWithFrame:CGRectMake(0, startX+71,320, 45)];
    UIButton * twoBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    [twoBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [twoBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [twoBtn setTitle:@"我的群角色" forState:UIControlStateNormal];
    twoBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [twoBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
    twoBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    twoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    twoBtn.userInteractionEnabled = YES;
    [twoBtn addTarget:self action:@selector(role:) forControlEvents:UIControlEventTouchUpInside];
    [itemtwo addSubview:twoBtn];
    UIImageView *twoimageView=[[UIImageView alloc] initWithFrame:CGRectMake(320-20, 16, 8, 12)];
    twoimageView.image = KUIImage(@"right_arrow");
    twoimageView.backgroundColor = [UIColor clearColor];
    [itemtwo addSubview:twoimageView];
    [self.view addSubview:itemtwo];
    
    UIView * itemthree=[[UIView alloc] initWithFrame:CGRectMake(0, startX+122,320, 45)];
    UIButton * threeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    [threeBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [threeBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [threeBtn setTitle:@"邀请新成员" forState:UIControlStateNormal];
    threeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [threeBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
    threeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    threeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    threeBtn.userInteractionEnabled = YES;
    [threeBtn addTarget:self action:@selector(new:) forControlEvents:UIControlEventTouchUpInside];
    [itemthree addSubview:threeBtn];
    UIImageView *threeimageView=[[UIImageView alloc] initWithFrame:CGRectMake(320-20, 16, 8, 12)];
    threeimageView.image = KUIImage(@"right_arrow");
    threeimageView.backgroundColor = [UIColor clearColor];
    [itemthree addSubview:threeimageView];
    [self.view addSubview:itemthree];
    
    
    UIView * itemfour=[[UIView alloc] initWithFrame:CGRectMake(0,startX+223,320, 45)];
    UIButton * fourBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    [fourBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [fourBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    [fourBtn setTitle:@"举报该群" forState:UIControlStateNormal];
    fourBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [fourBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
    fourBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    fourBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    fourBtn.userInteractionEnabled = YES;
    [fourBtn addTarget:self action:@selector(report:) forControlEvents:UIControlEventTouchUpInside];
    [itemfour addSubview:fourBtn];
    UIImageView *fourimageView=[[UIImageView alloc] initWithFrame:CGRectMake(320-20, 16, 8, 12)];
    fourimageView.image = KUIImage(@"right_arrow");
    fourimageView.backgroundColor = [UIColor clearColor];
    [itemfour addSubview:fourimageView];
    [self.view addSubview:itemfour];
    
    
    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(20,startX+300,280, 40)];
    [okButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [okButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor clearColor];
    [okButton addTarget:self action:@selector(leave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okButton];
    if (self.shiptypeCount ==0) {//群主
       [okButton setTitle:@"解散该群" forState:UIControlStateNormal];
    }if (self.shiptypeCount ==1) {//管理员
        [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
    }if (self.shiptypeCount ==2) {//群成员
        [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
    }if (self.shiptypeCount ==3) {//陌生人
        [okButton setTitle:@"离开该群" forState:UIControlStateNormal];
    }
}
-(void)hint:(id)sender
{
}
-(void)role:(id)sender
{
}
-(void)new:(id)sender
{
}
-(void)report:(id)sender
{
}
-(void)leave:(id)sender
{
    if (self.shiptypeCount ==0) {//群主
        [self dissolveGroup];
    }if (self.shiptypeCount ==1) {//管理员
        [self leaveGroup];
    }if (self.shiptypeCount ==2) {//群成员
        [self leaveGroup];
    }if (self.shiptypeCount ==3) {//陌生人
        [self leaveGroup];
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
