//
//  FirstView.h
//  GameGroup
//
//  Created by 魏星 on 14-7-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstCell.h"
#import "ChooseTab.h"
#import "DropDownChooseDelegate.h"
#import "DWTagList.h"

@protocol firstViewDelegate;
@interface FirstView : UIView<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,DropDownChooseDelegate,DropDownChooseDataSource,DWTagDelegate>
{
    DWTagList *tagList;
}

@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)UIButton *searchRoomBtn;
@property(nonatomic,strong)NSMutableArray *firstDataArray;
@property(nonatomic,assign)id<firstViewDelegate>myDelegate;
@property(nonatomic,strong)UILabel * personCountLb;
@property(nonatomic,strong)UILabel * teamCountLb;

-(void)receiveMsg:(NSDictionary *)msg;
-(void)readMsg:(NSString *)gameId PreferenceId:(NSString*)preferenceId;
@end

@protocol firstViewDelegate <NSObject>

-(void)enterSearchRoomPageWithView:(FirstView *)view;
-(void)refreWithRow:(NSInteger)row;
-(void)enterEditPageWithRow:(NSInteger)row isRow:(BOOL)isrow;
-(void)didClickPreferenceToNetWithRow:(NSInteger)row;
@end
