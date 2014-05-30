//
//  TitleObjUpView.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-26.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "TitleObjUpView.h"
#import "NetManager.h"

#define degreesToRadians(x) (M_PI*(x)/180.0)//弧度

@implementation TitleObjUpView

@synthesize rightImageId;
@synthesize gameId;
@synthesize rarenum;//稀有度
@synthesize titleName;
@synthesize characterName;
@synthesize remark;
@synthesize rarememo;//%
@synthesize detailDis;//查看详情内容
@synthesize rightBgImage;
@synthesize waitImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(void)getRightImageFromNet
{
    self.rightBgImage.image = KUIImage(@"title_bg_default.jpg");
    self.waitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenHeigth - 110, 300/2 - 45/2, 45, 45)];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 1; i < 8; i++) {
        NSString* str = [NSString stringWithFormat:@"load_%d", i];
        [arr addObject:KUIImage(str)];
    }
    self.waitImageView.animationImages = arr;
    self.waitImageView.animationDuration = 0.8;//越大越慢
    self.waitImageView.animationRepeatCount = 0;//无限次
    [self.waitImageView startAnimating];
    
    [self getImageByNetWithImageId:self.rightImageId];
    
    [self addSubview:self.rightBgImage];
    
    [self addSubview:self.waitImageView];
    
    self.waitLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(kScreenHeigth - 120, 300/2 - 45/2 + 45, 64, 30) textColor:[UIColor whiteColor] font:[UIFont boldSystemFontOfSize:15.0] text:@"加载中..." textAlignment:NSTextAlignmentCenter];
    [self addSubview:self.waitLabel];
}
- (void)setMainView
{
    float viewWidth = self.frame.size.width;//568 480
    self.rightBgImage = [[EGOImageView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, self.frame.size.height)];
    self.rightBgImage.backgroundColor = [UIColor clearColor];
    NSString *path = [RootDocPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.rightImageId]];
    NSLog(@"path%@",path);
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path])
    {
         UIImage * imageData=[UIImage imageWithContentsOfFile:path];
        if (imageData==nil) {
            [self getRightImageFromNet];
        }else{
            self.rightBgImage.image = imageData;
            [self addSubview:self.rightBgImage];
        }
    }
    else
    {
        [self getRightImageFromNet];
    }
    UIImageView* leftImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 330, self.frame.size.height)];
    leftImg.image = KUIImage(@"left_bg");
    [self addSubview:leftImg];
    
    UIImageView* gameImg = [[UIImageView alloc] initWithFrame:CGRectMake(100, 10, 140, 70)];
    gameImg.image = [self.gameId isEqualToString:@"1"] ? KUIImage(@"game_icon") : KUIImage(@"");
    [self addSubview:gameImg];
    
    UIImageView* rarenumImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 115, 60, 60)];
    NSString* rareStr = [NSString stringWithFormat:@"rarenum_%@", self.rarenum];
    rarenumImg.image = KUIImage(rareStr);
    [self addSubview:rarenumImg];
    
    UILabel* characterLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(70, 110, 200, 40) textColor:[UIColor whiteColor] font:[UIFont boldSystemFontOfSize:28.0] text:self.characterName textAlignment:NSTextAlignmentCenter];
    [self addSubview:characterLabel];
    
    UILabel* titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(70, 155, 200, 20) textColor:[UIColor whiteColor] font:[UIFont boldSystemFontOfSize:18.0] text:self.titleName textAlignment:NSTextAlignmentCenter];
    [self addSubview:titleLabel];
    
    CGSize remarkSize = [self.remark sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(250, 100)];

    UILabel* remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 195, 250, remarkSize.height)];
    remarkLabel.backgroundColor = [UIColor clearColor];
    remarkLabel.numberOfLines = 4;
    remarkLabel.textColor = kColorWithRGB(197, 197, 197, 1.0);
    remarkLabel.font = [UIFont boldSystemFontOfSize:13.0];
    remarkLabel.text = self.remark;
    [self addSubview:remarkLabel];
    
    UIButton* infoButton = [CommonControlOrView setButtonWithFrame:CGRectMake(10, 190 + remarkSize.height, 120, 40) title:@"如何获得此头衔" fontSize:[UIFont boldSystemFontOfSize:13.0] textColor:kColorWithRGB(35, 193, 238, 1.0) bgImage:nil HighImage:nil selectImage:nil];
    [infoButton addTarget:self action:@selector(infoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:infoButton];
    
    if ([self.rarememo hasSuffix:@"%"]) {
        float rare = [[self.rarememo substringToIndex:self.rarememo.length-1] floatValue];
        UILabel* rarememoLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, self.frame.size.height - 30, 150, 30) textColor:[UIColor whiteColor] font:[UIFont boldSystemFontOfSize:13.0] text:@"击败全国             的玩家" textAlignment:NSTextAlignmentLeft];
        [self addSubview:rarememoLabel];
        
        UILabel* percentLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(63, self.frame.size.height - 30, 50, 30) textColor:kColorWithRGB(250, 211, 49, 1.0) font:[UIFont boldSystemFontOfSize:13.0] text:[NSString stringWithFormat:@"%.2f%@", 100 - rare, @"%"] textAlignment:NSTextAlignmentCenter];
        [self addSubview:percentLabel];
    }
    else
    {
        UILabel* rarememoLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, self.frame.size.height - 30, 200, 30) textColor:[UIColor whiteColor] font:[UIFont boldSystemFontOfSize:13.0] text:@"全国仅有         位玩家拥有此头衔" textAlignment:NSTextAlignmentLeft];
        [self addSubview:rarememoLabel];
        
        UILabel* percentLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(65, self.frame.size.height - 30, 30, 30) textColor:kColorWithRGB(250, 211, 49, 1.0) font:[UIFont boldSystemFontOfSize:13.0] text:self.rarememo textAlignment:NSTextAlignmentCenter];
        [self addSubview:percentLabel];
    }
}

