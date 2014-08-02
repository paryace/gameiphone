//
//  TeamChatListView.m
//  GameGroup
//
//  Created by Apple on 14-7-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TeamChatListView.h"
#import "CardCell.h"
#import "CardTitleView.h"
#import "JoinTeamCell.h"
#import "ItemManager.h"
#import "InplaceCell.h"
#import "TestViewController.h"

#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians)*(180.0/M_PI))

@implementation TeamChatListView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changPosition:) name:kChangPosition object:nil];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame dataSource:(id)datasource delegate:(id) delegate SuperView:(UIView*)supView GroupId:(NSString*)groupId RoomId:(NSString*)roomId GameId:(NSString*)gameId teamUsershipType:(BOOL)teamUsershipType
{
    self = [super initWithFrame:frame];
    if (self) {
        currentExtendSection = -1;
        self.dropDownDataSource = datasource;
        self.dropDownDelegate = delegate;
        self.groipId = groupId;
        self.teamUsershipType = teamUsershipType;
        self.roomId = roomId;
        self.gameId = gameId;
        
        NSInteger sectionNum =0;
        if ([self.dropDownDataSource respondsToSelector:@selector(numberOfSections)] ) {
            sectionNum = [self.dropDownDataSource numberOfSections];
        }
        if (sectionNum == 0) {
            self = nil;
        }
        //初始化默认显示view
        CGFloat sectionWidth = (1.0*(frame.size.width)/sectionNum);
        for (int i = 0; i <sectionNum; i++) {
            UIButton *sectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(sectionWidth*i, 1, sectionWidth, frame.size.height)];
            sectionBtn.tag = SECTION_BTN_TAG_BEGIN + i;
            [sectionBtn addTarget:self action:@selector(sectionBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
            NSString *sectionBtnTitle = @"--";
            if ([self.dropDownDataSource respondsToSelector:@selector(titleInSection:index:)]) {
                sectionBtnTitle = [self.dropDownDataSource titleInSection:i index:[self.dropDownDataSource defaultShowSection:i]];
            }
            [sectionBtn  setTitle:sectionBtnTitle forState:UIControlStateNormal];
            [sectionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            sectionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            [self addSubview:sectionBtn];
            
            UIImageView *sectionBtnIv = [[UIImageView alloc] initWithFrame:CGRectMake(sectionWidth*i +(sectionWidth - 16), (self.frame.size.height-12)/2, 12, 12)];
            [sectionBtnIv setImage:[UIImage imageNamed:@"down_dark.png"]];
            [sectionBtnIv setContentMode:UIViewContentModeScaleToFill];
            sectionBtnIv.tag = SECTION_IV_TAG_BEGIN + i;
            [self addSubview: sectionBtnIv];
            if (i<sectionNum && i != 0) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(sectionWidth*i, frame.size.height/4, 1, frame.size.height/2)];
                lineView.backgroundColor = [UIColor lightGrayColor];
                [self addSubview:lineView];
            }
        }
        hud = [[MBProgressHUD alloc] initWithView:supView];
        hud.frame = CGRectMake((320-80)/2, (960-80)/2, 80, 80);
        hud.labelText = @"加载中...";
        [supView addSubview:hud];
    }
    return self;
}



-(void)sectionBtnTouch:(UIButton *)btn
{
    NSInteger section = btn.tag - SECTION_BTN_TAG_BEGIN;
    [self showOrHide:section];
}


-(void)showOrHide:(NSInteger)section{
    BOOL isOpen = [self.dropDownDelegate clickAtSection:section];
    if (!isOpen) {
        return;
    }
    if (currentExtendSection == section) {
        [self hideExtendedChooseView];
    }else{
        if (section==1) {
            [self getZU];
            if (!self.teamNotifityMsg||self.teamNotifityMsg.count==0) {
                [self showErrorAlertView];
                return;
            }
        }else{
            [self getmemberList];
        }
        currentExtendSection = section;
        [self showChooseListViewInSection:currentExtendSection choosedIndex:[self.dropDownDataSource defaultShowSection:currentExtendSection]];
    }

}

