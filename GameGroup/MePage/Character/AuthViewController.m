//
//  AuthViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-20.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "AuthViewController.h"
#import "EGOImageView.h"
#import "CharacterEditViewController.h"
@interface AuthViewController ()
{
    UIWebView * m_myWebView;
    UIAlertView * webViewAlert;
}
@end

@implementation AuthViewController

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
    
    [self setTopViewWithTitle:@"认证游戏角色" withBackButton:YES];
//    [self getDataByNet];
    
    m_myWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    m_myWebView.delegate = self;
    m_myWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    NSString *urlStr =[NSString stringWithFormat:@"%@token=%@&realm=%@&charactername=%@&gameid=%@&type=%@&from=from_client_ios",BaseAuthRoleUrl,[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken],self.realm,self.character,self.gameId,self.Type?self.Type:@""];
    NSURL *url =[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [m_myWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
    [(UIScrollView *)[[m_myWebView subviews] objectAtIndex:0] setBounces:NO];
    [self.view addSubview:m_myWebView];

    
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"加载中...";
    
    
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
            // 没有参
            
            
            if([funcStr isEqualToString:@"closeWindows"])
            {
                /*调用本地函数1*/
                NSLog(@"doFunc1");
                [self closeWindows];
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
-(void)closeWindows
{
    [self showMessageWindowWithContent:@"认证成功" imageType:0];
    if (self.isComeFromFirstOpen) {
        [[TempData sharedInstance]isBindingRolesWithBool:YES];

        [self dismissViewControllerAnimated:YES completion:^{
//            [self.authDelegate authCharacterRegist];
        }];
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}




//- (void)getDataByNet
//{
//    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
//    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
//    
//    [paramDict setObject:self.gameId forKey:@"gameid"];
//    [paramDict setObject:self.realm forKey:@"realm"];
//    [paramDict setObject:self.character forKey:@"charactername"];
//
//    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
//    [postDict setObject:paramDict forKey:@"params"];
//    [postDict setObject:@"220" forKey:@"method"];
//    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
//    
//    
//    [hud show:YES];
//    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [hud hide:YES];
//        if ([responseObject isKindOfClass:[NSDictionary class]]) {
//            [self buildListWithArray:KISDictionaryHaveKey(responseObject, @"area1")];
//            [self buildContentWithArray:KISDictionaryHaveKey(responseObject, @"area2")];
//            if ([[responseObject allKeys]containsObject:@"area3"]) {
//                [self buildOKbutton:KISDictionaryHaveKey(responseObject, @"area3")];
//            }
//        }
//        
//        
//       
//    } failure:^(AFHTTPRequestOperation *operation, id error) {
//        if ([error isKindOfClass:[NSDictionary class]]) {
//            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
//            {
//                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//                alert.tag = 100;
//                [alert show];
//            }
//        }
//        [hud hide:YES];
//    }];
//}
//
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == 100 || alertView.tag == 102) {
//        if (buttonIndex == alertView.cancelButtonIndex) {
//            if (alertView.tag == 102) {//认证成功
//                if (self.authDelegate && [self.authDelegate respondsToSelector:@selector(authCharacterSuccess)]) {
//                    [self.authDelegate authCharacterSuccess];
//                }
//            }
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }
//    }
////    else if(alertView.tag == 101)
////    {
////        [self.authDelegate authCharacterSuccess];
////        [self.navigationController popViewControllerAnimated:YES];
////    }
//}
//
//-(void)buildListWithArray:(NSArray *)array
//{
//    for (int i =0; i<array.count; i++) {
//        NSDictionary *dic = array[i];
//        UILabel* table_label_one = [[UILabel alloc] initWithFrame:CGRectMake(10, startX+42*i, 100, 40)];
//        table_label_one.textColor = kColorWithRGB(102, 102, 102, 1.0);
//        table_label_one.font = [UIFont boldSystemFontOfSize:15.0];
//        table_label_one.text =KISDictionaryHaveKey(dic, @"name");
//        table_label_one.backgroundColor = [UIColor clearColor];
//        [self.view addSubview:table_label_one];
//        
//        if ([[dic allKeys]containsObject:@"icon"]) {
//            EGOImageView* gameImg = [[EGOImageView alloc] initWithFrame:CGRectMake(120, startX+11+42*i, 18, 18)];
//            NSString * imageId=KISDictionaryHaveKey(dic, @"icon");
////            gameImg.imageURL= [NSURL URLWithString:[BaseImageUrl stringByAppendingString:imageId]];
//            gameImg.imageURL=[ImageService getImageUrl4:imageId];
//            [self.view addSubview:gameImg];
//        }
//        
//        UILabel* gameName = [CommonControlOrView setLabelWithFrame:CGRectMake(155, startX+40*i, 100, 40) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:15.0] text:KISDictionaryHaveKey(dic, @"value") textAlignment:NSTextAlignmentLeft];
//        [self.view addSubview:gameName];
//        
//        UIImageView* lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, startX+40*i, kScreenWidth, 2)];
//        lineImg.image = KUIImage(@"line");
//        lineImg.backgroundColor = [UIColor clearColor];
//        [self.view addSubview:lineImg];
//    }
//}
//
//-(void)buildContentWithArray:(NSArray *)array
//{
//    NSMutableArray *hegarr = [NSMutableArray array];
//    float heightForlb=0;
//    for (int i=0; i<array.count; i++) {
//                float height = [self returnSizeHeightWithValue:KISDictionaryHaveKey(array[i], @"value") font:KISDictionaryHaveKey(array[i], @"fontSize")];
//        heightForlb+=height;
//        [hegarr addObject:@(heightForlb)];
//    }
//    
//    for (int i =0; i<array.count; i++) {
//        NSDictionary *dic = array[i];
//        UILabel*  topLabel = [[UILabel alloc] init];
//        topLabel.text = KISDictionaryHaveKey(dic, @"value");
//        topLabel.font = [UIFont boldSystemFontOfSize:[KISDictionaryHaveKey(dic, @"fontSize")floatValue]];
//
//        float height = [self returnSizeHeightWithValue:KISDictionaryHaveKey(dic, @"value") font:KISDictionaryHaveKey(dic, @"fontSize")];
//        float hh = [hegarr[i] floatValue];
//
//        topLabel.textAlignment = [self putoutAletr:KISDictionaryHaveKey(dic, @"textAlign")];
//        topLabel.frame = CGRectMake(10, startX+130+hh-height, 300, height);
//        topLabel.numberOfLines = 0;
//        topLabel.backgroundColor = [UIColor clearColor];
//        topLabel.textColor =[self stringTOColor:KISDictionaryHaveKey(dic, @"color")];
//        [self.view addSubview:topLabel];
//}
//
//
//}
//-(float)returnSizeHeightWithValue:(NSString *)value font:(NSString *)font
//{
//    CGSize cSize = [value sizeWithFont:[UIFont systemFontOfSize:[font floatValue]] constrainedToSize:CGSizeMake(300, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//    return cSize.height;
//}
////    UILabel*  topLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, startX+130, 300, 40)];
////    topLabel.text = KISDictionaryHaveKey(array[0], @"value");
////    topLabel.numberOfLines = 0;
////    topLabel.backgroundColor = [UIColor clearColor];
////    topLabel.textColor =[self stringTOColor:KISDictionaryHaveKey(array[0], @"color")];
////    topLabel.font = [UIFont boldSystemFontOfSize:[KISDictionaryHaveKey(array[0], @"fontSize")floatValue]];
////    [self.view addSubview:topLabel];
////
////    UILabel* authitem  = [CommonControlOrView setLabelWithFrame:CGRectMake(10, startX+150, 300, 50) textColor:[self stringTOColor:KISDictionaryHaveKey(array[0], @"color")] font:[UIFont boldSystemFontOfSize:[KISDictionaryHaveKey(array[0], @"fontSize")floatValue]] text:KISDictionaryHaveKey(array[0], @"value") textAlignment:NSTextAlignmentCenter];
////    [self.view addSubview:authitem];
////
////    UILabel*  bottomLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(10, startX+200, 300, 40)];
////    bottomLabel1.text = KISDictionaryHaveKey(array[0], @"value");
////    bottomLabel1.numberOfLines = 0;
////    bottomLabel1.backgroundColor = [UIColor clearColor];
////    bottomLabel1.textColor = [self stringTOColor:KISDictionaryHaveKey(array[0], @"color")];
////    bottomLabel1.font = [UIFont boldSystemFontOfSize:[KISDictionaryHaveKey(array[0], @"fontSize")floatValue]];
////    [self.view addSubview:bottomLabel1];
////    bottomLabel1.textAlignment = [self putoutAletr:KISDictionaryHaveKey(array[0], @"textAlign")];
//
//#pragma mark - 颜色转换 IOS中十六进制的颜色转换为UIColor
////转换16进制颜色
//- (UIColor *) stringTOColor:(NSString *)str
//{
//    if (!str || [str isEqualToString:@""]) {
//        return nil;
//    }
//    unsigned red,green,blue;
//    NSRange range;
//    range.length = 2;
//    range.location = 1;
//    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&red];
//    range.location = 3;
//    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&green];
//    range.location = 5;
//    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&blue];
//    UIColor *color= [UIColor colorWithRed:red green:green blue:blue alpha:1];
//    
//    return color;
//}
//
//-(NSTextAlignment)putoutAletr:(NSString *)str
//{
//    if ([str isEqualToString:@"left"]) {
//        return NSTextAlignmentLeft;
//    }
//    else if([str isEqualToString:@"center"])
//    {
//        return NSTextAlignmentCenter;
//    }
//    else{
//        return NSTextAlignmentRight;
//    }
//}
//-(void)buildOKbutton:(NSArray *)array
//{
//    if (!array||![array isKindOfClass:[NSArray class]]||array.count<1) {
//        return;
//    }
//    NSDictionary *dic = [array objectAtIndex:0];
//    UIButton* authButton = [[UIButton alloc] initWithFrame:CGRectMake(10, startX+250, 300, 40)];
//    [authButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
//    [authButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
//    [authButton setTitle:KISDictionaryHaveKey(dic, @"value") forState:UIControlStateNormal];
//    [authButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    authButton.backgroundColor = [UIColor clearColor];
//    [authButton addTarget:self action:@selector(authButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:authButton];
//
//}
//
//- (void)authButtonClick:(id)sender
//{
//    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
//    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
//    
//    [paramDict setObject:self.gameId forKey:@"gameid"];
//    [paramDict setObject:self.realm forKey:@"realm"];
//    [paramDict setObject:self.character forKey:@"charactername"];
//
//    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
//    [postDict setObject:paramDict forKey:@"params"];
//    [postDict setObject:@"127" forKey:@"method"];
//    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
//    
//    
//    [hud show:YES];
//    
//    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [hud hide:YES];
//        NSLog(@"%@", responseObject);
//        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"认证成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        alert.tag = 102;
//        [alert show];
//    } failure:^(AFHTTPRequestOperation *operation, id error) {
//        if ([error isKindOfClass:[NSDictionary class]]) {
//            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
//            {
//                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//                alert.tag = 101;
//                [alert show];
//            }
//        }
//        [hud hide:YES];
//    }];
//}

- (void)dealloc
{
    webViewAlert.delegate = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
