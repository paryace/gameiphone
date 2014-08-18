//
//  MyRoomView.m
//  GameGroup
//
//  Created by 魏星 on 14-7-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MyRoomView.h"
#import "BaseItemCell.h"
#import "ICreatedCell.h"
#import "MJRefresh.h"

@implementation MyRoomView{
    NSInteger actionIndex;
    MJRefreshHeaderView *m_header;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //删除角色
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(roleRemove:) name:RoleRemoveNotify object:nil];
        //解散该群
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDisbandGroup:) name:kDisbandGroup object:nil];
        //被剔出该群
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onkickOffGroupGroup:) name:kKickOffGroupGroup object:nil];
        self.myListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, frame.size.height) style:UITableViewStylePlain];
        self.myListTableView.delegate = self;
        self.myListTableView.dataSource = self;
        [self addSubview:self.myListTableView];
        [GameCommon setExtraCellLineHidden:self.myListTableView];
        [self addHeader];
    }
    return self;
}

-(void)initMyRoomListData:(NSMutableDictionary*)dic{
    self.listDict = [NSMutableDictionary dictionaryWithDictionary:dic];
    self.myCreateRoomList = [dic objectForKey:@"OwnedRooms"];
    self.myJoinRoomList = [dic objectForKey:@"joinedRooms"];
    self.myRequestedRoomsList = [dic objectForKey:@"requestedRooms"];
    [self.myListTableView reloadData];
}

-(void)stopRefre{
    [m_header endRefreshing];
}

