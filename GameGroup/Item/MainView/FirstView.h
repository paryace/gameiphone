//
//  FirstView.h
//  GameGroup
//
//  Created by 魏星 on 14-7-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstCell.h"

@protocol firstViewDelegate;
@interface FirstView : UIView<UITableViewDataSource,UITableViewDelegate,firstCellDelegate>
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)UIButton *searchRoomBtn;
@property(nonatomic,assign)id<firstViewDelegate>myDelegate;
@end

@protocol firstViewDelegate <NSObject>

-(void)enterSearchRoomPageWithView:(FirstView *)view;

@end
