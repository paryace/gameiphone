//
//  JoinGroupViewController.m
//  GameGroup
//
//  Created by Apple on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "JoinGroupViewController.h"

@interface JoinGroupViewController ()
{
    UITextView*   m_contentTextView;
}

@end

@implementation JoinGroupViewController

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
    
    [self setTopViewWithTitle:@"申请加入群组织" withBackButton:YES];
    
    self.view.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0];
    m_contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10 + startX, 300, 100)];
    m_contentTextView.backgroundColor = [UIColor whiteColor];
    m_contentTextView.font = [UIFont boldSystemFontOfSize:15.0];
    m_contentTextView.delegate = self;
    m_contentTextView.layer.cornerRadius = 5;
    m_contentTextView.layer.masksToBounds = YES;
    [self.view addSubview:m_contentTextView];
    [m_contentTextView becomeFirstResponder];
    
    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 125 + startX, 300, 40)];
    [okButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [okButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [okButton setTitle:@"提 交" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor clearColor];
    [okButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okButton];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"提交中...";
}

- (void)okButtonClick:(id)sender
{
    if (KISEmptyOrEnter(m_contentTextView.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入申请理由" buttonTitle:@"确定"];
        return;
    }
    [m_contentTextView resignFirstResponder];
    [hud show:YES];
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * paramsDict = [NSMutableDictionary dictionary];
    [paramsDict setObject:self.groupId forKey:@"groupId"];
    [paramsDict setObject:m_contentTextView.text forKey:@"msg"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"232" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [postDict setObject:paramsDict forKey:@"params"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
