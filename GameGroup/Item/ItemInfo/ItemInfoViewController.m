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
    UILabel *titleLable;
    NSMutableDictionary *m_mainDict;
    NSMutableArray *m_dataArray;
    NSMutableArray *claimedList_dataArray;
    BOOL isJoinIn;
    ItemRoleButton *itemRoleBtn;
    RoleTabView *roleTabView;
    UIAlertView *jiesanAlert;
    UIButton *m_getOutBtn;
    BottomView *bView;
    UIAlertView * backAlert;
    UILabel *titleLabel1;
    UILabel *m_typeLabel;
    UILabel *m_timeLabel;
    UIAlertView* popAlertView;
    UIView *bottomView ;
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
    [self setTopViewWithTitle:@"" withBackButton:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changPosition:) name:kChangPosition object:nil];//位置改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changMemberList:) name:kChangMemberList object:nil];//组队成员变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teamMemberCountChang:) name:UpdateTeamMemberCount object:nil];//组队人数字变化
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(meJoinTeam:) name:@"myJoin" object:nil];//对方同意我加入该组队
    
    
    titleLable=[[UILabel alloc] initWithFrame:CGRectMake(60, startX - 44, 320-120, 44)];
    titleLable.backgroundColor=[UIColor clearColor];
    [titleLable setFont:[UIFont boldSystemFontOfSize:20]];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.textColor=[UIColor whiteColor];
    titleLable.text = @"队伍详情";
    [self.view addSubview:titleLable];
    
    
    m_getOutBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    m_getOutBtn.backgroundColor = [UIColor clearColor];
    [m_getOutBtn addTarget:self action:@selector(didClickShareItem:) forControlEvents:UIControlEventTouchUpInside];
    m_getOutBtn.hidden = YES;
    [self.view addSubview:m_getOutBtn];
    
    isJoinIn = YES;
    m_mainDict = [NSMutableDictionary dictionary];
    m_dataArray = [NSMutableArray array];
    claimedList_dataArray = [NSMutableArray array];
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth-startX-50) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [GameCommon setExtraCellLineHidden:m_myTableView];
    [self.view addSubview:m_myTableView];
    m_myTableView.tableHeaderView = [self getHeadView];
    

    roleTabView = [[RoleTabView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    roleTabView.mydelegate  =self;
    roleTabView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:.5];
    roleTabView.roleTableView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:.7];
    roleTabView.hidden = YES;
    roleTabView.mydelegate  =self;
    [self.view addSubview:roleTabView];
    [self setCharacterList:self.gameid];
    
    hud  = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    [self GETInfoWithNet:NO];
}

-(void)setRightBtn:(NSString*)teamUsershipType
{
    [m_getOutBtn setTitle:@"退出" forState:UIControlStateNormal];
    if ([teamUsershipType intValue]==0) {
        m_getOutBtn.hidden = NO;
        [m_getOutBtn setTitle:@"解散" forState:UIControlStateNormal];
    }else if([teamUsershipType intValue]==1){
        m_getOutBtn.hidden = NO;
    }else{
        m_getOutBtn.hidden = YES;
    }
}
#pragma mark ---创建选择角色模块
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
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"teamUsershipType")] intValue] == 0) {
        jiesanAlert =[[ UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要解散队伍吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"解散", nil];
        jiesanAlert.tag = 10000001;
        [jiesanAlert show];
  
    }else{
        jiesanAlert =[[ UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要退出该队伍吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
        jiesanAlert.tag =10000002;
        [jiesanAlert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==10000001) {
        if (buttonIndex==1) {
            hud.labelText = @"解散中...";
            [hud show:YES];
            [[ItemManager singleton] dissoTeam:self.itemId GameId:self.gameid reSuccess:^(id responseObject) {
                [hud hide:YES];
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self showMessageWindowWithContent:@"解散成功" imageType:0];
            } reError:^(id error) {
                [hud hide:YES];
                [self showAlertDialog:error];
            }];
        }

    }else if(alertView.tag ==10000002){
        if (buttonIndex==1) {
            hud.labelText = @"退出中...";
            [hud show:YES];
            [[ItemManager singleton] exitTeam:self.itemId GameId:self.gameid MemberId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"myMemberId")] reSuccess:^(id responseObject) {
                [hud hide:YES];
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
    }else if (alertView.tag==10000006)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)showAlertDialog:(id)error{
    if ([error isKindOfClass:[NSDictionary class]]) {
        NSLog(@"%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)]);
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"1000109"]) {
                popAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                popAlertView.tag =10000006;
                [popAlertView show];
            }else{

            
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}
#pragma mark ---创建底部button
-(void)buildbelowbutotnWithArray:(NSArray *)array TitleTexts:(NSArray*)titles shiptype:(NSInteger)shiptype
{
    bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 320, 50)];
    [self.view addSubview:bottomView];
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
        [bottomView addSubview:button];
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
        [bottomView addSubview:bView];
    }
    [self.view addSubview:bottomView];
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
        InvitationMembersViewController *editInfo = [[InvitationMembersViewController alloc]init];
        editInfo.roomId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"roomId")];
        editInfo.groupId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"groupId")];
        editInfo.gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(m_mainDict, @"createTeamUser"), @"gameid")];
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
    [self JoinInThisItemWithNet];
}

