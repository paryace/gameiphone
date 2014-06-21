//
//  ReusableView.h
//  GameGroup
//
//  Created by 魏星 on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@protocol GroupBillBoardDeleGate;

@interface ReusableView : UICollectionReusableView
@property (nonatomic, strong) UILabel *label;
@property (nonatomic,strong)EGOImageView *headImageView;
@property (nonatomic,strong)UILabel *contentLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)UIButton *topBtn;
@property(nonatomic,strong)UILabel * topLabel;
@property(nonatomic,strong)UIImageView * roghtImage;
@property(nonatomic,strong)UIImageView * gbMsgCountImageView;
@property(nonatomic,strong)UILabel * gbMsgCountLable;

@property(nonatomic,assign)id<GroupBillBoardDeleGate>delegate;

-(void)setInfo:(NSDictionary*)dict setMsgCount:(NSInteger)msgCount;

@end

@protocol GroupBillBoardDeleGate <NSObject>
//点击
-(void)onClick:(UIButton*)sender;

@end
