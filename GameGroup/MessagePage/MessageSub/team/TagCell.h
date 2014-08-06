//
//  TagCell.h
//  GameGroup
//
//  Created by Apple on 14-8-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TagOnCLicklDelegate;

@interface TagCell : UICollectionViewCell
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UIButton *bgImgView;
@property(nonatomic,assign)id<TagOnCLicklDelegate>delegate;

@end
@protocol TagOnCLicklDelegate <NSObject>

-(void)tagOnClick:(TagCell*)sender;

@end