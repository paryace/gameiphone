//
//  CommonControlOrView.m
//  GameGroup
//
//  Created by shenyanping on 13-12-16.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "CommonControlOrView.h"
#import "EGOImageView.h"
#import "ImageService.h"

@implementation CommonControlOrView

+ (UIButton*)setButtonWithFrame:(CGRect)btnFrame title:(NSString*)title fontSize:(UIFont*)font textColor:(UIColor*)textColor bgImage:(UIImage*)bgImage HighImage:(UIImage*)highImg selectImage:(UIImage*)selectImg;
{
    UIButton* tempButton = [[UIButton alloc] initWithFrame:btnFrame];
    [tempButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    [tempButton setBackgroundImage:highImg forState:UIControlStateHighlighted];
    [tempButton setBackgroundImage:selectImg forState:UIControlStateSelected];
    [tempButton setTitle:title forState:UIControlStateNormal];
    [tempButton setTitleColor:textColor forState:UIControlStateNormal];
    tempButton.titleLabel.font = font;
    
    return tempButton;
}

+ (UILabel*)setLabelWithFrame:(CGRect)myFrame textColor:(UIColor*)myColor font:(UIFont*)myFont text:(NSString*)text textAlignment:(NSTextAlignment)alignment
{
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:myFrame];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = myColor;
    nameLabel.font = myFont;
    nameLabel.text = text;
    nameLabel.textAlignment = alignment;
    
    return nameLabel;
}

+ (UIView*)setGenderAndAgeViewWithFrame:(CGRect)myFrame gender:(NSString*)gender age:(NSString*)age star:(NSString*)star gameIds:(NSArray*)gameIds
{
    UIView* myView = [[UIView alloc] initWithFrame:myFrame];
    
    UILabel* ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, 30, 12)];
    [ageLabel setTextColor:[UIColor whiteColor]];
    [ageLabel setFont:[UIFont boldSystemFontOfSize:10.0]];
    ageLabel.layer.cornerRadius = 3;
    ageLabel.layer.masksToBounds = YES;
    ageLabel.textAlignment = NSTextAlignmentLeft;
    [myView addSubview:ageLabel];
    
    if ([gender isEqualToString:@"0"]) {//男♀♂
        ageLabel.text = [@"♂ " stringByAppendingString:age];
        ageLabel.backgroundColor = kColorWithRGB(33, 193, 250, 1.0);
    }
    else
    {
        ageLabel.text = [@"♀ " stringByAppendingString:age];
        ageLabel.backgroundColor = kColorWithRGB(238, 100, 196, 1.0);
    }
    
    CGSize ageSize = [ageLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:10.0] constrainedToSize:CGSizeMake(100, 12) lineBreakMode:NSLineBreakByWordWrapping];
    ageLabel.frame = CGRectMake(0, 9, ageSize.width + 5, 12);
    
    UILabel* starSign = [CommonControlOrView setLabelWithFrame:CGRectMake(ageSize.width + 10, 0, 50, myFrame.size.height) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:star textAlignment:NSTextAlignmentLeft];
    [myView addSubview:starSign];
    CGFloat w=(gameIds.count*18)+(gameIds.count*4)-4;
    UIView *gameicomView=[self getGameIconUIView:gameIds X:ageSize.width + 50 Y:6 Width:w Height:18];
    [myView addSubview:gameicomView];
    
    
    
    return myView;
}