- (void)setTitle:(NSString *)title inSection:(NSInteger) section
{
    UIButton *btn = (id)[self viewWithTag:SECTION_BTN_TAG_BEGIN +section];
    [btn setTitle:title forState:UIControlStateNormal];
}

- (BOOL)isShow
{
    if (currentExtendSection == -1) {
        return NO;
    }
    return YES;
}
-  (void)hideExtendedChooseView
{
    if (currentExtendSection != -1) {
        currentExtendSection = -1;
        CGRect rect = self.mBgView.frame;
        rect.size.height = 0;
        self.mBgView.frame = rect;
        self.mBgView.alpha = 1.0f;
        [self.mBgView removeFromSuperview];
        [UIView animateWithDuration:0.3 animations:^{
            self.mTableBaseView.alpha = 1.0f;
            self.mTableBaseView.alpha = 0.2f;
        }completion:^(BOOL finished) {
            [self.mTableBaseView removeFromSuperview];
        }];
    }
}

-(void)showChooseListViewInSection:(NSInteger)section choosedIndex:(NSInteger)index
{
    if (!self.customPhotoCollectionView&&!self.mTableView) {
        self.mTableBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height , self.frame.size.width, self.mSuperView.frame.size.height - self.frame.origin.y - self.frame.size.height)];
        self.mTableBaseView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5];
        UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTappedAction:)];
        [self.mTableBaseView addGestureRecognizer:bgTap];
        self.mBgView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 120 )];
        self.mBgView.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    }
    if (section == 0) {
        if (self.agreeBtn) {
            self.agreeBtn.hidden=YES;
            self.refusedBtn.hidden=YES;
        }
        if (!self.customPhotoCollectionView){
            self.layout = [[UICollectionViewFlowLayout alloc]init];
            self.layout.minimumInteritemSpacing = 10;
            self.layout.minimumLineSpacing =10;
            self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            self.layout.itemSize = CGSizeMake(88, 30);
            self.customPhotoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10,10,300,100) collectionViewLayout:self.layout];
            self.customPhotoCollectionView.delegate = self;
            self.customPhotoCollectionView.showsHorizontalScrollIndicator = NO;
            self.customPhotoCollectionView.showsVerticalScrollIndicator = NO;
            self.customPhotoCollectionView.dataSource = self;
            [self.customPhotoCollectionView registerClass:[CardCell class] forCellWithReuseIdentifier:@"ImageCell"];
            self.customPhotoCollectionView.backgroundColor = [UIColor clearColor];
            [self.mTableView removeFromSuperview];
            self.mTableView = nil;
            [self.mBgView addSubview:self.customPhotoCollectionView];
        }
        //修改tableview的frame
        CGRect rect = self.mBgView.frame;
        rect.origin.x =0;
        rect.size.width = 320;
        NSInteger num = ( [self.dropDownDataSource numberOfRowsInSection:currentExtendSection]-1)/3+1;//标签行数
        rect.size.height = (num*(30+10)+10)>(self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40)?(self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40):(num*(30+10)+10);
        self.mBgView.frame = rect;
        self.customPhotoCollectionView.frame = CGRectMake(10,10,300,rect.size.height-20);
        [self.mSuperView addSubview:self.mTableBaseView];
        [self.mSuperView addSubview:self.mBgView];
        self.mBgView.alpha = 1.0;
        //动画设置位置
        [UIView animateWithDuration:0.3 animations:^{
            self.mTableBaseView.alpha = 0.2;
            self.mTableBaseView.alpha = 1.0;
        }];
        [self.customPhotoCollectionView reloadData];
    }else{
        float tableHight = self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40;
        if (section == 2) {
            tableHight -= 60;
        }
        if (!self.mTableView) {
            self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320,tableHight) style:UITableViewStylePlain];
            self.mTableView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
            self.mTableView.delegate = self;
            self.mTableView.dataSource = self;
            [self.customPhotoCollectionView removeFromSuperview];
            self.customPhotoCollectionView = nil;
            [self.mBgView addSubview:self.mTableView];
        }
        if (section == 2) {
            if (!self.agreeBtn) {
                self.agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, tableHight+5, (320-40)/2, 35)];
                [self.agreeBtn setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
                [self.agreeBtn setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
                [self.agreeBtn setTitle:@"位置确认" forState:UIControlStateNormal];
                [self.agreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.agreeBtn.backgroundColor = [UIColor clearColor];
                self.agreeBtn.layer.cornerRadius = 3;
                self.agreeBtn.layer.masksToBounds=YES;
                [self.agreeBtn addTarget:self action:@selector(agreeButton:) forControlEvents:UIControlEventTouchUpInside];
                [self.mBgView addSubview:self.agreeBtn];
                
                
                self.refusedBtn = [[UIButton alloc] initWithFrame:CGRectMake(15+10+(320-40)/2, tableHight+5, (320-40)/2, 35)];
                [self.refusedBtn setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
                [self.refusedBtn setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
                [self.refusedBtn setTitle:@"拒绝就位" forState:UIControlStateNormal];
                [self.refusedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.refusedBtn.backgroundColor = [UIColor clearColor];
                self.refusedBtn.layer.cornerRadius = 3;
                self.refusedBtn.layer.masksToBounds=YES;
                [self.refusedBtn addTarget:self action:@selector(refusedButton:) forControlEvents:UIControlEventTouchUpInside];
                [self.mBgView addSubview:self.refusedBtn];
            }
        }
        if (section==1) {
            self.agreeBtn.hidden=YES;
            self.refusedBtn.hidden= YES;
            self.mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        }else{
            self.agreeBtn.hidden=NO;
            self.refusedBtn.hidden=NO;
            self.mTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
            [GameCommon setExtraCellLineHidden:self.mTableView];
        }
        [self.mSuperView addSubview:self.mTableBaseView];
        [self.mSuperView addSubview:self.mBgView];
        CGRect rect = self.mBgView.frame;
        rect.size.height = self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40;
        self.mBgView.frame =  rect;
        self.mTableView.frame = CGRectMake(0, 0, 320,tableHight);
        [self.mTableView reloadData];
    }
}


-(void)agreeButton:(UIButton*)sender{
    [[ItemManager singleton] sendTeamPreparedUserSelect:self.roomId GameId:self.gameId reSuccess:^(id responseObject) {
        NSLog(@"successs");
    } reError:^(id error) {
        NSLog(@"error");
        [self showErrorAlertView:error];
    }];
}
-(void)refusedButton:(UIButton*)sender{
    NSLog(@"取消就位");
}

-(void)getZU
{
    self.teamNotifityMsg = [DataStoreManager queDSTeamNotificationMsgByMsgTypeAndGroupId:@"requestJoinTeam" GroupId:self.groipId];
}
-(void)getmemberList{
    self.memberList = [DataStoreManager getMemberList:self.groipId];
}

-(void)showErrorAlertView
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"暂无队友申请" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

-(void)bgTappedAction:(UITapGestureRecognizer *)tap
{
    [self hideExtendedChooseView];
}
//----------
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dropDownDataSource numberOfRowsInSection:currentExtendSection];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CardCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.bgImgView.image = KUIImage(@"card_show");
    cell.tag = indexPath.section*1000+indexPath.row;
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    cell.titleLabel.text = [self.dropDownDataSource titleInSection:currentExtendSection index:indexPath.row];
    cell.titleLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dropDownDelegate respondsToSelector:@selector(chooseAtSection:index:)]) {
        NSString *chooseCellTitle = [self.dropDownDataSource titleInSection:currentExtendSection index:indexPath.row];
        UIButton *currentSectionBtn = (UIButton *)[self viewWithTag:SECTION_BTN_TAG_BEGIN + currentExtendSection];
        [currentSectionBtn setTitle:chooseCellTitle forState:UIControlStateNormal];
        [self.dropDownDelegate chooseAtSection:currentExtendSection index:indexPath.row];
        [self hideExtendedChooseView];
    }
}

