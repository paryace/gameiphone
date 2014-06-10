//
//  JoinInGroupViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "JoinInGroupViewController.h"
#import "GroupListViewController.h"
#import "SearchGroupViewController.h"
@interface JoinInGroupViewController ()
{
    UITextField *m_searchTf;
}
@end

@implementation JoinInGroupViewController

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
    
    
    [self setTopViewWithTitle:@"推荐搜索" withBackButton:YES];
    
    m_searchTf = [[UITextField alloc]initWithFrame:CGRectMake(10, startX+20, 300, 40)];
    m_searchTf.backgroundColor = [UIColor clearColor];
    m_searchTf.borderStyle = UITextBorderStyleRoundedRect;
    m_searchTf.placeholder = @"搜索群名称或群号";
    m_searchTf.clearButtonMode = UITextFieldViewModeAlways;
    m_searchTf.autocorrectionType = UITextAutocorrectionTypeNo;
    m_searchTf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_searchTf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    m_searchTf.delegate = nil;
    [self.view addSubview:m_searchTf];
    
    UIButton *okbutton = [[UIButton alloc]initWithFrame:CGRectMake(10, startX+80, 300, 40)];
    [okbutton setTitle:@"搜索" forState:UIControlStateNormal];
    [okbutton addTarget:self action:@selector(searchStrToNextPage:) forControlEvents:UIControlEventTouchUpInside];
    okbutton.backgroundColor =[UIColor grayColor];
    [self.view addSubview:okbutton];
    
    
    // Do any additional setup after loading the view.
}

-(void)searchStrToNextPage:(id)sender
{    
    SearchGroupViewController *groupView = [[SearchGroupViewController alloc]init];
    groupView.conditiona = m_searchTf.text;
    [self.navigationController pushViewController:groupView animated:YES];
}







- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
