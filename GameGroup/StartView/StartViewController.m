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
    
    [self firtOpen];
    
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

#pragma mark 开机联网
-(void)firtOpen
{
    NSMutableDictionary * paramsDic = [NSMutableDictionary dictionary];
    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
    BOOL isTrue = [fileManager fileExistsAtPath:path];
    NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:path error:NULL];
    if (isTrue && [[fileAttr objectForKey:NSFileSize] unsignedLongLongValue] != 0) {
        
     NSMutableDictionary*   openData= [NSMutableDictionary dictionaryWithContentsOfFile:path];
        [paramsDic setObject:KISDictionaryHaveKey(openData, @"gamelist_millis") forKey:@"gamelist_millis"];
    }else{
        [paramsDic setObject:@"" forKey:@"gamelist_millis"];
    }

    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramsDic forKey:@"params"];
    [postDict setObject:@"203" forKey:@"method"];
  
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self openSuccessWithInfo:responseObject From:@"firstOpen"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
}

-(void)openSuccessWithInfo:(NSDictionary *)dict From:(NSString *)where
{
//    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    [[TempData sharedInstance] setRegisterNeedMsg:[KISDictionaryHaveKey(dict, @"registerNeedMsg") doubleValue]];
    
    
    
    if ([KISDictionaryHaveKey(dict, @"clientUpdate") doubleValue]) {
        [[NSUserDefaults standardUserDefaults] setObject:KISDictionaryHaveKey(dict, @"clientUpdateUrl") forKey:@"IOSURL"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到新版本，您要升级吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立刻升级", nil];
        alert.tag = 21;
        [alert show];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IOSURL"];
    }

    
    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
    NSMutableDictionary* openData = [NSMutableDictionary dictionaryWithContentsOfFile:path] ? [NSMutableDictionary dictionaryWithContentsOfFile:path] : [NSMutableDictionary dictionaryWithCapacity:1];
    
    if ([KISDictionaryHaveKey(dict, @"gamelist_update") boolValue]) {
        
   /* 这里略乱 临时添加尚未修改 */
        
        //本地开机数据和网络获取开机数据相互遍历 判断是否需要更新
        if ([[openData allKeys]containsObject:@"gamelist"]) {
            NSDictionary *oldDic = KISDictionaryHaveKey(openData, @"gamelist");
            NSMutableArray *array = [NSMutableArray array];
            NSArray *alk =[oldDic allKeys];
            for (int i =0; i<alk.count; i++) {
                NSArray *arr = [oldDic objectForKey:alk[i] ];
                [array addObjectsFromArray:arr];
            }
            
            NSDictionary *newDic = KISDictionaryHaveKey(dict, @"gamelist");
            NSMutableArray *newArray = [NSMutableArray array];
            NSArray *allk =[newDic allKeys];
            for (int i =0; i<allk.count; i++) {
                NSArray *array = [newDic objectForKey:allk[i] ];
                [newArray addObjectsFromArray:array];
            }
            
            for (int i =  0; i<array.count; i++) {
                for (int j = 0; j<newArray.count; j++) {
                    NSDictionary *dic = array[i];
                    NSDictionary *temDic = newArray[j];
                    NSString *oldId =[GameCommon getNewStringWithId: KISDictionaryHaveKey(dic,@"id")];
                    NSString *newid =[GameCommon getNewStringWithId: KISDictionaryHaveKey(temDic, @"id")];
                    NSString *gameInfoMills =[GameCommon getNewStringWithId: KISDictionaryHaveKey(dic, @"gameInfoMills")];
                    NSString *newGameInfoMills =[GameCommon getNewStringWithId: KISDictionaryHaveKey(temDic, @"gameInfoMills")];
                    
                    if ([oldId isEqualToString: newid]&&![gameInfoMills isEqualToString: newGameInfoMills]) {
                        
                        NSLog(@"%@--%@-=-%@--%@",oldId,gameInfoMills,newid,newGameInfoMills);
                        
                        NSArray * commonPArray = KISDictionaryHaveKey(KISDictionaryHaveKey(temDic, @"gameParams"), @"commonParams");
                        for (int m =0; m<commonPArray.count; m++) {
                            NSDictionary *commonDic = commonPArray[m];
                            [self getGameInfoWithGameID:KISDictionaryHaveKey(temDic, @"id") withParams:KISDictionaryHaveKey(commonDic, @"param")];
                        }

                    }
                    else if (![[dic allKeys]containsObject:KISDictionaryHaveKey(temDic, @"id")]&&array.count<newArray.count){
                        
                        NSLog(@"%@",temDic);

                        NSArray * commonPArray = KISDictionaryHaveKey(KISDictionaryHaveKey(temDic, @"gameParams"), @"commonParams");
                        for (int m =0; m<commonPArray.count; m++) {
                            NSDictionary *commonDic = commonPArray[m];
                            [self getGameInfoWithGameID:KISDictionaryHaveKey(temDic, @"id") withParams:KISDictionaryHaveKey(commonDic, @"param")];
                        }
                    }
                }
            }
            
        }else{
            
            //第一次登陆 无本地数据
            NSDictionary *newDic = KISDictionaryHaveKey(dict, @"gamelist");
            NSMutableArray *newArray = [NSMutableArray array];
            NSArray *allk =[newDic allKeys];
            for (int i =0; i<allk.count; i++) {
                NSArray *array = [newDic objectForKey:allk[i] ];
                [newArray addObjectsFromArray:array];
            }
            for (int i =0; i<newArray.count; i++) {
                NSDictionary *dic = newArray[i];
                NSArray * commonPArray = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"gameParams"), @"commonParams");
                
                for (int j =0; j<commonPArray.count; j++) {
                    NSDictionary *commonDic = commonPArray[j];
            [self getGameInfoWithGameID:KISDictionaryHaveKey(dic, @"id") withParams:KISDictionaryHaveKey(commonDic, @"param")];
                }
            }
        }
      //把开机数据写入文件
        [dict writeToFile:path atomically:YES];
        [self saveGameIconInfo:dict];
    }else
    {
        [self saveGameIconInfo:openData];
    }
}

