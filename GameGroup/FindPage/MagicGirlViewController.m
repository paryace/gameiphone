//
//  MagicGirlViewController.m
//  GameGroup
//
//  Created by admin on 14-3-7.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MagicGirlViewController.h"
#import "TestViewController.h"
#import "FunsOfOtherViewController.h"
@interface MagicGirlViewController ()
{
    UIWebView *contentWebView;
}
@end

@implementation MagicGirlViewController
//1：有导航条 2:没有导航条
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self setTopViewWithTitle:@"魔女棒" withBackButton:YES];
    UIButton *delButton=[UIButton buttonWithType:UIButtonTypeCustom];
    delButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [delButton setBackgroundImage:KUIImage(@"help_normal") forState:UIControlStateNormal];
    [delButton setBackgroundImage:KUIImage(@"help_click") forState:UIControlStateHighlighted];
    [self.view addSubview:delButton];
    [delButton addTarget:self action:@selector(cleanBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    contentWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,startX, 320, self.view.bounds.size.height-(KISHighVersion_7?20:0))];
    contentWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentWebView.delegate = self;
    [contentWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&from_client_ios&%@&%@",[MymonvbangURL stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ]],self.gameid,@"2"]]]];

    [(UIScrollView *)[[contentWebView subviews] objectAtIndex:0] setBounces:NO];
    [self.view addSubview:contentWebView];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.delegate = self;
    hud.labelText = @"正在加载魔女榜...";
}

- (void)cleanBtnClick:(id)sender
{
    
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
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [contentWebView reload];
    }
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType

{
    NSString *urlString = [[request URL] absoluteString];
    NSArray *urlComps = [urlString
                         componentsSeparatedByString:@"://"];
    if([urlComps count] && [[urlComps objectAtIndex:0]
                            isEqualToString:@"objc"])
    {
        NSArray *arrFucnameAndParameter = [(NSString*)[urlComps
                                                       objectAtIndex:1] componentsSeparatedByString:@":/"];
        NSString *funcStr = [arrFucnameAndParameter objectAtIndex:0];
        NSLog(@"%@",funcStr);
        NSLog(@"%@--%d",arrFucnameAndParameter,arrFucnameAndParameter.count);
        if (1 == [arrFucnameAndParameter count])
        {
            // 没有参数
            
            
            if([funcStr isEqualToString:@"closeWindows"])
            {
                /*调用本地函数1*/
                NSLog(@"doFunc1");
                [self closeWindows];
            }else{
                
                NSArray  * array= [funcStr componentsSeparatedByString:@"/"];
                NSString *str = [array objectAtIndex:0];
                NSString *str2 = [array objectAtIndex:1];
                if ([str isEqualToString:@"enterPersonInterfaceWithId"]) {
                    [self enterPersonInterfaceWithId:str2];

                }
               else if ([str isEqualToString:@"enterFansPageWithId"]) {
                    [self enterFansPageWithId:str2];

                }
               else{
                   
               }
            }
        
        }
        return NO;
    };
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//进入个人资料界面
-(void)enterPersonInterfaceWithId:(NSString *)userid
{
    TestViewController *testVC = [[TestViewController alloc]init];
    testVC.userId = userid;
    [self.navigationController pushViewController:testVC animated:YES];
}

-(void)enterFansPageWithId:(NSString*)userid
{
    FunsOfOtherViewController *fans = [[FunsOfOtherViewController alloc]init];
    fans.userId = userid;
    [self.navigationController pushViewController:fans animated:YES];
}

- (void)closeWindows
{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
