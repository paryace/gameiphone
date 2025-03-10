//
//  GroupInformationViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupInformationViewController.h"
#import "EGOImageView.h"
#import "EGOImageButton.h"
#import "JoinGroupViewController.h"
#import "KKChatController.h"
#import "MembersListViewController.h"
#import "GroupSettingController.h"
#import "SetUpGroupViewController.h"
#import "GroupLeaveViewController.h"
#import "CreateTimeCell.h"
#import "SearchGroupViewController.h"
#import "PhotoViewController.h"
#import "AddFriendsViewController.h"
#import "MyGroupViewController.h"
#import "SearchGroupViewController.h"
//#import "InvitationViewController.h"
#import "NewInvitationViewController.h"
#import "GuildMembersViewController.h"
@interface GroupInformationViewController ()
{
    UITableView *m_myTableView;
    UILabel *Memb;
    EGOImageView *topImg;
    NSMutableDictionary *m_mainDict;
    UIView *boView;
    UIView *aoView;
    UILabel* m_titleLabel;
    UIAlertView* alertView_1;
    UIAlertView *chexiaoAlert;
    UIAlertView *saobaoAction;
}
@end

@implementation GroupInformationViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getInfoWithNet];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNet:) name:@"refelsh_groupInfo_wx" object:nil];
    
    m_mainDict =[ NSMutableDictionary dictionary];
     m_mainDict = (NSMutableDictionary *)[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_group",self.groupId]];
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeigth - 50 )];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.backgroundColor = [UIColor clearColor];
    m_myTableView.showsVerticalScrollIndicator = NO;
    m_myTableView.showsHorizontalScrollIndicator = NO;
    [GameCommon setExtraCellLineHidden:m_myTableView];
    [self.view addSubview:m_myTableView];
    
    
    topImg = [[EGOImageView alloc]initWithFrame:CGRectMake(0, KISHighVersion_7?20:0, 320, 320)];
    NSString * imageUrl = KISDictionaryHaveKey(m_mainDict, @"backgroundImg");
    if ([GameCommon isEmtity:imageUrl]) {
        topImg.image = KUIImage(@"groupinfo_top");
    }else{
        topImg.imageURL = [ImageService getImageUrl:KISDictionaryHaveKey(m_mainDict, @"backgroundImg") Width:320*2 Height:320*2];
    }
    m_myTableView.tableHeaderView = topImg;
    topImg.userInteractionEnabled = YES;
    [m_myTableView reloadData];
    
    
    aoView =[[ UIView alloc]initWithFrame:CGRectMake(0, 270, 320, 50)];
    aoView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f  blue:0/255.0f  alpha:0.5];
    [topImg addSubview:aoView];
    
    [self setTopViewWithTitle:@"" withBackButton:NO];
    
    
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, KISHighVersion_7 ? 20 : 0, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:m_titleLabel];
    
    
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, KISHighVersion_7 ? 20 : 0, 65, 44)];
    [backButton setBackgroundImage:KUIImage(@"backButton") forState:UIControlStateNormal];
    [backButton setBackgroundImage:KUIImage(@"backButton2") forState:UIControlStateHighlighted];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
}

