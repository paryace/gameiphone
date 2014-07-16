//
//  H5CharacterDetailsViewController.m
//  GameGroup
//
//  Created by Marss on 14-7-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "H5CharacterDetailsViewController.h"
#import "ShareToOther.h"

@interface H5CharacterDetailsViewController ()
{
    UIWebView * m_myWebView;
    UIAlertView * webViewAlert;
    UIView *bgView;
}

@end

@implementation H5CharacterDetailsViewController

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
    [self setTopViewWithTitle:@"角色详情" withBackButton:YES];
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"share_normal.png") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"share_click.png") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    
    m_myWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    m_myWebView.delegate = self;
    m_myWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSString *urlStr =[NSString stringWithFormat:@"%@token=%@&realm=%@&charactername=%@&gameid=%@&type=%@&from=from_client_ios",BaseAuthRoleUrl,[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken],@"",@"",self.gameId,@""];
    NSURL *url =[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [m_myWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
    [(UIScrollView *)[[m_myWebView subviews] objectAtIndex:0] setBounces:NO];
    [self.view addSubview:m_myWebView];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"加载中...";
}

#pragma mark ---分享button方法
-(void)shareBtnClick:(UIButton *)sender
{
    if (bgView != nil) {
        [bgView removeFromSuperview];
    }
    bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(328, 0, kScreenHeigth-320, kScreenWidth);
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.4;
    [self.view addSubview:bgView];
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"分享到"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:Nil
                                  otherButtonTitles:@"我的动态",@"新浪微博",@"微信好友",@"微信朋友圈",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIGraphicsBeginImageContext(CGSizeMake(kScreenWidth, kScreenHeigth));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (buttonIndex ==0) {
        [self performSelector:@selector(pushSendNews) withObject:nil afterDelay:1.0];
    }
    else if (buttonIndex ==1)
    {
        [[ShareToOther singleton]shareTosina:viewImage];
    }
    else if(buttonIndex ==2)
    {
        [[ShareToOther singleton]changeScene:WXSceneSession];
        
        [[ShareToOther singleton] sendImageContentWithImage:viewImage];
    }
    else if(buttonIndex ==3)
    {
        [[ShareToOther singleton] changeScene:WXSceneTimeline];
        
        [[ShareToOther singleton] sendImageContentWithImage:viewImage];
    }
    if (bgView != nil) {
        [bgView removeFromSuperview];
    }
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
    webViewAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"加载失败" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"重新加载", nil];
    [webViewAlert show];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType

{
    NSString *urlString = [[request URL] absoluteString];
    NSArray *urlComps = [urlString componentsSeparatedByString:@"://"];
    if([urlComps count] && [[urlComps objectAtIndex:0]isEqualToString:@"objc"])
    {
        NSArray *arrFucnameAndParameter = [(NSString*)[urlComps objectAtIndex:1] componentsSeparatedByString:@":/"];
        NSString *funcStr = [arrFucnameAndParameter objectAtIndex:0];
        if (1 == [arrFucnameAndParameter count])
        {
            // 没有参
            if([funcStr isEqualToString:@"closeWindows"])
            {
                /*调用本地函数1*/
                NSLog(@"doFunc1");
            }else{
            }
        }
        return NO;
    };
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [m_myWebView reload];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc
{
    webViewAlert.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
