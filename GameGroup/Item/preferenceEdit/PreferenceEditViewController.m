//
//  PreferenceEditViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "PreferenceEditViewController.h"

@interface PreferenceEditViewController ()
{
    UITextField *m_tf1;
    UITextField *m_tf2;
    UITextField *m_tf3;
}
@end

@implementation PreferenceEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"偏好设置" withBackButton:YES];
    
    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [createBtn setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(didClickShareItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];

    // Do any additional setup after loading the view.
    
    [self buildThreeTextField];
    
}

-(void)buildThreeTextField
{
    m_tf1 = [GameCommon buildTextFieldWithFrame:CGRectMake(20, startX+30, 280, 40) font:[UIFont systemFontOfSize:13] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft placeholder:nil];
    m_tf2 = [GameCommon buildTextFieldWithFrame:CGRectMake(20, startX+90, 280, 40) font:[UIFont systemFontOfSize:13] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft placeholder:nil];
    m_tf3 = [GameCommon buildTextFieldWithFrame:CGRectMake(20, startX+150, 280, 40) font:[UIFont systemFontOfSize:13] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft placeholder:nil];
    m_tf1.borderStyle = UITextBorderStyleRoundedRect;
    m_tf2.borderStyle = UITextBorderStyleRoundedRect;
    m_tf3.borderStyle = UITextBorderStyleRoundedRect;
    m_tf1.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.mainDict, @"characterName")];
    m_tf2.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"type"), @"value")];
    m_tf3.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.mainDict, @"desc")];
    [self.view addSubview:m_tf1];
    [self.view addSubview:m_tf2];
    [self.view addSubview:m_tf3];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
