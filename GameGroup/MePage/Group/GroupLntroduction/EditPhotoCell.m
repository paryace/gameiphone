//
//  EditPhotoCell.m
//  GameGroup
//
//  Created by 魏星 on 14-6-17.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "EditPhotoCell.h"

@implementation EditPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.photoImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.photoImageView];
        self.delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.delBtn.frame = CGRectMake(0, 0, 15, 15);
        self.delBtn.backgroundColor = [UIColor blueColor];
        self.delBtn.hidden=YES;
        [self addSubview:self.delBtn];
    }
    return self;
}
-(void)editImage:(UIButton*)sender
{
    
}
-(void)SetPhotoUrlWithCache:(NSString *)url
{
    self.photoImageView.placeholderImage = [UIImage imageNamed:@"placeholder.png"];
    NSRange range=[url rangeOfString:@"<local>"];
    if (range.location!=NSNotFound) {
        NSString *path = [RootDocPath stringByAppendingPathComponent:@"tempImage"];
        NSString  *openImgPath = [NSString stringWithFormat:@"%@/%@",path,[url substringFromIndex:7]];
        NSData * nsData= [NSData dataWithContentsOfFile:openImgPath];
        UIImage * openPic= [UIImage imageWithData:nsData];
        self.photoImageView.image = openPic;
    }
    else
        self.photoImageView.imageURL = [ImageService getImageUrl3:url Width:160];
}

@end
