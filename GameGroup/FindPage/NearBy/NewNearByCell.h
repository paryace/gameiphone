//
//  NewNearByCell.h
//  GameGroup
//
//  Created by 魏星 on 14-5-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageButton.h"
#import "EGOImageView.h"

@protocol NewNearByCellDelegate ;

@interface NewNearByCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong)EGOImageButton *headImgBtn;//头像
@property(nonatomic,strong)UILabel *nickNameLabel;//昵称
@property(nonatomic,strong)UILabel *titleLabel;//内容
@property(nonatomic,strong)UIButton *focusButton;//关注button
@property(nonatomic,strong)UIButton *commentBtn;//评论butotn
@property(nonatomic,strong)UIButton *zanButton;//赞button
@property(nonatomic,strong)UILabel *timeLabel;//发表时间
@property(nonatomic,strong)UIButton *shareView;//后台推送显示背景
@property(nonatomic,strong)EGOImageView *shareImageView;//后台推送显示图片
@property(nonatomic,strong)UILabel *shareInfoLabel;//后台推送内容
@property(nonatomic,strong)UICollectionView *photoCollectionView;//发表照片墙
@property(nonatomic,strong)UICollectionViewFlowLayout *layout;
@property(nonatomic,strong)NSArray *photoArray;


@property(nonatomic,assign)id<NewNearByCellDelegate>myCellDelegate;

+ (CGSize)getContentHeigthWithStr:(NSString*)contStr;
//@property(nonatomic,strong)
@end
@protocol NewNearByCellDelegate <NSObject>

- (void)bigImgWithCircle:(NewNearByCell*)myCell WithIndexPath:(NSInteger)row;

-(void)enterPersonPageWithCell:(NewNearByCell *)myCell;

-(void)changeShiptypeWithCell:(NewNearByCell*)myCell;
@end