//
//  CommentCell.h
//  GameGroup
//
//  Created by 魏星 on 14-4-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CommentCellDelegate;

@interface CommentCell : UITableViewCell
@property(nonatomic,assign)id<CommentCellDelegate>myCommentCellDelegate;
@property(nonatomic,strong)UIButton *nicknameButton;
@property(nonatomic,strong)UILabel *commentContLabel;
@property(nonatomic,copy)NSString *commentStr;
@property(nonatomic,copy)NSString *comNickNameStr;
-(void)refreshsCell;
//显示可点击的呢称
-(void)showNickNameButton:(NSString *)nickName;
+ (CGSize)getCellHeigthWithStr:(NSString*)contStr;
@end


@protocol CommentCellDelegate <NSObject>
//点击昵称 代理 
- (void)handleNickNameButton:(CommentCell*)cell;
@end
