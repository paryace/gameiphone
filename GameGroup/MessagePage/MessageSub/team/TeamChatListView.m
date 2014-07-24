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

#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians)*(180.0/M_PI))

@implementation TeamChatListView



- (id)initWithFrame:(CGRect)frame dataSource:(id)datasource delegate:(id) delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        currentExtendSection = -1;
        self.dropDownDataSource = datasource;
        self.dropDownDelegate = delegate;
        
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
            UIButton *sectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(sectionWidth*i, 1, sectionWidth, frame.size.height-2)];
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
        
    }
    return self;
}

-(void)sectionBtnTouch:(UIButton *)btn
{
    NSInteger section = btn.tag - SECTION_BTN_TAG_BEGIN;
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
    UIButton *currentSectionBtn = (UIButton *)[self viewWithTag:SECTION_BTN_TAG_BEGIN + section];
    currentSectionBtn.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    if (!self.customPhotoCollectionView&&!self.mTableView) {
        self.mTableBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height , self.frame.size.width, self.mSuperView.frame.size.height - self.frame.origin.y - self.frame.size.height)];
        self.mTableBaseView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5];
        
        UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTappedAction:)];
        [self.mTableBaseView addGestureRecognizer:bgTap];
        
        self.mBgView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 120 )];
        self.mBgView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);

    }
    if (section == 0) {
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
        self.mBgView.frame =  rect;
        self.mBgView.alpha = 1.0;
        //动画设置位置
        
        [UIView animateWithDuration:0.3 animations:^{
            self.mTableBaseView.alpha = 0.2;
            self.mTableBaseView.alpha = 1.0;
        }];
        [self.customPhotoCollectionView reloadData];
    }else{
        if (!self.mTableView) {
            self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40) style:UITableViewStylePlain];
            self.mTableView.delegate = self;
            self.mTableView.dataSource = self;
            [self.customPhotoCollectionView removeFromSuperview];
            self.customPhotoCollectionView = nil;
            self.mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
            [self.mBgView addSubview:self.mTableView];
            
            
        }
        [self.mSuperView addSubview:self.mTableBaseView];
        [self.mSuperView addSubview:self.mBgView];
        CGRect rect = self.mBgView.frame;
        rect.origin.x =0;
        rect.size.width = 320;
        rect.size.height = self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40;
        self.mBgView.frame =  rect;
        self.mBgView.alpha = 1.0;
        self.mTableBaseView.alpha = 0.0;
        [self.mTableView reloadData];
    }
}

-(void)getZU
{
   self.teamNotifityMsg =  [DataStoreManager queDSTeamNotificationMsgByMsgType:@"requestJoinTeam"];
    NSLog(@"%@",self.teamNotifityMsg);
}
-(void)showErrorAlertView
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"暂没有群通知" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
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
    return 140;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dropDownDelegate respondsToSelector:@selector(chooseAtSection:index:)]) {
        NSString *chooseCellTitle = [self.dropDownDataSource titleInSection:currentExtendSection index:indexPath.row];
        
        UIButton *currentSectionBtn = (UIButton *)[self viewWithTag:SECTION_BTN_TAG_BEGIN + currentExtendSection];
        [currentSectionBtn setTitle:chooseCellTitle forState:UIControlStateNormal];
        [self.dropDownDelegate chooseAtSection:currentExtendSection index:indexPath.row];
        [self hideExtendedChooseView];

    }

}

#pragma mark -- UITableView DataSource


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.teamNotifityMsg.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"simpleApplicationCell";
    JoinTeamCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JoinTeamCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = kColorWithRGB(233, 233 ,233, 0.7);
    }
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
        cell.detailLable.hidden=YES;
    }else{
        cell.detailLable.hidden=NO;
        if ([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"1"]) {
            cell.detailLable.text=@"已同意";
        }else if([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"2"]){
            cell.detailLable.text=@"已拒绝";
        }else {
            cell.detailLable.text=@"已处理";
        }

    }
    return cell;
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
//同意288
-(void)onAgreeClick:(JoinTeamCell*)sender
{
    NSMutableDictionary * msgDic = [self.teamNotifityMsg objectAtIndex:sender.tag];
    [[ItemManager singleton] agreeJoinTeam:KISDictionaryHaveKey(msgDic, @"gameid") UserId:KISDictionaryHaveKey(msgDic, @"userid") RoomId:KISDictionaryHaveKey(msgDic, @"roomId") reSuccess:^(id responseObject) {
         [self changState:msgDic State:@"1"];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"同意加入成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } reError:^(id error) {
        [self showErrorAlertView:error];
    }];
    
}
//拒绝273
-(void)onDisAgreeClick:(JoinTeamCell*)sender
{
    NSMutableDictionary * msgDic = [self.teamNotifityMsg objectAtIndex:sender.tag];
    [[ItemManager singleton] disAgreeJoinTeam:KISDictionaryHaveKey(msgDic, @"gameid") UserId:KISDictionaryHaveKey(msgDic, @"userid") RoomId:KISDictionaryHaveKey(msgDic, @"roomId") reSuccess:^(id responseObject) {
        [self changState:msgDic State:@"2"];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"您已拒绝加入" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } reError:^(id error) {
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
    
    for (NSMutableDictionary * clickDic in self.teamNotifityMsg) {
        if ([KISDictionaryHaveKey(clickDic, @"userid") isEqualToString:KISDictionaryHaveKey(dict, @"userid")]) {
            [clickDic setObject:state forKey:@"state"];
        }
    }
    [self.mTableView reloadData];
    [DataStoreManager updateTeamNotifityMsgState:KISDictionaryHaveKey(dict, @"userid") State:state];
    
}

@end