#pragma mark ----把所有游戏的图标以key为游戏id写入文件
-(void)saveGameIconInfo:(NSDictionary*)openData
{
    NSMutableDictionary *gameiconDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *gameListDic=KISDictionaryHaveKey(openData, @"gamelist");
    NSArray *keysArr =[gameListDic allKeys];
    for (int i = 0; i <keysArr.count; i++) {
        NSArray *arr = KISDictionaryHaveKey(gameListDic, keysArr[i]);
        for (NSDictionary *dic in arr) {
            [gameiconDic setObject:KISDictionaryHaveKey(dic, @"img") forKey:[NSString stringWithFormat:@"id%@",KISDictionaryHaveKey(dic, @"id")]];
        }
    }
    NSString *filePath  =[RootDocPath stringByAppendingString:@"/gameicon_wx"];
    [gameiconDic writeToFile:filePath atomically:YES];
    NSLog(@"%@",gameiconDic);
}
#pragma mark ----更新游戏数据、、wow服务器等
-(void)getGameInfoWithGameID:(NSString *)gameId withParams:(NSString *)params
{
    NSMutableDictionary * paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:gameId forKey:@"gameid"];
    [paramsDic setObject:params forKey:@"param"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramsDic forKey:@"params"];
    [postDict setObject:@"216" forKey:@"method"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"res -----> %@",responseObject);
        
        /*
         params 是需要输入的内容
         info是需要选择的内容
         
         
         gameName,//游戏名称
         searchParams,//查找这个游戏角色所需要的参数
         gameid,//
         bindParams,//绑定游戏角色需要上传的参数
         bindInfo,//绑定角色是需要的特殊参数----》>需要选择的参数
         commonParams,
         version,//开机返回信息的格式版本号
         commonInfo,//数据
         searchInfo//查找角色的时候需要的参数
         searchParams//
         */
      //  [self openSuccessWithInfo:responseObject From:@"firstOpen"];
        
        //把获取的数据根据游戏id保存本地

        
        NSString *filePath = [RootDocPath stringByAppendingString:@"/openInfo"];
        [responseObject writeToFile:[filePath stringByAppendingString:[NSString stringWithFormat:@"gameid_%@_%@",gameId,params]] atomically:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];

}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (21 == alertView.tag) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"IOSURL"]) {
                NSURL *url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"IOSURL"]];
                if([[UIApplication sharedApplication] canOpenURL:url])
                {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }
    }
}
#pragma mark 下载开机图
-(void)downloadImageWithID:(NSString *)imageId Type:(NSString *)theType PicName:(NSString *)picName
{
    [NetManager downloadImageWithBaseURLStr:imageId ImageId:@"" success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if ([theType isEqualToString:@"open"]) {
            NSString *path = [RootDocPath stringByAppendingPathComponent:@"OpenImages"];
            NSFileManager *fm = [NSFileManager defaultManager];
            if([fm fileExistsAtPath:path] == NO)
            {
                [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString  *openImgPath = [NSString stringWithFormat:@"%@/openImage.jpg",path];
            
            if ([UIImageJPEGRepresentation(image, 1.0) writeToFile:openImgPath atomically:YES]) {
                NSLog(@"success///");
                [[NSUserDefaults standardUserDefaults] setObject:imageId forKey:@"OpenImg"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else
            {
                NSLog(@"fail");
            }
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
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
