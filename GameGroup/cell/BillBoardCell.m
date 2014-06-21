//
//  BillBoardCell.m
//  GameGroup
//
//  Created by Apple on 14-6-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BillBoardCell.h"

@implementation BillBoardCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.groupHeadImage = [[EGOImageButton alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        self.groupHeadImage.layer.cornerRadius = 5;
        self.groupHeadImage.layer.masksToBounds=YES;
        self.groupHeadImage.backgroundColor = [UIColor clearColor];
        [self addSubview:self.groupHeadImage];
        
        self.groupNameLable = [[UILabel alloc] initWithFrame:CGRectMake(65, 4, 150, 25)];
        [self.groupNameLable setTextAlignment:NSTextAlignmentLeft];
        [self.groupNameLable setFont:[UIFont boldSystemFontOfSize:13.0]];
        [self.groupNameLable setBackgroundColor:[UIColor clearColor]];
        [self.groupNameLable setTextColor:UIColorFromRGBA(0x455ca8, 1)];
        [self addSubview:self.groupNameLable];
        
        self.billTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(230, 4, 80, 25)];
        [self.billTimeLable setTextAlignment:NSTextAlignmentRight];
        [self.billTimeLable setFont:[UIFont systemFontOfSize:11.0]];
        [self.billTimeLable setBackgroundColor:[UIColor clearColor]];
        [self.billTimeLable setTextColor:kColorWithRGB(151, 151, 151, 1.0)];
        [self addSubview:self.billTimeLable];
        
        self.billContentLable = [[UILabel alloc]initWithFrame:CGRectMake(65, 28, 245, 20)];
        [self.billContentLable setFont:[UIFont systemFontOfSize:13.0]];
        self.billContentLable.numberOfLines = 0;
        [self.billContentLable setBackgroundColor:[UIColor clearColor]];
        [self.billContentLable setTextColor:[UIColor darkGrayColor]];
        [self addSubview:self.billContentLable];

    }
    return self;
}

@end