-(void)backButtonClick:(id)sender
{
    if (self.isAudit) {
        for(UIViewController *controller in self.navigationController.viewControllers) {
            if([controller isKindOfClass:[MyGroupViewController class]]){
                MyGroupViewController*owr = (MyGroupViewController *)controller;
                [self.navigationController popToViewController:owr animated:YES];
                return;
            }
            else if ([controller isKindOfClass:[MyGroupViewController class]]){
                MyGroupViewController*owr = (MyGroupViewController *)controller;
                [self.navigationController popToViewController:owr animated:YES];
                return;
            }
            else if ([controller isKindOfClass:[AddFriendsViewController class]]){
                AddFriendsViewController*owr = (AddFriendsViewController *)controller;
                [self.navigationController popToViewController:owr animated:YES];
                return;
            }
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)refreshGroupInfo
{
    [self getInfoWithNet];
}

-(void)refreshNet:(id)sender
{
    [self getInfoWithNet];
}
-(void)didClickGroup:(UIButton *)sender
{
    
    if (self.shiptypeCount==0) {//群主
        
        if (sender.tag ==100) {//发消息
            KKChatController * kkchat = [[KKChatController alloc] init];
            kkchat.chatWithUser = self.groupId;
            kkchat.type = @"group";
            [self.navigationController pushViewController:kkchat animated:YES];
        }else{
            NSLog(@"群设置");//
//            GroupSettingController *gr = [[GroupSettingController alloc]init];
            
            NewGroupSettingViewController *gr = [[NewGroupSettingViewController alloc]init];
            gr.groupId = self.groupId;
            gr.myDelegate = self;
            gr.realmStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"gamerealm")];
            gr.CharacterInfo = KISDictionaryHaveKey(m_mainDict, @"bindCharacterInfo");
            gr.shiptypeCount = self.shiptypeCount;
            
            [self.navigationController pushViewController:gr animated:YES];
        }
        
    }
   else if (self.shiptypeCount==1) {//管理员
       if (sender.tag ==100) {//发消息
           KKChatController * kkchat = [[KKChatController alloc] init];
           kkchat.chatWithUser = self.groupId;
           kkchat.type = @"group";
           [self.navigationController pushViewController:kkchat animated:YES];
       }
       else if(sender.tag ==101){
//           GroupSettingController *gr = [[GroupSettingController alloc]init];
           
           NewGroupSettingViewController *gr = [[NewGroupSettingViewController alloc]init];
           gr.CharacterInfo = KISDictionaryHaveKey(m_mainDict, @"bindCharacterInfo");

           gr.groupId = self.groupId;
           gr.shiptypeCount = self.shiptypeCount;
           [self.navigationController pushViewController:gr animated:YES];//
           NSLog(@"群设置");
       }else{
           NSLog(@"退出群");
       }
   
    }
   else if (self.shiptypeCount==2) {//成员
       if (sender.tag ==100) {//发消息
           KKChatController * kkchat = [[KKChatController alloc] init];
           kkchat.chatWithUser = self.groupId;
           kkchat.type = @"group";
           [self.navigationController pushViewController:kkchat animated:YES];
       }else{
//           GroupSettingController *gr = [[GroupSettingController alloc]init];
           NewGroupSettingViewController *gr = [[NewGroupSettingViewController alloc]init];
           gr.CharacterInfo = KISDictionaryHaveKey(m_mainDict, @"bindCharacterInfo");

           gr.groupId = self.groupId;
           gr.shiptypeCount = self.shiptypeCount;
           [self.navigationController pushViewController:gr animated:YES];
           NSLog(@"群设置");
       }
       
    }
    else{//陌生人
        SetUpGroupViewController *setupVC = [[SetUpGroupViewController alloc]init];
        setupVC.groupid = self.groupId;
        [self.navigationController pushViewController:setupVC animated:YES];
    }
    
}


-(void)wlgc:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    JoinGroupViewController * gruupV = [[JoinGroupViewController alloc] init];
    gruupV.groupId = self.groupId;
    [self.navigationController pushViewController:gruupV animated:YES];
}



