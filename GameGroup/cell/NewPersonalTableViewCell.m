//
//  NewPersonalTableViewCell.m
//  GameGroup
//
//  Created by Apple on 14-5-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewPersonalTableViewCell.h"

@implementation NewPersonalTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        self.headImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 6, 45, 45)];
        self.headImageV.backgroundColor = [UIColor whiteColor];
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        [self.bgView addSubview:self.headImageV];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 7, 90, 20)];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.nameLabel];
        
        
        self.sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(170, 7, 20, 20)];
        self.sexImg.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:self.sexImg];
        
        self.distLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 31, 240, 20)];
        [self.distLabel setTextColor:[UIColor blackColor]];
        [self.distLabel setFont:[UIFont systemFontOfSize:13]];
        [self.distLabel setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:self.distLabel];
        [self.contentView addSubview:self.bgView];
    }
    return self;
}
-(void)setGameIconUIView:(NSArray*)gameIds
{
    NSArray * us=self.bgView.subviews;
    for(UIView *uv in us)
    {
        if (uv.tag==122222) {
            [uv removeFromSuperview];
        }
    }
    int gamecount = gameIds.count>3?3:gameIds.count;
    
    CGFloat w=(gamecount*23);
    UIView *gV=[self getGameIconUIView:gameIds X:320-30-w Y:20 Width:w Height:20];
    gV.tag=122222;
    [self.bgView addSubview:gV];
}
-(UIView*)getGameIconUIView:(NSArray*)gameIds X:(CGFloat)x Y:(CGFloat)y Width:(CGFloat)width Height:(CGFloat)height
{
    UIView *gameIconView=[[UIView alloc]initWithFrame:CGRectMake(x, y, width, height)];
//    gameIconView.backgroundColor = [UIColor grayColor];
    NSLog(@"ffff-------%@",gameIconView);

    for (int i=0 ; i<gameIds.count;i++) {
        if (i<3) {
            NSString * gameid=[gameIds objectAtIndex:i];
            EGOImageView *gameImg_one = [[EGOImageView alloc] initWithFrame:CGRectMake(i*23, 0, 20, 20)];
            gameImg_one.backgroundColor = [UIColor clearColor];
            NSString * gameImageId=[GameCommon putoutgameIconWithGameId:gameid];
            if ([GameCommon isEmtity:gameImageId]) {
                gameImg_one.image=KUIImage(@"clazz_0");
            }else{
                gameImg_one.imageURL= [ImageService getImageUrl4:gameImageId];
            }
            [gameIconView addSubview:gameImg_one];
        }
    }
    return gameIconView;
}

- (void)awakeFromNib
{
}
- (void)dealloc
{
    self.headImageV.imageURL = nil;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
