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
        UIImageView * bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        bgImage.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
        [self.contentView addSubview:bgImage];
        self.titleImage = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
        self.titleImage.image=KUIImage(@"not_read_dyn_img");
        [bgImage addSubview:self.titleImage];
        
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 120, 20)];
        self.titleLable.text=@"去看看有趣的人";
        self.titleLable.backgroundColor=[UIColor clearColor];
        [bgImage addSubview:self.titleLable];
    }
    return self;
}

@end
