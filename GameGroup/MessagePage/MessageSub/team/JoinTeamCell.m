//
//  JoinTeamCell.m
//  GameGroup
//
//  Created by Apple on 14-7-24.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "JoinTeamCell.h"

@implementation JoinTeamCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bgV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 310, 149)];
        self.bgV.image = KUIImage(@"group_cell_bg");
        self.bgV.userInteractionEnabled =YES;
        
        self.headImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
        [self.bgV addSubview:self.headImageV];
    
        
        self.groupNameLable = [[UILabel alloc]initWithFrame:CGRectMake(75, 12, 100, 20)];
        self.groupNameLable.backgroundColor = [UIColor clearColor];
        self.groupNameLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.groupNameLable.text = @"群名";
        self.groupNameLable.font =[ UIFont systemFontOfSize:12];
        [self.bgV addSubview:self.groupNameLable];
        
        self.genderImageV = [[UIImageView alloc]initWithFrame:CGRectMake(180, 10, 20, 20)];
        [self.bgV addSubview:self.genderImageV];
        
        self.positionLable = [[UILabel alloc]initWithFrame:CGRectMake(205, 13, 30, 15)];
        self.positionLable.backgroundColor = [UIColor blueColor];
        self.positionLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.positionLable.text = @"职位";
        self.positionLable.textColor = [UIColor whiteColor];
        self.positionLable.layer.masksToBounds = YES;
        self.positionLable.layer.cornerRadius = 3.0;
        self.positionLable.font =[ UIFont systemFontOfSize:12];
        [self.bgV addSubview:self.positionLable];
        
        self.gameImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(75, 35, 25, 25)];
        [self.bgV addSubview:self.gameImageV];
        
        self.realmLable = [[UILabel alloc]initWithFrame:CGRectMake(105, 37, 200, 20)];
        self.realmLable.backgroundColor = [UIColor clearColor];
        self.realmLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.realmLable.text = @"服务器名";
        self.realmLable.font =[ UIFont systemFontOfSize:12];
        [self.bgV addSubview:self.realmLable];
        
        self.pveLable = [[UILabel alloc]initWithFrame:CGRectMake(75, 62, 300, 20)];
        self.pveLable.backgroundColor = [UIColor clearColor];
        self.pveLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.pveLable.text = @"战斗力";
        self.pveLable.font =[ UIFont systemFontOfSize:12];
        [self.bgV addSubview:self.pveLable];
        
        self.timeLable = [[UILabel alloc]initWithFrame:CGRectMake(220, 12, 80, 20)];
        self.timeLable.backgroundColor = [UIColor clearColor];
        self.timeLable.textAlignment = NSTextAlignmentRight;
        self.timeLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.timeLable.text = @"时间";
        self.timeLable.font =[ UIFont systemFontOfSize:12];
        [self.bgV addSubview:self.timeLable];
        
        [self.contentView addSubview:self.bgV];
        
    }
    return self;
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
