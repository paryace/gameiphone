//
//  AboutRoleCell.m
//  GameGroup
//
//  Created by 魏星 on 14-5-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "AboutRoleCell.h"

@implementation AboutRoleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
//        UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, .5)];
//        topView.backgroundColor = [UIColor blackColor];
//        [self addSubview:topView];
//        UIView *lessView = [[UIView alloc]initWithFrame:CGRectMake(0, 43, 320, .5)];
//        lessView.backgroundColor = [UIColor grayColor];
//        [self addSubview:lessView];
        UIImageView* lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 43.5, 320, .5)];
        lineImg.image = KUIImage(@"line");
        lineImg.userInteractionEnabled = YES;
        lineImg.backgroundColor = [UIColor clearColor];
        [self addSubview:lineImg];

        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 44)];
       // self.titleLabel.text = @"选择游戏";
        self.titleLabel.textColor = kColorWithRGB(102, 102, 102, 1.0);
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        self.titleLabel.backgroundColor= [UIColor clearColor];
        [self.contentView addSubview:self.titleLabel];
   
        
        self.contentTF = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 180, 40)];
        self.contentTF.returnKeyType = UIReturnKeyDone;
        self.contentTF.delegate = self;
        self.contentTF.textAlignment = NSTextAlignmentRight;
        self.contentTF.font = [UIFont boldSystemFontOfSize:15.0];
        self.contentTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.contentTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.contentTF.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.contentTF];

        self.rightImageView = [[UIButton alloc] initWithFrame:CGRectMake(280, 0, 40, 40)];
//        self.rightImageView seti
//        (290, 16, 12, 8)
        [self.rightImageView setImage:KUIImage(@"arrow_bottom") forState:UIControlStateNormal];
        [self.rightImageView setImageEdgeInsets:UIEdgeInsetsMake(16, 10, 16, 18)];
        [self.rightImageView addTarget:self action:@selector(result:) forControlEvents:UIControlEventTouchUpInside];
        self.rightImageView.hidden = YES;
        [self.contentView addSubview:self.rightImageView];
        
        self.serverButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 0, 220, 40)];
        self.serverButton.backgroundColor = [UIColor clearColor];
        self.serverButton.hidden = YES;
        [self.contentView addSubview:self.serverButton];

        self.gameImg = [[EGOImageView alloc] initWithFrame:CGRectMake(170, 13, 18, 18)];
        self.gameImg.hidden = YES;
        [self.contentView addSubview:self.gameImg];

    }
    return self;
}

- (void)dealloc
{
    self.gameImg.imageURL = nil;
}
-(void)result:(id)sender
{
    NSLog(@"111111111");
    [self.contentTF becomeFirstResponder];
}


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
