//
//  AddTeamMsgPushController.h
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//
#import "BaseViewController.h"
#import "CharacterView.h"
#import "SelectCharacterCell.h"
#import "SelectOtherCell.h"
#import "PowerableCell.h"
#import "TypeView.h"
#import "DWTagList.h"
#import "TagView.h"
#import "TeamTagCell.h"

@interface AddTeamMsgPushController : BaseViewController<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate,CharacterDelegate,SwitchDelegate,TypeDelegate,TagDelegate>
@property (assign, nonatomic)  BOOL ifOpen;
@property(nonatomic,strong) UITableView*  m_TableView;
@property(nonatomic,strong) CharacterView * characterView;
@property(nonatomic,strong) TypeView * typeView;
@property(nonatomic,strong) TagView * tagView;
@property(nonatomic,copy) NSString * type;
@property(nonatomic,strong) NSMutableDictionary * selectRoleDict;
@property(nonatomic,strong) NSMutableDictionary * selectTypeDict;
@property(nonatomic,strong) NSMutableDictionary * selectTagDict;
@property(nonatomic,copy) NSString * selectGender;
@property(nonatomic,copy) NSString * selectPowerable;
@property(nonatomic,strong) NSMutableDictionary * updatePreferInfoDic;

@property(nonatomic,strong) NSMutableArray * tagArray;
@end