#pragma mark ---请求角色详情
-(void)GETInfoWithNet:(BOOL)isRefre
{
    if (!isRefre) {
        hud.labelText = @"请求中...";
        hud.mode = MBProgressHUDModeIndeterminate;
        [hud show:YES];
    }
    [[TeamManager singleton] GETInfoWithNet:[GameCommon getNewStringWithId:self.gameid] RoomId:[GameCommon getNewStringWithId:self.itemId] reSuccess:^(id responseObject) {
        [hud hide:YES];
        m_getOutBtn .hidden = NO;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            m_mainDict = responseObject;
            NSString *teamUsershipType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"teamUsershipType")];
            NSString *requested = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"requested")];
            NSMutableArray * memberList = KISDictionaryHaveKey(responseObject, @"memberList");
            NSMutableArray * claimedList = KISDictionaryHaveKey(responseObject, @"claimedList");
            [self setTeamTopInfo];
            [self queryMyRoleWithArr:memberList];
            [self setGetOutBtn:teamUsershipType Requested:requested];
            [self setRightBtn:teamUsershipType];
            [self setTitleMsg:responseObject];
            
            if ([claimedList isKindOfClass:[NSArray class]]) {
                [claimedList_dataArray removeAllObjects];
                [claimedList_dataArray addObjectsFromArray:claimedList];
            }
            if ([memberList isKindOfClass:[NSArray class]]) {
                [m_dataArray removeAllObjects];
                [m_dataArray addObjectsFromArray:[self comm:memberList]];
            }
            [m_myTableView reloadData];
        }
    } reError:^(id error) {
        [hud hide:YES];
        [self showAlertDialog:error];
    }];
}


-(void)setTeamTopInfo{
    if ([[m_mainDict allKeys]containsObject:@"type"]) {
        m_typeLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(m_mainDict, @"type"), @"value")];
    }else{
        m_typeLabel.text = @"";
    }
    titleLabel1.text = KISDictionaryHaveKey(m_mainDict, @"description");
    NSString *timeStr = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"createDate")]];
    NSString *lb2Str = [NSString stringWithFormat:@"%@",timeStr];
    m_timeLabel.text = lb2Str;
    CGSize size = [m_typeLabel.text sizeWithFont:m_typeLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, 25) lineBreakMode:NSLineBreakByCharWrapping];
    m_typeLabel.frame = CGRectMake((320-size.width)/2, 0, size.width, 25);
    m_timeLabel.frame =CGRectMake(165+size.width/2, 0, 110, 25);
}


-(void)setCharacterList:(NSString*)gameId{
    NSMutableArray * coreArray =  [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID] gameid:[GameCommon getNewStringWithId:gameId]];
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic  in roleTabView.coreArray) {
        if ([KISDictionaryHaveKey(dic, @"failedmsg") isEqualToString:@"notSupport"]||[KISDictionaryHaveKey(dic, @"failedmsg") isEqualToString:@"404"]) {
        }else{
            [arr addObject:dic];
        }
    }
    [roleTabView setDate:coreArray];
}

