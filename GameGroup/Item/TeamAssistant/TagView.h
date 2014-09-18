//
//  TagView.h
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagCell.h"
@protocol TagDelegate;
@interface TagView : UIView<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate,TagOnCLicklDelegate>
@property(nonatomic,strong)NSMutableArray * tagArray;
@property(nonatomic,strong)UICollectionViewFlowLayout *layout;
@property(nonatomic,strong)UICollectionView *customPhotoCollectionView;
-(void)setDate:(NSMutableArray*)tagArray;
@property(nonatomic,assign)id<TagDelegate>tagDelegate;
-(void)hiddenSelf;
-(void)showSelf;
@end
@protocol TagDelegate <NSObject>
-(void)tagType:(NSMutableDictionary *)tagDic;
@end