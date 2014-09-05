//
//  BoundRoleCell.m
//  GameGroup
//
//  Created by Marss on 14-9-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BoundRoleCell.h"
//
//  AboutRoleCell.m
//  GameGroup
//
//  Created by 魏星 on 14-5-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BoundRoleCell.h"

@implementation BoundRoleCell

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
        
        self.gameNameBt = [[UIButton alloc] initWithFrame:CGRectMake(48, 0, 220, 40)];
        self.gameNameBt.backgroundColor = [UIColor whiteColor];
        self.gameNameBt.hidden = YES;
        [self.gameNameBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.gameNameBt.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.gameNameBt setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.contentView addSubview:self.gameNameBt];
        
        
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 44)];
        self.titleLabel.textColor = kColorWithRGB(102, 102, 102, 1.0);
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        self.titleLabel.backgroundColor= [UIColor clearColor];
        [self.contentView addSubview:self.titleLabel];
        
        
        self.contentTF = [[UITextField alloc] initWithFrame:CGRectMake(50, 0, 200, 40)];
        self.contentTF.returnKeyType = UIReturnKeyDone;
        self.contentTF.delegate = self;
//        self.contentTF.placeholder = @"请输入角色名称";
        self.contentTF.textAlignment = NSTextAlignmentLeft;
        self.contentTF.font = [UIFont boldSystemFontOfSize:15.0];
        self.contentTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.contentTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.contentTF.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.contentTF];
        
        self.rightImageView = [[UIButton alloc] initWithFrame:CGRectMake(280, 10, 15, 15)];
        [self.rightImageView setImage:KUIImage(@"touxiang_14") forState:UIControlStateNormal];
//        [self.rightImageView setImageEdgeInsets:UIEdgeInsetsMake(16, 10, 16, 18)];
        [self.rightImageView addTarget:self action:@selector(result:) forControlEvents:UIControlEventTouchUpInside];
        self.rightImageView.hidden = YES;
        [self.contentView addSubview:self.rightImageView];
        
        self.serverButton = [[UIButton alloc] initWithFrame:CGRectMake(48, 0, 220, 40)];
        self.serverButton.backgroundColor = [UIColor whiteColor];
        self.serverButton.hidden = YES;
        [self.serverButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.serverButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [self.serverButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.contentView addSubview:self.serverButton];
        
        self.gameImg = [[EGOImageView alloc] initWithFrame:CGRectMake(19, 12, 18, 18)];
        self.gameImg.hidden = YES;
        [self.contentView addSubview:self.gameImg];
        
        self.smallImg = [[EGOImageView alloc]initWithFrame:CGRectMake(19, 12, 22, 18)];
        self.smallImg.hidden = YES;
        [self.contentView addSubview:self.smallImg];
        
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


