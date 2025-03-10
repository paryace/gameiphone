//
//  CreateTeamController.h
//  GameGroup
//
//  Created by Apple on 14-8-26.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "EGOImageView.h"
#import "SelectCharacterView.h"
#import "SelectTypeAndNumberPersonView.h"
#import "DWTagList.h"
#import "CharacterView.h"
#import "TeamInvitationController.h"
#import "TagCell.h"

@interface CreateTeamController : BaseViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITextViewDelegate,UIAlertViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,SelectCharacterDelegate,SelectTypeDelegate,CharacterDelegate,TagOnCLicklDelegate>
@property(nonatomic,strong)NSMutableDictionary *selectRoleDict;
@property(nonatomic,strong)NSMutableDictionary *selectTypeDict;
@end
