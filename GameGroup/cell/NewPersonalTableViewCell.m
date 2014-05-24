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
        self.backgroudImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.backgroudImageV];
        
        self.headImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 6, 45, 45)];
        self.headImageV.backgroundColor = [UIColor whiteColor];
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        [self addSubview:self.headImageV];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 90, 20)];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self addSubview:self.nameLabel];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        
        self.sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(170, 5, 20, 20)];
        self.sexImg.backgroundColor = [UIColor clearColor];
        [self addSubview:self.sexImg];
        
        self.distLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 35, 240, 20)];
        [self.distLabel setTextColor:[UIColor blackColor]];
        [self.distLabel setFont:[UIFont systemFontOfSize:13]];
        [self.distLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.distLabel];
    }
    return self;
}
-(void)setGameIconUIView:(NSArray*)gameIds
{
    for (int i=0 ; i<gameIds.count;i++) {
        NSString * gameid=[gameIds objectAtIndex:i];
        EGOImageView *gameImg_one = [[EGOImageView alloc] initWithFrame:CGRectMake(320-50-20*i-2, 20, 20, 20)];
        gameImg_one.backgroundColor = [UIColor clearColor];
        gameImg_one.imageURL=[self getHeadImageUrl:[GameCommon putoutgameIconWithGameId:gameid]];
        [self addSubview:gameImg_one];
    }
}
//
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
- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
