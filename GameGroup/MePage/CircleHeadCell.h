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
#import "CommentCell.h"

@protocol CircleHeadDelegate;

@interface CircleHeadCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,EGOImageViewDelegate>
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
@property(nonatomic,strong)UILabel *zanNameLabel;
@property(nonatomic,strong)UIImageView *zanImageView;
@property(nonatomic,strong)UILabel *zanLabel;
@property(nonatomic,strong)UIImageView *zanView;
@property(nonatomic,strong)UICollectionViewFlowLayout *layout;
@property(nonatomic,strong)UICollectionView *customPhotoCollectionView;
@property(nonatomic,strong)NSArray *collArray;
@property(nonatomic,strong)NSArray *commentArray;
@property(nonatomic,strong)NSArray *zanArray;
@property(nonatomic,strong)EGOImageView *oneImageView;
@property(nonatomic,strong)UITableView *commentTabelView;
@property(nonatomic,strong)UIButton *delBtn;
@property(nonatomic,strong)UIButton *zanBtn;
@property(nonatomic,strong)UIButton *commentBtn;



+ (CGSize)getContentHeigthWithStr:(NSString*)contStr;
- (void)refreshCell:(NSInteger)hieght;
@end
@protocol CircleHeadDelegate <NSObject>

//评论点击事件
- (void)pinglunWithCircle:(CircleHeadCell*)myCell;

//赞点击事件
- (void)zanWithCircle:(CircleHeadCell*)myCell;

//传送collectionview点击事件 获取大图
- (void)bigImgWithCircle:(CircleHeadCell*)myCell WithIndexPath:(NSInteger)row;

//传送msgid 获取
- (void)getmsgIdwithCircle:(CircleHeadCell *)myCell withindexPath:(NSInteger)row;

//传送评论条点击事件
- (void)editCommentOfYouWithCircle:(CircleHeadCell *)myCell withIndexPath:(NSInteger)row;

//传送评论者昵称点击事件
-(void)transferClickEventsWithCell:(CircleHeadCell *)myCell withIndexPath:(NSInteger)row;


-(void)hiddenOrShowMenuImageViewWithCell:(CircleHeadCell*)myCell;

//传送显示的 评论，赞菜单的Cell
- (void)openMenuCell:(CircleHeadCell*)myCell;

-(void)delCellWithCell:(CircleHeadCell*)myCell;



@end



