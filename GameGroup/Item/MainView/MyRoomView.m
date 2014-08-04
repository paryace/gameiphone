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

@implementation MyRoomView{
    NSInteger actionIndex;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.myListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, frame.size.height) style:UITableViewStylePlain];
        self.myListTableView.delegate = self;
        self.myListTableView.dataSource = self;
        
        
        
        [self addSubview:self.myListTableView];
    }
    return self;
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
    switch (section) {
        case 0:
            return [[self.listDict objectForKey:@"OwnedRooms"] count];
            break;
        case 1:
            return [[self.listDict objectForKey:@"joinedRooms"] count];
            break;
            
        default:
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        static NSString *indifience = @"cell1";
        ICreatedCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
        if (!cell) {
            cell = [[ICreatedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
        }
       NSDictionary * dic = [[self.listDict objectForKey:@"OwnedRooms"] objectAtIndex:indexPath.row];
        cell.titleLabel.text =[NSString stringWithFormat:@"[%@/%@]%@的队伍",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberCount")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"maxVol")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"nickname")]];
        
        cell.gameIconImageView.imageURL = [ImageService getImageUrl4:[GameCommon putoutgameIconWithGameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")]]];
        cell.realmLabel.text = [NSString stringWithFormat:@"%@-%@",KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"realm"),KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"type"), @"value")];
        NSInteger msgCount = [DataStoreManager getTeamNotifityMsgCount:@"0" GroupId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"groupId")]];
        cell.numLabel.text = [NSString stringWithFormat:@"%d",msgCount];
        return cell;
        
    }else{
        static NSString *indifience = @"cell";
        BaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
        if (!cell) {
            cell = [[BaseItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
        }

       NSDictionary * dic = [[self.listDict objectForKey:@"joinedRooms"] objectAtIndex:indexPath.row];
        cell.headImg.placeholderImage = KUIImage(@"placeholder");
        NSString *imageids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"img")];
        cell.headImg.imageURL =[ImageService getImageStr2:imageids] ;
        
        NSString *title = [NSString stringWithFormat:@"[%@/%@]%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberCount")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"maxVol")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"nickname")]];
        cell.titleLabel.text = title;
        //    cell.titleLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"nickname")];
        cell.contentLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"description")];
        
        NSString *timeStr = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];
        NSString *personStr = [NSString stringWithFormat:@"%@/%@人",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberCount")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"maxVol")]];
        
        cell.timeLabel.text = [NSString stringWithFormat:@"%@|%@",timeStr,personStr];
        return cell;

    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    
    NSDictionary *dic;
    if (indexPath.section ==0) {
        dic = [[self.listDict objectForKey:@"OwnedRooms"] objectAtIndex:indexPath.row];
    }else{
        dic = [[self.listDict objectForKey:@"joinedRooms"] objectAtIndex:indexPath.row];
        
    }
    
    
    if ([self.myDelegate respondsToSelector:@selector(didClickMyRoomWithView: dic:)]) {
        [self.myDelegate didClickMyRoomWithView:self dic:dic];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    UILabel *label  =[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 300, 30)];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentLeft;
    if (section ==0) {
        label.text =@"我创建的队伍";
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterCreatePage:)]];
    }else{
        label.text = @"我加入的队伍";
    }
    [view addSubview:label];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        NSArray * arr = [self.listDict objectForKey:@"OwnedRooms"];
        if (arr||[arr isKindOfClass:[NSArray class]]) {
            return 30;
        }else
        {
            return 0;
        }
    }else{
        NSArray * arr = [self.listDict objectForKey:@"joinedRooms"];
        if (arr&&[arr isKindOfClass:[NSArray class]]&&arr.count>0) {
            return 30;
        }else
        {
            return 0;
        }
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        NSArray * arr = [self.listDict objectForKey:@"OwnedRooms"];
        if (arr||[arr isKindOfClass:[NSArray class]]) {
            return 60;
        }else
        {
            return 0;
        }
    }else{
        NSArray * arr = [self.listDict objectForKey:@"joinedRooms"];
        if (arr||[arr isKindOfClass:[NSArray class]]) {
            return 60;
        }else
        {
            return 0;
        }
    }

}
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section ==1) {
        UIView *view =[[ UIView alloc]init];
        view.backgroundColor = [UIColor whiteColor];
        UIImageView *headImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        headImg.image =KUIImage(@"clazz_11");
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
    if (section==0) {
        return 0;
    }else{
        return 60;
    }
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
    return YES;
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
        }else{
            tableView.editing = NO;
            UIAlertView *jiesanAlert =[[ UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要退出该队伍吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"必须退出", nil];
            jiesanAlert.tag =10000002;
            [jiesanAlert show];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==10000001) {//解散队伍
        if (buttonIndex==1) {
            NSDictionary * dic = [[self.listDict objectForKey:@"OwnedRooms"] objectAtIndex:actionIndex];
            if (self.myDelegate) {
                [self.myDelegate dissTeam:self dic:dic];
            }
        }
    }else{
        if (buttonIndex==1) {//退出队伍
            NSDictionary * dic = [[self.listDict objectForKey:@"joinedRooms"] objectAtIndex:actionIndex];
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
- (void)dealloc
{
    self.myListTableView.delegate=nil;
    self.myListTableView.dataSource=nil;
}
@end
