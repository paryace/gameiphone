//
//  StartViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-5.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "StartViewController.h"
#import "AppDelegate.h"
#import "IntroduceViewController.h"
#import "MessagePageViewController.h"
#import "FindViewController.h"
#import "MePageViewController.h"
#import "MLNavigationController.h"
#import "Custom_tabbar.h"
#import "LocationManager.h"
#import "TempData.h"
#import "MLNavigationController.h"
#import "NewFriendPageController.h"
#import "DownloadImageService.h"

#define kStartViewShowTime  (2.0f) //开机页面 显示时长

@interface StartViewController ()
{
    UIImageView* splashImageView;
}

@end

@implementation StartViewController

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
    
    [[GameCommon shareGameCommon]firtOpen];
    splashImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    splashImageView.image = [self getOpenImage];

    [self.view addSubview:splashImageView];
    [self performSelector:@selector(showLoading:) withObject:nil afterDelay:kStartViewShowTime];
    [[LocationManager sharedInstance] initLocation];//定位
    [self getUserLocation];
    [self getOpenImageFromNet];
}

-(UIImage*)getOpenImage
{
    NSString * imageId = [[NSUserDefaults standardUserDefaults] objectForKey:OpenImage];
    if ([GameCommon isEmtity:imageId]) {
        return [self getDefaultOpenImage];
    }
    return [self getOpemImageByImageId:imageId];
}
-(UIImage*)getOpemImageByImageId:(NSString*)imageId
{
    NSString *openImgPath = [RootDocPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",imageId]];
    UIImage *openImage = [[UIImage alloc]initWithContentsOfFile:openImgPath];
    if (openImage&&![openImage isEqual:@""]) {
        return openImage;
//        return [NetManager image2:openImage centerInSize:CGSizeMake(self.view.bounds.size.width*2, self.view.bounds.size.height*2)];
    }
    return [self getDefaultOpenImage];
}

-(UIImage*)getDefaultOpenImage
{
    if (iPhone5) {
        return KUIImage(@"Default-568h@2x.png");
    }
    return KUIImage(@"Default.png");
}

#pragma mark 首页或介绍页
- (void)showLoading:(id)sender
{
    [splashImageView removeFromSuperview];
//    if ([self isHaveLogin]){
    //消息页面
        MessagePageViewController* fist  = [[MessagePageViewController alloc] init];
        fist.hidesBottomBarWhenPushed = YES;
        UINavigationController* navigationController_First = [[UINavigationController alloc] initWithRootViewController:fist];
        navigationController_First.navigationBarHidden = YES;
//好友页面
        NewFriendPageController* second = [[NewFriendPageController alloc] init];
        second.hidesBottomBarWhenPushed = YES;
        UINavigationController* navigationController_Second = [[UINavigationController alloc] initWithRootViewController:second];
        navigationController_Second.navigationBarHidden = YES;
//发现页面
        FindViewController* third = [[FindViewController alloc] init];
        third.hidesBottomBarWhenPushed = YES;
        UINavigationController* navigationController_Third = [[UINavigationController alloc] initWithRootViewController:third];
        navigationController_Third.navigationBarHidden = YES;
//我的页面
        MePageViewController* fourth = [[MePageViewController alloc] init];
        fourth.hidesBottomBarWhenPushed = YES;
        UINavigationController* navigationController_Fourth = [[UINavigationController alloc] initWithRootViewController:fourth];
        navigationController_Fourth.navigationBarHidden = YES;

    
        Custom_tabbar*  ryc_tabbarController = [[Custom_tabbar alloc] init];
    
        ryc_tabbarController.viewControllers = [NSArray arrayWithObjects:navigationController_First,navigationController_Second, navigationController_Third, navigationController_Fourth, nil];
        [self presentViewController:ryc_tabbarController animated:NO completion:^{
            
        }];
}

//下载开机图
-(void)downloadImageWithID:(NSString *)imageId
{
   [[DownloadImageService singleton] startDownload:imageId];
    
//    NSString * urlStr= [ImageService getImgUrl:imageId];
//    [NetManager downloadImageWithBaseURLStr:urlStr ImageId:imageId completion:^(NSURLResponse *response, NSURL *filePath, NSError *error)
//     {
//         if (!error) {
//             [[NSUserDefaults standardUserDefaults] setObject:[GameCommon getNewStringWithId:imageId] forKey:OpenImage];
//         }
//     }
//     ];
}

#pragma mark 获取用户位置
-(void)getUserLocation
{
    [[LocationManager sharedInstance] startCheckLocationWithSuccess:^(double lat, double lon) {
        [[TempData sharedInstance] setLat:lat Lon:lon];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kMyToken]) {//自动登录
            [self upLoadUserLocationWithLat:lat Lon:lon];
        }
    } Failure:^{
        NSLog(@"开机定位失败");
    }];
}

-(void)upLoadUserLocationWithLat:(double)userLatitude Lon:(double)userLongitude
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSDictionary * locationDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",userLongitude],@"longitude",[NSString stringWithFormat:@"%f",userLatitude],@"latitude", nil];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"108" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [postDict setObject:locationDict forKey:@"params"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
//请求开机图
-(void)getOpenImageFromNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@(kScreenWidth) forKey:@"width"];
    [paramDict setObject:@(kScreenHeigth) forKey:@"height"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"263" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken]?[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken]:@"" forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict
     
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
             NSString * openImageId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"adImg")];
             NSString * imageId = [[NSUserDefaults standardUserDefaults] objectForKey:OpenImage];
            if ([GameCommon isEmtity:openImageId]) {
                [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:OpenImage];
            }else{
                if (![openImageId isEqualToString:imageId]) {
                    [self downloadImageWithID:openImageId];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
