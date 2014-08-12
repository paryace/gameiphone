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
#import "ReviewapplicationViewController.h"
#import "InvitationMembersViewController.h"
#import "KKChatController.h"
#import "H5CharacterDetailsViewController.h"
#import "CharacterDetailsViewController.h"

#import "BottomView.h"
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
    BottomView *bView;
    UIAlertView * backAlert;
    NSString *descriptionStr;
}
@end

@implementation ItemInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
//teamUsershipType 组队关系:0房主，1队员，2陌生人
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"队伍详情" withBackButton:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changPosition:) name:kChangPosition object:nil];//位置改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changMemberList:) name:kChangMemberList object:nil];//组队成员变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teamMemberCountChang:) name:UpdateTeamMemberCount object:nil];//组队人数字变化
    
    
    
    
    m_getOutBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    m_getOutBtn.backgroundColor = [UIColor clearColor];
    [m_getOutBtn addTarget:self action:@selector(didClickShareItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_getOutBtn];
    [self setRightBtn];
    
    isJoinIn = YES;
    m_mainDict = [NSMutableDictionary dictionary];
    m_dataArray = [NSMutableArray array];
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth-startX-50)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [GameCommon setExtraCellLineHidden:m_myTableView];
    [self.view addSubview:m_myTableView];
    
    

    roleTabView = [[RoleTabView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];

    roleTabView.mydelegate  =self;
    roleTabView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:.5];
    roleTabView.roleTableView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:.7];

    roleTabView.hidden = YES;
    roleTabView.mydelegate  =self;
    NSMutableArray *coreArray =  [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    [self.view addSubview:roleTabView];
    [roleTabView setDate:coreArray];
    hud  = [[MBProgressHUD alloc]initWithView:self.view];
    hud.labelText = @"获取中...";
    [self.view addSubview:hud];
    [self GETInfoWithNet:NO];
}

-(void)setRightBtn
{
    if (self.isCaptain) {
        [m_getOutBtn setTitle:@"解散" forState:UIControlStateNormal];
    }else{
        [m_getOutBtn setTitle:@"退出" forState:UIControlStateNormal];
    }
}

-(void)buildRoleView
{
    
    NSDictionary *dic = roleTabView.coreArray[0];
    self.infoDict = roleTabView.coreArray[0];
    itemRoleBtn =[[ItemRoleButton alloc]initWithFrame:CGRectMake(85, kScreenHeigth-startX -50-(KISHighVersion_7?0:20), 150, 35)];
    itemRoleBtn.hidden = YES;
    itemRoleBtn.backgroundColor = [UIColor blackColor];
    itemRoleBtn.headImageV.imageURL = [ImageService getImageStr2:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"img")]];
    itemRoleBtn.nameLabel.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"name")];
    itemRoleBtn.distLabel.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"simpleRealm")];
    [itemRoleBtn addTarget:self action:@selector(showRoleTableView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:itemRoleBtn];
}
-(void)showRoleTableView:(id)sender
{
    itemRoleBtn.hidden = YES;
    roleTabView.hidden= NO;
    [self.view bringSubviewToFront:roleTabView];
}
#pragma mark ----delegate
-(void)refreshMyTeamInfoWithViewController:(UIViewController *)vc
{
    [self GETInfoWithNet:YES];
}
#pragma mark --分享组队
-(void)didClickShareItem:(id)sender
{
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
            [[ItemManager singleton] dissoTeam:self.itemId GameId:self.gameid reSuccess:^(id responseObject) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self showMessageWindowWithContent:@"解散成功" imageType:0];
            } reError:^(id error) {
                [hud hide:YES];
                [self showAlertDialog:error];
            }];
        }

    }else if(alertView.tag ==10000002){
        if (buttonIndex==1) {
            [[ItemManager singleton] exitTeam:self.itemId GameId:self.gameid MemberId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"myMemberId")] reSuccess:^(id responseObject) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self showMessageWindowWithContent:@"退出成功" imageType:1];
            } reError:^(id error) {
                [hud hide:YES];
                [self showAlertDialog:error];
            }];
        }
    }else if(alertView.tag ==10212)
    {
        if (buttonIndex==1) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTeamList_wx" object:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
    
}

-(void)showAlertDialog:(id)error{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}

