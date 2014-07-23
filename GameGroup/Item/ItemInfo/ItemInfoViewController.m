//
//  ItemInfoViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ItemInfoViewController.h"
#import "ItemInfoCell.h"
#import "TestViewController.h"
#import "ItemRoleButton.h"
#import "EditInfoViewController.h"
#import "ReviewapplicationViewController.h"
#import "InvitationMembersViewController.h"
@interface ItemInfoViewController ()
{
    UITableView *m_myTableView;
    NSMutableDictionary *m_mainDict;
    NSMutableArray *m_dataArray;
    BOOL isJoinIn;
    ItemRoleButton *itemRoleBtn;
    RoleTabView *roleTabView;
    UIAlertView *jiesanAlert;
    UIButton *m_getOutBtn;
}
@end

@implementation ItemInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"队伍详情" withBackButton:YES];
    
    m_getOutBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    
    if (self.isCaptain) {
        [m_getOutBtn setTitle:@"解散" forState:UIControlStateNormal];
    }else{
        [m_getOutBtn setTitle:@"退出" forState:UIControlStateNormal];
    }
    
    
//    [createBtn setBackgroundImage:KUIImage(@"createGroup_normal") forState:UIControlStateNormal];
//    [createBtn setBackgroundImage:KUIImage(@"createGroup_click") forState:UIControlStateHighlighted];
    m_getOutBtn.backgroundColor = [UIColor clearColor];
    [m_getOutBtn addTarget:self action:@selector(didClickShareItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_getOutBtn];

    isJoinIn = YES;
    
    m_mainDict = [NSMutableDictionary dictionary];
    m_dataArray = [NSMutableArray array];
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth-startX-50)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [GameCommon setExtraCellLineHidden:m_myTableView];
    [self.view addSubview:m_myTableView];
    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    
    
    [self GETInfoWithNet];
    [self buildRoleView];

    roleTabView = [[RoleTabView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    roleTabView.mydelegate  =self;
    roleTabView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:.5];
    roleTabView.roleTableView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:.5];
    roleTabView.coreArray =  [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    roleTabView.hidden = YES;
    [self.view addSubview:roleTabView];
    [roleTabView.roleTableView reloadData];
    // Do any additional setup after loading the view.
}

-(void)buildRoleView
{
    itemRoleBtn =[[ItemRoleButton alloc]initWithFrame:CGRectMake(85, kScreenHeigth-startX -50-(KISHighVersion_7?0:20), 150, 35)];
    itemRoleBtn.hidden = YES;
    itemRoleBtn.backgroundColor = [UIColor blackColor];
    itemRoleBtn.headImageV.imageURL = [ImageService getImageStr2:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"img")]];
    itemRoleBtn.nameLabel.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"name")];
    itemRoleBtn.distLabel.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"realm")];
    [itemRoleBtn addTarget:self action:@selector(showRoleTableView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:itemRoleBtn];
}
-(void)showRoleTableView:(id)sender
{
    itemRoleBtn.hidden = YES;
    roleTabView.hidden= NO;
    [self.view bringSubviewToFront:roleTabView];
}

