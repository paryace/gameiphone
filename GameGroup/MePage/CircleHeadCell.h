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

@interface CircleHeadCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,CommentCellDelegate,EGOImageViewDelegate>
@property(nonatomic,strong)EGOImageButton *headImgBtn;
@property(nonatomic,strong)UILabel *nickNameLabel;
@property(nonatomic,strong)UILabel *titleLabel; //动态内容
@property(nonatomic,strong)UILabel *contentLabel;   //文章
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)UILabel *lastLabel;//XXX发表了 、分享了XXX
@property(nonatomic,copy)NSString *commentStr;//评论内容
@property(nonatomic,strong)UIButton * shareView;//如果来自后台分享 展示此界面
@property(nonatomic,strong)UIButton *openBtn; //展开菜单“。。。”
@property(nonatomic,strong)UIImageView *menuImageView;//点击展开评论和赞
@property(nonatomic,strong)EGOImageView *shareImgView;//后台分享的图片
@property(nonatomic,assign)id<CircleHeadDelegate>myCellDelegate;
@property(nonatomic,strong)UILabel *zanNameLabel;  //赞Label
@property(nonatomic,strong)UIImageView *zanImageView;
@property(nonatomic,strong)UILabel *zanLabel;
@property(nonatomic,strong)UIImageView *zanView;
@property(nonatomic,strong)UICollectionViewFlowLayout *layout;
@property(nonatomic,strong)UICollectionView *customPhotoCollectionView;
@property(nonatomic,strong)NSArray *collArray;//图片数组
@property(nonatomic,strong)NSArray *commentArray;
@property(nonatomic,strong)NSArray *zanArray;
@property(nonatomic,strong)UITableView *commentTabelView;
@property(nonatomic,strong)UIButton *delBtn;
@property(nonatomic,strong)UIButton *zanBtn;
@property(nonatomic,strong)UIButton *commentBtn;
@property(nonatomic,assign)NSInteger  commentCount;
@property(nonatomic,strong)UIButton *commentMoreBtn;
@property(nonatomic,strong)NSString *destUserStr;
+ (CGSize)getContentHeigthWithStr:(NSString*)contStr;
+ (CGSize)getTitleHeigthWithStr:(NSString*)contStr;

-(void)getImgWithArray:(NSArray *)array;

-(void)getCommentArray:(NSArray *)array;




//- (void)refreshCell:(NSInteger)hieght;
@end
@protocol CircleHeadDelegate <NSObject>

//CommentCell中得NickNameButton被点击
- (void)handleNickNameButton_HeadCell:(CircleHeadCell*)cell withIndexPathRow:(NSInteger)row;

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


-(void)enterCommentPageWithCell:(CircleHeadCell *)myCell;

-(void)tapZanNickNameWithCell:(CircleHeadCell *)myCell;


//传送显示的 评论，赞菜单的Cell
- (void)openMenuCell:(CircleHeadCell*)myCell;

-(void)delCellWithCell:(CircleHeadCell*)myCell;



@end



