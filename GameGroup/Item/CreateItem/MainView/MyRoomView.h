//
//  MyRoomView.h
//  GameGroup
//
//  Created by 魏星 on 14-7-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyroomDelegate;

@interface MyRoomView : UIView<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView *myListTableView;
@property(nonatomic,strong)NSMutableDictionary *listDict;
@property(nonatomic,assign)id<MyroomDelegate>myDelegate;
@end

@protocol MyroomDelegate <NSObject>

-(void)didClickMyRoomWithView:(MyRoomView*)view dic:(NSDictionary *)dic;

@end
