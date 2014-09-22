//
//  WorldCell.h
//  GameGroup
//
//  Created by Marss on 14-9-15.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageButton.h"
#import "EGOImageView.h"
#import "commentCell.h"
@protocol WorldCellDelegate ;

@interface WorldCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource,CommentCellDelegate,UITableViewDataSource,UITableViewDelegate>
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
//区域lebel
@property(nonatomic,strong)UILabel *areaLabel;
@property(nonatomic,strong)UIImageView *areaIcon;
//标准label，参照的是举报按钮的frame
@property(nonatomic,strong)UIButton *ETBtn;
//加好友button
@property(nonatomic,strong)UIButton *makeFriendBtn;
+ (CGSize)getContentHeigthWithStr:(NSString*)contStr;
+ (CGSize)getTitleHeigthWithStr:(NSString*)contStr;

@property(nonatomic,assign)id<WorldCellDelegate>myCellDelegate;


//@property(nonatomic,strong)
@end
@protocol WorldCellDelegate <NSObject>

- (void)bigImgWithCircle:(WorldCell*)myCell WithIndexPath:(NSInteger)row;

-(void)enterPersonPageWithCell:(WorldCell *)myCell;

-(void)changeShiptypeWithCell:(WorldCell*)myCell;

-(void)didClickToZan:(WorldCell*)myCell;
-(void)didClickToComment:(WorldCell*)myCell;

- (void)handleNickNameButton_HeadCell:(WorldCell*)cell withIndexPathRow:(NSInteger)row;

//评论点击事件
- (void)pinglunWithCircle:(WorldCell*)myCell;

//赞点击事件
- (void)zanWithCircle:(WorldCell*)myCell;

//传送msgid 获取
- (void)getmsgIdwithCircle:(WorldCell *)myCell withindexPath:(NSInteger)row;

//传送评论条点击事件
- (void)editCommentOfYouWithCircle:(WorldCell *)myCell withIndexPath:(NSInteger)row;

//传送评论者昵称点击事件
-(void)transferClickEventsWithCell:(WorldCell *)myCell withIndexPath:(NSInteger)row;


-(void)hiddenOrShowMenuImageViewWithCell:(WorldCell*)myCell;


-(void)enterCommentPageWithCell:(WorldCell *)myCell;

-(void)tapZanNickNameWithCell:(WorldCell *)myCell;

-(void)TapMiss;//点击collectionview收回键盘

//传送显示的 评论，赞菜单的Cell
- (void)openMenuCell:(WorldCell*)myCell;

-(void)delCellWithCell:(WorldCell*)myCell;

-(void)jubaoThisInfoWithCell:(WorldCell*)myCell;

@end

