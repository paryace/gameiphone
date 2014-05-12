//
//  NearByPhotoCell.m
//  GameGroup
//
//  Created by 魏星 on 14-5-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NearByPhotoCell.h"

@implementation NearByPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.photoView = [[EGOImageView alloc]initWithFrame:CGRectMake(0, 0, 77, 77)];
        self.photoView.placeholderImage = KUIImage(@"placeholder");
       // self.photoView.backgroundColor = [UIColor redColor];
        [self addSubview:self.photoView];
        
        
        
        self.lestView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-15, self.bounds.size.width, 15)];
        self.lestView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.4];
        [self.photoView addSubview:self.lestView];
        
        self.tagImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
        self.tagImageView.image = KUIImage(@"icon_nearby");
        [self.lestView addSubview:self.tagImageView];
        
        self.distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 47, 15)];
        self.distanceLabel.text = @"0.05km";
        self.distanceLabel.font = [UIFont systemFontOfSize:10];
        self.distanceLabel.textColor = [UIColor whiteColor];
        self.distanceLabel.backgroundColor = [UIColor clearColor];
        [self.lestView addSubview:self.distanceLabel];
        
        self.sexImageView = [[UIImageView alloc]initWithFrame:CGRectMake(63, 0, 15, 15)];
        [self.lestView addSubview:self.sexImageView];
//       
        
        self.moreImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 77, 77)];
        self.moreImageView.hidden= YES;
        [self addSubview:self.moreImageView];
        
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