//排序
-(NSMutableArray*)comm:(NSMutableArray*)array{
    NSMutableArray *chineseStringsArray=[NSMutableArray array];
    for(int i=0;i<[array count];i++){
        ChineseString *chineseString=[[ChineseString alloc]init];
        NSDictionary * memberDic = [array objectAtIndex:i];
        NSString * str;
        if ([KISDictionaryHaveKey(memberDic, @"position")&&KISDictionaryHaveKey(memberDic, @"position") isKindOfClass:[NSDictionary class]]) {
            str = KISDictionaryHaveKey(KISDictionaryHaveKey(memberDic, @"position"), @"value");
            if ([GameCommon isEmtity:str]) {
                str = @"Z";
            }
        }else{
            str = @"Z";
        }
        chineseString.string=[NSString stringWithString:str];
        chineseString.memberInfo = memberDic;
        if(chineseString.string==nil){
            chineseString.string=@"";
        }
        if(![chineseString.string isEqualToString:@""]){
            NSString *pinYinResult=[NSString string];
            for(int j=0;j<chineseString.string.length;j++){
                NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([chineseString.string characterAtIndex:j])]uppercaseString];
                
                pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
            }
            chineseString.pinYin=pinYinResult;
        }else{
            chineseString.pinYin=@"";
        }
        [chineseStringsArray addObject:chineseString];
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    
    NSMutableArray *result=[NSMutableArray array];
    for(int i=0;i<[chineseStringsArray count];i++){
        [result addObject:((ChineseString*)[chineseStringsArray objectAtIndex:i]).memberInfo];
    }
    return result;
}

-(void)setTitleMsg:(NSDictionary*)teamInfo{
    NSString * roomName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(teamInfo, @"roomName")];
    titleLable.text = [NSString  stringWithFormat:@"[%@/%@]%@",KISDictionaryHaveKey(teamInfo, @"memberCount"),KISDictionaryHaveKey(m_mainDict, @"maxVol"),roomName];
}

-(void)queryMyRoleWithArr:(NSArray *)arr
{
    for (NSDictionary *dic in arr) {
        if ([KISDictionaryHaveKey(dic, @"userid")isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
            [[NSUserDefaults standardUserDefaults]setObject:dic forKey:[NSString stringWithFormat:@"myRole_%@",[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]];
        }
    }
}

-(void)setGetOutBtn:(NSString*)teamUsershipType Requested:(NSString*)requested
{
    NSArray *arr = [NSArray array] ;
    NSArray *titlearr = [NSArray array] ;
    if ([teamUsershipType intValue]==0) {
        [self noHaveBottomView];
    }else if([teamUsershipType intValue]==1){
        [self noHaveBottomView];
    }else{
        titlearr = @[@"",([requested intValue]==1)?@"再次申请":@"申请加入"];
        arr = @[@"",@"team_join_low"];
        [self buildbelowbutotnWithArray:arr TitleTexts:titlearr shiptype:[teamUsershipType intValue]];
        [self haveBottomView];
    }
}
//带底部按钮
-(void)haveBottomView{
    m_myTableView .frame=CGRectMake(0, startX, kScreenWidth, kScreenHeigth-startX-50);
}
//不带底部按钮
-(void)noHaveBottomView{
    m_myTableView .frame=CGRectMake(0, startX, kScreenWidth, kScreenHeigth-startX);
}

#pragma mark ----tableview delegate  datasourse
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (claimedList_dataArray&&[claimedList_dataArray isKindOfClass:[NSArray class]]&&claimedList_dataArray.count>0) {
        return 2;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return m_dataArray.count;
    }
    return claimedList_dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        static NSString *indifience = @"cell";
        ItemInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
        if (!cell) {
            cell = [[ItemInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
        }
        cell.tag= indexPath.row;
        cell.indexPath = indexPath;
        cell.delegate = self;
        NSDictionary *dict = [m_dataArray objectAtIndex:indexPath.row];
        cell.headImageView.placeholderImage = KUIImage(@"placeholder");
        NSString *imageids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"img")];
        cell.headImageView.imageURL =[ImageService getImageStr:imageids Width:80] ;
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
        cell.value2Lb.frame = CGRectMake(70, 41, 320-120, 15);
        NSDictionary *tempdict = KISDictionaryHaveKey(dict, @"position");
        if ([tempdict isKindOfClass:[NSDictionary class]]&&[[tempdict allKeys]containsObject:@"value"]) {
            cell.value3Lb.text = [GameCommon getNewStringWithId: KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"position"), @"value")];
        }else{
            cell.value3Lb.text = @"未选";
        }
        return cell;
    }else{
        static NSString *indifience = @"cell2";
        ItemInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
        if (!cell) {
            cell = [[ItemInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
        }
        cell.tag= indexPath.row;
        cell.indexPath = indexPath;
        cell.delegate = self;
        NSDictionary *dict = [claimedList_dataArray objectAtIndex:indexPath.row];
        cell.headImageView.placeholderImage = KUIImage(@"placeholder");
        NSString *imageids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"characterImg")];
        cell.headImageView.imageURL =[ImageService getImageStr:imageids Width:80] ;
        cell.bgImageView.userInteractionEnabled =NO;
        NSString *nameStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"characterName")];
        if (nameStr.length>16) {
            nameStr =[[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"characterName")] substringToIndex:8];
        }
         cell.nickLabel.text = [NSString stringWithFormat:@"%@...",nameStr];
        [cell refreshViewFrameWithText:cell.nickLabel.text];
        cell.MemberLable.hidden = NO;
        
        cell.MemberLable.backgroundColor = UIColorFromRGBA(0xfdcd12, 1);
        cell.MemberLable.text = @"预约";
        NSString * gameImageId = [GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dict, @"gameid")];
        cell.gameIconImgView.imageURL = [ImageService getImageUrl4:gameImageId];
        
        cell.value1Lb.text = [NSString stringWithFormat:@"%@-%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"realm")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"characterName")]];
        cell.value2Lb.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"msg")];
        cell.value2Lb.frame = CGRectMake(70, 41, 320-75, 15);
        cell.value3Lb.text = @"";
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
        [self toH5CharacterDetailPage:dic];
    }else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSDictionary *dic = [claimedList_dataArray objectAtIndex:indexPath.row];
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"failedmsg")] isEqualToString:@"404"]
            ||[[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"failedmsg")] isEqualToString:@"notSupport"]
            ||[[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")] isEqualToString:@"3"]) {
            
            [self showMessageWithContent:@"无法获取角色详情数据,由于角色不存在或暂不支持" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
            return;
        }
        H5CharacterDetailsViewController* VC = [[H5CharacterDetailsViewController alloc] init];
        VC.characterId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"characterId")];
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
            VC.myViewType = CHARA_INFO_MYSELF;
        }else{
            VC.myViewType = CHARA_INFO_PERSON;
        }
        
        VC.gameId = [GameCommon getNewStringWithId: KISDictionaryHaveKey(dic, @"gameid")];
        [self.navigationController pushViewController:VC animated:YES];
    }
}