-(void)enterCreatePage:(id)sender
{
    if ([self.myDelegate respondsToSelector:@selector(didClickCreateTeamWithView:)]) {
        [self.myDelegate didClickCreateTeamWithView:self];
    }
}
#pragma mark ----tableview delegate  datasourse
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.listDict allKeys] count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    if(section==0){
        if ([self.myCreateRoomList isKindOfClass:[NSArray class]]&&self.myCreateRoomList.count>0) {
            return [self.myCreateRoomList count];
        }else{
            return 1;
        }
    }else if (section==1){
        if ([self.myJoinRoomList isKindOfClass:[NSArray class]]&&self.myJoinRoomList.count>0) {
            return [self.myJoinRoomList count];
        }else{
            return 1;
        }
    }else if (section==2){
        if ([self.myRequestedRoomsList isKindOfClass:[NSArray class]]&&self.myRequestedRoomsList.count>0) {
            return [self.myRequestedRoomsList count];
        }else{
            return 1;
        }

    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        static NSString *indifience = @"cell1";
        BaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
        if (!cell) {
            cell = [[BaseItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
        }
        if ([self.myCreateRoomList isKindOfClass:[NSArray class]]&&self.myCreateRoomList.count>0) {
            NSDictionary * dic = [self.myCreateRoomList objectAtIndex:indexPath.row];
            cell.headImg.placeholderImage = KUIImage(@"placeholder");
            NSString *imageids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"img")];
            cell.headImg.imageURL =[ImageService getImageStr:imageids Width:80] ;
            cell.gameIconImg.imageURL = [ImageService getImageUrl4:[GameCommon putoutgameIconWithGameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")]]];
            NSString *title = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomName")];
            cell.titleLabel.text = title;
            cell.contentLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"description")];
            NSString *timeStr = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];
            NSString *personStr = [NSString stringWithFormat:@"%@/%@人",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberCount")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"maxVol")]];
            cell.timeLabel.text = [NSString stringWithFormat:@"%@|%@",timeStr,personStr];
            cell.bgImageView.hidden = YES;
        }else{
            cell.bgImageView.image = KUIImage(@"team_ placeholder1.jpg");
            cell.bgImageView.hidden = NO;
            cell.headImg.imageURL = nil;
            cell.titleLabel.text = nil;
            cell.contentLabel.text = nil;
            cell.timeLabel.text = nil;
        }
        return cell;
        
    }else if(indexPath.section==1){
        static NSString *indifience = @"cell2";
        BaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
        if (!cell) {
            cell = [[BaseItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
        }
        if ([self.myJoinRoomList isKindOfClass:[NSArray class]]&&self.myJoinRoomList.count>0) {
            NSDictionary * dic = [self.myJoinRoomList objectAtIndex:indexPath.row];
            cell.headImg.placeholderImage = KUIImage(@"placeholder");
            NSString *imageids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"img")];
            cell.headImg.imageURL =[ImageService getImageStr:imageids Width:80] ;
            cell.gameIconImg.imageURL = [ImageService getImageUrl4:[GameCommon putoutgameIconWithGameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")]]];
            cell.titleLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomName")];
            cell.contentLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"description")];
            NSString *timeStr = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];
            NSString *personStr = [NSString stringWithFormat:@"%@/%@人",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberCount")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"maxVol")]];
            
            cell.timeLabel.text = [NSString stringWithFormat:@"%@|%@",timeStr,personStr];
            cell.bgImageView.hidden = YES;
        }else{
            cell.bgImageView.image = KUIImage(@"team_placeholder2.jpg");

            cell.bgImageView.hidden = NO;
            cell.headImg.imageURL = nil;
            cell.titleLabel.text = nil;
            cell.contentLabel.text = nil;
            cell.timeLabel.text = nil;
        }
        return cell;
    }else if(indexPath.section==2){
        static NSString *indifience = @"cell3";
        BaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
        if (!cell) {
            cell = [[BaseItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
        }
        if ([self.myRequestedRoomsList isKindOfClass:[NSArray class]]&&self.myRequestedRoomsList.count>0) {
            NSDictionary * dic = [self.myRequestedRoomsList objectAtIndex:indexPath.row];
            cell.headImg.placeholderImage = KUIImage(@"placeholder");
            NSString *imageids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"img")];
            cell.headImg.imageURL =[ImageService getImageStr:imageids Width:80] ;
            cell.gameIconImg.imageURL = [ImageService getImageUrl4:[GameCommon putoutgameIconWithGameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")]]];
            cell.titleLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomName")];
            cell.contentLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"description")];
            NSString *timeStr = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];
            NSString *personStr = [NSString stringWithFormat:@"%@/%@人",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberCount")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"maxVol")]];
            cell.timeLabel.text = [NSString stringWithFormat:@"%@|%@",timeStr,personStr];
            cell.bgImageView.hidden = YES;
        }else{
            cell.bgImageView.image = KUIImage(@"team_placeholder2.jpg");
            cell.bgImageView.hidden = NO;
            cell.headImg.imageURL = nil;
            cell.titleLabel.text = nil;
            cell.contentLabel.text = nil;
            cell.timeLabel.text = nil;
        }
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic;
    if (indexPath.section ==0) {
        if (self.myCreateRoomList&&self.myCreateRoomList.count>0) {
            [[Custom_tabbar showTabBar] hideTabBar:YES];
            dic = [self.myCreateRoomList objectAtIndex:indexPath.row];
            if ([self.myDelegate respondsToSelector:@selector(didClickMyRoomWithView: dic:)]) {
                [self.myDelegate didClickMyRoomWithView:self dic:dic];
            }
        }
    }else if(indexPath.section ==1){
        if (self.myJoinRoomList&&self.myJoinRoomList.count>0) {
            [[Custom_tabbar showTabBar] hideTabBar:YES];
            dic = [self.myJoinRoomList objectAtIndex:indexPath.row];
            if ([self.myDelegate respondsToSelector:@selector(didClickMyRoomWithView: dic:)]) {
                [self.myDelegate didClickMyRoomWithView:self dic:dic];
            }
        }
    }else if(indexPath.section == 2){
//        if (self.myRequestedRoomsList&&self.myRequestedRoomsList.count>0) {
//            [[Custom_tabbar showTabBar] hideTabBar:YES];
//            dic = [self.myRequestedRoomsList objectAtIndex:indexPath.row];
//            if ([self.myDelegate respondsToSelector:@selector(didClickRoomInfoWithView: dic:)]) {
//                [self.myDelegate didClickRoomInfoWithView:self dic:dic];
//            }
//        }
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(10, 8.0f, 13, 13)];
    [view addSubview:img];
    
    UILabel *label  =[[UILabel alloc]initWithFrame:CGRectMake(24, 0, 300, 29)];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentLeft;
    if (section ==0) {
        label.text =@"我创建的队伍";
        img.image = KUIImage(@"team_mine");
    }else if(section == 1){
        img.image = KUIImage(@"team_join");
        label.text = @"我加入的队伍";
    }else if(section == 2){
        img.image = KUIImage(@"team_join");
        label.text = @"我申请的队伍";
    }
    [view addSubview:label];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 29, 320, 1)];
    lineView.backgroundColor = UIColorFromRGBA(0xd8d8d8, 1);
    [view addSubview:lineView];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (section ==0) {
//        NSArray * arr = [self.listDict objectForKey:@"OwnedRooms"];
//        if (arr||[arr isKindOfClass:[NSArray class]]) {
//            return 30;
//        }else
//        {
//            return 0;
//        }
//    }else{
//        NSArray * arr = [self.listDict objectForKey:@"joinedRooms"];
//        if (arr&&[arr isKindOfClass:[NSArray class]]&&arr.count>0) {
//            return 30;
//        }else
//        {
//            return 0;
//        }
//    }
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section ==0) {
//        NSArray * arr = [self.listDict objectForKey:@"OwnedRooms"];
//        if (arr||[arr isKindOfClass:[NSArray class]]) {
//            return 60;
//        }else
//        {
//            return 0;
//        }
//    }else{
//        NSArray * arr = [self.listDict objectForKey:@"joinedRooms"];
//        if (arr||[arr isKindOfClass:[NSArray class]]) {
//            return 60;
//        }else
//        {
//            return 0;
//        }
//    }
    return 60;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section ==1) {
        UIView *view =[[ UIView alloc]init];
        view.backgroundColor = [UIColor whiteColor];
        UIImageView *headImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        headImg.image =KUIImage(@"team_history");
        [view addSubview:headImg];
        UILabel *label =[GameCommon buildLabelinitWithFrame:CGRectMake(60, 0, 200, 60) font:[UIFont boldSystemFontOfSize:15] textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        label.text = @"历史组队";
        [view addSubview:label];
        [self setOneLineWithY:0 view:view];
        [self setOneLineWithY:59 view:view];
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterHistoryReamList:)]];
        return view;
    }else{
        return nil;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        return @"解散";
    }else{
        return @"退出";
    }
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0) {
        NSArray *arr=[self.listDict objectForKey:@"OwnedRooms"];
        if ([arr isKindOfClass:[NSArray class]]&&arr.count>0) {
            return YES;
        }
        else{
            return NO;
        }
    }else if(indexPath.section == 1){
        NSArray *arr=[self.listDict objectForKey:@"joinedRooms"];
        if ([arr isKindOfClass:[NSArray class]]&&arr.count>0) {
            return YES;
        }
        else{
            return NO;
        }
    }else if(indexPath.section == 2){//我申请的队伍
        return NO;
    }
    return NO;
    
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        actionIndex = indexPath.row;
        if (indexPath.section ==0) {
            tableView.editing = NO;
            UIAlertView *jiesanAlert =[[ UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要解散队伍吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"必须解散", nil];
            jiesanAlert.tag = 10000001;
            [jiesanAlert show];
        }else if (indexPath.section ==1){
            tableView.editing = NO;
            UIAlertView *jiesanAlert =[[ UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要退出该队伍吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"必须退出", nil];
            jiesanAlert.tag =10000002;
            [jiesanAlert show];
        }
        else if (indexPath.section ==2){
            //TODO
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==10000001) {//解散队伍
        if (buttonIndex==1) {
            NSDictionary * dic = [self.myCreateRoomList objectAtIndex:actionIndex];
            if (self.myDelegate) {
                [self.myDelegate dissTeam:self dic:dic];
            }
        }
    }else{
        if (buttonIndex==1) {//退出队伍
            NSDictionary * dic = [self.myJoinRoomList objectAtIndex:actionIndex];
            if (self.myDelegate) {
                [self.myDelegate exitTeam:self dic:dic];
            }
        }
    }
}

-(void)enterHistoryReamList:(id)sender
{
    NSLog(@"查看历史组队");
}
- (void)setOneLineWithY:(float)frameY view:(UIView *)view
{
    UIImageView* lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, frameY, kScreenWidth, 2)];
    lineImg.image = KUIImage(@"line");
    lineImg.backgroundColor = [UIColor clearColor];
    [view addSubview:lineImg];
}

