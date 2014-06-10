//
//  GroupInfomationJsCell.h
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupInfoCellDelegate;

@interface GroupInfomationJsCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,strong)UICollectionViewFlowLayout *layout;
@property(nonatomic,strong)UICollectionView *photoView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel * contentLabel;
@property(nonatomic,strong)NSMutableArray *photoArray;
@property(nonatomic,assign)id<GroupInfoCellDelegate>myCellDelegate;
@end

@protocol GroupInfoCellDelegate <NSObject>

-(void)bigImgWithCircle:(GroupInfomationJsCell*)myCell WithIndexPath:(int)indexPath;

@end