//
//  SelectCharacterView.m
//  GameGroup
//
//  Created by Apple on 14-8-26.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SelectCharacterView.h"

@implementation SelectCharacterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.characterView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.characterView setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];;
        self.characterView.backgroundColor = [UIColor whiteColor];
        [self.characterView addTarget:self action:@selector(SelectAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.characterView];

        
        self.characterImage = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 15, 50, 50)];
        self.characterImage.layer.cornerRadius = 5;
        self.characterImage.layer.masksToBounds=YES;
        [self addSubview:self.characterImage];
        
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(65, 15, 320-20-16-65-3, 20)];
        self.titleLable.textColor = [UIColor blackColor];
        self.titleLable.backgroundColor  = [UIColor clearColor];
        self.titleLable.font = [UIFont systemFontOfSize:14.0];
        self.titleLable.text = @"";
        [self addSubview:self.titleLable];
        
        self.gameImage = [[EGOImageView alloc] initWithFrame:CGRectMake(65, 40, 20, 20)];
        [self addSubview:self.gameImage];
        
        self.characterNameLable = [[UILabel alloc] initWithFrame:CGRectMake(90, 40, 320-20-16-90-3, 20)];
        self.characterNameLable.textColor = [UIColor grayColor];
        self.characterNameLable.backgroundColor  = [UIColor clearColor];
        self.characterNameLable.font = [UIFont systemFontOfSize:12.0];
        self.characterNameLable.text = @"";
        [self addSubview:self.characterNameLable];
        
        self.rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(320-20-11.5, (80-18.5)/2, 11.5, 18.5)];
        self.rightImage.image = KUIImage(@"selectCharacter_rightIcon");
        [self addSubview:self.rightImage];
        
        self.noSelectLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height)];
        self.noSelectLable.textColor = [UIColor blackColor];
        self.noSelectLable.textAlignment = NSTextAlignmentCenter;
        self.noSelectLable.backgroundColor  = [UIColor clearColor];
        self.noSelectLable.font = [UIFont systemFontOfSize:14.0];
        self.noSelectLable.text = @"点击选择角色";
        [self addSubview:self.noSelectLable];
        
    }
    return self;
}
-(void)SelectAction:(UIButton*)sender{
    if (self.clickDelegate) {
        [self.clickDelegate onCLick:sender];
    }
}

-(void)seTCharacterInfo:(NSMutableDictionary*)characterInfo{
    if (characterInfo) {
        self.noSelectLable.hidden = YES;
        self.characterImage.imageURL = [ImageService getImageStr:KISDictionaryHaveKey(characterInfo, @"img") Width:100];
        self.titleLable.text = KISDictionaryHaveKey(characterInfo, @"name");
        NSString * gameImage = [GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(characterInfo, @"gameid")];
        self.gameImage.imageURL = [ImageService getImageUrl2:gameImage];
        self.characterNameLable.text = KISDictionaryHaveKey(characterInfo, @"simpleRealm");
    }else{
        self.noSelectLable.hidden = NO;
    }
    
}

@end