#pragma mark ---创建底部button
-(void)buildbelowbutotnWithArray:(NSArray *)array TitleTexts:(NSArray*)titles shiptype:(NSInteger)shiptype
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 320, 50)];
    [self.view addSubview:view];
    float width = 320/array.count;
    for (int i = 0; i<array.count; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(width*i, 0, width, 50)];
        [button setBackgroundImage:KUIImage(array[i]) forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGBA(0x339adf, 1)forState:UIControlStateNormal];
        [button setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        button.tag = i+100+shiptype*10;
        if (shiptype ==0) {
            [button addTarget:self action:@selector(EditItem:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (shiptype ==1)
        {
            [button addTarget:self action:@selector(members:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if(shiptype ==2){
            button.frame = CGRectMake(160, 0, 160, 50);
            [button addTarget:self action:@selector(joinInItem:) forControlEvents:UIControlEventTouchUpInside];
        }
        [view addSubview:button];
    }

    if (shiptype ==2) {
        bView =[[BottomView alloc]initWithFrame:CGRectMake(0,0, 160, 50)];
        [bView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseRoles:)]];
        if (self.infoDict) {
            bView.lowImg.placeholderImage = KUIImage(@"clazz_icon");
            bView.lowImg.imageURL = [ImageService getImageStr2:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"img")]];
            bView.titleLabel.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"name")];
            bView.gameIcon.imageURL = [ImageService getImageUrl4:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(self.infoDict, @"gameid")]];
            bView.realmLb.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"simpleRealm")];
            bView.topLabel.hidden = YES;
        }
        [view addSubview:bView];
    }
    [self.view addSubview:view];
}


-(void)EditItem:(UIButton *)sender
{
    if (sender.tag ==100)
    {
        KKChatController * kkchat = [[KKChatController alloc] init];
        kkchat.unreadMsgCount  = 0;
        kkchat.chatWithUser =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"groupId")];
        kkchat.type = @"group";
        kkchat.roomId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"roomId")];
        kkchat.gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(m_mainDict, @"createTeamUser"), @"gameid")];
        kkchat.isTeam = YES;
        [self.navigationController pushViewController:kkchat animated:YES];
    }
    else if(sender.tag ==101)
    {
        InvitationMembersViewController *editInfo = [[InvitationMembersViewController alloc]init];
        editInfo.roomId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"roomId")];
        editInfo.groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"groupId")];
        editInfo.gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(m_mainDict, @"createTeamUser"), @"gameid")];
        editInfo.descriptionStr = descriptionStr;
//        editInfo.firstStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"description")];
//        editInfo.secondStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"teamInfo")];
        [self.navigationController pushViewController:editInfo animated:YES];
   
    }
}
-(void)members:(UIButton *)sender
{
    if (sender.tag ==110)
    {
        KKChatController * kkchat = [[KKChatController alloc] init];
        kkchat.unreadMsgCount  = 0;
        kkchat.chatWithUser = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"groupId")];
        kkchat.type = @"group";
        kkchat.roomId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"roomId")];
        kkchat.gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(m_mainDict, @"createTeamUser"), @"gameid")];
        kkchat.isTeam = YES;
        [self.navigationController pushViewController:kkchat animated:YES];
    }
    else if(sender.tag ==111)
    {
//        [self showMessageWindowWithContent:@"退出群" imageType:0];
//        [self gooutRoomWithNet];
        InvitationMembersViewController *editInfo = [[InvitationMembersViewController alloc]init];
        editInfo.roomId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"roomId")];
        editInfo.gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(m_mainDict, @"createTeamUser"), @"gameid")];
        //        editInfo.firstStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"description")];
        //        editInfo.secondStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"teamInfo")];
        [self.navigationController pushViewController:editInfo animated:YES];

    }
}
-(void)chooseRoles:(id)sender
{
    [self showRoleTableView:nil];
}

-(void)joinInItem:(UIButton *)sender
{
    sender = (UIButton *)[self.view viewWithTag:120];
//    if (isJoinIn==YES) {
//        itemRoleBtn.hidden =NO;
//        [self.view bringSubviewToFront:itemRoleBtn];
//        [sender setBackgroundImage:KUIImage(@"realy_item") forState:UIControlStateNormal];
//        isJoinIn =NO;
//
//    }else{
        [self JoinInThisItemWithNet];
}

