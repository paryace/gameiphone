//
//  EditPhotoCell.h
//  GameGroup
//
//  Created by 魏星 on 14-6-17.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface EditPhotoCell : UICollectionViewCell
@property(nonatomic,strong)EGOImageView *photoImageView;
@property(nonatomic,strong)UIButton *delBtn;
@end
