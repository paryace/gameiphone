//
//  CommentCell.m
//  GameGroup
//
//  Created by 魏星 on 14-4-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.nicknameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,0, 100, 16)];
        self.nicknameLabel.textColor =  UIColorFromRGBA(0x455ca8, 1);
        self.nicknameLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.nicknameLabel];
        
        self.commentContLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 0, 100, 30)];
        self.commentContLabel.font = [UIFont systemFontOfSize:12];
        self.commentContLabel.numberOfLines = 0;
        [self.contentView addSubview:self.commentContLabel];
    }
    return self;
}
+ (CGSize)getcommentNickNameHeigthWithStr:(NSString*)contStr
{
    CGSize size1 =[[contStr stringByAppendingString:@":"] sizeWithFont:[UIFont boldSystemFontOfSize:12.0] constrainedToSize:CGSizeMake(200, 16) lineBreakMode:NSLineBreakByWordWrapping];
    return size1;
}
+ (CGSize)getcommentHeigthWithNIckNameStr:(NSString*)contStr Commentstr:(NSString *)str
{
    CGSize cSize = [str sizeWithFont:[UIFont boldSystemFontOfSize:12.0] constrainedToSize:CGSizeMake(250-[CommentCell getcommentNickNameHeigthWithStr:contStr].width, 300) lineBreakMode:NSLineBreakByWordWrapping];
    return cSize;
}

-(void)refreshCell
{
    CGSize size1 =[CommentCell getcommentNickNameHeigthWithStr:[self.comNickNameStr stringByAppendingString:@":"]];
    CGSize size2 = [CommentCell getcommentHeigthWithNIckNameStr:self.comNickNameStr Commentstr:self.commentStr];
    self.nicknameLabel.frame = CGRectMake(5, 0, size1.width, 16);
    self.commentContLabel.frame = CGRectMake(5+size1.width, 0,250-size1.width, size2.height);
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
