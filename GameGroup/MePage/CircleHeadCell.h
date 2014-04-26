//
//  CircleHeadCell.h
//  GameGroup
//
//  Created by 魏星 on 14-4-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageButton.h"
#import "EGOImageView.h"
@protocol CircleHeadDelegate;

@interface CircleHeadCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong)EGOImageButton *headImgBtn;
@property(nonatomic,strong)UILabel *nickNameLabel;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *contentLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)UILabel *lastLabel;//XXX发表了 、分享了XXX
@property(nonatomic,copy)NSString *commentStr;
@property(nonatomic,strong)UIView * shareView;
@property(nonatomic,strong)UIButton *openBtn;
@property(nonatomic,strong)UIImageView *menuImageView;
@property(nonatomic,strong)EGOImageView *shareImgView;
@property(nonatomic,assign)id<CircleHeadDelegate>myCellDelegate;
@property(nonatomic,strong)UIImageView *commentsView;
@property(nonatomic,strong)UILabel*commentsLabel;
@property(nonatomic,strong)UILabel *commNameLabel;
@property(nonatomic,strong)UILabel *zanNameLabel;
@property(nonatomic,strong)UIImageView *zanImageView;
@property(nonatomic,strong)UILabel *zanLabel;
@property(nonatomic,strong)UILabel *sayAllcommentsLabel;
@property(nonatomic,strong)UIImageView *zanView;
@property(nonatomic,strong)UICollectionViewFlowLayout *layout;
@property(nonatomic,strong)UICollectionView *customPhotoCollectionView;
@property(nonatomic,strong)NSArray *collArray;
@property(nonatomic,strong)NSArray *commentArray;
@property(nonatomic,strong)NSArray *zanArray;


+ (CGSize)getContentHeigthWithStr:(NSString*)contStr;
- (void)refreshCell:(NSInteger)hieght;
@end
@protocol CircleHeadDelegate <NSObject>

- (void)pinglunWithCircle:(CircleHeadCell*)myCell;
- (void)zanWithCircle:(CircleHeadCell*)myCell;
- (void)bigImgWithCircle:(CircleHeadCell*)myCell WithIndexPath:(NSInteger)row;
@end