-(void)toH5CharacterDetailPage:(NSDictionary*)dic{
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"failedmsg")] isEqualToString:@"404"]
        ||[[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"failedmsg")] isEqualToString:@"notSupport"]
        ||[[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")] isEqualToString:@"3"]) {
        
        [self showMessageWithContent:@"无法获取角色详情数据,由于角色不存在或暂不支持" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
        return;
    }
    H5CharacterDetailsViewController* VC = [[H5CharacterDetailsViewController alloc] init];
    VC.characterId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"teamUser"), @"characterId")];
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
        VC.myViewType = CHARA_INFO_MYSELF;
    }else{
        VC.myViewType = CHARA_INFO_PERSON;
    }
    
    VC.gameId = [GameCommon getNewStringWithId: KISDictionaryHaveKey(dic, @"gameid")];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)headImgClick:(ItemInfoCell*)Sender{
    NSIndexPath * indexPath = Sender.indexPath;
    if (indexPath.section == 0) {
        if (Sender.tag<m_dataArray.count) {
            NSDictionary *dic = [m_dataArray objectAtIndex:Sender.tag];
            NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")];
            [self toUserInfoPage:userid];
        }
    }else if (indexPath.section == 1) {
        if (Sender.tag<claimedList_dataArray.count) {
            NSDictionary *dic = [claimedList_dataArray objectAtIndex:Sender.tag];
            NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")];
            [self toUserInfoPage:userid];
        }
    }
}


-(void)toUserInfoPage:(NSString*)userId{
    TestViewController *itemInfo = [[TestViewController alloc]init];
    itemInfo.userId = userId;
    [self.navigationController pushViewController:itemInfo animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 29;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return nil;
    }else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
        view.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
        UILabel *label  =[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 300, 29)];
        label.font = [UIFont systemFontOfSize:12];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"位置预约";
        [view addSubview:label];
        return view;
    }
}


