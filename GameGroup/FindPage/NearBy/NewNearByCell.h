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
#import "commentCell.h"
@protocol NewNearByCellDelegate ;

@interface NewNearByCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource,CommentCellDelegate,UITableViewDataSource,UITableViewDelegate>
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


@property(nonatomic,strong)UILabel *zanNameLabel;  //赞Label
@property(nonatomic,strong)UIImageView *zanImageView;
@property(nonatomic,strong)UILabel *zanLabel;
@property(nonatomic,strong)UIImageView *zanView;
@property(nonatomic,strong)NSArray *commentArray;
@property(nonatomic,strong)NSArray *zanArray;
@property(nonatomic,strong)UITableView *commentTabelView;
@property(nonatomic,strong)UIButton *jubaoBtn;
@property(nonatomic,strong)UIButton *zanBtn;
@property(nonatomic,assign)NSInteger  commentCount;
@property(nonatomic,strong)UIButton *commentMoreBtn;
@property(nonatomic,strong)NSString *destUserStr;
@property(nonatomic,strong)UIButton *openBtn;
@property(nonatomic,strong)UIImageView *menuImageView;
+ (CGSize)getContentHeigthWithStr:(NSString*)contStr;
+ (CGSize)getTitleHeigthWithStr:(NSString*)contStr;


@property(nonatomic,assign)id<NewNearByCellDelegate>myCellDelegate;

+ (CGSize)getContentHeigthWithStr:(NSString*)contStr;
//@property(nonatomic,strong)
@end
@protocol NewNearByCellDelegate <NSObject>

- (void)bigImgWithCircle:(NewNearByCell*)myCell WithIndexPath:(NSInteger)row;

-(void)enterPersonPageWithCell:(NewNearByCell *)myCell;

-(void)changeShiptypeWithCell:(NewNearByCell*)myCell;

-(void)didClickToZan:(NewNearByCell*)myCell;
-(void)didClickToComment:(NewNearByCell*)myCell;

- (void)handleNickNameButton_HeadCell:(NewNearByCell*)cell withIndexPathRow:(NSInteger)row;

//评论点击事件
- (void)pinglunWithCircle:(NewNearByCell*)myCell;

//赞点击事件
- (void)zanWithCircle:(NewNearByCell*)myCell;

//传送msgid 获取
- (void)getmsgIdwithCircle:(NewNearByCell *)myCell withindexPath:(NSInteger)row;

//传送评论条点击事件
- (void)editCommentOfYouWithCircle:(NewNearByCell *)myCell withIndexPath:(NSInteger)row;

//传送评论者昵称点击事件
-(void)transferClickEventsWithCell:(NewNearByCell *)myCell withIndexPath:(NSInteger)row;


-(void)hiddenOrShowMenuImageViewWithCell:(NewNearByCell*)myCell;


-(void)enterCommentPageWithCell:(NewNearByCell *)myCell;

-(void)tapZanNickNameWithCell:(NewNearByCell *)myCell;


//传送显示的 评论，赞菜单的Cell
- (void)openMenuCell:(NewNearByCell*)myCell;

-(void)delCellWithCell:(NewNearByCell*)myCell;

-(void)jubaoThisInfoWithCell:(NewNearByCell*)myCell;

@end