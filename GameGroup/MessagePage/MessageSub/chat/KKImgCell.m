//
//  KKImgCell.m
//  GameGroup
//
//  Created by 魏星 on 14-4-7.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "KKImgCell.h"
#import "SendFileManager.h"

@implementation KKImgCell
{
    NSInteger cellIndex;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bgImageView.hidden = YES;  //图片聊天不要背景泡泡
        self.msgImageView = [[EGOImageView alloc]initWithPlaceholderImage:[UIImage imageNamed:@"default_icon.png"]];
        self.msgImageView.layer.masksToBounds = YES;
        self.msgImageView.layer.borderWidth = 1;
        self.msgImageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.msgImageView.layer.cornerRadius = 5;
        [self.contentView addSubview:self.msgImageView];
        
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        [self.progressView setProgressViewStyle:UIProgressViewStyleBar];    //进度条样式
        self.progressView.progressTintColor = UIColorFromRGBA(0x16a3f0, 1);
        self.progressView.hidden = YES; 
        
        [self.contentView addSubview:self.progressView];
    
    }
    return self;
}

-(void)uploadImage:(int)index
{
    NSString *str = KISDictionaryHaveKey([KISDictionaryHaveKey(self.message, @"payload") JSONValue], @"title");
    NSString * state = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(self.message, @"status")];
    if ([state isEqualToString:@"10"]) {//假如还没有执行上传操作
        [[SendFileManager singleton] addUploadImage:index FilePath:str SendFileDelegate:self.uploaddelegate];
        self.progressView.hidden = NO;
        self.progressView.progress = 0.0f;
    }
}

@end
