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
#import "FriendPageViewController.h"
#import "FindViewController.h"
#import "MePageViewController.h"
//#import "NewFindViewController.h"

#import "MLNavigationController.h"
#import "Custom_tabbar.h"

#import "LocationManager.h"
#import "TempData.h"

#import "MLNavigationController.h"
#import "NewFriendPageController.h"
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
    
    if (iPhone5) {
        splashImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
        splashImageView.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
    }
    else
    {
        splashImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default.png"]];
        splashImageView.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
    }
    [self.view addSubview:splashImageView];
    [self performSelector:@selector(showLoading:) withObject:nil afterDelay:kStartViewShowTime];
    
//    [self showLoading:nil];
    [[LocationManager sharedInstance] initLocation];//定位
    [self getUserLocation];
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


//#pragma mark 下载开机图
//-(void)downloadImageWithID:(NSString *)imageId Type:(NSString *)theType PicName:(NSString *)picName
//{
//    [NetManager downloadImageWithBaseURLStr:imageId ImageId:@"" success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//        if ([theType isEqualToString:@"open"]) {
//            NSString *path = [RootDocPath stringByAppendingPathComponent:@"OpenImages"];
//            NSFileManager *fm = [NSFileManager defaultManager];
//            if([fm fileExistsAtPath:path] == NO)
//            {
//                [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//            }
//            NSString  *openImgPath = [NSString stringWithFormat:@"%@/openImage.jpg",path];
//            
//            if ([UIImageJPEGRepresentation(image, 1.0) writeToFile:openImgPath atomically:YES]) {
//                NSLog(@"success///");
//                [[NSUserDefaults standardUserDefaults] setObject:imageId forKey:@"OpenImg"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
//            else
//            {
//                NSLog(@"fail");
//            }
//        }
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        
//    }];
//}

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
//    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] forKey:@"userid"];
    [postDict setObject:@"108" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [postDict setObject:locationDict forKey:@"params"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