#pragma mark --分享组队
-(void)didClickShareItem:(id)sender
{
//    ReviewapplicationViewController *review = [[ReviewapplicationViewController alloc]init];
//    [self.navigationController pushViewController:review animated:YES];
    if (self.isCaptain) {
        jiesanAlert =[[ UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要解散队伍吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"必须解散", nil];
        jiesanAlert.tag = 10000001;
        [jiesanAlert show];
  
    }else{
        jiesanAlert =[[ UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要退出该队伍吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"必须退出", nil];
        jiesanAlert.tag =10000002;
        [jiesanAlert show];

    }

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==10000001) {
        if (buttonIndex==1) {
            
            NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
            NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
            
            [paramDict setObject:self.itemId forKey:@"roomId"];
            [paramDict setObject:self.gameid forKey:@"gameid"];
            [postDict setObject:paramDict forKey:@"params"];
            
            [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
            [postDict setObject:@"270" forKey:@"method"];
            [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
            [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTeamList_wx" object:nil];
                
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self showMessageWindowWithContent:@"解散成功" imageType:1];
                
                
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

    }else{
        if (buttonIndex==1) {
            NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
            NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
            
            [paramDict setObject:self.itemId forKey:@"roomId"];
            [paramDict setObject:self.gameid forKey:@"gameid"];
            NSString *userid = [GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
            [paramDict setObject:userid forKey:@"userid"];
            [postDict setObject:paramDict forKey:@"params"];
            
            [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
            [postDict setObject:@"269" forKey:@"method"];
            [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
            [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTeamList_wx" object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self showMessageWindowWithContent:@"退出成功" imageType:1];
                
                
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
    }
}

#pragma mark ---创建底部button
-(void)buildbelowbutotnWithArray:(NSArray *)array  shiptype:(NSInteger)shiptype
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 320, 50)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    float width = 320/array.count;
    for (int i = 0; i<array.count; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(width*i, 0, width, 50)];
        [button setImage:KUIImage(array[i]) forState:UIControlStateNormal];
        button.tag = i+100+shiptype*10;
        if (shiptype ==0) {
            [button addTarget:self action:@selector(EditItem:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (shiptype ==1)
        {
            [button addTarget:self action:@selector(members:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if(shiptype ==2){
            [button addTarget:self action:@selector(joinInItem:) forControlEvents:UIControlEventTouchUpInside];
        }
        [view addSubview:button];
    }
    [self.view addSubview:view];
}


-(void)EditItem:(UIButton *)sender
{
    if (sender.tag ==100)
    {
        [self showMessageWindowWithContent:@"发消息" imageType:0];
    }
    else if(sender.tag ==101)
    {
        InvitationMembersViewController *editInfo = [[InvitationMembersViewController alloc]init];
        editInfo.roomId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"roomId")];
        editInfo.gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(m_mainDict, @"createTeamUser"), @"gameid")];
//        editInfo.firstStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"description")];
//        editInfo.secondStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"teamInfo")];
        [self.navigationController pushViewController:editInfo animated:YES];
   
    }
}
-(void)members:(UIButton *)sender
{
    if (sender.tag ==110)
    {
        [self showMessageWindowWithContent:@"发消息" imageType:0];
   
    }
    else if(sender.tag ==111)
    {
//        [self showMessageWindowWithContent:@"退出群" imageType:0];
        [self gooutRoomWithNet];
    }
}


-(void)joinInItem:(UIButton *)sender
{
    sender = (UIButton *)[self.view viewWithTag:120];
    if (isJoinIn==YES) {
        itemRoleBtn.hidden =NO;
        [self.view bringSubviewToFront:itemRoleBtn];
        [sender setBackgroundImage:KUIImage(@"realy_item") forState:UIControlStateNormal];
        isJoinIn =NO;

    }else{
        [self JoinInThisItemWithNet];
//        [self showMessageWindowWithContent:@"现在申请不了" imageType:0];
    }
}

/*typeName  teamInfo options type1-->创建者  Value1 第一行 value2 第二行  */
#pragma mark ---NET
-(void)GETInfoWithNet
{
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:self.itemId] forKey:@"roomId"];
    [paramDict setObject:[GameCommon getNewStringWithId:self.gameid] forKey:@"gameid"];

    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"266" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            m_mainDict = responseObject;
            
            
            [DataStoreManager saveTeamInfoWithDict:responseObject];
            
            NSString *teamUsershipType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"teamUsershipType")];
            NSArray *arr = [NSArray array] ;
            if ([teamUsershipType intValue]==0) {
                arr = @[@"sendMsg_normal.jpg",@"groupEdit"];
                m_getOutBtn.hidden = NO;
            }
            else if([teamUsershipType intValue]==1)
            {
                arr = @[@"sendMsg_normal.jpg",@"goout_item"];
                m_getOutBtn.hidden = NO;
            }
            else
            {
                m_getOutBtn.hidden = YES;
                arr = @[@"joinInBtn_Item"];
            }
            [self buildbelowbutotnWithArray:arr shiptype:[teamUsershipType intValue]];
            [m_dataArray removeAllObjects];
            [m_dataArray addObjectsFromArray:KISDictionaryHaveKey(m_mainDict, @"memberList")];
            [m_myTableView reloadData];
        }
        
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

#pragma mark ----tableview delegate  datasourse

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indifience = @"cell";
    ItemInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
    if (!cell) {
        cell = [[ItemInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }
    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    
    cell.headImageView.placeholderImage = KUIImage(@"placeholder");
    NSString *imageids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"img")];
    cell.headImageView.imageURL =[ImageService getImageStr2:imageids] ;
    
    cell.nickLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"nickname")];
    [cell refreshViewFrameWithText:cell.nickLabel.text];
    
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gender")] isEqualToString:@"0"]) {//男♀♂
        
        cell.genderImgView.image = KUIImage(@"gender_boy");
        cell.headImageView.placeholderImage = [UIImage imageNamed:@"people_man.png"];
    }
    else
    {
        cell.genderImgView.image = KUIImage(@"gender_girl");
        cell.headImageView.placeholderImage = [UIImage imageNamed:@"people_woman.png"];
    }
    
    
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]isEqualToString:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(m_mainDict, @"createTeamUser"), @"userid")]]) {
        cell.MemberImgView.backgroundColor = [UIColor redColor];
    }else{
        cell.MemberImgView.backgroundColor = [UIColor greenColor];
    }
    
    NSString * gameImageId = [GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")];
    cell.gameIconImgView.imageURL = [ImageService getImageUrl4:gameImageId];

    cell.value1Lb.text = [NSString stringWithFormat:@"%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"teamUser"), @"realm")]/*,[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"teamUser"), @"memberInfo")]*/];
    cell.value2Lb.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"teamUser"), @"memberInfo")];
    cell.value3Lb.text = [GameCommon getNewStringWithId: KISDictionaryHaveKey(dic, @"position")];