-(UIView*)getHeadView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 87)];
    view.backgroundColor = UIColorFromRGBA(0x6f7478, 1);
    
    UIView *view1 =  [self buildViewWithFrame:CGRectMake(0, 25, 320, 62)backgroundColor:[UIColor colorWithRed:92/255.0f green:96/255.0f blue:99/255.0f alpha:1] leftImg:@"item_list1" /*title:*/];
    [view1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeInfo1)]];

    [view addSubview:view1];
    
    
    
    titleLabel1 = [GameCommon buildLabelinitWithFrame:CGRectMake(60, 0, 250, 62) font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
    titleLabel1.numberOfLines = 0;
    titleLabel1.adjustsFontSizeToFitWidth = YES;
    [view1 addSubview:titleLabel1];

    
    
    UIImageView *view3 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 25)];
    view3.image = KUIImage(@"team_detail_topImage");
    
    
    m_typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
    m_typeLabel.backgroundColor =[ UIColor clearColor];
    m_typeLabel.textColor = UIColorFromRGBA(0x3eacf5, 1);
    m_typeLabel.font = [UIFont boldSystemFontOfSize:16];
    

    
    CGSize size = [m_typeLabel.text sizeWithFont:m_typeLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, 25) lineBreakMode:NSLineBreakByCharWrapping];
    m_typeLabel.frame = CGRectMake((320-size.width)/2, 0, size.width, 25);
    
    m_typeLabel.textAlignment = NSTextAlignmentCenter;
    [view3 addSubview:m_typeLabel];
    
    
    m_timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(165+size.width/2, 0, 110, 25)];
    m_timeLabel.backgroundColor =[ UIColor clearColor];
    m_timeLabel.textColor = UIColorFromRGBA(0x6e737e, 1);
    m_timeLabel.font = [UIFont boldSystemFontOfSize:10];
    m_timeLabel.textAlignment = NSTextAlignmentLeft;
    [view3 addSubview:m_timeLabel];
    [view addSubview:view3];
    return view;
}



-(void)changeInfo1
{
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_mainDict, @"teamUsershipType")] intValue] == 0) {
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
        if (indexPath.section == 0) {
            [self removeItemer:indexPath.row];
        }else{
            [self removeClaimed:indexPath.row];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
         NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]isEqualToString:[GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]]) {
             return @"解散";
        }
        return  @"删除";
    }
    return @"删除";
}


#pragma mark ---删除成员
-(void)removeClaimed:(NSInteger)row
{
    NSDictionary *dic = claimedList_dataArray[row];
    [self deleteMenberFromList:KISDictionaryHaveKey(dic, @"roomId") GameId:self.gameid MemberId:KISDictionaryHaveKey(dic, @"memberId") MemberTeamUserId:nil];
}

#pragma mark ---解散队伍
-(void)removeItemer:(NSInteger)row
{
    NSDictionary *dic = m_dataArray[row];
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]isEqualToString:[GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]]) {
       UIAlertView*  alert =[[ UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要解散队伍吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"必须解散", nil];
        alert.tag = 10000001;
        [alert show];
        return;
    }
    [self deleteMenberFromList:KISDictionaryHaveKey(dic, @"roomId") GameId:self.gameid MemberId:KISDictionaryHaveKey(dic, @"memberId") MemberTeamUserId:KISDictionaryHaveKey(dic, @"memberTeamUserId")];
}


-(void)deleteMenberFromList:(NSString*)roomId GameId:(NSString*)gameId MemberId:(NSString*)memberId MemberTeamUserId:(NSString*)memberTeamUserId{
    [hud show:YES];
    [[ItemManager singleton] removeFromTeam:[GameCommon getNewStringWithId:roomId] GameId:[GameCommon getNewStringWithId:gameId] MemberId:[GameCommon getNewStringWithId:memberId] MemberTeamUserId:[GameCommon getNewStringWithId:memberTeamUserId] reSuccess:^(id responseObject) {
        [hud hide:YES];
        [self deleteMember:[GameCommon getNewStringWithId:memberId] GameId:[GameCommon getNewStringWithId:gameId] RoomId:[GameCommon getNewStringWithId:roomId] MemberTeamUserId:memberTeamUserId];
        [m_myTableView reloadData];
        [self showMessageWindowWithContent:@"删除成功" imageType:0];
    } reError:^(id error) {
        [hud hide:YES];
        [self showAlertDialog:error];
    }];

}

