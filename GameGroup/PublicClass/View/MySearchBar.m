//
//  MySearchBar.m
//  GameGroup
//
//  Created by Apple on 14-9-15.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MySearchBar.h"

@implementation MySearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self changeBarTextfieldWithColor];
        [self changeBarCancelButtonWithColor];
    }
    return self;
}
- (void)changeBarTextfieldWithColor
{
    UITextField *textField;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.1f) {
        for (UIView *subv in self.subviews) {
            for (UIView* view in subv.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                    textField = (UITextField*)view;
                    break;
                }
            }
        }
    }else{
        for (UITextField *subv in self.subviews) {
            if ([subv isKindOfClass:[UITextField class]]) {
                textField = (UITextField*)subv;
                break;
            }
        }
    }
    
    // 设置文本框背景
    NSArray *subs = self.subviews;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]  > 6.1f) { // ios 7
        for (int i = 0; i < [subs count]; i++) {
            UIView* subv = (UIView*)[self.subviews objectAtIndex:i];
            for (UIView* subview in subv.subviews) {
                if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
                {
                    [subview setHidden:YES];
                    [subview removeFromSuperview];
                    break;
                }
            }
        }
    }else{
        for (int i = 0; i < [subs count]; i++) {
            UIView* subv = (UIView*)[self.subviews objectAtIndex:i];
            if ([subv isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subv removeFromSuperview];
                break;
            }
        }
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_bar_bg.png"]];
    imageView.frame = CGRectMake(0, 0, 320, 44);
    [self insertSubview:imageView atIndex:0];
    [textField setBackground:KUIImage(@"search_bar_textfield")];
}

- (void)changeBarCancelButtonWithColor
{
    for (UIView *searchbuttons in self.subviews)
    {
        
        if ([searchbuttons isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton*)searchbuttons;
            cancelButton.enabled = YES;
            [cancelButton setTitleColor:kColorWithRGB(112, 112, 114, 1) forState:UIControlStateNormal];
            [cancelButton setTitleColor:kColorWithRGB(112, 112, 114, 1) forState:UIControlStateSelected];
            [cancelButton setBackgroundImage:KUIImage(@"") forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:KUIImage(@"") forState:UIControlStateSelected];
            break;
        }
    }
}
@end
