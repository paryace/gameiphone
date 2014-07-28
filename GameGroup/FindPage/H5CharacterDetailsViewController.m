//
//  H5CharacterDetailsViewController.m
//  GameGroup
//
//  Created by Marss on 14-7-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "H5CharacterDetailsViewController.h"
#import "ShareToOther.h"
#import "SendNewsViewController.h"

@interface H5CharacterDetailsViewController ()
{
    UIWebView * m_myWebView;
    UIAlertView * webViewAlert;
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
    NSString *urlStr =[NSString stringWithFormat:@"%@%@token=%@&characterid=%@&gameid=%@",BaseLolRoleDetail,self.gameUrl,[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken],self.characterId,self.gameId];
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
}

- (void)pushSendNews
{
    UIGraphicsBeginImageContext(CGSizeMake(kScreenWidth, kScreenHeigth));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSString * imageName=[NSString stringWithFormat:@"%@.jpg",uuid];
    NSString * imagePath=[self writeImageToFile:viewImage ImageName:imageName];//完整路径
    if (imagePath) {
        SendNewsViewController* VC = [[SendNewsViewController alloc] init];
        VC.titleImage = viewImage;
        VC.titleImageName = imageName;
        VC.delegate = self;
        VC.isComeFromMe = NO;
        VC.defaultContent = [NSString stringWithFormat:@"分享了%@的数据",self.characterName];
        [self.navigationController pushViewController:VC animated:NO];
    }
}

//将图片保存到本地，返回保存的路径
-(NSString*)writeImageToFile:(UIImage*)thumbimg ImageName:(NSString*)imageName
{
    NSData * imageDate=[self compressImage:thumbimg];
    NSString *path = [RootDocPath stringByAppendingPathComponent:@"tempImage"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path] == NO)
    {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString  *openImgPath = [NSString stringWithFormat:@"%@/%@",path,imageName];
    if ([imageDate writeToFile:openImgPath atomically:YES]) {
        return openImgPath;
    }
    return nil;
}
//压缩图片
-(NSData*)compressImage:(UIImage*)thumbimg
{
    UIImage * a = [NetManager compressImage:thumbimg targetSizeX:640 targetSizeY:1136];
    NSData *imageData = UIImageJPEGRepresentation(a, 0.7);
    return imageData;
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