- (void)infoButtonClick:(id)sender
{
//    UIAlertView* alter = [[UIAlertView alloc] initWithTitle:@"" message:self.detailDis delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [alter show];
//    alter.transform = CGAffineTransformIdentity;
//    alter.transform = CGAffineTransformMakeRotation(degreesToRadians(-90));
    
    if (self.showDetailView != nil) {
        [self.showDetailView removeFromSuperview];
    }
    self.showDetailView = [[UIView alloc] initWithFrame:CGRectMake(kScreenHeigth/2 - 150, kScreenWidth/2 - 90, 330, 210)];
    self.showDetailView.layer.cornerRadius = 5;
    self.showDetailView.layer.masksToBounds = YES;
    self.showDetailView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.showDetailView];
    
    UIImageView* imageBg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 300, 180)];
    imageBg.image = KUIImage(@"alter_bg");
    [self.showDetailView addSubview:imageBg];
    
    UITextView* contentView = [[UITextView alloc] initWithFrame:CGRectMake(25, 25, 280, 160)];
    contentView.text = self.detailDis;
    contentView.editable = NO;
//    contentView.userInteractionEnabled = NO;
    contentView.backgroundColor = [UIColor clearColor];
//    contentView.textColor = kColorWithRGB(197, 197, 197, 1.0);
    contentView.textColor = [UIColor whiteColor];
    [self.showDetailView addSubview:contentView];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(295, 0, 30, 30)];
    imageView.image = KUIImage(@"close_normal");
    [self.showDetailView addSubview:imageView];
    UIButton* btn = [CommonControlOrView setButtonWithFrame:CGRectMake(285, 0, 50, 50) title:@"" fontSize:[UIFont boldSystemFontOfSize:15.0] textColor:[UIColor clearColor] bgImage:nil HighImage:nil selectImage:nil];
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.showDetailView addSubview:btn];
    
//    [UIView animateWithDuration:0.2 animations:^{
//        self.showDetailView.frame = CGRectMake(kScreenHeigth/2 - 100, kScreenWidth/2 - 100, 200, 200);
//    }];

}

- (void)buttonClick:(id)sender
{
    [self.showDetailView removeFromSuperview];
}

//下载图片
- (void)getImageByNetWithImageId:(NSString*)imageid
{
    NSString * urlStr= [ImageService getImgUrl:imageid];
//    [NetManager downloadImageWithBaseURLStr:urlStr ImageId:@""
//                                    success:^(NSURLRequest *request,
//                                              NSHTTPURLResponse *response,
//                                              UIImage *image){
//            NSString *path = [RootDocPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",imageid]];
//        
//            if ([UIImageJPEGRepresentation(image, 1.0) writeToFile:path atomically:YES]) {
//                self.rightBgImage.image = image;
//                NSLog(@"下载图片 success//%@",imageid);
//            }
//            else
//            {
//                NSLog(@"fail");
//            }
//        [self.waitImageView stopAnimating];
//        self.waitLabel.hidden = YES;
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        [self.waitImageView stopAnimating];
//        self.waitLabel.hidden = YES;
//    }];
    
    
    [NetManager downloadImageWithBaseURLStr:urlStr ImageId:imageid
                                 completion:^(NSURLResponse *response, NSURL *filePath, NSError *error)
     {
         NSString * path=[filePath path];
         NSFileManager *fm = [NSFileManager defaultManager];
         if([fm fileExistsAtPath:path])
         {
             self.rightBgImage.image = [UIImage imageWithContentsOfFile:path];
         }
         [self.waitImageView stopAnimating];
         self.waitLabel.hidden = YES;
     }
     ];
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
