//
//  AddGroupMemberCell.h
//  GameGroup
//
//  Created by 魏星 on 14-6-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageButton.h"

@protocol addGroupMemberDelegate;

@interface AddGroupMemberCell : UITableViewCell
@property(nonatomic,strong)UIImageView *chooseImg;
@property(nonatomic,strong)EGOImageButton *headImg;
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UILabel *disLabel;
@property(nonatomic,assign)id<addGroupMemberDelegate>myDelegate;

@end
@protocol addGroupMemberDelegate <NSObject>

-(void)enterMembersInfoPageWithCell:(AddGroupMemberCell*)cell;

@end