//    cell.timeLabel.text = [NSString stringWithFormat:@"%@|%@",timeStr,personStr];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    
    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")];
    NSString *nickName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"nickname")];
    
    
    TestViewController *itemInfo = [[TestViewController alloc]init];
    if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        itemInfo.viewType = VIEW_TYPE_Self1;
    }
    itemInfo.userId = userid;
    itemInfo.nickName = nickName;
    [self.navigationController pushViewController:itemInfo animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 127)];
    view.backgroundColor = UIColorFromRGBA(0x6f7478, 1);
    
    UIView *view1 =  [self buildViewWithFrame:CGRectMake(0, 26, 320, 50)backgroundColor:[UIColor colorWithRed:92/255.0f green:96/255.0f blue:99/255.0f alpha:1] leftImg:@"item_list1" title:KISDictionaryHaveKey(m_mainDict, @"description")];
    [view addSubview:view1];
    
    UIView *view2 = [self buildViewWithFrame:CGRectMake(0, 77, 320, 50)backgroundColor:[UIColor colorWithRed:92/255.0f green:96/255.0f blue:99/255.0f alpha:1]  leftImg:@"item_list2" title:KISDictionaryHaveKey(m_mainDict, @"teamInfo")];
    
    [view1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeInfo1)]];
    [view2 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeInfo2)]];
    
    UIView *view3 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 25)];
    view3.backgroundColor =UIColorFromRGBA(0x43474a, 1);
    UILabel *lb1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
    lb1.backgroundColor =[ UIColor clearColor];
    lb1.textColor = [UIColor whiteColor];
    lb1.font = [UIFont boldSystemFontOfSize:14];
    
    if ([[m_mainDict allKeys]containsObject:@"type"]) {
        lb1.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(m_mainDict, @"type"), @"value")];
    }else{
        lb1.text = @"";
    }
    
    lb1.textAlignment = NSTextAlignmentCenter;
    [view3 addSubview:lb1];
    
    NSString *timeStr = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"createDate")]];
    NSString *lb2Str = [NSString stringWithFormat:@"%@| %@/%@人",timeStr,[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"memberCount")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"maxVol")]];
    
    UILabel *lb2 = [[UILabel alloc]initWithFrame:CGRectMake(200, 0, 110, 25)];
    lb2.backgroundColor =[ UIColor clearColor];
    lb2.textColor = [UIColor whiteColor];
    lb2.font = [UIFont boldSystemFontOfSize:14];
    lb2.text = lb2Str;
    lb2.textAlignment = NSTextAlignmentCenter;
    [view3 addSubview:lb2];
    
    [view addSubview:view3];
    [view addSubview:view2];
    return view;
}
-(void)changeInfo1
{
    EditInfoViewController *editInfo = [[EditInfoViewController alloc]init];
    editInfo.itemId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"roomId")];
    editInfo.firstStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"description")];
