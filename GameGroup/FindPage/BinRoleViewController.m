//
//  BinRoleViewController.m
//  GameGroup
//
//  Created by Apple on 14-5-22.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BinRoleViewController.h"
#import "EGOImageView.h"
#import "ShareToOther.h"
#import "AuthViewController.h"


#define OfficerUrl @"http://www.momotalk.com"

@interface BinRoleViewController ()
{
    EGOImageView *titleImageView;
    EGOImageView *roleImageView;
    UILabel *titleLabel;
    UILabel *serverLabel;
    UILabel *ValueLabel;
    UIImageView *sexImageView;
    UIImageView *NumImageView;
    UILabel *NumLable;
    NSIndexPath  *myIndexPath;
    UIImageView  *bgImageView;
    
    NSString * messageText;
}

@end

@implementation BinRoleViewController

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
    
    if ([self.type isEqualToString:@"1"]) {
        [self setTopViewWithTitle:@"邀请绑定" withBackButton:YES];
    }else
    {
        [self setTopViewWithTitle:@"举报该角色" withBackButton:YES];
    }
    [self initView];
    [self setInfo:self.dataDic];
}
-(void)initView
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(5, startX+5, 310, 60)];
    
    bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 310, 60)];
    bgImageView.image = KUIImage(@"me_normal");
    [topView addSubview:bgImageView];
    
    NumImageView =[[UIImageView alloc]initWithFrame:CGRectMake(10, 18, 25, 25)];
    NumImageView.backgroundColor = [UIColor clearColor];
    [topView addSubview:NumImageView];
    
    NumLable=[[UILabel alloc] initWithFrame:CGRectMake(10, 18, 25, 25)];
    NumLable.backgroundColor = [UIColor clearColor];
    NumLable.textColor = [UIColor grayColor];
    NumLable.textAlignment = NSTextAlignmentCenter;
    NumLable.font = [UIFont fontWithName:@"汉仪菱心体简" size:20];
    NumLable.hidden=YES;
    [topView addSubview:NumLable];
    
    titleImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(40, 10, 40, 40)];
    titleImageView.layer.masksToBounds = YES;
    titleImageView.layer.cornerRadius = 5;
    titleImageView.layer.borderWidth = 0.1;
    titleImageView.layer.borderColor = [[UIColor blackColor] CGColor];
    [topView addSubview:titleImageView];
    
    titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(90, 8, 100, 20)];
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.backgroundColor =[ UIColor clearColor];
    [topView addSubview:titleLabel];
    
    roleImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(195, 9, 15, 15)];
    roleImageView.layer.masksToBounds = YES;
    roleImageView.layer.borderWidth = 0.1;
    roleImageView.layer.borderColor = [[UIColor blackColor] CGColor];
    [topView addSubview:roleImageView];
    
    [topView addSubview:titleImageView];
    sexImageView = [[UIImageView alloc]initWithFrame:CGRectMake(90, 36, 13, 13)];
    sexImageView.image = KUIImage(@"icon_12");
    [topView addSubview:sexImageView];
    
    serverLabel =[[UILabel alloc]initWithFrame:CGRectMake(108, 32, 150, 20)];
    serverLabel.font = [UIFont boldSystemFontOfSize:14];
    serverLabel.textColor = [UIColor grayColor];
    serverLabel.backgroundColor = [UIColor clearColor];
    [topView addSubview:serverLabel];
    
    ValueLabel =[[UILabel alloc]initWithFrame:CGRectMake(230, 15, 80, 30)];
    ValueLabel.backgroundColor = [UIColor clearColor];
    ValueLabel.textColor = [UIColor grayColor];
    ValueLabel.textAlignment = NSTextAlignmentCenter;
    ValueLabel.font = [UIFont fontWithName:@"汉仪菱心体简" size:20];
    [topView addSubview:ValueLabel];
    
    
    [self.view addSubview:topView];
    UILabel *text1 =[[UILabel alloc] initWithFrame:CGRectMake(10, 75+startX, 310, 30)];
    text1.font=[UIFont boldSystemFontOfSize:12];
    text1.backgroundColor=[UIColor clearColor];
    text1.text=@"如果该角色为您所有，您可以立即通过认证将该角色找回到您的名下";
    text1.textColor=UIColorFromRGBA(0x5c81c0, 1);
    text1.numberOfLines=2;
    [self.view addSubview:text1];
    
    UIButton *binBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 120+startX, 300, 35)];
    [binBtn setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [binBtn setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [binBtn setTitle:@"举报并认证" forState:UIControlStateNormal];
    [binBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    binBtn.backgroundColor = [UIColor clearColor];
    binBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [binBtn addTarget:self action:@selector(binBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:binBtn];
    
    UIView *tongzhiVIew=[[UIView alloc] initWithFrame:CGRectMake(0, 170+startX, 320, 23)];
    tongzhiVIew.backgroundColor=UIColorFromRGBA(0x666666, 1);
    
    UIImageView *tImage=[[UIImageView alloc] initWithFrame:CGRectMake(10, 4, 15, 15)];
    tImage.image=KUIImage(@"new_msg_tixing.png");
    [tongzhiVIew addSubview:tImage];
    
    UILabel *text2 =[[UILabel alloc] initWithFrame:CGRectMake(28,1.5, 200, 20)];
    text2.font=[UIFont boldSystemFontOfSize:12];
    text2.text=@"通知朋友绑定角色";
    text2.textColor=[UIColor whiteColor];
    text2.backgroundColor=[UIColor clearColor];
    [tongzhiVIew addSubview:text2];
    [self.view addSubview:tongzhiVIew];
    
    UILabel *text3 =[[UILabel alloc] initWithFrame:CGRectMake(10, 210+startX, 310, 60)];
    text3.font=[UIFont boldSystemFontOfSize:12];
    text3.backgroundColor=[UIColor clearColor];
    text3.text=@"如果此角色被非本人绑定了，您可以在这里举报他！我们建议您通知您的朋友来认领此角色，因为未被绑定的角色很容易被他人冒充绑定";
    text3.numberOfLines= 4;
    text3.textColor=UIColorFromRGBA(0x5c81c0, 1);
    [self.view addSubview:text3];
    
    UIButton *jubaoBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 280+startX, 300, 35)];
    [jubaoBtn setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [jubaoBtn setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [jubaoBtn setTitle:@"举报并通知好友" forState:UIControlStateNormal];
    [jubaoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    jubaoBtn.backgroundColor = [UIColor clearColor];
    jubaoBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [jubaoBtn addTarget:self action:@selector(notificationClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:jubaoBtn];
    
    messageText=@"该角色在陌游已被人绑定";
    
    
    if ([self.type isEqualToString:@"1"]) {
        text1.hidden=YES;
        binBtn.hidden=YES;
        
        tongzhiVIew.frame=CGRectMake(0, 85+startX, 320, 23);
        text2.text=@"通知朋友绑定角色";
        text3.frame=CGRectMake(10, 125+startX, 310, 60);
        text3.text=@"如果该角色为您朋友所有，您可以立即通知他来绑定角色，这样可以方便您们再好友排行榜上比较战绩，也可以防止他人冒领角色";
        jubaoBtn.frame=CGRectMake(10, 200+startX, 300, 30);
        [jubaoBtn setTitle:@"通知好友绑定角色" forState:UIControlStateNormal];
        
        messageText=@"邀请您在陌游绑定该角色";
    }
    
}
//设置数据
-(void)setInfo:(NSDictionary*)dic
{
    NSInteger i = [KISDictionaryHaveKey(dic, @"rank")integerValue];
    if (i <=3) {
        NumImageView.hidden = NO;
        NumLable.hidden=YES;
        if (i==1) {
            NumImageView.image =KUIImage(@"01_17");
        }
        if (i==2) {
            NumImageView.image =KUIImage(@"02_17");
        }
        if (i==3) {
            NumImageView.image =KUIImage(@"03_17");
        }
    }else{
        NumImageView.hidden =YES;
        NumLable.hidden=NO;
        
    }
   NSString * headImage =[GameCommon getHeardImgId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"img")]];
    if ([GameCommon isEmtity:headImage]) {
        titleImageView.image = [UIImage imageNamed:@"people_man.png"];
    }else{
        titleImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseImageUrl,headImage]];
    }
    
    NSString *characterImage=[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"characterImg")];
    if ([GameCommon isEmtity:characterImage]) {
        roleImageView.image = [UIImage imageNamed:@"clazz_0.png"];
    }else{
        roleImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseImageUrl,characterImage]];
    }
    
    NumLable.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"rank")];
    titleLabel.text = KISDictionaryHaveKey(dic, @"charactername");
    
    NSString *str =KISDictionaryHaveKey(dic, @"nickname");
    if ([GameCommon isEmtity:str]) {
        serverLabel.text = @"未绑定";
        sexImageView.image = KUIImage(@"icon_12");
    }else{
        serverLabel.text = str;
        if ([KISDictionaryHaveKey(dic, @"gender")isEqualToString:@"1"]) {
            sexImageView.image= KUIImage(@"icon_09");
        }else{
            sexImageView.image= KUIImage(@"icon_07");
        }
    }
    ValueLabel.text=[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"value")];
    
    CGSize nameSize = [titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    titleLabel.frame=CGRectMake(90, 7, nameSize.width, 20);
    roleImageView.frame=CGRectMake(90+nameSize.width+5, 10, 15, 15);
    
}
//绑定认证
-(void)binBtnClick:(id)sender
{
    AuthViewController* authVC = [[AuthViewController alloc] init];
    authVC.gameId = self.gameId;
    authVC.realm = KISDictionaryHaveKey(self.dataDic, @"realm");
    authVC.character = KISDictionaryHaveKey(self.dataDic, @"charactername");
    [self.navigationController pushViewController:authVC animated:YES];
}
//举报邀请
-(void)notificationClick:(id)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"通知方式"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:Nil
                                  otherButtonTitles:@"通过QQ通知",@"通过微信通知",@"通过短信通知",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}
