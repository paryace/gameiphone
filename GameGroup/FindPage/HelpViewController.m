//
//  HelpViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-4-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

{
    UIWebView *contentWebView;
}
@end

@implementation HelpViewController

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
    
    [self setTopViewWithTitle:@"帮助" withBackButton:YES];
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-42, KISHighVersion_7?27:7, 37, 30)];
    [shareButton setTitle:@"列表" forState:UIControlStateNormal];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(backToHomePage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    
    contentWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX)];
    contentWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentWebView.delegate = self;
    [contentWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[BaseHelpUrl stringByAppendingString:self.myUrl]]]];
    [(UIScrollView *)[[contentWebView subviews] objectAtIndex:0] setBounces:NO];
    [self.view addSubview:contentWebView];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"加载中..";
    
    
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [hud show:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [hud hide:YES];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [hud hide:YES];
    [webView stopLoading];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"加载失败" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"重新加载", nil];
    [alert show];
}

-(void)backToHomePage:(id)sender
{
    [contentWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[BaseHelpUrl stringByAppendingString:@"help.html"]]]];
    //[contentWebView reload];
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
