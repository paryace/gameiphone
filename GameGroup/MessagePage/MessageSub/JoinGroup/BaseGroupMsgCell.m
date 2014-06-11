//
//  BaseGroupMsgCell.m
//  GameGroup
//
//  Created by Apple on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseGroupMsgCell.h"

@implementation BaseGroupMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bgV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 310, 135)];
        self.bgV.image = KUIImage(@"group_cell_bg");
        self.bgV.userInteractionEnabled =YES;
        
        self.groupImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(10, 5, 25, 25)];
        [self.bgV addSubview:self.groupImageV];
        
        self.groupNameLable = [[UILabel alloc]initWithFrame:CGRectMake(40, 7, 100, 20)];
        self.groupNameLable.backgroundColor = [UIColor clearColor];
        self.groupNameLable.textColor = [UIColor grayColor];
        self.groupNameLable.text = @"群名";
        self.groupNameLable.font =[ UIFont systemFontOfSize:12];
        [self.bgV addSubview:self.groupNameLable];
        
        self.groupCreateTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(300-50-5, 7, 50, 20)];
        self.groupCreateTimeLable.backgroundColor = [UIColor clearColor];
        self.groupCreateTimeLable.textColor = [UIColor grayColor];
        self.groupCreateTimeLable.text = @"昨天20:09";
        self.groupCreateTimeLable.font =[ UIFont systemFontOfSize:12];
        [self.bgV addSubview:self.groupCreateTimeLable];
        
        UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(10, 35, 310-20, 1)];
        lineView1.backgroundColor = kColorWithRGB(200,200,200, 0.7);
        [self.bgV addSubview:lineView1];

    }
    return self;
}
-(void)refreTimeLable
{
    CGSize nameSize = [self.groupCreateTimeLable.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    self.groupCreateTimeLable.frame=CGRectMake(300-nameSize.width-5, 7, nameSize.width, 20);
}
- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
