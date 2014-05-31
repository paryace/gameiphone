//
//  KKImgCell.m
//  GameGroup
//
//  Created by 魏星 on 14-4-7.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "KKImgCell.h"

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



- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


-(void)uploadImage:(NSString*)imagePath cellIndex:(int)index
{
    cellIndex=index;
    self.progressView.hidden = NO;
    self.progressView.progress = 0.0f;
    UpLoadFileService * up = [[UpLoadFileService alloc] init];
    [up simpleUpload:imagePath UpDeleGate:self];
}

// 上传进度
- (void)uploadProgressUpdated:(NSString *)theFilePath percent:(float)percent
{
    self.progressView.progress = percent;
}
//上传成功代理回调
- (void)uploadSucceeded:(NSString *)theFilePath ret:(NSDictionary *)ret
{
    NSString *response = [GameCommon getNewStringWithId:KISDictionaryHaveKey(ret, @"key")];//图片id
    self.progressView.hidden = YES;
    if (self.sendMsgDeleGate) {
        [self.sendMsgDeleGate sendMsg:response Index:cellIndex];
    }
}
//上传失败代理回调
- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    self.progressView.hidden = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发送图片失败请重新发送" delegate:nil cancelButtonTitle:@"知道啦"otherButtonTitles:nil];
    [alert show];
    if (self.sendMsgDeleGate) {
        [self.sendMsgDeleGate refreStatus:cellIndex];
    }
}

@end