-(void)buildmemberisAudit:(NSString *)isAudit title:(NSString *)title num:(NSString *)numStr  imgArray:(NSArray *)array
{
    if (!boView) {
        boView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        boView.backgroundColor =[ UIColor clearColor];
        [aoView addSubview:boView];
    }
    if ([isAudit intValue]==0||[isAudit intValue]==3) {
        
        aoView.backgroundColor = [UIColor clearColor];
        UIImageView *imageView;
        if (!imageView) {
            imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
            imageView.image = KUIImage(@"shenhezhong");
            imageView.backgroundColor = [UIColor clearColor];
            [boView addSubview:imageView];
        }
        
        UILabel *label;
        if (!label) {
            label=[[ UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:18];
            label.textAlignment = NSTextAlignmentCenter;
            [boView addSubview:label];

        }
      
        if ([isAudit intValue]==0) {
            label.text = [NSString stringWithFormat:@"审核队列中,您排在第%@位",numStr];
        }else{
            label.text = @"审核中...";
        }
        
    }else{
        
        
        UILabel *m_cy_label;
        if (!m_cy_label) {
            m_cy_label= [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 85, 20)];
            m_cy_label.backgroundColor = [UIColor clearColor];
            m_cy_label.font = [UIFont boldSystemFontOfSize:13];
            m_cy_label.textColor = [UIColor whiteColor];
            m_cy_label.text = @"群组成员";
            m_cy_label.textAlignment = NSTextAlignmentCenter;
            [boView addSubview:m_cy_label];

        }
        if (!Memb) {
            Memb = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 85, 15)];
            Memb.backgroundColor = [UIColor clearColor];
            Memb.font = [UIFont boldSystemFontOfSize:13];
            Memb.textColor = [UIColor whiteColor];
            Memb.textAlignment = NSTextAlignmentCenter;
            [boView addSubview:Memb];

        }
    Memb.text = title;
        
        for (int i =0; i<array.count; i++) {
            EGOImageButton *headimgView = [[EGOImageButton alloc]initWithFrame:CGRectMake(100+45*i, 5, 40, 40)];
            
            if ([KISDictionaryHaveKey(array[i], @"img")isEqualToString:@"wxxxx"]) {
                headimgView.placeholderImage = KUIImage(@"find_billboard");

                headimgView.imageURL = nil;
                [headimgView addTarget:self action:@selector(enterAddMembersPage:) forControlEvents:UIControlEventTouchUpInside];

            }else{
                headimgView.placeholderImage = KUIImage(@"people_man");
                headimgView.imageURL  = [ImageService getImageStr:KISDictionaryHaveKey(array[i], @"img") Width:80];
                [headimgView addTarget:self action:@selector(enterMembersPage:) forControlEvents:UIControlEventTouchUpInside];

            }
            
            [boView addSubview:headimgView];
        }
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(297, 5, 25, 40);
        [rightBtn setImage:KUIImage(@"right") forState:UIControlStateNormal];
        [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 15)];

        [rightBtn addTarget:self action:@selector(enterMembersPage:) forControlEvents:UIControlEventTouchUpInside];
        [boView addSubview:rightBtn];
    }
}


#pragma mark ---进入组织成员界面
-(void)enterMembersPage:(id)sender
{
    MembersListViewController *memberVC = [[MembersListViewController alloc]init];
    memberVC.groupId = self.groupId ;
    [self.navigationController pushViewController:memberVC animated:YES];
}
//创建屏幕底部按钮
-(void)buildbelowbutotnWithArray:(NSArray *)array  shiptype:(NSInteger)shiptype
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeigth-(KISHighVersion_7?50:60), 320, (KISHighVersion_7?50:60))];
    [self.view addSubview:view];
    float width = 320/array.count;
    for (int i = 0; i<array.count; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(width*i, 0, width, 50)];
        [button setBackgroundImage:KUIImage(array[i]) forState:UIControlStateNormal];
        button.tag = i+100;
        if (shiptype ==1) {
            [button addTarget:self action:@selector(didClickGroup:) forControlEvents:UIControlEventTouchUpInside];

        }else{
            [button addTarget:self action:@selector(chexiaoGroup:) forControlEvents:UIControlEventTouchUpInside];
  
        }
        [view addSubview:button];
    }
    
}

//撤销群申请
-(void)chexiaoGroup:(id)sender
{
    //251
    chexiaoAlert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您确认撤销申请吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    chexiaoAlert.tag = 777;
    [chexiaoAlert show];
}