//    editInfo.secondStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"teamInfo")];
    editInfo.isStyle = YES;
    [self.navigationController pushViewController:editInfo animated:YES];

}
-(void)changeInfo2
{
    EditInfoViewController *editInfo = [[EditInfoViewController alloc]init];
    editInfo.itemId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"roomId")];
//    editInfo.firstStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"description")];
    editInfo.secondStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"options")];
    editInfo.isStyle = NO;
    [self.navigationController pushViewController:editInfo animated:YES];

}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *itemShipType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"teamUsershipType")] ;
  if([itemShipType intValue] ==0)
  {
      return YES;
  }else{
      return NO;
  }
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        
        [self removeItemerFromNetWithIndexPath:indexPath.row];
    }
}
#pragma mark ---删除成员
-(void)removeItemerFromNetWithIndexPath:(NSInteger)row
{
    NSDictionary *dic = m_dataArray[row];
    
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]isEqualToString:[GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]]) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = @"您不能踢出自己,如果想撤销队伍,点击择队伍设置,进入设置页面后解散队伍";
        [hud show:YES];
        [hud hide:YES afterDelay:2];
        return;
    }
    
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")] forKey:@"roomId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberId")] forKey:@"memberId"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"268" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [m_dataArray removeObjectAtIndex:row];
        [m_myTableView reloadData];
        
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

//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 70)];
//    view.backgroundColor = [UIColor whiteColor];
//    UIButton *Button = [[UIButton alloc]initWithFrame:CGRectMake(10, 30, 300, 40)];
//    Button.backgroundColor = [UIColor grayColor];
//    if (self.isCaptain) {
//        [Button setTitle:@"解散队伍" forState:UIControlStateNormal];
//    }else{
//        [Button setTitle:@"申请加入" forState:UIControlStateNormal];
//    }
//    [view addSubview:Button];
//    return view;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 127;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 70;
//}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(UIView *)buildViewWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor leftImg:(NSString *)leftImg title:(NSString *)title
{
    UIView *customView = [[UIView alloc]initWithFrame:frame];
    customView.backgroundColor =backgroundColor;
    
    UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    imageView.image = KUIImage(leftImg);
    [customView addSubview:imageView];
    
//    UILabel *titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(35, 0, 100, 40) font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
//    titleLabel.text = title;
//    [customView addSubview:titleLabel];
    
    UILabel *titleLabel1 = [GameCommon buildLabelinitWithFrame:CGRectMake(50, 0, 260, 50) font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
    titleLabel1.text = title;
    titleLabel1.numberOfLines = 0;
    titleLabel1.adjustsFontSizeToFitWidth = YES;
    [customView addSubview:titleLabel1];
    
    return customView;
}
-(void)didClickChooseWithView:(RoleTabView*)view info:(NSDictionary *)info
{
    itemRoleBtn.hidden = NO;
    roleTabView.hidden = YES;
    self.infoDict = [NSMutableDictionary dictionaryWithDictionary:info];
    itemRoleBtn.headImageV.imageURL = [ImageService getImageStr2:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"img")]];
    itemRoleBtn.nameLabel.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"name")];
    itemRoleBtn.distLabel.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"realm")];

}

-(void)JoinInThisItemWithNet
{
    
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:self.itemId] forKey:@"roomId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"id")] forKey:@"characterId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"gameid")] forKey:@"gameid"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"267" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self showMessageWindowWithContent:@"申请成功" imageType:0];
        
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
-(void)gooutRoomWithNet
{
    
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:self.itemId] forKey:@"roomId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"myMemberId")] forKey:@"memberId"];
    
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"269" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self showMessageWindowWithContent:@"退出成功" imageType:0];
        [self.navigationController popViewControllerAnimated:YES];
        
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
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