+(UIView*)getGameIconUIView:(NSArray*)gameIds X:(CGFloat)x Y:(CGFloat)y Width:(CGFloat)width Height:(CGFloat)height
{
    UIView *gameIconView=[[UIView alloc]initWithFrame:CGRectMake(x, y, width, height)];
    for (int i=0 ; i<gameIds.count;i++) {
        if (i<3) {
            NSString * gameid=[gameIds objectAtIndex:i];
            EGOImageView *gameImg_one = [[EGOImageView alloc] initWithFrame:CGRectMake(i*23, 0, 20, 20)];
            gameImg_one.backgroundColor = [UIColor clearColor];
            NSString * imageId=[GameCommon putoutgameIconWithGameId:gameid];
            if ([GameCommon isEmtity:imageId]) {
                gameImg_one.image=KUIImage(@"clazz_0");
            }else{
               gameImg_one.imageURL = [ImageService getImageUrl3:imageId Width:40];
            }
            [gameIconView addSubview:gameImg_one];
        }
    }
    return gameIconView;
}
//---
//好友详情 个人动态
+ (UIView*)setPersonStateViewTime:(NSString*)time nameText:(NSString*)nameText achievement:(NSString*)achievement achievementLevel:(NSString*)level titleImage:(NSString*)images
{
    UIView* myView = [[UIView alloc] init];
    UILabel* oneLabel =  [CommonControlOrView setLabelWithFrame:CGRectMake(10, 5, 200, 20) textColor:kColorWithRGB(102, 102, 102, 1.0) font:[UIFont boldSystemFontOfSize:12.0] text:nameText textAlignment:NSTextAlignmentLeft];
    [myView addSubview:oneLabel];
    
//    float achiWidth = 175;
//    if ([titleImage isEqualToString:@""]) {
//        achiWidth = 300;
//    }
//    CGSize achievemnetSize = [achievement sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(achiWidth, 100)];
    UILabel* twoLabel =  [CommonControlOrView setLabelWithFrame:CGRectMake(20, 20, 220, 40) textColor:kColorWithRGB(51, 51, 51, 1.0) font:[UIFont boldSystemFontOfSize:13.0] text:achievement textAlignment:NSTextAlignmentLeft];
    twoLabel.numberOfLines = 2;
    [myView addSubview:twoLabel];
    
    UILabel* thereLabel =  [CommonControlOrView setLabelWithFrame:CGRectMake(10, 60, 100, 15) textColor:kColorWithRGB(102, 102, 102, 1.0) font:[UIFont boldSystemFontOfSize:12.0] text:time textAlignment:NSTextAlignmentLeft];
    [myView addSubview:thereLabel];
    
    EGOImageView* img = [[EGOImageView alloc] initWithFrame:CGRectMake(250, 20, 40, 40)];
//    if ([titleImage isEqualToString:[BaseImageUrl stringByAppendingString:@"/80"]]) {
//        img.imageURL = nil;
//    }else{
//        img.imageURL = [NSURL URLWithString:titleImage];
//    }
    
    img.imageURL=[ImageService getImageStr:images Width:80];
    
    img.layer.cornerRadius = 5;
    img.layer.masksToBounds = YES;
    [myView addSubview:img];
    
    myView.frame = CGRectMake(0, 0, 320, 80);
    
    UIImageView* arrow = [[UIImageView alloc] initWithFrame:CGRectMake(300, 40 - 6, 8, 12)];
    arrow.image = KUIImage(@"right_arrow");
    arrow.backgroundColor = [UIColor clearColor];
    [myView addSubview:arrow];
    
    return myView;
}