-(void)getInfoWithNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.groupId forKey:@"groupId"];

    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"231" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            m_mainDict = responseObject;
            [DataStoreManager saveDSGroupList:responseObject];
            [[GroupManager singleton] clearGroupCache:self.groupId];
            m_titleLabel.text = KISDictionaryHaveKey(responseObject, @"groupName");
            NSString * imageUrl = KISDictionaryHaveKey(m_mainDict, @"backgroundImg");
            if ([GameCommon isEmtity:imageUrl]) {
                topImg.image = KUIImage(@"groupinfo_top");
            }else{
                topImg.imageURL = [ImageService getImageUrl:KISDictionaryHaveKey(m_mainDict, @"backgroundImg") Width:320*2 Height:320*2];
            }
            [m_myTableView reloadData];
            
            NSString * authStr = KISDictionaryHaveKey(responseObject, @"state");
            
            [[NSUserDefaults standardUserDefaults]setObject:responseObject forKey:[NSString stringWithFormat:@"%@_group",self.groupId]];
            
            NSMutableArray *arr = KISDictionaryHaveKey(responseObject, @"memberList");
            [arr insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"wxxxx",@"img", nil] atIndex:0];
            
                [self buildmemberisAudit:authStr title:[NSString stringWithFormat:@"%@/%@",KISDictionaryHaveKey(responseObject, @"currentMemberNum"),KISDictionaryHaveKey(responseObject, @"maxMemberNum")] num:[GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"rank")] imgArray:arr];
            
            
            
            NSString *identity = KISDictionaryHaveKey( responseObject, @"groupUsershipType");
            
            self.shiptypeCount = [identity intValue];
            
            if ([authStr intValue]==0||[authStr intValue]==3) {
                NSArray *array = @[@"chexiaogroup"];
                [self buildbelowbutotnWithArray:array shiptype:2];
  
            }else{
                if ([identity intValue]==0) {//群主
                    NSArray *array = @[@"sendMsg_normal",@"team_edit"];
                    [self buildbelowbutotnWithArray:array shiptype:1];
                }
                else if ([identity intValue]==1) {//管理员
                    NSArray *array = @[@"sendMsg_normal",@"team_edit"];
                    [self buildbelowbutotnWithArray:array shiptype:1];
                }
                else if ([identity intValue]==2) {//普通成员
                    NSArray *array = @[@"sendMsg_normal",@"team_edit"];
                    [self buildbelowbutotnWithArray:array shiptype:1];
                    
                }else{//陌生人
                    NSArray *array = @[@"joinIn"];
                    [self buildbelowbutotnWithArray:array shiptype:1];
                    
                }

            }
            
            
        }
        
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

