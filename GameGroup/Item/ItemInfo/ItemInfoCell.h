//
//  ItemInfoCell.h
//  GameGroup
//
//  Created by 魏星 on 14-7-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@protocol HeadClickDelegate;

@interface ItemInfoCell : UITableViewCell
@property(nonatomic,strong)EGOImageView *headImageView;
@property(nonatomic,strong)UIButton *bgImageView;
@property(nonatomic,strong)UIImageView *genderImgView;
@property(nonatomic,strong)UILabel *MemberLable;
@property(nonatomic,strong)EGOImageView *gameIconImgView;
@property(nonatomic,strong)UILabel *nickLabel;
@property(nonatomic,strong)UILabel *value1Lb;
@property(nonatomic,strong)UILabel *value2Lb;
@property(nonatomic,strong)UILabel *value3Lb;
@property(assign,nonatomic)id<HeadClickDelegate> delegate;

-(void)refreshViewFrameWithText:(NSString *)text;
@end

@protocol HeadClickDelegate <NSObject>

- (void)headImgClick:(ItemInfoCell*)Sender;

@end
