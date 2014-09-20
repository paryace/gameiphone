//
//  ShareDynamicView.h
//  GameGroup
//
//  Created by Apple on 14-9-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface ShareDynamicView : UIView
@property (strong,nonatomic) UIView * m_shareView;
@property (strong,nonatomic) UIView * m_shareViewBg;
@property (strong,nonatomic) UILabel * titleLabel;
@property (strong,nonatomic) EGOImageView* thumb;
@property (strong,nonatomic) UILabel* contentLabel;
@property (strong,nonatomic) UIButton* cancelBtn;
@property (strong,nonatomic) UIButton* sendBtn;
@property (strong,nonatomic) UILabel* sharePeopleLabel;
-(void)setTextToView:(NSMutableDictionary*)msgDic type:(NSInteger)type;
-(void)showSelf;
-(void)hideSelf;
@end