-(void)chexiaogroup
{
    hud.labelText = @"处理中...";
    [hud show:YES];
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.groupId forKey:@"groupId"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"251" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshMyGroupList" object:nil];
        [DataStoreManager deleteGroupMsgWithSenderAndSayType:self.groupId];//删除聊天记录
        [DataStoreManager deleteGroupInfoByGoupId:self.groupId];//删除群信息
        [self showMessageWindowWithContent:@"取消成功" imageType:0];
        [self.navigationController popViewControllerAnimated:YES];
        
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                alertView_1 = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alertView_1.tag = 789;
                [alertView_1 show];
            }
        }
        [hud hide:YES];
    }];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 789)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag == 777)
    {
        if (buttonIndex ==1) {
            [self chexiaogroup];
        }
    }
    else if (alertView.tag == 1111)
    {
        switch (buttonIndex) {
            case 1:
                [self copyNum:nil];
                break;
            case 2:
                [self seeLv:nil];
                break;
                
            default:
                break;
        }
        
    }
    
 }


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![GameCommon isEmtity:KISDictionaryHaveKey(m_mainDict, @"guild")]) {
        return 6;
    }
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (![GameCommon isEmtity:KISDictionaryHaveKey(m_mainDict, @"guild")]) {
        if (indexPath.row ==0) {
            static NSString *cellinde2 = @"cell2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde2];
            if (cell ==nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde2];
            }
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 20)];
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:titleLabel];
            
            titleLabel.text = @"群组号";
            
            UILabel *numLb = [[UILabel alloc]initWithFrame:CGRectMake(80, 0,70, 40)];
            numLb.font = [UIFont boldSystemFontOfSize:14];
            numLb.backgroundColor = [UIColor clearColor];
            numLb.textColor =[ UIColor blackColor];
            numLb.text = KISDictionaryHaveKey(m_mainDict, @"groupId");
            [cell addSubview:numLb];
            
            UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(250, 5, 40, 30)];
            imageView.image = KUIImage(@"lv_group");
            [cell addSubview:imageView];
            
            UILabel *lvLb =[[ UILabel alloc]initWithFrame:CGRectMake(250, 5, 40, 30)];
            lvLb.font = [UIFont boldSystemFontOfSize:11];
            lvLb.backgroundColor = [UIColor clearColor];
            lvLb.textColor =[ UIColor whiteColor];
            lvLb.textAlignment = NSTextAlignmentCenter;
            lvLb.text = KISDictionaryHaveKey(m_mainDict, @"level");
            [cell addSubview:lvLb];
            
            return cell;
            
        }
        else if(indexPath.row ==1){
            static NSString *cellinde2 = @"cell002";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde2];
            if (cell ==nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde2];
            }
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 80, 20)];
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.text = @"智能邀请";
            [cell addSubview:titleLabel];
            
            UILabel *numLb = [[UILabel alloc]initWithFrame:CGRectMake(80, 10,210, 20)];
            numLb.font = [UIFont systemFontOfSize:14];
            numLb.backgroundColor = [UIColor clearColor];
            numLb.textColor =[ UIColor blueColor];
            numLb.text = @"您可以立即邀请您游戏中的好友";
            [cell addSubview:numLb];
            return cell;
        }
        else if (indexPath.row ==2) {
            static NSString *cellinde = @"cell1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
            if (cell ==nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
            }
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 20)]
            ;
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:titleLabel];
            titleLabel.text = @"服务器";
            
            EGOImageView *gameImg =[[EGOImageView alloc]initWithFrame:CGRectMake(80, 10, 20, 20)];
            NSString * gameImageId = [GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(m_mainDict, @"gameid")];
            gameImg.imageURL = [ImageService getImageUrl4:gameImageId];
            [cell addSubview:gameImg];
            
            
            UILabel *numLb = [[UILabel alloc]initWithFrame:CGRectMake(110, 0,100, 40)];
            numLb.font = [UIFont boldSystemFontOfSize:14];
            numLb.backgroundColor = [UIColor clearColor];
            numLb.textColor =[ UIColor blackColor];
            numLb.text = KISDictionaryHaveKey(m_mainDict, @"gameRealm");
            [cell addSubview:numLb];
            return cell;
        }
        else if (indexPath.row ==3)
        {
            static NSString *cellinde = @"cell0";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
            if (cell ==nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
            }
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 50, 20)]
            ;
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:titleLabel];
            
            titleLabel.text = @"群分类";
            if (m_mainDict &&[m_mainDict allKeys].count>0) {
                NSArray *tags = KISDictionaryHaveKey(m_mainDict, @"tags");
                
                NSArray * us=cell.contentView.subviews;
                for(UIView *uv in us)
                {
                    if ([uv isKindOfClass:[UIImageView class]]) {
                        [uv removeFromSuperview];
                    }
                }
                for (int i =0; i<tags.count; i++) {
                    UIImageView * tagImage = [self buildImgVWithframe:CGRectMake(80+(i%2)*88+5*(i%2)-5,10+(i/2)*30+5*(i/2),88,30) title:KISDictionaryHaveKey(tags[i], @"tagName")];
                    tagImage.tag=100+i;
                    tagImage.userInteractionEnabled = YES;
                    [tagImage addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterSearchGroupPage:)]];
                    [cell.contentView addSubview:tagImage];
                }
            }
            return cell;
            
        }
        else if (indexPath.row ==4)
        {
            static NSString *cellinde3 = @"cell3";
            GroupInfomationJsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde3];
            if (cell ==nil) {
                cell = [[GroupInfomationJsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde3];
            }
            cell.myCellDelegate = self;
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
            
            if (m_mainDict&&[m_mainDict allKeys].count>0) {
                cell.titleLabel.text = @"群介绍";
                cell.contentLabel.text = KISDictionaryHaveKey(m_mainDict, @"info");
                
                CGSize sizeThatFits = [cell.contentLabel sizeThatFits:CGSizeMake(245, MAXFLOAT)];
                float height1= sizeThatFits.height;
                cell.contentLabel.frame = CGRectMake(80, 10, 210, height1);
                
                
                cell.photoArray =[ImageService getImageIds:KISDictionaryHaveKey(m_mainDict, @"infoImg")];
                if (cell.photoArray.count==0) {
                    cell.photoView.frame =  CGRectMake(80, height1+10+5, 210, 0);
                }else{
                    NSInteger photoCount = (cell.photoArray.count-1)/3+1;
                    cell.photoView.frame =  CGRectMake(80, height1+10+5, 210, photoCount*68+photoCount*2);
                }
            }
            return cell;
        }
        else
        {
            static NSString *cellinde4 = @"cell4";
            CreateTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde4];
            if (cell ==nil) {
                cell = [[CreateTimeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde4];
            }
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
            cell.timeLabel.text = [NSString stringWithFormat:@"%@ , %@",[self getDataWithTimeInterval:[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(m_mainDict, @"createDate")]],[self getLocation:KISDictionaryHaveKey(m_mainDict, @"location")]];
            cell.distance.text = [self getDist:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"distance")]];
            
            return cell;
        }
    }
    else{
        if (indexPath.row ==0) {
            static NSString *cellinde2 = @"cell2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde2];
            if (cell ==nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde2];
            }
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 20)];
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:titleLabel];
            
            titleLabel.text = @"群组号";
            
            UILabel *numLb = [[UILabel alloc]initWithFrame:CGRectMake(80, 0,70, 40)];
            numLb.font = [UIFont boldSystemFontOfSize:14];
            numLb.backgroundColor = [UIColor clearColor];
            numLb.textColor =[ UIColor blackColor];
            numLb.text = KISDictionaryHaveKey(m_mainDict, @"groupId");
            [cell addSubview:numLb];
            
            UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(250, 5, 40, 30)];
            imageView.image = KUIImage(@"lv_group");
            [cell addSubview:imageView];
            
            UILabel *lvLb =[[ UILabel alloc]initWithFrame:CGRectMake(250, 5, 40, 30)];
            lvLb.font = [UIFont boldSystemFontOfSize:11];
            lvLb.backgroundColor = [UIColor clearColor];
            lvLb.textColor =[ UIColor whiteColor];
            lvLb.textAlignment = NSTextAlignmentCenter;
            lvLb.text = KISDictionaryHaveKey(m_mainDict, @"level");
            [cell addSubview:lvLb];
            
            return cell;
            
        }
        else if (indexPath.row ==1) {
            static NSString *cellinde = @"cell1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
            if (cell ==nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
            }
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 20)]
            ;
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:titleLabel];
            titleLabel.text = @"服务器";
            
            EGOImageView *gameImg =[[EGOImageView alloc]initWithFrame:CGRectMake(80, 10, 20, 20)];
            NSString * gameImageId = [GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(m_mainDict, @"gameid")];
            gameImg.imageURL = [ImageService getImageUrl4:gameImageId];
            [cell addSubview:gameImg];
            
            
            UILabel *numLb = [[UILabel alloc]initWithFrame:CGRectMake(110, 0,100, 40)];
            numLb.font = [UIFont boldSystemFontOfSize:14];
            numLb.backgroundColor = [UIColor clearColor];
            numLb.textColor =[ UIColor blackColor];
            numLb.text = KISDictionaryHaveKey(m_mainDict, @"gameRealm");
            [cell addSubview:numLb];
            return cell;
        }
        else if (indexPath.row ==2)
        {
            static NSString *cellinde = @"cell0";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
            if (cell ==nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
            }
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 50, 20)]
            ;
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:titleLabel];
            
            titleLabel.text = @"群分类";
            if (m_mainDict &&[m_mainDict allKeys].count>0) {
                NSArray *tags = KISDictionaryHaveKey(m_mainDict, @"tags");
                
                NSArray * us=cell.contentView.subviews;
                for(UIView *uv in us)
                {
                    if ([uv isKindOfClass:[UIImageView class]]) {
                        [uv removeFromSuperview];
                    }
                }
                for (int i =0; i<tags.count; i++) {
                    UIImageView * tagImage = [self buildImgVWithframe:CGRectMake(80+(i%2)*88+5*(i%2)-5,10+(i/2)*30+5*(i/2),88,30) title:KISDictionaryHaveKey(tags[i], @"tagName")];
                    tagImage.tag=100+i;
                    tagImage.userInteractionEnabled = YES;
                    [tagImage addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterSearchGroupPage:)]];
                    [cell.contentView addSubview:tagImage];
                }
            }
            return cell;
            
        }
        else if (indexPath.row ==3)
        {
            static NSString *cellinde3 = @"cell3";
            GroupInfomationJsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde3];
            if (cell ==nil) {
                cell = [[GroupInfomationJsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde3];
            }
            cell.myCellDelegate = self;
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
            
            if (m_mainDict&&[m_mainDict allKeys].count>0) {
                cell.titleLabel.text = @"群介绍";
                cell.contentLabel.text = KISDictionaryHaveKey(m_mainDict, @"info");
                
                CGSize sizeThatFits = [cell.contentLabel.text sizeWithFont:cell.contentLabel.font constrainedToSize:CGSizeMake(230, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
                float height1= sizeThatFits.height;
                cell.contentLabel.frame = CGRectMake(80, 10, 230, height1);
                
                cell.photoArray =[ImageService getImageIds:KISDictionaryHaveKey(m_mainDict, @"infoImg")];
                if (cell.photoArray.count==0) {
                    cell.photoView.frame =  CGRectMake(80, height1+10+5, 210, 0);
                }else{
                    NSInteger photoCount = (cell.photoArray.count-1)/3+1;
                    cell.photoView.frame =  CGRectMake(80, height1+10+5, 210, photoCount*68+photoCount*2);
                }
            }
            return cell;
        }
        else
        {
            static NSString *cellinde4 = @"cell4";
            CreateTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde4];
            if (cell ==nil) {
                cell = [[CreateTimeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde4];
            }
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
            cell.timeLabel.text = [NSString stringWithFormat:@"%@ , %@",[self getDataWithTimeInterval:[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(m_mainDict, @"createDate")]],[self getLocation:KISDictionaryHaveKey(m_mainDict, @"location")]];
            cell.distance.text = [self getDist:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"distance")]];
            return cell;
        }
    }
}

