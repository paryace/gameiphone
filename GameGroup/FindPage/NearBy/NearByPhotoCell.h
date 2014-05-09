//
//  NearByPhotoCell.h
//  GameGroup
//
//  Created by 魏星 on 14-5-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface NearByPhotoCell : UICollectionViewCell
@property(nonatomic,strong)EGOImageView *photoView;
@property(nonatomic,strong)UIView *lestView;
@property(nonatomic,strong)UIImageView *tagImageView;
@property(nonatomic,strong)UILabel *distanceLabel;
@property(nonatomic,strong)UIImageView *sexImageView;
@end
