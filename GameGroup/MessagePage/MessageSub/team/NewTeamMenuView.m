//
//  NewTeamMenuView.m
//  GameGroup
//
//  Created by Apple on 14-8-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewTeamMenuView.h"
#import "TagCell.h"
#import "CardTitleView.h"
#import "JoinTeamCell.h"
#import "ItemManager.h"
#import "InplaceCell.h"
#import "TestViewController.h"
#import "ChineseString.h"
#import "pinyin.h"
#import "InplaceTimer.h"
#define bottomHight 55
#define bottomPadding 10

@implementation NewTeamMenuView

- (id)initWithFrame:(CGRect)frame GroupId:(NSString*)groupId RoomId:(NSString*)roomId GameId:(NSString*)gameId teamUsershipType:(BOOL)teamUsershipType
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changPosition:) name:kChangPosition object:nil];//位置改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changMemberList:) name:kChangMemberList object:nil];//组队人数变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changInplaceState:) name:kChangInplaceState object:nil];//收到确认或者取消就位确认状态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendChangInplaceState:) name:kSendChangInplaceState object:nil];//发起就位确认状态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetChangInplaceState:) name:kResetChangInplaceState object:nil];//初始化就位确认状态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序.
        self.groipId = groupId;
        self.teamUsershipType = teamUsershipType;
        self.roomId = roomId;
        self.gameId = gameId;
        UIImageView * bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        UIImage * bgImage = [[UIImage imageNamed:@"chat_bg_image.png"]stretchableImageWithLeftCapWidth:1 topCapHeight:10];
        bgImageView.image = bgImage;
        bgImageView.userInteractionEnabled = YES;
        for (int i = 0; i <4; i++) {
            UIButton *sectionBtn = [self getUIBtn:i NormalImage:@"new_friend_normal_1" ClickImage:@"new_friend_click_1"];
            [bgImageView addSubview:sectionBtn];
            UILabel * titlelable=[self getUILable:i TitleText:@"邀请"];
            [bgImageView addSubview:titlelable];
        }
        [self addSubview:bgImageView];
        
        if (!self.mTableView) {
            self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, 320,kScreenHeigth-60) style:UITableViewStylePlain];
            self.mTableView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
            self.mTableView.delegate = self;
            self.mTableView.dataSource = self;
            self.mTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
            [GameCommon setExtraCellLineHidden:self.mTableView];
            [self addSubview:self.mTableView];
        }
        
        if (!self.bottomView){
            self.bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kScreenHeigth-60-bottomHight, 320, bottomHight)];
            self.bottomView.backgroundColor = [UIColor whiteColor];
            self.bottomView.image =KUIImage(@"bottom_bg");
            self.bottomView.userInteractionEnabled = YES;
            [self addSubview:self.bottomView];
            if (self.teamUsershipType) {
                self.sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, bottomPadding, 290, 35)];
                [self.sendBtn setBackgroundImage:KUIImage(@"longBtn_normal") forState:UIControlStateNormal];
                [self.sendBtn setBackgroundImage:KUIImage(@"longBtn_select") forState:UIControlStateHighlighted];
                [self.sendBtn setBackgroundImage:KUIImage(@"longBtn_select") forState:UIControlStateSelected];
                [self.sendBtn setTitle:@"发起就位确认" forState:UIControlStateNormal];
                [self.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.sendBtn.backgroundColor = [UIColor clearColor];
                self.sendBtn.layer.cornerRadius = 3;
                self.sendBtn.layer.masksToBounds=YES;
                [self.sendBtn addTarget:self action:@selector(sendButton:) forControlEvents:UIControlEventTouchUpInside];
                [self.bottomView addSubview:self.sendBtn];
            }else{
                self.agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, bottomPadding, (320-40)/2, 35)];
                [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_normal") forState:UIControlStateNormal];
                [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateHighlighted];
                [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateSelected];
                [self.agreeBtn setTitle:@"确定就位" forState:UIControlStateNormal];
                [self.agreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.agreeBtn.backgroundColor = [UIColor clearColor];
                self.agreeBtn.layer.cornerRadius = 3;
                self.agreeBtn.layer.masksToBounds=YES;
                [self.agreeBtn addTarget:self action:@selector(agreeButton:) forControlEvents:UIControlEventTouchUpInside];
                [self.bottomView addSubview:self.agreeBtn];
                
                self.refusedBtn = [[UIButton alloc] initWithFrame:CGRectMake(15+10+(320-40)/2,bottomPadding, (320-40)/2, 35)];
                [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_normal") forState:UIControlStateNormal];
                [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateHighlighted];
                [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateSelected];
                [self.refusedBtn setTitle:@"拒绝就位" forState:UIControlStateNormal];
                [self.refusedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.refusedBtn.backgroundColor = [UIColor clearColor];
                self.refusedBtn.layer.cornerRadius = 3;
                self.refusedBtn.layer.masksToBounds=YES;
                [self.refusedBtn addTarget:self action:@selector(refusedButton:) forControlEvents:UIControlEventTouchUpInside];
                [self.bottomView addSubview:self.refusedBtn];
            }
        }
        [self getmemberList];
        [self.mTableView reloadData];
    }
    return self;
}

