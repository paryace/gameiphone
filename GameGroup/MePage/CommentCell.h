//
//  CommentCell.h
//  GameGroup
//
//  Created by 魏星 on 14-4-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"


@protocol CommentCellDelegate;

@interface CommentCell : UITableViewCell<OHAttributedLabelDelegate>
@property(nonatomic,assign)id<CommentCellDelegate>myCommentCellDelegate;
@property(nonatomic,strong)UIButton *nicknameButton;
@property(nonatomic,copy)NSString *commentStr;
@property(nonatomic,copy)NSString *comNickNameStr;
@property (nonatomic, retain) OHAttributedLabel *commentContLabel;
-(void)refreshsCell;
//显示可点击的呢称
-(void)showNickNameButton:(NSString *)nickName withSize:(CGSize)commentstrSize;
+ (CGSize)getCellHeigthWithStr:(NSString*)contStr;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
+(NSMutableAttributedString*)GetAttributedCommentWithStr:(NSString*)Str;
@end




@protocol CommentCellDelegate <NSObject>
//点击昵称 代理 
- (void)handleNickNameButton:(CommentCell*)cell;
@end