//通知方式
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString * characterImage=[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"characterImg")];
    NSString * clazzImageUrl=[NSString stringWithFormat:@"%@%@",BaseImageUrl,characterImage];
    
    NSString * characyerName=[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"charactername")];
    UIGraphicsBeginImageContext(CGSizeMake(kScreenWidth, kScreenHeigth));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    if (buttonIndex ==0) {
        [[ShareToOther singleton] onTShareImage:clazzImageUrl Title:characyerName Description:messageText Url:OfficerUrl];
    }
    else if (buttonIndex ==1)
    {
        [[ShareToOther singleton] sendAppExtendContent_friend:[self getImageFromURL:clazzImageUrl] Title:characyerName Description:messageText Url:OfficerUrl];
    }
    else if(buttonIndex ==2)
    {
        NSString * msgBody= [NSString stringWithFormat:@"%@%@%@",@"你的角色 ",characyerName,@" 已被他人绑定. 您的好友邀请您进入陌游APP认领该角色. 陌游APP http://www.momotalk.com"];
         NSString * msgBody2= [NSString stringWithFormat:@"%@%@%@",@"你的角色 ",characyerName,@" 在陌游中尚未被绑定. 您的好友邀请您进入陌游APP认领该角色. 陌游APP http://www.momotalk.com"];
        if ([self.type isEqualToString:@"2"]) {
            [self sendSMS:msgBody];
        }else{
            [self sendSMS:msgBody2];
        }
        
    }
}
//请求网络图片
-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}
//内容，收件人列表
- (void)sendSMS:(NSString*)bodyOfMessage
{
    
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        picker.body=bodyOfMessage;
        [self presentViewController:picker animated:YES completion:^{
        }];
    }
    else {
        UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:nil message:@"您的设备不支持短信功能" delegate:nil cancelButtonTitle:@"知道啦" otherButtonTitles: nil];
        [alertV show];
    }

}
//发送消息结束代理回调
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:^{
        switch (result) {
            case MessageComposeResultSent:{
                [self showMessageWindowWithContent:@"发送成功" imageType:0];
            }break;
            case MessageComposeResultFailed:{
                [self showMessageWindowWithContent:@"发送失败" imageType:0];
            }break;
            default:
                break;
        }
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