-(UIButton *)getUIBtn:(NSInteger)index NormalImage:(NSString*)normalImage ClickImage:(NSString*)clickImage{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = index;
    button.frame = CGRectMake(index*80, 0, 80, 60);
    [button addTarget:self action:@selector(buttonAction:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:normalImage]forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:clickImage]forState:UIControlStateHighlighted];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    return button;
}
-(UILabel *)getUILable:(NSInteger)i TitleText:(NSString*)titleText{
    UILabel *titleLable = [[UILabel alloc] init];
    CGSize textSize =[titleText sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
    CGFloat textWidth = textSize.width;
    titleLable.frame=CGRectMake(i*80+((80-textWidth)/2),40, 80 ,20);
    titleLable.font = [UIFont systemFontOfSize:11];
    titleLable.textColor=UIColorFromRGBA(0xf7f7f7, 1);
    titleLable.backgroundColor=[UIColor clearColor];
    titleLable.text=titleText;
    return titleLable;
}

-(void)buttonAction:(UIButton*)sender{
    if ([self.detaildelegate respondsToSelector:@selector(btnAction:)] ) {
        [self.detaildelegate btnAction:sender];
    }
}

//设置按钮状态
-(void)setBtnState{
    NSInteger onClickState = [DataStoreManager getTeamUser:self.groipId UserId:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    if(onClickState == 0){
        [self reset];
        [self normal];
    }else if(onClickState == 1){
        [self showButton];
        [self send];
    }else if(onClickState == 2){
        [self showButton];
        [self ok];
    }else if(onClickState == 3){
        [self showButton];
        [self cancel];
    }
}

//正常
-(void)normal{
    if (self.teamUsershipType) {
        [self.sendBtn setTitle:@"发起就位确认" forState:UIControlStateNormal];
        self.sendBtn.selected = NO;
        self.sendBtn.enabled = YES;
        
    }else{
        self.agreeBtn.hidden = NO;
        self.agreeBtn.frame = CGRectMake(15, bottomPadding, (320-40)/2, 35);
        [self.agreeBtn setTitle:@"确定就位" forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_normal") forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateHighlighted];
        [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateSelected];
        self.agreeBtn.selected = NO;
        self.agreeBtn.enabled = YES;
        
        self.refusedBtn.hidden = NO;
        self.refusedBtn.frame = CGRectMake(15+10+(320-40)/2,bottomPadding, (320-40)/2, 35);
        [self.refusedBtn setTitle:@"拒绝就位" forState:UIControlStateNormal];
        [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_normal") forState:UIControlStateNormal];
        [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateHighlighted];
        [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateSelected];
        self.refusedBtn.selected = NO;
        self.refusedBtn.enabled = YES;
    }
}

//已经发送
-(void)send{
    if (self.teamUsershipType) {
        [self.sendBtn setTitle:@"已经发起就位确认" forState:UIControlStateNormal];
        self.sendBtn.selected = YES;
        self.sendBtn.enabled = NO;
        self.agreeBtn.hidden = YES;
        self.refusedBtn.hidden = YES;
    }else{
        self.agreeBtn.hidden = NO;
        self.agreeBtn.frame = CGRectMake(15, bottomPadding, (320-40)/2, 35);
        [self.agreeBtn setTitle:@"确定就位" forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_normal") forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateHighlighted];
        [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateSelected];
        self.agreeBtn.selected = NO;
        self.agreeBtn.enabled = YES;
        
        self.refusedBtn.hidden = NO;
        self.refusedBtn.frame = CGRectMake(15+10+(320-40)/2,bottomPadding, (320-40)/2, 35);
        [self.refusedBtn setTitle:@"拒绝就位" forState:UIControlStateNormal];
        [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_normal") forState:UIControlStateNormal];
        [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateHighlighted];
        [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateSelected];
        self.refusedBtn.selected = NO;
        self.refusedBtn.enabled = YES;
    }
}

//没有就位确认消息的时候
-(void)reset{
    if (self.teamUsershipType) {
        [self showButton];
    }else{
        [self hideButton];
    }
}

//已经确定
-(void)ok{
    if (self.teamUsershipType) {
        [self.sendBtn setTitle:@"已经发起就位确认" forState:UIControlStateNormal];
        self.sendBtn.selected = YES;
        self.sendBtn.enabled = NO;
    }else{
        self.agreeBtn.hidden = NO;
        self.agreeBtn.frame = CGRectMake(15, bottomPadding, 290, 35);
        [self.agreeBtn setTitle:@"已确认" forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"longBtn_normal") forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"longBtn_select") forState:UIControlStateHighlighted];
        [self.agreeBtn setBackgroundImage:KUIImage(@"longBtn_select") forState:UIControlStateSelected];
        self.agreeBtn.selected = YES;
        self.agreeBtn.enabled = NO;
        
        self.refusedBtn.selected = YES;
        self.refusedBtn.enabled = NO;
        self.refusedBtn.hidden = YES;
    }
}


//已经取消
-(void)cancel{
    if (self.teamUsershipType) {
        [self.sendBtn setTitle:@"已经发起就位确认" forState:UIControlStateNormal];
        self.sendBtn.selected = YES;
        self.sendBtn.enabled = NO;
    }else{
        self.agreeBtn.hidden = YES;
        self.agreeBtn.selected = YES;
        self.agreeBtn.enabled = NO;
        
        self.refusedBtn.hidden = NO;
        self.refusedBtn.frame = CGRectMake(15, bottomPadding, 290, 35);
        [self.refusedBtn setTitle:@"已拒绝" forState:UIControlStateNormal];
        [self.refusedBtn setBackgroundImage:KUIImage(@"longBtn_normal") forState:UIControlStateNormal];
        [self.refusedBtn setBackgroundImage:KUIImage(@"longBtn_select") forState:UIControlStateHighlighted];
        [self.refusedBtn setBackgroundImage:KUIImage(@"longBtn_select") forState:UIControlStateSelected];
        self.refusedBtn.selected = YES;
        self.refusedBtn.enabled = NO;
    }
}
//隐藏按钮
-(void)hideButton{
    self.bottomView.hidden=YES;
    self.mTableView.frame = CGRectMake(0, 0, 320,self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40);
}
//显示按钮
-(void)showButton{
    self.bottomView.hidden=NO;
    self.mTableView.frame = CGRectMake(0, 0, 320,self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40-bottomHight);
}

//发起就位确认
-(void)sendButton:(UIButton*)sender{
    [hud show:YES];
    [[ItemManager singleton] sendTeamPreparedUserSelect:self.roomId GameId:self.gameId reSuccess:^(id responseObject) {
        [hud hide:YES];
        [[InplaceTimer singleton] startTimer:self.gameId RoomId:self.roomId GroupId:self.groipId timeDeleGate:self];
    } reError:^(id error) {
        [hud hide:YES];
        [self showErrorAlertView:error];
    }];
}
//清除未读的就位确认消息
-(void)clearNorReadInpaceMsg{
    if ([self.detaildelegate respondsToSelector:@selector(buttonOnClick)] ) {
        [self.detaildelegate buttonOnClick];
    }
}

//确定就位
-(void)agreeButton:(UIButton*)sender{
    [hud show:YES];
    [[ItemManager singleton] teamPreparedUserSelect:self.roomId GameId:self.gameId Value:@"1" reSuccess:^(id responseObject) {
        [hud hide:YES];
    } reError:^(id error) {
        [hud hide:YES];
        [self showErrorAlertView:error];
    }];
}
//取消就位
-(void)refusedButton:(UIButton*)sender{
    [hud show:YES];
    [[ItemManager singleton] teamPreparedUserSelect:self.roomId GameId:self.gameId Value:@"0" reSuccess:^(id responseObject){
        [hud hide:YES];
    } reError:^(id error) {
        [hud hide:YES];
        [self showErrorAlertView:error];
    }];
}

//就位确认数据
-(void)getmemberList{
    self.memberList = [self comm:[DataStoreManager getMemberList:self.roomId GameId:self.gameId]];
}

//排序
-(NSMutableArray*)comm:(NSMutableArray*)array{
    NSMutableArray *chineseStringsArray=[NSMutableArray array];
    for(int i=0;i<[array count];i++){
        ChineseString *chineseString=[[ChineseString alloc]init];
        NSDictionary * memberDic = [array objectAtIndex:i];
        NSString * str = KISDictionaryHaveKey(memberDic, @"value");
        if ([GameCommon isEmtity:str]) {
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
-(void)showToastAlertView:(NSString*)msgText
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:msgText delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}


#pragma mark -- UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        [self.mTableView deselectRowAtIndexPath:indexPath animated:YES];
        NSMutableDictionary *dic = [self.memberList objectAtIndex:indexPath.row];
        if ([[dic allKeys]containsObject:@"teamUser"]) {
            [self.detaildelegate itemOnClick:[self createCharaDic:dic]];
        }else{
            hud.labelText = @"注意，这是坑位，请等小伙伴一下";
            hud.mode = MBProgressHUDModeText;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
        }
}

-(NSDictionary*)createCharaDic:(NSMutableDictionary*)dic{
    NSDictionary * charadic = @{@"characterId":[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"teamUser"), @"characterId")],
                                @"characterName":[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"teamUser"), @"characterName")],
                                @"gameid":[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")]};
    return charadic;
}

#pragma mark -- UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.memberList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"simpleInplaceCell";
    InplaceCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[InplaceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.tag = indexPath.row;
    cell.headCkickDelegate = self;
    cell.onclickdelegate = self;
    NSMutableDictionary * msgDic = [self.memberList objectAtIndex:indexPath.row];
    NSMutableDictionary * teamUserDic = KISDictionaryHaveKey(msgDic, @"teamUser");
    cell.headImageV.placeholderImage = KUIImage([self headPlaceholderImage:KISDictionaryHaveKey(msgDic, @"gender")]);
    cell.headImageV.imageURL=[ImageService getImageStr:KISDictionaryHaveKey(msgDic, @"img") Width:80];
    cell.genderImageV.image = KUIImage([self genderImage:KISDictionaryHaveKey(msgDic, @"gender")]);
    NSString * gameImageId=[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(msgDic, @"gameid")];
    if ([GameCommon isEmtity:gameImageId]) {
        cell.gameImageV.image=KUIImage(@"clazz_0");
    }else{
        cell.gameImageV.imageURL= [ImageService getImageUrl4:gameImageId];
    }
    cell.groupNameLable.text = KISDictionaryHaveKey(msgDic, @"nickname");
    if ([teamUserDic isKindOfClass:[NSDictionary class]]) {
        cell.realmLable.text = [NSString stringWithFormat:@"%@%@%@",KISDictionaryHaveKey(KISDictionaryHaveKey(msgDic, @"teamUser"), @"realm"),@"-",KISDictionaryHaveKey(KISDictionaryHaveKey(msgDic, @"teamUser"), @"characterName")];
        cell.pveLable.text = KISDictionaryHaveKey(KISDictionaryHaveKey(msgDic, @"teamUser"), @"memberInfo");
        
    }else{
        cell.realmLable.text = @"";
        cell.pveLable.text = @"";
    }
    
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"userid")] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
        cell.positionLable.textColor = UIColorFromRGBA(0x339adf, 1);
        cell.positionLable.text = [GameCommon isEmtity:KISDictionaryHaveKey(msgDic, @"value")]?@"请选择":KISDictionaryHaveKey(msgDic, @"value");
    }else{
        cell.positionLable.textColor = [UIColor grayColor];
        cell.positionLable.text = [GameCommon isEmtity:KISDictionaryHaveKey(msgDic, @"value")]?@"未选":KISDictionaryHaveKey(msgDic, @"value");
    }
    
    if([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"0"]){//未发起
        cell.stateView.hidden = YES;
    }else{
        cell.stateView.hidden = NO;
        if ([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"1"]) {//未处理
            cell.stateView.backgroundColor = [UIColor grayColor];
        }else if([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"2"]){//确认
            cell.stateView.backgroundColor = [UIColor greenColor];
        }else if([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"3"]){//取消
            cell.stateView.backgroundColor = [UIColor redColor];
        }
    }
    NSInteger shipType = [KISDictionaryHaveKey(msgDic, @"teamUsershipType") integerValue];
    if (shipType==0) {
        cell.MemberLable.hidden = NO;
        cell.MemberLable.backgroundColor = UIColorFromRGBA(0x2eac1d, 1);
        cell.MemberLable.text = @"队长";
    }else{
        cell.MemberLable.hidden = YES;
    }
    CGSize size = [cell.groupNameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(MAXFLOAT, 15) lineBreakMode:NSLineBreakByCharWrapping];
    float w = size.width>((shipType==0)?119:145)?((shipType==0)?119:145):size.width;
    cell.groupNameLable.frame = CGRectMake(80, 9, w, 20);
    cell.genderImageV.frame = CGRectMake(80+w, 9, 20, 20);
    cell.MemberLable.frame = CGRectMake(80+w+20+2, 13, 26, 13);
    
    return cell;
}
-(void)positionOnClick:(InplaceCell*)sender{
    [self.detaildelegate positionAction];
}
//格式化时间
-(NSString*)getMsgTime:(NSString*)senderTime
{
    NSString *time = [senderTime substringToIndex:10];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSString* strNowTime = [NSString stringWithFormat:@"%d",(int)nowTime];
    NSString* strTime = [NSString stringWithFormat:@"%d",[time intValue]];
    return [GameCommon getTimeWithChatStyle:strNowTime AndMessageTime:strTime];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.teamUsershipType) {
        NSMutableDictionary * dic = [self.memberList objectAtIndex:indexPath.row];
        NSString *userId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")] ;
        if ([userId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
            return @"解散";
        }
        return @"删除";
    }
    return @"";
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.teamUsershipType) {
        return YES;
    }
    return NO;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        tableView.editing = NO;
        NSMutableDictionary * dic = [self.memberList objectAtIndex:indexPath.row];
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]isEqualToString:[GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]]) {
            UIAlertView*  alert =[[ UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要解散队伍吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"必须解散", nil];
            alert.tag = 10000001;
            [alert show];
            return;
        }
        [hud show:YES];
        [[ItemManager singleton] removeFromTeam:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")] GameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")] MemberId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberId")] MemberTeamUserId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberTeamUserId")] reSuccess:^(id responseObject) {
            [hud hide:YES];
            [self resetMemberList];
            [self showToastAlertView:@"删除成功"];
        } reError:^(id error) {
            [hud hide:YES];
            [self showErrorAlertView:error];
        }];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==10000001) {
        if (buttonIndex==1) {
            hud.labelText = @"解散中...";
            [hud show:YES];
            [[ItemManager singleton] dissoTeam:self.roomId GameId:self.gameId reSuccess:^(id responseObject) {
                [hud hide:YES];
                [self showToastAlertView:@"解散成功"];
            } reError:^(id error) {
                [hud hide:YES];
                [self showErrorAlertView:error];
            }];
        }
    }
}


