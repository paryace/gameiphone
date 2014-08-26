//
//  TeamInvitationController.m
//  GameGroup
//
//  Created by Apple on 14-8-26.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TeamInvitationController.h"
#define  marginLeftRight 40 
#define marginTop 36+36+59.5
@interface TeamInvitationController (){
    UIImageView * topImage;
}
@end

@implementation TeamInvitationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void)onTeamUpdateSuccess:(NSNotification*)notification{
    [hud hide:YES];
    NSMutableDictionary *  teamInfo = [[TeamManager singleton] getTeamInfo:[GameCommon getNewStringWithId:self.gameId] RoomId:[GameCommon getNewStringWithId:self.roomId]];
    self.roomInfoDic = teamInfo;
}
-(void)onTeamUpdateFaile:(NSNotification*)notification{
    [hud hide:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    [self setTopViewWithTitle:self.createFinish?@"创建队伍成功":@"邀请好友" withBackButton:YES];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTeamUpdateSuccess:) name:teamInfoUpload object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTeamUpdateFaile:) name:teamInfoUploadFaile object:nil];
    
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, KISHighVersion_7 ? 20 : 0, 65, 44)];
    [backButton setBackgroundImage:KUIImage(@"btn_back") forState:UIControlStateNormal];
    [backButton setBackgroundImage:KUIImage(@"btn_back_onclick") forState:UIControlStateHighlighted];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"finish_btn_icon_normal") forState:UIControlStateNormal];
    [createBtn setBackgroundImage:KUIImage(@"finish_btn_icon_click") forState:UIControlStateHighlighted];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(createItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    
    
    topImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, startX+36, 320, 59.5)];
    topImage.image = KUIImage(self.createFinish?@"create_finish_top_image":@"invitation_top_image");
    [self.view addSubview:topImage];
    
    
    NSArray * imageArray = @[@"invitation_qq",@"invitation_wx",@"invitation_group",@"invitation_my"];
    NSArray * titleArray = @[@"邀请QQ好友",@"邀请微信好友",@"邀请陌游群组",@"邀请陌游好友"];
    
    for (int i =0; i<imageArray.count; i++) {
        float x =  marginLeftRight+(i%2)*92.5+(320-marginLeftRight*2-92.5*2)*(i%2);
        float y = startX+marginTop+(i/2)*92.5+(21+30)*(i/2);
        UIButton *  menuImage = [[UIButton alloc] initWithFrame:CGRectMake(x,y, 92.5, 92.5)];
        menuImage.tag=100+i;
        menuImage.userInteractionEnabled = YES;
        [menuImage setBackgroundImage:KUIImage(imageArray[i]) forState:UIControlStateNormal];
        [menuImage addTarget:self action:@selector(menuOnCLick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:menuImage];
        
        UILabel * menuLable = [[UILabel alloc] initWithFrame:CGRectMake(x, y+10+92.5, 92.5, 20)];
        menuLable.backgroundColor = [UIColor clearColor];
        menuLable.textColor = [UIColor grayColor];
        menuLable.textAlignment = NSTextAlignmentCenter;
        menuLable.font = [UIFont boldSystemFontOfSize:14];
        menuLable.text = titleArray[i];
        [self.view addSubview:menuLable];
    }
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"请稍等...";
    
    NSMutableDictionary *  teamInfo = [[TeamManager singleton] getTeamInfo:[GameCommon getNewStringWithId:self.gameId] RoomId:[GameCommon getNewStringWithId:self.roomId]];
    if (teamInfo) {
        self.roomInfoDic = teamInfo;
    }else{
        [hud show:YES];
    }
    
}

-(void)menuOnCLick:(UIButton*)sender{
    NSInteger index = sender.tag;
    switch (index) {
        case 100:
            [self shareToQQ:10001];//分享到QQ
            break;
        case 101:
             [self shareToQQ:10002];//分享到微信
            break;
        case 102:
            //分享到群组
        {
            InviationGroupViewController *invgro = [[InviationGroupViewController alloc]init];
            invgro.gameId = self.gameId;
            invgro.roomId = self.roomId;
            invgro.gameId = self.gameId;
            invgro.roomInfoDic = self.roomInfoDic;
            [self.navigationController pushViewController:invgro animated:YES];
        }
            break;
        case 103:
        {
            InviationMYFriendController *invgro = [[InviationMYFriendController alloc]init];
            invgro.gameId = self.gameId;
            invgro.roomId = self.roomId;
            invgro.gameId = self.gameId;
            invgro.roomInfoDic = self.roomInfoDic;
            [self.navigationController pushViewController:invgro animated:YES];
        }
            break;
            
        default:
            break;
    }
}

-(void)shareToQQ:(NSInteger)sender
{
    NSString *imgStr = [GameCommon getHeardImgId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"img")]];
    NSString * roomName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"roomName")];
    NSString *description = [NSString stringWithFormat:@"%@邀请你加入在陌游的队伍",roomName];
    NSString *myUserid =[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID];
    NSString * shareUrl = [NSString stringWithFormat:@"%@roomId=%@&gameid=%@&inviterid=%@&realm=%@&characterId=%@",ShareUrl,self.roomId,self.gameId,myUserid,[[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"realm")] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"characterId")]];
    
    if (sender ==10001) {
        [[ShareToOther singleton] onTShareImage:[ImageService getImgUrl:imgStr] Title:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"description")] Description:description Url:shareUrl];
    }else{
        [[ShareToOther singleton] sendAppExtendContent_friend:[self getImageFromURL:[ImageService getImgUrl:imgStr]] Title:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.roomInfoDic, @"description")] Description:description Url:shareUrl];
    }
}
-(UIImage *) getImageFromURL:(NSString *)fileURL {
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    UIImage *result = [UIImage imageWithData:data];
    return result;
}

- (void)backButtonClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)createItem:(UIButton*)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