-(void)didRoleRomeve:(NSString*)characterId{
    NSMutableArray * teamArray = [self.myCreateRoomList mutableCopy];
    for (NSMutableDictionary * dic in teamArray) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"characterId")] isEqualToString:[GameCommon getNewStringWithId:characterId]]) {
            [self.myCreateRoomList removeObject:dic];
        }
    }
    NSMutableArray * teamArray2 = [self.myJoinRoomList mutableCopy];
    for (NSMutableDictionary * dic in teamArray2) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"characterId")] isEqualToString:[GameCommon getNewStringWithId:characterId]]) {
            [self.myJoinRoomList removeObject:dic];
        }
    }
    NSMutableArray * teamArray3 = [self.myRequestedRoomsList mutableCopy];
    for (NSMutableDictionary * dic in teamArray3) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"characterId")] isEqualToString:[GameCommon getNewStringWithId:characterId]]) {
            [self.myRequestedRoomsList removeObject:dic];
        }
    }
    [self.myListTableView reloadData];
}

#pragma mark -- 删除角色
-(void)roleRemove:(NSNotification*)notification{
    NSDictionary * msg = notification.userInfo;
    [self didRoleRomeve:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"characterId")]];
}

#pragma mark 该群组解散通知
- (void)onDisbandGroup:(NSNotification*)notification
{
    NSString * groupId = KISDictionaryHaveKey(notification.userInfo, @"groupId");
    [self DisbandTeam:groupId];
}
#pragma mark 被剔出该组队
- (void)onkickOffGroupGroup:(NSNotification*)notification
{
    NSString * groupId = KISDictionaryHaveKey(notification.userInfo, @"groupId");
    [self DisbandTeam:groupId];
}