//头像默认图片
-(NSString*)headPlaceholderImage:(NSString*)gender
{
    if ([[GameCommon getNewStringWithId:gender] isEqualToString:@"0"]) {//男♀♂
        return @"people_man.png";
    }
    else
    {
        return @"people_woman.png";
    }
}
//性别图标
-(NSString*)genderImage:(NSString*)gender
{
    if ([gender intValue]==0)
    {
        return @"gender_boy";
    }else
    {
        return @"gender_girl";
    }
}

- (void)userHeadImgClick:(id)Sender{
    InplaceCell * iCell = (InplaceCell*)Sender;
    NSMutableDictionary *dic = [self.memberList objectAtIndex:iCell.tag];
    [self.detaildelegate headImgClick:KISDictionaryHaveKey(dic, @"userid")];
}

//弹出提示框
-(void)showErrorAlertView:(id)error
{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}


#pragma mark 改变位置
-(void)changPosition:(NSNotification*)notification{
    NSDictionary * positionDic = notification.userInfo;
    NSLog(@"positipon-->>>>%@",positionDic);
    [self resetMemberList];
}
#pragma mark 人数变化
-(void)changMemberList:(NSNotification*)notification{
    [self resetMemberList];
}

-(void)resetMemberList{
    [self getmemberList];
    [self.mTableView reloadData];
}

