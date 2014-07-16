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
    UITextView *textView;
}
@end

@implementation FillInInfoViewController

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
    
    [self setTopViewWithTitle:@"填写描述" withBackButton:YES];
    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [createBtn setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(backToBeforePage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];

    
    
    textView = [[UITextView alloc]initWithFrame:CGRectMake(10, startX+20, 300, 200)];
    [self.view addSubview:textView];
    
    
    
    // Do any additional setup after loading the view.
}
-(void)backToBeforePage:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.mydelegate coreBackWithVC:self info:textView.text];
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