+ (UIView*)setTwoLabelViewNameText:(NSString*)nameText text:(NSString*)text nameTextColor:(UIColor*)nameTextColor textColor:(UIColor*)textColor
{
    UIView* myView = [[UIView alloc] init];
    
    UILabel* oneLabel =  [CommonControlOrView setLabelWithFrame:CGRectMake(10, 10, 100, 20) textColor:nameTextColor font:[UIFont boldSystemFontOfSize:13.0] text:nameText textAlignment:NSTextAlignmentLeft];
    [myView addSubview:oneLabel];
    
    CGSize textSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(190, 100)];
    UILabel* twoLabel =  [CommonControlOrView setLabelWithFrame:CGRectMake(100, 10, 190, textSize.height) textColor:textColor font:[UIFont boldSystemFontOfSize:14.0] text:text textAlignment:NSTextAlignmentLeft];
    twoLabel.numberOfLines = 0;
    [myView addSubview:twoLabel];
    
    myView.frame = CGRectMake(0, 0, 320, 20 + textSize.height);

    return myView;
}
//我的角色
+ (UIView*)setCharactersViewWithName:(NSString*)text gameId:(NSString*)gameId realm:(NSString*)realm pveScore:(NSString*)pveScore img:(NSString*)image auth:(NSString *)auth Pro:(NSString*)pro
{
    UIView* myView = [[UIView alloc] init];
    EGOImageView* heardImg = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 25.0/2, 35, 35)];
    heardImg.backgroundColor = [UIColor clearColor];
    heardImg.placeholderImage = KUIImage(@"clazz_icon.png");
    if ([GameCommon isEmtity:image]) {
        heardImg.image = KUIImage(@"clazz_icon.png");
    }
    else{
        heardImg.imageURL = [ImageService getImageUrl3:image Width:80];
    }
    
    
    
    [myView addSubview:heardImg];
    UILabel* oneLabel =  [CommonControlOrView setLabelWithFrame:CGRectMake(55, 5, 120, 20) textColor:kColorWithRGB(51, 51, 51, 1.0) font:[UIFont boldSystemFontOfSize:15.0] text:text textAlignment:NSTextAlignmentLeft];
    [myView addSubview:oneLabel];
    //---
    EGOImageView* gameIg = [[EGOImageView alloc] initWithFrame:CGRectMake(55, 31, 18, 18)];
    NSString * imageId=[GameCommon putoutgameIconWithGameId:[GameCommon getNewStringWithId:gameId]];
    gameIg.imageURL = [ImageService getImageUrl4:imageId];
    [myView addSubview:gameIg];
    //---
    UILabel* twoLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(75, 30, 130, 20) textColor:kColorWithRGB(102, 102, 102, 1.0) font:[UIFont boldSystemFontOfSize:14.0] text:realm textAlignment:NSTextAlignmentLeft];
    [myView addSubview:twoLabel];
    
    UILabel* lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 10, 1, 40)];
    lineLabel.backgroundColor = kColorWithRGB(200, 200, 200, 1.0);
    [myView addSubview:lineLabel];
    
    UILabel* pveLabel = [[UILabel alloc] init];
    pveLabel.frame = CGRectMake(201, 7, 110, 20);
    pveLabel.text = pveScore;
    pveLabel.textColor = UIColorFromRGBA(0x0077ff,1.0);
    pveLabel.textAlignment = NSTextAlignmentCenter;
    pveLabel.font = [UIFont boldSystemFontOfSize:16.0];
    pveLabel.backgroundColor = [UIColor clearColor];
    [myView addSubview:pveLabel];
    
    UILabel* pveTitle = [[UILabel alloc] initWithFrame:CGRectMake(201, 30, 110, 20)];
    pveTitle.textColor = UIColorFromRGBA(0xa7a7a7,1.0);
    pveTitle.textAlignment = NSTextAlignmentCenter;
    pveTitle.font = [UIFont boldSystemFontOfSize:13.0];
    pveTitle.text = pro;
    pveTitle.backgroundColor = [UIColor clearColor];
    [myView addSubview:pveTitle];
    UIImageView* authBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    authBg.backgroundColor = [UIColor clearColor];
    [myView addSubview:authBg];
    
    if ([[GameCommon getNewStringWithId:gameId] isEqualToString:@"3"]) {
        authBg.image = KUIImage(@"");
    }else{
        if ([auth isEqualToString:@"00"]) {
            authBg.image = KUIImage(@"chara_auth_3");
            
        }else if ([auth isEqualToString:@"1"]) {
            authBg.image = KUIImage(@"chara_auth_1");
            
        }else{
            authBg.image = KUIImage(@"chara_auth_2");
            
        }
    }
    return myView;
}

//我的头衔
+ (UIView*)setMyTitleObjWithImage:(NSString*)imageName titleName:(NSString*)titleName rarenum:(NSString*)rarenum showCurrent:(BOOL)isNoShow
{
    UIView* myView = [[UIView alloc] init];//40
    
    UIImageView* headImageV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
    headImageV.backgroundColor = [UIColor clearColor];
    headImageV.image = KUIImage(imageName);
    [myView addSubview:headImageV];

    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 200, 40)];
    [nameLabel setTextAlignment:NSTextAlignmentLeft];
    [nameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    nameLabel.text = titleName;
    nameLabel.textColor = [GameCommon getAchievementColorWithLevel:[rarenum integerValue]];
    [myView addSubview:nameLabel];
    
    UIImageView* arrow = [[UIImageView alloc] initWithFrame:CGRectMake(300, 14, 8, 12)];
    arrow.image = KUIImage(@"right_arrow");
    arrow.backgroundColor = [UIColor clearColor];
    [myView addSubview:arrow];
    
    UIButton* usedButton = [[UIButton alloc] initWithFrame:CGRectMake(230, 0, 80, 40)];
    usedButton.backgroundColor = [UIColor clearColor];
    [usedButton setTitle:@"当前头衔" forState:UIControlStateNormal];
    [usedButton setTitleColor:UIColorFromRGBA(0xa7a7a7,1.0) forState:UIControlStateNormal];
    usedButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [myView addSubview:usedButton];
    usedButton.hidden = isNoShow;
    
    return myView;
}

@end