#pragma mark 接收到确认或者取消消息通知,改变就位确认状态
-(void)changInplaceState:(NSNotification*)notification{
    NSDictionary * memberUserInfo = notification.userInfo;
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"groupId")] isEqualToString:[GameCommon getNewStringWithId:self.groipId]]) {
        [self changPState:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"userid")] GroupId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"groupId")] State:[self getState:KISDictionaryHaveKey(memberUserInfo, @"type")]];
        [self.mTableView reloadData];
        if (![self isShow]) {
            [self clearInpaceMsg];
        }else{
            [self clearNorReadInpaceMsg];//清除消息
        }
        [self setBtnState];
    }
}
#pragma mark 接收到发起就位确认消息通知,改变就位确认状态
-(void)sendChangInplaceState:(NSNotification*)notification{
    [self showButton];
    [self changPState:@"1"];
    [self.mTableView reloadData];
    [self setBtnState];
}
#pragma mark 接收到初始化就位确认消息通知,改变就位确认状态
-(void)resetChangInplaceState:(NSNotification*)notification{

    if (self.teamUsershipType) {
        [[InplaceTimer singleton] resetTimer:self.gameId RoomId:self.roomId];
    }
    if (!self.isShow) {
        [self clearInpaceMsg];
    }else{
        [self clearNorReadInpaceMsg];//清除消息
    }
    [self setBtnState];
}
//显示
-(void)showView{
    self.isShow = YES;
    [[InplaceTimer singleton] reStartTimer:self.gameId RoomId:self.roomId GroupId:self.groipId timeDeleGate:self];
}
//隐藏
-(void)hideView{
    self.isShow = NO;
    if (self.teamUsershipType) {//停止计时
        [[InplaceTimer singleton] stopTimer:self.gameId RoomId:self.roomId GroupId:self.groipId];
    }
}
-(void)clearInpaceMsg{
    [DataStoreManager updateDSTeamNotificationMsgCount:self.groipId SayHightType:@"1"];
    [DataStoreManager updateDSTeamNotificationMsgCount:self.groipId SayHightType:@"4" Successcompletion:^(BOOL success, NSError *error) {
        [self clearNorReadInpaceMsg];//清除消息
    }];
}

