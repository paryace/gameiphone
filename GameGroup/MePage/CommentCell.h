//
//  CommentCell.h
//  GameGroup
//
//  Created by 魏星 on 14-4-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CommentCell : UITableViewCell
//@property(nonatomic,strong)UILabel *nicknameLabel;
@property(nonatomic,strong)UILabel *commentContLabel;
@property(nonatomic,copy)NSString *commentStr;
@property(nonatomic,copy)NSString *comNickNameStr;
-(void)refreshsCell;
+ (CGSize)getcommentNickNameHeigthWithStr:(NSString*)contStr;
@end

