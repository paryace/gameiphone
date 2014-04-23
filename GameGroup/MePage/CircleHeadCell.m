//
//  CircleHeadCell.m
//  GameGroup
//
//  Created by 魏星 on 14-4-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CircleHeadCell.h"
#import "FinderView.h"
@implementation CircleHeadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.headImgBtn = [[EGOImageButton alloc]initWithPlaceholderImage:KUIImage(@"placeholder")];
        self.headImgBtn.frame = CGRectMake(10, 10, 40, 40);
    
        [self.contentView addSubview:self.headImgBtn];
        
        self.nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 120, 20)];
        self.nickNameLabel.textColor = UIColorFromRGBA(0x455ca8, 1);
        self.nickNameLabel.backgroundColor = [UIColor clearColor];
        self.nickNameLabel.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:self.nickNameLabel];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 27, 170, 30)];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.titleLabel.numberOfLines=0;
        [self addSubview:self.titleLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 60, 130, 30)];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.textColor =kColorWithRGB(41, 164, 246, 1.0);
        [self.contentView addSubview:self.timeLabel];
        
        self.shareView = [[UIView alloc]initWithFrame:CGRectMake(60, 60, 250, 50)];
        self.shareView.backgroundColor = UIColorFromRGBA(0xf0f1f3, 1);
        [self addSubview:self.shareView];
        self.shareImgView = [[EGOImageView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
        self.shareImgView.placeholderImage = KUIImage(@"placeholder");
        [self.shareView addSubview:self.shareImgView];
        
        self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 190, 40)];
        self.contentLabel.font = [UIFont systemFontOfSize:10];
        self.contentLabel.backgroundColor = [UIColor clearColor];
        [self.shareView addSubview:self.contentLabel];
     
        
        self.openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.openBtn.frame = CGRectMake(270, 60, 50, 30);
        [self.openBtn setBackgroundImage:KUIImage(@"按下_03") forState:UIControlStateNormal];
        [self.openBtn addTarget:self action:@selector(openBtnList:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.openBtn];
        
        
        CGSize size = [CircleHeadCell getContentHeigthWithStr:self.commentStr];
        
        self.titleLabel.frame = CGRectMake(60, 27, 170, size.height);
//        if (![imgStr isEqualToString:@""]) {
//            
//            NSArray* arr = [imgStr componentsSeparatedByString:@","];
//            NSLog(@"arr%@-->%@-->%d",arr,imgStr,arr.count);
//            
//            for (int i =0; i<3; i++) {
//                for (int j = 0; j<arr.count/3; j++) {
//                    
//                    self.thumbImgView = [[EGOImageView alloc]initWithPlaceholderImage:KUIImage( @"placeholder")];
//                    if (arr.count==1)
//                    {
//                        self.thumbImgView.frame = CGRectMake(60, size.height+27,180, self.thumbImgView.image.size.height*(180/ self.thumbImgView.image.size.width));
//                        self.timeLabel.frame = CGRectMake(60, size.height+27+self.thumbImgView.image.size.height*(180/self.thumbImgView.image.size.width), 120, 30);
//                    }
//                    else{
//                        self.thumbImgView.frame = CGRectMake(60+80*i, size.height+27+80*j, 75, 75);
//                        self.timeLabel.frame = CGRectMake(60,size.height+27+80*arr.count/3, 120, 30);
//                    }
//                    
//                    self.thumbImgView.imageURL = [NSURL URLWithString:[[GameCommon isNewOrOldWithImage:[arr objectAtIndex:i+j*i] ] stringByAppendingString:[arr objectAtIndex:i+j*i]]];
//                    [self addSubview:self.thumbImgView];
//                }
//            }
//        }
 
    }
    return self;
}
-(void)openBtnList:(id)sender
{
    NSLog(@"展开");
}

+ (CGSize)getContentHeigthWithStr:(NSString*)contStr
{
    CGSize cSize = [contStr sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(170, 300) lineBreakMode:NSLineBreakByWordWrapping];
    
    return cSize;
}

-(void)buildImagePathWithImage:(NSString *)imgStr
{
    CGSize size = [CircleHeadCell getContentHeigthWithStr:self.commentStr];
    self.thumbImgView.imageURL = nil;
    [self.thumbImgView removeFromSuperview];
    self.titleLabel.frame = CGRectMake(60, 27, 170, size.height);
    if (![imgStr isEqualToString:@""]) {
        
        NSArray* arr = [imgStr componentsSeparatedByString:@","];
        NSLog(@"arr%@-->%@-->%d",arr,imgStr,arr.count);
        
            for (int i =0; i<3; i++) {
                for (int j = 0; j<arr.count/3; j++) {
                    
                    if (arr.count==1)
                    {
                        self.thumbImgView = [[EGOImageView alloc]initWithPlaceholderImage:KUIImage( @"placeholder")];
                        self.thumbImgView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[arr objectAtIndex:0]]];
                        self.thumbImgView.frame = CGRectMake(60, size.height+27,180, self.thumbImgView.image.size.height*(180/ self.thumbImgView.image.size.width));
                        [self addSubview:self.thumbImgView];
                        self.timeLabel.frame = CGRectMake(60, size.height+27+self.thumbImgView.image.size.height*(180/self.thumbImgView.image.size.width), 120, 30);
                    }
                    else{
                    self.thumbImgView = [[EGOImageView alloc]initWithFrame:CGRectMake(60+80*i, size.height+27+80*j, 75, 75)];
                    self.thumbImgView.placeholderImage = KUIImage(@"placeholder");
                    self.thumbImgView.imageURL = [NSURL URLWithString:[GameCommon isNewOrOldWithImage:imgStr]];
                    [self addSubview:self.thumbImgView];
                    }
                }
            }
            self.timeLabel.frame = CGRectMake(60,size.height+27+80*arr.count/3, 120, 30);
        }
}
- (void)refreshCell
{
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