//location
-(NSString*)getLocation:(NSString*)location
{
    if ([GameCommon isEmtity:location]) {
        return @"未知";
    }
    return location;
}

//距离
- (NSString*)getDist:(NSString*)distrance
{
    double dis = [distrance doubleValue];
    double gongLi = dis/1000;
    if (gongLi < 0 || gongLi == 9999) {
        return @"未知";
    }
    return [NSString stringWithFormat:@"%.2fkm", gongLi];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        saobaoAction = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"复制群号",@"查看组织等级", nil];
        saobaoAction.tag = 1111;
        [saobaoAction show];
    }
    if(![GameCommon isEmtity:KISDictionaryHaveKey(m_mainDict, @"guild")] ){
        if (indexPath.row ==1) {
            GuildMembersViewController *guildMember = [[GuildMembersViewController alloc]init];
            guildMember.guildStr = KISDictionaryHaveKey(m_mainDict, @"guild");
            guildMember.realmStr = KISDictionaryHaveKey(m_mainDict, @"gameRealm");
            guildMember.gameidStr = KISDictionaryHaveKey(m_mainDict, @"gameid");
            [self.navigationController pushViewController:guildMember animated:YES];
        }else if (indexPath.row==2){
            SearchGroupViewController *groupView = [[SearchGroupViewController alloc]init];
            groupView.ComeType =SETUP_SAMEREALM;
            groupView.gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"gameid")];
            groupView.realmStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"gameRealm")];
            groupView.titleName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"gameRealm")];
            [self.navigationController pushViewController:groupView animated:YES];
        }
    }else{
        if (indexPath.row==1) {
            SearchGroupViewController *groupView = [[SearchGroupViewController alloc]init];
            groupView.ComeType =SETUP_SAMEREALM;
            groupView.gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"gameid")];
            groupView.realmStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"gameRealm")] ;
            groupView.titleName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"gameRealm")];
            [self.navigationController pushViewController:groupView animated:YES];
        }
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self copyNum:nil];
            break;
        case 1:
            [self seeLv:nil];
            break;
            
        default:
            break;
    }
}

