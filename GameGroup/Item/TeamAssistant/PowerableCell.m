//
//  PowerableCell.m
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "PowerableCell.h"

@implementation PowerableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.tlb = [[UILabel alloc]initWithFrame:CGRectMake(20, 12.5, 100, 20)];
        self.tlb.backgroundColor = [UIColor clearColor];
        self.tlb.textColor = kColorWithRGB(123, 123, 123, 1);
        self.tlb.text = @"与你实力接近";
        self.tlb.font =[ UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.tlb];
        
        self.soundSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(320-90, 7.5, 60, 30)];
        self.soundSwitch.on = YES;
        [self.soundSwitch addTarget:self action:@selector(infomationAction:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.soundSwitch];
    }
    return self;
}
-(void)infomationAction:(UISwitch*)sender
{
    [self.switchelegate infomationAccording:sender];
}
@end