-(void)DisbandTeam:(NSString*)groupId{
    
    NSMutableArray * teamArray = [self.myCreateRoomList mutableCopy];
    for (NSMutableDictionary * dic in teamArray) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"groupId")] isEqualToString:[GameCommon getNewStringWithId:groupId]]) {
            [self.myCreateRoomList removeObject:dic];
        }
    }
    NSMutableArray * teamArray2 = [self.myJoinRoomList mutableCopy];
    for (NSMutableDictionary * dic in teamArray2) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"groupId")] isEqualToString:[GameCommon getNewStringWithId:groupId]]) {
            [self.myJoinRoomList removeObject:dic];
        }
    }
    NSMutableArray * teamArray3 = [self.myRequestedRoomsList mutableCopy];
    for (NSMutableDictionary * dic in teamArray3) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"groupId")] isEqualToString:[GameCommon getNewStringWithId:groupId]]) {
            [self.myRequestedRoomsList removeObject:dic];
        }
    }
    [self.myListTableView reloadData];
}
- (void)addHeader
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = self.myListTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        if (self.myDelegate) {
            [self.myDelegate reloadRoomList];
        }
    };
    m_header = header;
}
- (void)dealloc
{
    self.myListTableView.delegate=nil;
    self.myListTableView.dataSource=nil;
}
@end
