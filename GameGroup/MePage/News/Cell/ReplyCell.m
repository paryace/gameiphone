//
//  ReplyCell.m
//  GameGroup
//
//  Created by Shen Yanping on 14-1-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ReplyCell.h"

@implementation ReplyCell

+ (float)getContentHeigthWithStr:(NSString*)contStr
{
    CGSize size1 = [contStr sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(245, MAXFLOAT)];
    return size1.height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.headImageV = [[EGOImageButton alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        self.headImageV.backgroundColor = [UIColor clearColor];
        [self.headImageV addTarget:self action:@selector(headButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.headImageV];

        self.nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 4, 100, 25)];
        [self.nickNameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nickNameLabel setFont:[UIFont systemFontOfSize:13.0]];
        [self.nickNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.nickNameLabel setTextColor:UIColorFromRGBA(0x455ca8, 1)];
        [self addSubview:self.nickNameLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 4, 80, 25)];
        [self.timeLabel setTextAlignment:NSTextAlignmentRight];
        [self.timeLabel setFont:[UIFont systemFontOfSize:11.0]];
        [self.timeLabel setBackgroundColor:[UIColor clearColor]];
        [self.timeLabel setTextColor:kColorWithRGB(151, 151, 151, 1.0)];
        [self addSubview:self.timeLabel];
        
        self.commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(65, 28, 245, 20)];
        [self.commentLabel setFont:[UIFont systemFontOfSize:13.0]];
        self.commentLabel.numberOfLines = 0;
        [self.commentLabel setBackgroundColor:[UIColor clearColor]];
        [self.commentLabel setTextColor:[UIColor darkGrayColor]];
        //[self.commentLabel setTextColor:kColorWithRGB(153, 153, 153, 1.0)];
        [self addSubview:self.commentLabel];
    }
    return self;
}

- (void)refreshCell
{
    
}

- (void)headButtonClick
{
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(CellHeardButtonClick:)]) {
        [self.myDelegate CellHeardButtonClick:self.rowIndex];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
