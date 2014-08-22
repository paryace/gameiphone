//
//  MyRoomView.h
//  GameGroup
//
//  Created by 魏星 on 14-7-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseItemCell.h"

@protocol MyroomDelegate;

@interface MyRoomView : UIView<UITableViewDataSource,UITableViewDelegate,teamlistCellDelegate>
@property(nonatomic,strong)UITableView *myListTableView;
@property(nonatomic,strong)NSMutableDictionary *listDict;
@property(nonatomic,strong)NSMutableArray *myCreateRoomList;
@property(nonatomic,strong)NSMutableArray *myJoinRoomList;
@property(nonatomic,strong)NSMutableArray *myRequestedRoomsList;

@property(nonatomic,assign)id<MyroomDelegate>myDelegate;

-(void)initMyRoomListData:(NSMutableDictionary*)dic;
-(void)stopRefre;
@end

@protocol MyroomDelegate <NSObject>

-(void)didClickMyRoomWithView:(MyRoomView*)view dic:(NSDictionary *)dic;

-(void)didClickRoomInfoWithView:(MyRoomView*)view dic:(NSDictionary *)dic;

-(void)didClickCreateTeamWithView:(MyRoomView *)view ;

-(void)dissTeam:(MyRoomView *)view dic:(NSDictionary *)dic;//解散队伍

-(void)exitTeam:(MyRoomView *)view dic:(NSDictionary *)dic;//退出队伍

-(void)didClickTableViewCellEnterNextPageWithController:(UIViewController *)vc;


-(void)reloadRoomList;//刷新
@end
