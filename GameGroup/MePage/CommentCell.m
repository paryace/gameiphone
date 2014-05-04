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
        self.nicknameButton = [[UIButton alloc]initWithFrame:CGRectMake(5,0, 100, 16)];
        self.nicknameButton.titleLabel.textColor =  UIColorFromRGBA(0x455ca8, 1);
        [self.contentView addSubview:self.nicknameButton];
        self.nicknameButton.hidden = YES;
        
        self.commentContLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 0, 100, 30)];
        self.commentContLabel.font = [UIFont systemFontOfSize:12];
        self.commentContLabel.numberOfLines = 0;
        [self.contentView addSubview:self.commentContLabel];
    }
    return self;
}

//显示可点击的呢称
-(void)showNickNameButton:(NSString *)nickName;
{
    // 实现可点击昵称的原理
    // 生成一个Button覆盖在文字之上， 写着相同的内容。 响应点击。
	CGPoint outputPoint = CGPointZero;
    NSLog(@"***********当前commentCell的坐标%f,%f,%f,%f",self.frame.origin.x,self.frame.origin.y,
          self.frame.size.width,self.frame.size.height);
    NSLog(@"***********当前commentContLabel的坐标%f,%f,%f,%f",self.commentContLabel.frame.origin.x,self.commentContLabel.frame.origin.y,
          self.commentContLabel.frame.size.width,self.commentContLabel.frame.size.height);
    CGSize textSize =[self.commentStr sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(245, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
	CGRect bounds = [self bounds];
	if (textSize.height < bounds.size.height)
	{
		// the lines of text are centered in the bounds, so adjust the output point
		CGFloat boundsMidY = CGRectGetMidY(bounds);
		CGFloat textMidY = textSize.height / 2.0;
		outputPoint.y = ceilf(boundsMidY - textMidY);
	}
    
    //创建按钮
    UIFont *font = self.commentContLabel.font;
    CGSize matchSize = [nickName sizeWithFont:font];
    
    CGRect matchFrame = CGRectMake(2,0, matchSize.width + 6.0f, matchSize.height);
    [self.nicknameButton setFrame:matchFrame];
	[self.nicknameButton.titleLabel setFont:font];
	[self.nicknameButton setTitle:nickName forState:UIControlStateNormal];
	[self.nicknameButton.titleLabel setLineBreakMode:[self.commentContLabel lineBreakMode]];
	//[self.nicknameButton  setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
	//[self.nicknameButton setTitleColor:self.highlightColor forState:UIControlStateHighlighted];
	[self.nicknameButton addTarget:self action:@selector(handleNickNameButton:) forControlEvents:UIControlEventTouchUpInside];
    self.nicknameButton.hidden = NO;
}

//点击昵称
- (void)handleNickNameButton:(id)cell
{
   
    [self.myCommentCellDelegate handleNickNameButton:self];
}


+ (CGSize)getCellHeigthWithStr:(NSString*)contStr
{
    CGSize size1 =[contStr sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(245, MAXFLOAT)lineBreakMode:NSLineBreakByWordWrapping];
    return size1;
}

-(void)refreshsCell
{
    CGSize size1 =[CommentCell getCellHeigthWithStr:[NSString stringWithFormat:@"%@",self.commentStr]];
    self.commentContLabel.frame = CGRectMake(5, 0, 245, size1.height);
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
