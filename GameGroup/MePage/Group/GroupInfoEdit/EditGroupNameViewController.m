//
//  EditGroupNameViewController.m
//  GameGroup
//
//  Created by Apple on 14-6-17.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "EditGroupNameViewController.h"

@interface EditGroupNameViewController ()

{
    UITextView*   m_contentTextView;
    UILabel*       m_ziNumLabel;
    NSInteger      m_maxZiShu;
    UIDatePicker* m_birthDayPick;
}
@end

@implementation EditGroupNameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0];
    m_maxZiShu = 100;
    [self setTopViewWithTitle:@"修改群名称" withBackButton:YES];
    
    
    m_contentTextView = [[UITextView alloc] initWithFrame: CGRectMake(10, 10 + startX, 300, 90)];
    m_contentTextView.backgroundColor = [UIColor whiteColor];
    m_contentTextView.font = [UIFont boldSystemFontOfSize:15.0];
    m_contentTextView.delegate = self;
    m_contentTextView.layer.cornerRadius = 5;
    m_contentTextView.layer.masksToBounds = YES;
    m_contentTextView.text = self.placeHold ? self.placeHold : @"";
    [self.view addSubview:m_contentTextView];
    [m_contentTextView becomeFirstResponder];
    
    
    m_ziNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 105 + startX, 150, 20)];
    m_ziNumLabel.textColor = [UIColor grayColor];
    m_ziNumLabel.textAlignment = NSTextAlignmentRight;
    m_ziNumLabel.font = [UIFont systemFontOfSize:12.0f];
    m_ziNumLabel.backgroundColor = [UIColor clearColor];
    m_ziNumLabel.text = [NSString stringWithFormat:@"还可输入%d个字", m_maxZiShu];
    [self.view addSubview:m_ziNumLabel];
    
    [self refreshZiLabelText];
    
    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 400 + startX, 300, 40)];
    [okButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [okButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [okButton setTitle:@"完 成" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor clearColor];
    [okButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okButton];

}
- (void)refreshZiLabelText
{
    NSInteger ziNum = m_maxZiShu - [[GameCommon shareGameCommon] unicodeLengthOfString:m_contentTextView.text];
    if(ziNum >= 0)
    {
        m_ziNumLabel.text = [NSString stringWithFormat:@"还可以输入%d字", ziNum];
        m_ziNumLabel.textColor = [UIColor grayColor];
    }
    else
    {
        m_ziNumLabel.text = [NSString stringWithFormat:@"已超过%d字", [[GameCommon shareGameCommon] unicodeLengthOfString:m_contentTextView.text] - m_maxZiShu];
        m_ziNumLabel.textColor = [UIColor redColor];
    }
}


- (void)okButtonClick:(id)sender
{
    [m_contentTextView resignFirstResponder];
    if (KISEmptyOrEnter(m_contentTextView.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入有效的文字！" buttonTitle:@"确定"];
        return;
    }
    NSInteger ziNum = m_maxZiShu - [[GameCommon shareGameCommon] unicodeLengthOfString:m_contentTextView.text];
    if (ziNum < 0) {
        [self showAlertViewWithTitle:@"提示" message:@"输入字数超过上限，请修改！" buttonTitle:@"确定"];
        return;
    }
    if (self.delegate) {
        [self.delegate comeBackGroupNameWithController:m_contentTextView.text];
    }
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark 返回
- (void)backButtonClick:(id)sender
{
    if (KISEmptyOrEnter(m_contentTextView.text) || [m_contentTextView.text isEqualToString:self.placeHold]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您这样返回是没有保存的喔！" delegate:self cancelButtonTitle:@"返回"otherButtonTitles:@"确定", nil];
    alert.tag = 345;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 345) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
#pragma mark textView delegate
- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshZiLabelText];
}

#pragma mark 手势
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [m_contentTextView resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
