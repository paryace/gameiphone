//
//  KKImgCell.h
//  GameGroup
//
//  Created by 魏星 on 14-4-7.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageButton.h"
#import "EGOImageView.h"
@interface KKImgCell : UITableViewCell
@property(nonatomic, strong) EGOImageButton * headImgV;
@property(nonatomic, strong) UILabel *senderAndTimeLabel;
@property(nonatomic,strong)EGOImageView *MSGImageView;
@end