//-------

#pragma mark -- UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentExtendSection==1) {
        return 140;
    }
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dropDownDelegate respondsToSelector:@selector(chooseAtSection:index:)]) {
        if (currentExtendSection==1) {
            NSMutableDictionary *dic = [self.teamNotifityMsg objectAtIndex:indexPath.row];
            [self.dropDownDataSource itemOnClick:dic];
        }else{
            [self.mTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

#pragma mark -- UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (currentExtendSection==1) {
        return self.teamNotifityMsg.count;
    }else{
        return self.memberList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (currentExtendSection==1) {
        static NSString *identifier = @"simpleApplicationCell";
        JoinTeamCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[JoinTeamCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
        cell.tag = indexPath.row;
        NSMutableDictionary * msgDic = [self.teamNotifityMsg objectAtIndex:indexPath.row];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.headImageV.placeholderImage = KUIImage([self headPlaceholderImage:KISDictionaryHaveKey(msgDic, @"gender")]);
        cell.headImageV.imageURL=[ImageService getImageStr:KISDictionaryHaveKey(msgDic, @"userImg") Width:80];
        cell.genderImageV.image = KUIImage([self genderImage:KISDictionaryHaveKey(msgDic, @"gender")]);
        NSString * gameImageId=[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(msgDic, @"gameid")];
        if ([GameCommon isEmtity:gameImageId]) {
            cell.gameImageV.image=KUIImage(@"clazz_0");
        }else{
            cell.gameImageV.imageURL= [ImageService getImageUrl4:gameImageId];
        }
        cell.groupNameLable.text = KISDictionaryHaveKey(msgDic, @"nickname");
        cell.positionLable.hidden=YES;
        cell.realmLable.text = KISDictionaryHaveKey(msgDic, @"value1");
        cell.pveLable.text = KISDictionaryHaveKey(msgDic, @"value2");
        if ([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"0"]) {
            if (self.teamUsershipType) {
                cell.detailLable.hidden=YES;
            }else {
                [cell.agreeButton setUserInteractionEnabled:NO];
                [cell.refuseButton setUserInteractionEnabled:NO];
                cell.detailLable.hidden=NO;
                cell.detailLable.text=@"审核中";
            }
        }else{
            [cell.agreeButton setUserInteractionEnabled:NO];
            [cell.refuseButton setUserInteractionEnabled:NO];
            cell.detailLable.hidden=NO;
            if ([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"1"]) {
                cell.detailLable.text=@"已同意";
            }else if([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"2"]){
                cell.detailLable.text=@"已拒绝";
            }else {
                cell.detailLable.text=@"已处理";
            }
        }
        
        CGSize nameSize = [cell.groupNameLable.text sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping];
        cell.groupNameLable.frame = CGRectMake(75, 12, nameSize.width, 20);
        cell.genderImageV.frame = CGRectMake(75+nameSize.width+5, 10, 20, 20);
        [cell setTime:KISDictionaryHaveKey(msgDic, @"senTime")];
        return cell;
    }else{
        static NSString *identifier = @"simpleInplaceCell";
        InplaceCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[InplaceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.tag = indexPath.row;
        cell.headCkickDelegate = self;
        NSMutableDictionary * msgDic = [self.memberList objectAtIndex:indexPath.row];
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
        cell.realmLable.text = [NSString stringWithFormat:@"%@%@%@",KISDictionaryHaveKey(KISDictionaryHaveKey(msgDic, @"teamUser"), @"characterName"),@"-",KISDictionaryHaveKey(KISDictionaryHaveKey(msgDic, @"teamUser"), @"realm")];
        cell.pveLable.text = KISDictionaryHaveKey(KISDictionaryHaveKey(msgDic, @"teamUser"), @"memberInfo");
        cell.positionLable.text = [GameCommon isEmtity:KISDictionaryHaveKey(msgDic, @"value")]?@"未选":KISDictionaryHaveKey(msgDic, @"value");
        if (indexPath.row%2==0) {
            cell.stateView.backgroundColor = [UIColor greenColor];
        }else{
            cell.stateView.backgroundColor = [UIColor redColor];
        }
        CGSize nameSize = [cell.groupNameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping];
        cell.groupNameLable.frame = CGRectMake(80, 8, nameSize.width, 20);
        cell.genderImageV.frame = CGRectMake(80+nameSize.width+3, 8, 20, 20);
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentExtendSection==1) {
        return @"删除";
    }
   return @"";
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentExtendSection==1) {
        return YES;
    }
    return NO;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        NSMutableDictionary * msgDic = [self.teamNotifityMsg objectAtIndex:indexPath.row];
        [DataStoreManager deleteTeamNotifityMsgStateByMsgId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"msgId")] Successcompletion:^(BOOL success, NSError *error) {
            [self.teamNotifityMsg removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }];
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

-(void)headImgClick:(JoinTeamCell*)Sender{
    NSMutableDictionary *dic = [self.teamNotifityMsg objectAtIndex:Sender.tag];
    [self.dropDownDataSource headImgClick:KISDictionaryHaveKey(dic, @"userid")];
}
- (void)userHeadImgClick:(id)Sender{
    InplaceCell * iCell = (InplaceCell*)Sender;
     NSMutableDictionary *dic = [self.memberList objectAtIndex:iCell.tag];
    [self.dropDownDataSource headImgClick:KISDictionaryHaveKey(dic, @"userid")];
}
//同意288
-(void)onAgreeClick:(JoinTeamCell*)sender
{
     [hud show:YES];
    NSMutableDictionary * msgDic = [self.teamNotifityMsg objectAtIndex:sender.tag];
    [[ItemManager singleton] agreeJoinTeam:KISDictionaryHaveKey(msgDic, @"gameid") UserId:KISDictionaryHaveKey(msgDic, @"userid") RoomId:KISDictionaryHaveKey(msgDic, @"roomId") reSuccess:^(id responseObject) {
         [hud hide:YES];
         [self changState:msgDic State:@"1"];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"同意加入成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } reError:^(id error) {
         [hud hide:YES];
        [self showErrorAlertView:error];
    }];
}
//拒绝273
-(void)onDisAgreeClick:(JoinTeamCell*)sender
{
    [hud show:YES];
    NSMutableDictionary * msgDic = [self.teamNotifityMsg objectAtIndex:sender.tag];
    [[ItemManager singleton] disAgreeJoinTeam:KISDictionaryHaveKey(msgDic, @"gameid") UserId:KISDictionaryHaveKey(msgDic, @"userid") RoomId:KISDictionaryHaveKey(msgDic, @"roomId") reSuccess:^(id responseObject) {
         [hud hide:YES];
        [self changState:msgDic State:@"2"];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"您已拒绝加入" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } reError:^(id error) {
         [hud hide:YES];
        [self showErrorAlertView:error];
    }];
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

//改变消息状态
-(void)changState:(NSMutableDictionary*)dict State:(NSString*)state
{
    [self changState:KISDictionaryHaveKey(dict, @"userid") GroupId:self.groipId State:state];
}

-(void)changState:(NSString*)userId GroupId:(NSString*)groupId State:(NSString*)state
{
    for (NSMutableDictionary * clickDic in self.teamNotifityMsg) {
        if ([KISDictionaryHaveKey(clickDic, @"userid") isEqualToString:userId]
            && [KISDictionaryHaveKey(clickDic, @"state") isEqualToString:@"0"]
            &&[KISDictionaryHaveKey(clickDic, @"groupId") isEqualToString:groupId]) {
            [clickDic setObject:state forKey:@"state"];
        }
    }
    [self.mTableView reloadData];
    [DataStoreManager updateTeamNotifityMsgState:userId State:state GroupId:groupId];
}
//改变位置
-(void)changPosition:(NSNotification*)notification{
    NSDictionary * positionDic = notification.userInfo;
    NSLog(@"positipon-->>>>%@",positionDic);
}

- (void)dealloc
{
    if (self.mTableView) {
        self.mTableView.delegate=nil;
        self.mTableView.dataSource=nil;
    }
}
@end