-(void)deleteMember:(NSString*)memberId GameId:(NSString*)gameId RoomId:(NSString*)roomId MemberTeamUserId:(NSString*)memberTeamUserId{
    NSMutableArray * claimedList_array = [claimedList_dataArray mutableCopy];
    NSMutableArray * m_array = [m_dataArray mutableCopy];
    if ([GameCommon isEmtity:[GameCommon getNewStringWithId:memberTeamUserId]]) {
        for (NSDictionary * dic in claimedList_array) {
            if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")] isEqualToString:gameId]
                && [[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberId")] isEqualToString:memberId]
                && [[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")] isEqualToString:roomId]) {
                [claimedList_dataArray removeObject:dic];
            }
        }
    }else{
        for (NSDictionary * dic in m_array ) {
            if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")] isEqualToString:gameId]
                && [[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberId")] isEqualToString:memberId]
                && [[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")] isEqualToString:roomId]) {
                [m_dataArray removeObject:dic];
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(UIView *)buildViewWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor leftImg:(NSString *)leftImg
{
    UIView *customView = [[UIView alloc]initWithFrame:frame];
    customView.backgroundColor =backgroundColor;
    
    UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    imageView.image = KUIImage(leftImg);
    [customView addSubview:imageView];
    return customView;
}
//选择角色
-(void)didClickChooseWithView:(RoleTabView*)view info:(NSDictionary *)info
{
    roleTabView.hidden = YES;
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"failedmsg")] isEqualToString:@"404"]) {
        [self showMessageWithContent:@"无法获取角色详情数据,由于角色不存在或暂不支持" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
        return;
    }
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
    hud.detailsLabelText  = @"";
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
        NSDictionary * msgDic = @{@"roomId":self.itemId,@"gameid":[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.infoDict, @"gameid")]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRoomState" object:nil userInfo:msgDic];
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

#pragma mark 改变位置(待处理)
-(void)changPosition:(NSNotification*)notification{
    NSDictionary * userDic = notification.userInfo;
    [self updatePosition:userDic];
}
#pragma mark 组队成员变化
-(void)changMemberList:(NSNotification*)notification{
    [self updateMemberList];
}
#pragma mark 组队人数变化(待处理)
-(void)teamMemberCountChang:(NSNotification *)notification
{
    NSMutableDictionary * teamInfo = [[TeamManager singleton] getTeamInfo:[GameCommon getNewStringWithId:self.gameid] RoomId:[GameCommon getNewStringWithId:self.itemId]];
    [self setTitleMsg:teamInfo];
    
    NSLog(@"%@",notification.userInfo);
}
#pragma mark 我被同意加入该组队
-(void)meJoinTeam:(NSNotification*)notification{
    [self hideBottomView];
    [self noHaveBottomView];
}
-(NSString*)getMemberCount:(NSMutableDictionary*)teamInfo{
    
    return [NSString stringWithFormat:@"[%@/%@]",KISDictionaryHaveKey(teamInfo, @"memberCount"),KISDictionaryHaveKey(teamInfo, @"maxVol")];
}


-(void)hideBottomView{
    if(bottomView && bottomView.hidden == NO){
        bottomView.hidden = YES;
    }
}
- (void)dealloc
{
    m_myTableView.delegate=nil;
    m_myTableView.dataSource=nil;
    backAlert.delegate = nil;
    popAlertView.delegate = nil;
}


-(void)updateMemberList{
    m_dataArray = [DataStoreManager getMemberList:[GameCommon getNewStringWithId:self.itemId] GameId:[GameCommon getNewStringWithId:self.gameid]];
    [m_myTableView reloadData];
}


-(void)updatePosition:(NSDictionary*)userDic{
    for (NSMutableDictionary * dic in m_dataArray) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")] isEqualToString:[GameCommon getNewStringWithId:KISDictionaryHaveKey(userDic, @"sender")]]) {
            NSDictionary * pisitionDic = KISDictionaryHaveKey(dic, @"position");
            if ([pisitionDic isKindOfClass:[NSDictionary class]]) {
                [pisitionDic setValue:KISDictionaryHaveKey(userDic, @"teamPosition") forKey:@"value"];
            }else {
                [dic setValue:[[ItemManager singleton] createPosition:KISDictionaryHaveKey(userDic, @"teamPosition")] forKey:@"position"];
            }
        }
    }
    [m_myTableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