/*typeName  teamInfo options type1-->创建者  Value1 第一行 value2 第二行  */
#pragma mark ---NET
-(void)GETInfoWithNet:(BOOL)isRefre
{
    if (!isRefre) {
        hud.labelText = @"请求中...";
        [hud show:YES];
    }
    [[TeamManager singleton] GETInfoWithNet:[GameCommon getNewStringWithId:self.gameid] RoomId:[GameCommon getNewStringWithId:self.itemId] reSuccess:^(id responseObject) {
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            m_mainDict = responseObject;
            NSString *teamUsershipType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"teamUsershipType")];
            roleTabView.coreArray =  [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID] gameid:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"createTeamUser"), @"gameid")]];

            [self queryMyRoleWithArr:KISDictionaryHaveKey(responseObject, @"memberList")];
            descriptionStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"description")];
            [self setGetOutBtn:teamUsershipType];
            [self setCaptain:teamUsershipType];
            [self setRightBtn];
            [m_dataArray removeAllObjects];
            [m_dataArray addObjectsFromArray:KISDictionaryHaveKey(responseObject, @"memberList")];
            [m_myTableView reloadData];
            [roleTabView.roleTableView reloadData];
        }
    } reError:^(id error) {
        [hud hide:YES];
        [self showAlertDialog:error];
    }];
}

-(void)queryMyRoleWithArr:(NSArray *)arr
{
    for (NSDictionary *dic in arr) {
        if ([KISDictionaryHaveKey(dic, @"userid")isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
            [[NSUserDefaults standardUserDefaults]setObject:dic forKey:[NSString stringWithFormat:@"myRole_%@",[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]];
        }
    }
}

-(void)setGetOutBtn:(NSString*)teamUsershipType
{
    NSArray *arr = [NSArray array] ;
    NSArray *titlearr = [NSArray array] ;
    if ([teamUsershipType intValue]==0) {
        arr = @[@"sendMsg_normal.jpg",@"yaoqing.jpg"];
        titlearr = @[@"",@""];
        m_getOutBtn.hidden = NO;
    }
    else if([teamUsershipType intValue]==1)
    {
        arr = @[@"sendMsg_normal.jpg",@"yaoqing.jpg"];
        titlearr = @[@"",@""];
        m_getOutBtn.hidden = NO;
    }
    else
    {
        m_getOutBtn.hidden = YES;
        titlearr = @[@"",@"申请加入"];
        arr = @[@"",@"team_join_low"];
    }
    [self buildbelowbutotnWithArray:arr TitleTexts:titlearr shiptype:[teamUsershipType intValue]];
}

-(void)setCaptain:(NSString*)shipType
{
    if ([shipType intValue] == 0) {
        self.isCaptain = YES;
    }
    else{
        self.isCaptain = NO;
    }
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
    cell.tag= indexPath.row;
    cell.delegate = self;
    NSDictionary *dict = [m_dataArray objectAtIndex:indexPath.row];
    cell.headImageView.placeholderImage = KUIImage(@"placeholder");
    NSString *imageids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"img")];
    cell.headImageView.imageURL =[ImageService getImageStr2:imageids] ;
    cell.nickLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"nickname")];
    [cell refreshViewFrameWithText:cell.nickLabel.text];
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"gender")] isEqualToString:@"0"]) {//男♀♂
        cell.genderImgView.image = KUIImage(@"gender_boy");
        cell.headImageView.placeholderImage = [UIImage imageNamed:@"people_man.png"];
    }
    else{
        cell.genderImgView.image = KUIImage(@"gender_girl");
        cell.headImageView.placeholderImage = [UIImage imageNamed:@"people_woman.png"];
    }
    
    
    if ([KISDictionaryHaveKey(dict, @"teamUsershipType") integerValue]==0) {
        cell.MemberLable.hidden = NO;
        cell.MemberLable.backgroundColor = UIColorFromRGBA(0x2eac1d, 1);
        cell.MemberLable.text = @"队长";
    }else{
        cell.MemberLable.hidden = YES;
    }
    
    NSString * gameImageId = [GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dict, @"gameid")];
    cell.gameIconImgView.imageURL = [ImageService getImageUrl4:gameImageId];

    cell.value1Lb.text = [NSString stringWithFormat:@"%@-%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"teamUser"), @"realm")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"teamUser"), @"characterName")]];
    cell.value2Lb.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"teamUser"), @"memberInfo")];
    
    NSDictionary *tempdict = KISDictionaryHaveKey(dict, @"position");
    if ([tempdict isKindOfClass:[NSDictionary class]]&&[[tempdict allKeys]containsObject:@"value"]) {
        cell.value3Lb.text = [GameCommon getNewStringWithId: KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"position"), @"value")];
    }else{
        cell.value3Lb.text = @"";
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    H5CharacterDetailsViewController* VC = [[H5CharacterDetailsViewController alloc] init];
    VC.characterId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"teamUser"), @"characterId")];
    VC.gameId =  KISDictionaryHaveKey(dic, @"gameid");
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)headImgClick:(ItemInfoCell*)Sender{
    NSDictionary *dic = [m_dataArray objectAtIndex:Sender.tag];
    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")];
    TestViewController *itemInfo = [[TestViewController alloc]init];
    itemInfo.userId = userid;
    [self.navigationController pushViewController:itemInfo animated:YES];

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 87)];
    view.backgroundColor = UIColorFromRGBA(0x6f7478, 1);
    
    UIView *view1 =  [self buildViewWithFrame:CGRectMake(0, 25, 320, 62)backgroundColor:[UIColor colorWithRed:92/255.0f green:96/255.0f blue:99/255.0f alpha:1] leftImg:@"item_list1" title:KISDictionaryHaveKey(m_mainDict, @"description")];
    [view addSubview:view1];
    
    
    [view1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeInfo1)]];
    
    UIImageView *view3 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 25)];
