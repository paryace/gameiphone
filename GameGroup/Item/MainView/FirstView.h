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
@property(nonatomic,strong)NSMutableArray *firstDataArray;
@property(nonatomic,assign)id<firstViewDelegate>myDelegate;
@property(nonatomic,strong)UILabel * personCountLb;
@property(nonatomic,strong)UILabel * teamCountLb;
@end

@protocol firstViewDelegate <NSObject>

-(void)enterSearchRoomPageWithView:(FirstView *)view;
-(void)enterEditPageWithRow:(NSInteger)row isRow:(BOOL)isrow;
-(void)didClickPreferenceToNetWithRow:(NSInteger)row;
@end
