//
//  SelectView.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-24.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "SelectView.h"
#import "EGOImageView.h"
@implementation SelectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setMainView
{
    self.backgroundColor = [UIColor clearColor];
    NSInteger buttonCount = [self.buttonTitleArray count];
    
    UIImageView* topImage = [[UIImageView alloc] initWithFrame:CGRectMake(55, 0, 210, 18)];
    topImage.image = KUIImage(@"select_top");
    [self addSubview:topImage];
  
    UIImageView* middleImage = [[UIImageView alloc] initWithFrame:CGRectMake(55, 18, 210, buttonCount * 40)];
    middleImage.image = KUIImage(@"select_middle");
    [self addSubview:middleImage];
    
    UIImageView* bottomImage = [[UIImageView alloc] initWithFrame:CGRectMake(55, 18 + buttonCount * 40, 210, 3)];
    bottomImage.image = KUIImage(@"select_bottom");
    [self addSubview:bottomImage];
    
    for (int i = 0; i < buttonCount; i++) {
        NSDictionary * dataDic = [self.buttonTitleArray objectAtIndex:i];
        CGSize nameSize = [KISDictionaryHaveKey(dataDic, kSelectRealmKey) sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(182, 20) lineBreakMode:NSLineBreakByWordWrapping];
        EGOImageView* gameImg = [[EGOImageView alloc] initWithFrame:CGRectMake(55+(210-3-18-(nameSize.width>182?182:nameSize.width))/2, 29 + i * 40, 18, 18)];
        NSString * gameImageId=[GameCommon putoutgameIconWithGameId:[dataDic objectForKey:kSelectGameIdKey ]];
        gameImg.imageURL = [ImageService getImageUrl4:gameImageId];
        
        [self addSubview:gameImg];
        UIButton*  tempButton = [[UIButton alloc] initWithFrame:CGRectMake(gameImg.frame.size.width+gameImg.frame.origin.x+3, 18 + i * 40, nameSize.width>182?182:nameSize.width, 40)];
        [tempButton setTitle:[dataDic objectForKey:kSelectRealmKey] forState:UIControlStateNormal];
        [tempButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        tempButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        tempButton.backgroundColor = [UIColor clearColor];
        [tempButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        tempButton.tag = i;
        [self addSubview:tempButton];
        
        if (i != buttonCount - 1) {
            UIImageView* lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(57, 18 + (i + 1)* 40, 206, 2)];
            lineImg.image = KUIImage(@"line");
            lineImg.backgroundColor = [UIColor clearColor];
            [self addSubview:lineImg];
        }
    }
}

- (void)buttonClick:(UIButton*)btn
{
    [self.selectDelegate selectButtonWithIndex:btn.tag];
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
