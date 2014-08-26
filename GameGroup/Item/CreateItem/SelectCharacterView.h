//
//  SelectCharacterView.h
//  GameGroup
//
//  Created by Apple on 14-8-26.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@protocol SelectCharacterDelegate;

@interface SelectCharacterView : UIView
@property (nonatomic, strong) UIButton * characterView;
@property (nonatomic, strong) EGOImageView * characterImage;
@property (nonatomic, strong) EGOImageView * gameImage;
@property (nonatomic, strong) UILabel * titleLable;
@property (nonatomic, strong) UILabel * characterNameLable;
@property (nonatomic, strong) UIImageView * rightImage;
@property(nonatomic,assign)id<SelectCharacterDelegate>clickDelegate;

-(void)seTCharacterInfo:(NSMutableDictionary*)characterInfo;
@end

@protocol SelectCharacterDelegate <NSObject>

-(void)onCLick:(UIButton*)action;

@end
