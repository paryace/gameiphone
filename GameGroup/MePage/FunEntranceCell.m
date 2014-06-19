//
//  FunEntranceCell.m
//  GameGroup
//
//  Created by Apple on 14-6-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "FunEntranceCell.h"

@implementation FunEntranceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleImage = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
        self.titleImage.image=KUIImage(@"not_read_dyn_img");
        [self.contentView addSubview:self.titleImage];
        
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 120, 20)];
        self.titleLable.text=@"有趣的人";
        self.titleLable.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:self.titleLable];
    }
    return self;
}

@end
