//
//  MemberView.h
//  GameGroup
//
//  Created by 魏星 on 14-7-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface MemberView : UIView
@property(nonatomic,strong)EGOImageView *headImageView;
@property(nonatomic,strong)UIImageView *genderImgView;
@property(nonatomic,strong)UIImageView *MemberImgView;
@property(nonatomic,strong)EGOImageView *gameIconImgView;
@property(nonatomic,strong)UILabel *nickLabel;
@property(nonatomic,strong)UILabel *value1Lb;
@property(nonatomic,strong)UILabel *value2Lb;
@property(nonatomic,strong)UILabel *value3Lb;
-(void)refreshViewFrameWithText:(NSString *)text;

@end
