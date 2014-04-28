//
//  KKImgCell.m
//  GameGroup
//
//  Created by 魏星 on 14-4-7.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "KKImgCell.h"

@implementation KKImgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.msgImageView = [[EGOImageView alloc]
                        initWithPlaceholderImage:[UIImage
                                                  imageNamed:@"default_icon.png"]];
        self.msgImageView.frame = CGRectZero;
        self.msgImageView.layer.masksToBounds = YES;
        self.msgImageView.layer.borderWidth = 1;
        self.msgImageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.msgImageView.layer.cornerRadius = 6;
        [self.contentView addSubview:self.msgImageView];
        
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        [self.progressView setProgressViewStyle:UIProgressViewStyleBar];    //进度条样式
        self.progressView.progressTintColor = UIColorFromRGBA(0x16a3f0, 1);
        self.progressView.hidden = YES;
        
        [self.contentView addSubview:self.progressView];
    
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
