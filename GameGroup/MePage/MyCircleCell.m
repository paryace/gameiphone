//
//  MyCircleCell.m
//  GameGroup
//
//  Created by 魏星 on 14-4-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MyCircleCell.h"
#import "FinderView.h"
@implementation MyCircleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.dataLabel =[FinderView setLabelWithFrame:CGRectMake(10, 5, 60, 30) backgroundColor:[UIColor clearColor] textColor:UIColorFromRGBA(0x767676, 1) font:[UIFont fontWithName:@"汉仪菱心体简" size:30]];
        self.dataLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.dataLabel];
        
        self.monthLabel =[FinderView setLabelWithFrame:CGRectMake(10, 30, 60, 20) backgroundColor:[UIColor clearColor] textColor:UIColorFromRGBA(0x767676, 1) font:[UIFont boldSystemFontOfSize:13]];
        self.monthLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.monthLabel];

        
        
        self.thumbImageView = [[EGOImageView alloc]initWithPlaceholderImage:KUIImage(@"placeholder")];
        self.thumbImageView.frame = CGRectMake(80, 10, 70, 70);
        [self addSubview:self.thumbImageView];
        
        
        self.titleLabel = [FinderView setLabelWithFrame:CGRectMake(155, 0, 155, 70) backgroundColor:[UIColor clearColor] textColor:UIColorFromRGBA(0x1c1c1a, 1) font:[UIFont systemFontOfSize:12]];
        self.titleLabel.numberOfLines = 3;
        [self addSubview:self.titleLabel];
        
        self.imgCountLabel = [FinderView setLabelWithFrame:CGRectMake(155, 70, 60, 10) backgroundColor:[UIColor clearColor] textColor:UIColorFromRGBA(0x989898, 1) font:[UIFont systemFontOfSize:12]];
        [self addSubview:self.imgCountLabel];
    }
    return self;
}
+ (CGSize)getContentHeigthWithStr:(NSString*)contStr
{
    CGSize cSize = [contStr sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(225, 300) lineBreakMode:NSLineBreakByWordWrapping];
    
    return cSize;
}

-(void)getImageWithCount:(NSString *)img
{
    if ([img isEqualToString:@""] || [img isEqualToString:@" "]) {
        return;
    }
    NSArray* arr = [img componentsSeparatedByString:@","];
    if (arr.count ==2) {
        self.thumbImageView = [[EGOImageView alloc]initWithPlaceholderImage:KUIImage(@"placeholder")];
        self.thumbImageView.frame = CGRectMake(80, 10, 70, 70);
        [self addSubview:self.thumbImageView];

//        self.thumbImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[arr objectAtIndex:0]]];
        self.thumbImageView.imageURL = [ImageService getImageUrl4:[arr objectAtIndex:0]];
    }
    else if (arr.count ==3)
    {
        for (int i =0; i<arr.count-1; i++) {
            
            self.thumbImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(80+35*i, 10, 35, 70)];
//            self.thumbImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[arr objectAtIndex:i]]];
            self.thumbImageView.imageURL = [ImageService getImageUrl4:[arr objectAtIndex:i]];
            
            [self addSubview:self.thumbImageView];

        }
    }
    else if (arr.count ==4)
    {
        for (int i = 0; i <arr.count-1; i++) {
            self.thumbImageView = [[EGOImageView alloc]initWithPlaceholderImage:KUIImage(@"placeholder")];

            switch (i) {
                case 0:
                    self.thumbImageView.frame = CGRectMake(80, 10, 35, 70);
                    break;
                case 1:
                    self.thumbImageView.frame = CGRectMake(115, 10, 35, 35);
                    break;
                case 2:
                    self.thumbImageView.frame = CGRectMake(115, 45, 35, 35);
                    break;
                   
                default:
                    break;
            }
//            self.thumbImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[arr objectAtIndex:i]]];
            self.thumbImageView.imageURL = [ImageService getImageUrl4:[arr objectAtIndex:i]];
            [self addSubview:self.thumbImageView];
        }
    }
    else if (arr.count>4){
        for (int i =0; i<2; i++) {
            for (int j =0; j<2; j++) {
                self.thumbImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(80+35*i, 10+35*j, 35, 35)];
                self.thumbImageView.imageURL = [NSURL URLWithString:[arr objectAtIndex:((i+1)*(j+1)-1)]];
                [self addSubview:self.thumbImageView];
                NSLog(@"[arr objectAtIndex:(i+j)]%@  %d",[arr objectAtIndex:((i+1)*(j+1)-1)],i+j);
            }
        }
    }
}

- (void)refreshCell
{
    CGSize size = [MyCircleCell getContentHeigthWithStr:self.commentStr];
    if (size.height<40) {
        self.titleLabel.frame = CGRectMake(80, 5, 225,size.height);
    }else{
        self.titleLabel.frame = CGRectMake(80, 5, 225,40);
    }
    self.titleLabel.center = CGPointMake(self.titleLabel.center.x, self.center.y);
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
