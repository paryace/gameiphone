//
//  PersonTableCell.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-19.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "PersonTableCell.h"

@implementation PersonTableCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroudImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.backgroudImageV setBackgroundColor:[UIColor clearColor]];
        
        
        self.headImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 5, 60, 60)];
        self.headImageV.backgroundColor = [UIColor whiteColor];
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        [self.backgroudImageV addSubview:self.headImageV];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 90, 20)];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.backgroudImageV addSubview:self.nameLabel];
        
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 5, 130, 20)];
        self.timeLabel.textColor = kColorWithRGB(102, 102, 102, 1.0);
        [self.timeLabel setTextAlignment:NSTextAlignmentRight];
        self.timeLabel.font = [UIFont systemFontOfSize:12.0];
        [self.timeLabel setBackgroundColor:[UIColor clearColor]];
        [self.backgroudImageV addSubview:self.timeLabel];
        
        
        
        self.shiptypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(170, 30, 130, 20)];
        self.shiptypeLabel.textColor = kColorWithRGB(102, 102, 102, 1.0);
        self.shiptypeLabel.textAlignment = NSTextAlignmentRight;
        self.shiptypeLabel.font = [UIFont systemFontOfSize:12];
        self.shiptypeLabel.backgroundColor = [UIColor clearColor];
        [self.backgroudImageV addSubview:self.shiptypeLabel];
        
        self.ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 25, 30, 20)];
        [self.ageLabel setTextColor:[UIColor whiteColor]];
        [self.ageLabel setFont:[UIFont boldSystemFontOfSize:10.0]];
        [self.ageLabel setBackgroundColor:[UIColor clearColor]];
        self.ageLabel.layer.cornerRadius = 3;
        self.ageLabel.layer.masksToBounds = YES;
        self.ageLabel.textAlignment = NSTextAlignmentCenter;
        [self.backgroudImageV addSubview:self.ageLabel];
        
        self.sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(82, 29, 13, 13)];
        self.sexImg.backgroundColor = [UIColor clearColor];
        [self.backgroudImageV addSubview:self.sexImg];
        
        self.distLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 45, 240, 20)];
        [self.distLabel setTextColor:[UIColor blackColor]];
        [self.distLabel setFont:[UIFont systemFontOfSize:13]];
        [self.distLabel setBackgroundColor:[UIColor clearColor]];
        [self.backgroudImageV addSubview:self.distLabel];
        
        [self addSubview:self.backgroudImageV];
    }
    return self;
}
-(void)setGameIconUIView:(NSArray*)gameIds
{
    NSArray * us=self.backgroudImageV.subviews;
    for (UIView *uv in us) {
        if (uv.tag==122222) {
            [uv removeFromSuperview];
        }
    }
    CGSize ageSize = [self.ageLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:10.0] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat w=(gameIds.count*18)+(gameIds.count*2)-2;
    UIView * gV=[self getGameIconUIView:gameIds X:95 + ageSize.width Y:26 Width:w Height:18];
    gV.tag=122222;
    [self.backgroudImageV addSubview:gV];
}
//---
-(NSURL*)getHeadImageUrl:(NSString*)imageUrl
{
    if ([GameCommon isEmtity:imageUrl]) {
        return nil;
    }else{
        if ([GameCommon getNewStringWithId:imageUrl]) {
            return [NSURL URLWithString:[[BaseImageUrl stringByAppendingString:[GameCommon getNewStringWithId:imageUrl]] stringByAppendingString:@"/40/40"]];
        }else{
            return  nil;
        }
    }
}
//获取游戏图标
-(UIView*)getGameIconUIView:(NSArray*)gameIds X:(CGFloat)x Y:(CGFloat)y Width:(CGFloat)width Height:(CGFloat)height
{
    UIView *gameIconView=[[UIView alloc]initWithFrame:CGRectMake(x, y, width, height)];
    for (int i=0 ; i<gameIds.count;i++) {
        NSString * gameid=[gameIds objectAtIndex:i];
        EGOImageView *gameImg_one = [[EGOImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        gameImg_one.backgroundColor = [UIColor clearColor];
        gameImg_one.imageURL=[self getHeadImageUrl:[GameCommon putoutgameIconWithGameId:gameid]];
        [gameIconView addSubview:gameImg_one];
    }
    return gameIconView;
}
//---
- (void)refreshCell
{
    CGSize ageSize = [self.ageLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:10.0] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    self.ageLabel.frame = CGRectMake(80, 29, ageSize.width + 5, 12);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
