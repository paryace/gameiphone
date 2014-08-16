//
//  InDoduAddressTableViewCell.h
//  GameGroup
//
//  Created by wangxr on 14-3-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DodeAddressCellDelegate.h"
#import "EGOImageView.h"
@protocol DetailDelegate;

@interface InDoduAddressTableViewCell : UITableViewCell
@property (nonatomic,assign) id<DetailDelegate>delegate;
@property (nonatomic,retain) NSIndexPath * indexPath;
@property (nonatomic,retain) UILabel * nameL;
@property (nonatomic,retain) UILabel * photoNoL;
@property (nonatomic,retain) UIButton * addFriendB;
@property (nonatomic,retain) EGOImageView * headerImage;
@property (assign, nonatomic) BOOL isSearch;
@end

@protocol DetailDelegate <NSObject>
-(void)DodeAddressCellTouchButtonWithIndexPath:(NSIndexPath *)indexPath IsSearch:(BOOL)isSearch;
@end