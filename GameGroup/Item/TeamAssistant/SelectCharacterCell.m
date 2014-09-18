//
//  SelectCharacterCell.m
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SelectCharacterCell.h"

@implementation SelectCharacterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.tlb = [[UILabel alloc]initWithFrame:CGRectMake(20, 12.5, 40, 20)];
        self.tlb.backgroundColor = [UIColor clearColor];
        self.tlb.textColor = kColorWithRGB(123, 123, 123, 1);
        self.tlb.text = @"角色";
        self.tlb.font =[ UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.tlb];
        
        self.headImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 12.5, 20, 20)];
        self.headImageView.image = KUIImage(@"");
        [self.contentView addSubview:self.headImageView];
        
        self.characterLable = [[UILabel alloc]initWithFrame:CGRectMake(46, 12.5, 320-20, 20)];
        self.characterLable.textColor = kColorWithRGB(164, 164, 164, 1);
        self.characterLable.textColor = [UIColor blackColor];
        self.characterLable.backgroundColor = [UIColor clearColor];
        self.characterLable.font =[ UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.self.characterLable];
 
    }
    return self;
}

-(void)reloadCell{
    CGSize textSize = [self.characterLable.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(320-60-23-30, 20) lineBreakMode:NSLineBreakByWordWrapping];
    self.characterLable.frame = CGRectMake(320-30-textSize.width, 12.5, textSize.width, 20);
    self.headImageView.frame = CGRectMake(320-30-textSize.width-3-20, 12.5, 20, 20);

}

@end
