//
//  FillInInfoViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "FillInInfoViewController.h"

@interface FillInInfoViewController ()
{
    UITextView *contenttextView;
    NSInteger  m_maxZiShu;//发表字符数量
    UILabel *m_ziNumLabel;//提示文字
}
@end

@implementation FillInInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"填写描述" withBackButton:YES];
    m_maxZiShu = 100;
    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [createBtn setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(backToBeforePage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];

    contenttextView = [[UITextView alloc]initWithFrame:CGRectMake(10, startX+20, 300, 200)];
     contenttextView.delegate = self;
    [self.view addSubview:contenttextView];
    
    
    m_ziNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(320-10-10, 200+startX+20-20-10, 100, 20)];
    m_ziNumLabel.backgroundColor = [UIColor clearColor];
    m_ziNumLabel.font= [UIFont systemFontOfSize:12];
    m_ziNumLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:m_ziNumLabel];

}
-(void)backToBeforePage:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.mydelegate coreBackWithVC:self info:contenttextView.text];
}
//
- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshZiLabelText];
}

#pragma mark - text view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *new = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger res = m_maxZiShu-[[GameCommon shareGameCommon] unicodeLengthOfString:new];
    if(res >= 0){
        return YES;
    }
    else{
        [self showAlertViewWithTitle:@"提示" message:@"最多不能超过100个字" buttonTitle:@"确定"];
        return NO;
    }
}

- (void)refreshZiLabelText
{
    NSInteger ziNum = m_maxZiShu - [[GameCommon shareGameCommon] unicodeLengthOfString:contenttextView.text];
    if (ziNum<0) {
        ziNum=0;
    }
    m_ziNumLabel.text =[NSString stringWithFormat:@"%d%@%d",ziNum,@"/",m_maxZiShu];
    CGSize nameSize = [m_ziNumLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    m_ziNumLabel.frame=CGRectMake(320-5-nameSize.width, startX+148,nameSize.width,20);
    m_ziNumLabel.backgroundColor=[UIColor clearColor];
}
#pragma mark - touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [contenttextView resignFirstResponder];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