//改变列表就位确认状态
-(void)changPState:(NSString*)userId GroupId:(NSString*)groupId State:(NSString *)state{
    for (NSMutableDictionary * clickDic in self.memberList) {
        if ([KISDictionaryHaveKey(clickDic, @"userid") isEqualToString:userId]
            &&[KISDictionaryHaveKey(clickDic, @"groupId") isEqualToString:groupId]) {
            [clickDic setObject:state forKey:@"state"];
        }
    }
}
//改变列表就位确认状态
-(void)changPState:(NSString*)state{
    for (NSMutableDictionary * clickDic in self.memberList) {
        if ([KISDictionaryHaveKey(clickDic, @"teamUsershipType") intValue]==0) {
            [clickDic setObject:@"2" forKey:@"state"];
        }else{
            [clickDic setObject:state forKey:@"state"];
        }
    }
}
//重置列表就位确认状态
-(void)resetPState{
    for (NSMutableDictionary * clickDic in self.memberList) {
        [clickDic setObject:@"0" forKey:@"state"];
    }
}

-(NSString*)getState:(NSString*)result{
    if([[GameCommon getNewStringWithId:result]isEqualToString:@"teamPreparedUserSelectOk"]){
        return @"2";
    }else if ([[GameCommon getNewStringWithId:result]isEqualToString:@"teamPreparedUserSelectCancel"]) {
        return @"3";
    }
    return @"1";
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if (self.isShow) {
        if (self.teamUsershipType) {
            NSLog(@"从应用退到桌面");
            self.sendBtn.selected = NO;
            self.sendBtn.enabled = YES;
            [[InplaceTimer singleton] stopTimer:self.gameId RoomId:self.roomId GroupId:self.groipId];
        }
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (self.isShow) {
        if (self.teamUsershipType) {
            NSLog(@"从桌面回到应用");
            self.sendBtn.selected = YES;
            self.sendBtn.enabled = NO;
            [[InplaceTimer singleton] reStartTimer:self.gameId RoomId:self.roomId GroupId:self.groipId timeDeleGate:self];
        }
    }
}
//计时
- (void)timingTime:(long long )time{
    NSLog(@"计时时间---->>>>>>%lld",time);
    self.sendBtn.selected = NO;
    self.sendBtn.enabled = YES;
    [self.sendBtn setTitle:[NSString stringWithFormat:@"%@(%lld)",@"已经发起就位确认",time] forState:UIControlStateNormal];
    self.sendBtn.selected = YES;
    self.sendBtn.enabled = NO;
}

- (void)dealloc
{
    if (self.mTableView) {
        self.mTableView.delegate=nil;
        self.mTableView.dataSource=nil;
    }
}
@end