-(void)copyNum:(id)sender
{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [m_mainDict objectForKey:@"groupId"];
    [self showMessageWindowWithContent:@"复制成功" imageType:0];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *tags = KISDictionaryHaveKey(m_mainDict, @"tags");
        NSArray * photoArray =[ImageService getImageIds2:KISDictionaryHaveKey(m_mainDict, @"infoImg") Width:160];
        if (![GameCommon isEmtity:KISDictionaryHaveKey(m_mainDict, @"guild")]) {
            switch (indexPath.row) {
                case 0:
                    return 40;
                    break;
                case 1:
                    return 40;
                    break;
                case 2:
                    return 40;
                    break;
                case 3:{
                    if (tags&&[tags isKindOfClass:[NSArray class]]&&tags.count>0) {
                        NSLog(@"--------%d",tags.count/2);
                        if (tags.count==0) {
                            return 10;
                        }else{
                            NSInteger tagsRowCount = (tags.count-1)/2+1;//标签行数
                            return  tagsRowCount*30+tagsRowCount*5+10;
                        }
                    }
                    else{
                        return 40;
                    }
                }
                   
                    break;
                case 4:
                {
                    GroupInfomationJsCell *cell = (GroupInfomationJsCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
                    float heigth = cell.contentLabel.frame.size.height;
                    if (heigth<20) {
                        heigth =20;
                    }
                    if (!photoArray||photoArray.count==0) {
                        return heigth+20;
                    }else{
                        NSInteger photoCount = (photoArray.count-1)/3+1;//图片行数
                        return photoCount*68+photoCount*2+heigth+10+10;
                    }
                }
                    break;
                default:
                    return 40;
                    break;
            }
        }else{
            switch (indexPath.row) {
                case 0:
                    return 40;
                    break;
                case 1:
                    return 40;
                    break;
                case 2:
                {
                    if (tags&&[tags isKindOfClass:[NSArray class]]&&tags.count>0) {
                        NSLog(@"--------%d",tags.count/2);
                        if (tags.count==0) {
                            return 10;
                        }else{
                            NSInteger tagsRowCount = (tags.count-1)/2+1;//标签行数
                            return  tagsRowCount*30+tagsRowCount*5+10;
                        }
                    }
                    else{
                        return 40;
                    }
                }
                    break;
                case 3:
                {
                    GroupInfomationJsCell *cell = (GroupInfomationJsCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
                    float heigth = cell.contentLabel.frame.size.height;
                    if (heigth<20) {
                        heigth =20;
                    }
                    if (!photoArray||photoArray.count==0) {
                        return heigth+20;
                    }else{
                        NSInteger photoCount = (photoArray.count-1)/3+1;//图片行数
                        return photoCount*68+photoCount*2+heigth+10+10;
                    }
                }
                    break;
                default:
                    return 40;
                    break;
            }
        }
}


-(UIImageView*)buildImgVWithframe:(CGRect)frame title:(NSString *)title
{
    UIImageView *imgV =[[ UIImageView alloc]initWithFrame:frame];
    imgV.image = KUIImage(@"card_show");
    imgV.userInteractionEnabled = YES;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];

    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textColor = [UIColor blueColor];
    label.backgroundColor = [UIColor clearColor];
    
    label.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.7];
    label.shadowOffset = CGSizeMake(.7f, 1.0f);

    label.text = title;
    [imgV addSubview:label];
    [imgV bringSubviewToFront:label];
    NSLog(@"%@",title);
    return imgV;
}

