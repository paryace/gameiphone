//
//  SelectOtherCell.m
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SelectOtherCell.h"

@implementation SelectOtherCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.tlb = [[UILabel alloc]initWithFrame:CGRectMake(20, 12.5, 100, 20)];
        self.tlb.backgroundColor = [UIColor clearColor];
        self.tlb.textColor = kColorWithRGB(123, 123, 123, 1);
        self.tlb.text = @"选择分类";
        self.tlb.font =[ UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.tlb];
        
        self.characterLable = [[UILabel alloc]initWithFrame:CGRectMake(46, 12.5, 320-20, 20)];
        self.characterLable.textColor = kColorWithRGB(164, 164, 164, 1);
        self.characterLable.textColor = [UIColor blackColor];
        self.characterLable.text = @"匹配开黑";
        self.characterLable.textAlignment = NSTextAlignmentRight;
        self.characterLable.backgroundColor = [UIColor clearColor];
        self.characterLable.font =[ UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.characterLable];
    }
    return self;
}
-(void)reloadCell{
//    CGSize textSize = [self.characterLable.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(320-60-23-20, 20) lineBreakMode:NSLineBreakByWordWrapping];
//    self.characterLable.frame = CGRectMake(320-30-textSize.width-5, 12.5, textSize.width+5, 20);
    
    CGSize tlbSize = [self.tlb.text sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(320, 20) lineBreakMode:NSLineBreakByWordWrapping];
    self.characterLable.frame = CGRectMake(20+tlbSize.width+5, 12.5,320-20-tlbSize.width-5-30, 20);
}
@end