//    view3.backgroundColor =UIColorFromRGBA(0x24272e, 1);
    view3.image = KUIImage(@"team_detail_topImage");

    
    
    UILabel *lb1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
    lb1.backgroundColor =[ UIColor clearColor];
    lb1.textColor = UIColorFromRGBA(0x3eacf5, 1);
    lb1.font = [UIFont boldSystemFontOfSize:16];
    
    if ([[m_mainDict allKeys]containsObject:@"type"]) {
        lb1.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(m_mainDict, @"type"), @"value")];
    }else{
        lb1.text = @"";
    }
    
    CGSize size = [lb1.text sizeWithFont:lb1.font constrainedToSize:CGSizeMake(MAXFLOAT, 25) lineBreakMode:NSLineBreakByCharWrapping];
    lb1.frame = CGRectMake((320-size.width)/2, 0, size.width, 25);
    
    lb1.textAlignment = NSTextAlignmentCenter;
    [view3 addSubview:lb1];
    
    NSString *timeStr = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"createDate")]];
    NSString *lb2Str = [NSString stringWithFormat:@"%@",timeStr];
    
    UILabel *lb2 = [[UILabel alloc]initWithFrame:CGRectMake(165+size.width/2, 0, 110, 25)];
    lb2.backgroundColor =[ UIColor clearColor];
    lb2.textColor = UIColorFromRGBA(0x6e737e, 1);
    lb2.font = [UIFont boldSystemFontOfSize:10];
    lb2.text = lb2Str;
    lb2.textAlignment = NSTextAlignmentLeft;
    [view3 addSubview:lb2];
    
    [view addSubview:view3];
    return view;
}
-(void)changeInfo1
{
    
    if (self.isCaptain) {
        EditInfoViewController *editInfo = [[EditInfoViewController alloc]init];
        editInfo.itemId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"roomId")];
        editInfo.firstStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"description")];
        editInfo.gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(m_mainDict, @"createTeamUser"), @"gameid")];
        editInfo.characterId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(m_mainDict, @"createTeamUser"), @"characterId")];
        editInfo.typeId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(m_mainDict, @"type"), @"constId")];
        editInfo.delegate = self;
        [self.navigationController pushViewController:editInfo animated:YES];
    }

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
         tableView.editing = NO;
        [self removeItemerFromNetWithIndexPath:indexPath.row];
    }
}
#pragma mark ---删除成员
-(void)removeItemerFromNetWithIndexPath:(NSInteger)row
{
    
    NSDictionary *dic = m_dataArray[row];
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]isEqualToString:[GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]]) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"您不能踢出自己,如果想撤销队伍,点击择队伍设置,进入设置页面后解散队伍" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [hud show:YES];
    [[ItemManager singleton] removeFromTeam:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")] GameId:[GameCommon getNewStringWithId:self.gameid] MemberId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberId")] MemberTeamUserId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberTeamUserId")] reSuccess:^(id responseObject) {
        [hud hide:YES];
        [m_dataArray removeObjectAtIndex:row];
        [m_myTableView reloadData];
        [self showMessageWindowWithContent:@"删除成功" imageType:0];
    } reError:^(id error) {
        [hud hide:YES];
        [self showAlertDialog:error];
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
    return 87;
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
    
    UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    imageView.image = KUIImage(leftImg);
    [customView addSubview:imageView];
    
//    UILabel *titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(35, 0, 100, 40) font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
//    titleLabel.text = title;
//    [customView addSubview:titleLabel];
    
    UILabel *titleLabel1 = [GameCommon buildLabelinitWithFrame:CGRectMake(60, 0, 250, 62) font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
    titleLabel1.text = title;
    titleLabel1.numberOfLines = 0;
    titleLabel1.adjustsFontSizeToFitWidth = YES;
    [customView addSubview:titleLabel1];
    
    return customView;
}
-(void)didClickChooseWithView:(RoleTabView*)view info:(NSDictionary *)info
{
//    itemRoleBtn.hidden = NO;
    roleTabView.hidden = YES;
    self.infoDict = [NSMutableDictionary dictionaryWithDictionary:info];
    bView.lowImg.imageURL = [ImageService getImageStr2:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"img")]];
    bView.titleLabel.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"name")];
    bView.gameIcon.imageURL = [ImageService getImageUrl4:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(self.infoDict, @"gameid")]];
    
    bView.realmLb.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"simpleRealm")];
    bView.topLabel.hidden = YES;
}
//申请加入房间
-(void)JoinInThisItemWithNet
{
    if (!self.infoDict||[self.infoDict allKeys].count<=0) {
        [self showAlertViewWithTitle:@"提示" message:@"您还没有选择角色,请点击左侧摁键选择角色再申请加入" buttonTitle:@"确定"];
        return;
    }
    
    hud.labelText = @"操作中...";
    [hud show:YES];
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
        [hud hide:YES];
        [self showMessageWindowWithContent:@"申请成功" imageType:0];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        [self showErrorDialog:error];
    }];
    
}
//退出房间
-(void)gooutRoomWithNet
{
    hud.labelText = @"操作中...";
    [hud show:YES];
    [[ItemManager singleton] exitTeam:[GameCommon getNewStringWithId:self.itemId] GameId:[GameCommon getNewStringWithId:self.gameid] MemberId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"myMemberId")] reSuccess:^(id responseObject) {
        [hud hide:YES];
        [self showMessageWindowWithContent:@"退出成功" imageType:0];
        [self.navigationController popViewControllerAnimated:YES];
    } reError:^(id error) {
        [hud hide:YES];
        [self showErrorDialog:error];
    }];
}

-(void)showErrorDialog:(id)error{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"1000124"]) {
                backAlert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                backAlert.tag = 10212;
                [backAlert show];
            }else{

            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            }
        }
    }
}

//改变位置(待处理)
-(void)changPosition:(NSNotification*)notification{
    NSDictionary * dic = [KISDictionaryHaveKey(notification.userInfo, @"payload") JSONValue];
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")]isEqualToString:[GameCommon getNewStringWithId:self.gameid]]
        && [[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")] isEqualToString:[GameCommon getNewStringWithId:self.itemId]]) {
        [self GETInfoWithNet:YES];
    }
}
//组队成员变化
-(void)changMemberList:(NSNotification*)notification{
    m_dataArray = [DataStoreManager getMemberList:[GameCommon getNewStringWithId:self.itemId] GameId:[GameCommon getNewStringWithId:self.gameid]];
    [m_myTableView reloadData];
}
//组队人数变化(待处理)
-(void)teamMemberCountChang:(NSNotification *)notification
{
    NSLog(@"%@",notification.userInfo);
}

- (void)dealloc
{
    m_myTableView.delegate=nil;
    m_myTableView.dataSource=nil;
    backAlert.delegate = nil;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
