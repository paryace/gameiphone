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
#import "SortingView.h"
#import "DropDownListView.h"

@protocol firstViewDelegate;
@interface FirstView : UIView<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,DropDownChooseDelegate,DropDownChooseDataSource,DWTagDelegate,sortingDelegate>
{
    DWTagList *tagList;
}
@property(nonatomic,strong)DropDownListView *dropDownView;
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)UIButton *searchRoomBtn;
@property(nonatomic,strong)NSMutableArray *firstDataArray;
@property(nonatomic,assign)id<firstViewDelegate>myDelegate;
@property(nonatomic,strong)UILabel * personCountLb;
@property(nonatomic,strong)UILabel * teamCountLb;
@property(nonatomic,strong)NSMutableDictionary * selectCharacter ;//角色
@property(nonatomic,strong)NSMutableDictionary * selectType;//分类
@property(nonatomic,strong)NSMutableDictionary * selectFilter;//筛选
@property(nonatomic,copy)NSString * selectPreferenceId;
-(void)receiveMsg:(NSDictionary *)msg;
-(void)readMsg:(NSString *)gameId PreferenceId:(NSString*)preferenceId;


-(void)showFilterMenu;
-(void)updateFilterId:(id)responseObject;
-(void)showErrorAlertView:(id)error;
-(void)reloInfo:(BOOL)isRefre;
-(void)didClickScreen;//筛选
-(void)initSearchConditions;//使用上次的搜索条件搜索
-(void)InitializeInfo:(NSDictionary*)mainDict;//拿偏好页面的条件搜索

@end

@protocol firstViewDelegate <NSObject>

-(void)enterSearchRoomPageWithView:(FirstView *)view;
-(void)refreWithRow:(NSInteger)row;
-(void)enterEditPageWithRow:(NSInteger)row isRow:(BOOL)isrow;
-(void)didClickPreferenceToNetWithRow:(NSInteger)row;
-(void)didClickTableViewCellEnterNextPageWithController:(UIViewController *)vc;
-(void)didClickSuccessWithText:(NSString *)text tag:(NSInteger)tag;

@end