-(CGSize)getStringSizeWithString:(NSString *)str font:(UIFont *)font
{
    CGSize size = [str sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
    return size;
}


#pragma mark =====查看等级
-(void)seeLv:(id)sender
{
    GroupLeaveViewController *gl = [[GroupLeaveViewController alloc]init];
    gl.groupId = self.groupId;
    [self.navigationController pushViewController:gl animated:YES];
}
- (void)bigImgWithCircle:(GroupInfomationJsCell*)myCell WithIndexPath:(NSInteger)row
{
    NSLog(@"点击查看大图");
    PhotoViewController * pV = [[PhotoViewController alloc] initWithSmallImages:nil images:[ImageService getImageIds:KISDictionaryHaveKey(m_mainDict, @"infoImg")] indext:row];
    [self presentViewController:pV animated:NO completion:^{
    }];
    
}

#pragma mark ---点击标签 进入搜索页面
-(void)enterSearchGroupPage:(UIGestureRecognizer *)sender
{
    NSArray *tags = [m_mainDict objectForKey:@"tags"];
    SearchGroupViewController *groupView = [[SearchGroupViewController alloc]init];
    groupView.ComeType = SETUP_Tags;
    groupView.tagsId =KISDictionaryHaveKey(tags[sender.view.tag-100], @"tagId");
    groupView.titleName = KISDictionaryHaveKey(tags[sender.view.tag-100], @"tagName");
    [self.navigationController pushViewController:groupView animated:YES];
}

-(void)enterAddMembersPage:(id)sender
{
    NewInvitationViewController *inv = [[NewInvitationViewController alloc]init];
    inv.groupId = self.groupId;
    inv.realmStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"gameRealm")];
    [self.navigationController pushViewController:inv animated:YES];
}
- (NSString*)getDataWithTimeInterval:(NSString*)timeInterval
{
    if ([NSString stringWithFormat:@"%.f", [timeInterval doubleValue]].length < 10) {
        return timeInterval;
    }
    NSString* timeStr = [timeInterval substringToIndex:timeInterval.length-3];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];//location设置为中国
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    double time = [timeStr doubleValue];
    NSLog(@"%@", [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]]);
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

- (void)dealloc
{
    alertView_1.delegate = nil;
    chexiaoAlert.delegate = nil;
    saobaoAction.delegate =nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
