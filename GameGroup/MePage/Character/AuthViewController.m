//
//  AuthViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-20.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "AuthViewController.h"
#import "EGOImageView.h"
@interface AuthViewController ()
{
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
    [self getDataByNet];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"查询中...";
}

- (void)getDataByNet
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:self.realm forKey:@"realm"];
    [paramDict setObject:self.character forKey:@"charactername"];

    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"220" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    
    
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self buildListWithArray:KISDictionaryHaveKey(responseObject, @"area1")];
            [self buildContentWithArray:KISDictionaryHaveKey(responseObject, @"area2")];
            if ([[responseObject allKeys]containsObject:@"area3"]) {
                [self buildOKbutton:KISDictionaryHaveKey(responseObject, @"area3")];
            }
        }
        
        
       
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag = 100;
                [alert show];
            }
        }
        [hud hide:YES];
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 || alertView.tag == 102) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            if (alertView.tag == 102) {//认证成功
                if (self.authDelegate && [self.authDelegate respondsToSelector:@selector(authCharacterSuccess)]) {
                    [self.authDelegate authCharacterSuccess];
                }
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
//    else if(alertView.tag == 101)
//    {
//        [self.authDelegate authCharacterSuccess];
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}

-(void)buildListWithArray:(NSArray *)array
{
    for (int i =0; i<array.count; i++) {
        NSDictionary *dic = array[i];
        UILabel* table_label_one = [[UILabel alloc] initWithFrame:CGRectMake(10, startX+42*i, 100, 40)];
        table_label_one.textColor = kColorWithRGB(102, 102, 102, 1.0);
        table_label_one.font = [UIFont boldSystemFontOfSize:15.0];
        table_label_one.text =KISDictionaryHaveKey(dic, @"name");
        table_label_one.backgroundColor = [UIColor clearColor];
        [self.view addSubview:table_label_one];
        
        if ([[dic allKeys]containsObject:@"icon"]) {
            EGOImageView* gameImg = [[EGOImageView alloc] initWithFrame:CGRectMake(120, startX+11+42*i, 18, 18)];
            gameImg.imageURL= [NSURL URLWithString:[BaseImageUrl stringByAppendingString:KISDictionaryHaveKey(dic, @"icon")]];
            [self.view addSubview:gameImg];
        }
        
        UILabel* gameName = [CommonControlOrView setLabelWithFrame:CGRectMake(155, startX+40*i, 100, 40) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:15.0] text:KISDictionaryHaveKey(dic, @"value") textAlignment:NSTextAlignmentLeft];
        [self.view addSubview:gameName];
        
        UIImageView* lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, startX+40*i, kScreenWidth, 2)];
        lineImg.image = KUIImage(@"line");
        lineImg.backgroundColor = [UIColor clearColor];
        [self.view addSubview:lineImg];
    }
}

-(void)buildContentWithArray:(NSArray *)array
{
    
    UILabel*  topLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, startX+130, 300, 40)];
    topLabel.text = KISDictionaryHaveKey(array[0], @"value");
    topLabel.numberOfLines = 0;
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.textColor =[self stringTOColor:KISDictionaryHaveKey(array[0], @"color")];
    topLabel.font = [UIFont boldSystemFontOfSize:[KISDictionaryHaveKey(array[0], @"fontSize")floatValue]];
    [self.view addSubview:topLabel];

    UILabel* authitem  = [CommonControlOrView setLabelWithFrame:CGRectMake(10, startX+150, 300, 50) textColor:[self stringTOColor:KISDictionaryHaveKey(array[1], @"color")] font:[UIFont boldSystemFontOfSize:[KISDictionaryHaveKey(array[1], @"fontSize")floatValue]] text:KISDictionaryHaveKey(array[1], @"value") textAlignment:NSTextAlignmentCenter];
    [self.view addSubview:authitem];

    UILabel*  bottomLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(10, startX+200, 300, 40)];
    bottomLabel1.text = KISDictionaryHaveKey(array[2], @"value");
    bottomLabel1.numberOfLines = 0;
    bottomLabel1.backgroundColor = [UIColor clearColor];
    bottomLabel1.textColor = [self stringTOColor:KISDictionaryHaveKey(array[2], @"color")];
    bottomLabel1.font = [UIFont boldSystemFontOfSize:[KISDictionaryHaveKey(array[2], @"fontSize")floatValue]];
    [self.view addSubview:bottomLabel1];
    bottomLabel1.textAlignment = [self putoutAletr:KISDictionaryHaveKey(array[2], @"textAlign")];
}
#pragma mark - 颜色转换 IOS中十六进制的颜色转换为UIColor
//转换16进制颜色
- (UIColor *) stringTOColor:(NSString *)str
{
    if (!str || [str isEqualToString:@""]) {
        return nil;
    }
    unsigned red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 1;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&blue];
    UIColor *color= [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
    return color;
}

-(NSTextAlignment)putoutAletr:(NSString *)str
{
    if ([str isEqualToString:@"left"]) {
        return NSTextAlignmentLeft;
    }
    else if([str isEqualToString:@"center"])
    {
        return NSTextAlignmentCenter;
    }
    else{
        return NSTextAlignmentRight;
    }
}
-(void)buildOKbutton:(NSArray *)array
{
    if (!array||![array isKindOfClass:[NSArray class]]||array.count<1) {
        return;
    }
    NSDictionary *dic = [array objectAtIndex:0];
    UIButton* authButton = [[UIButton alloc] initWithFrame:CGRectMake(10, startX+250, 300, 40)];
    [authButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [authButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [authButton setTitle:KISDictionaryHaveKey(dic, @"value") forState:UIControlStateNormal];
    [authButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    authButton.backgroundColor = [UIColor clearColor];
    [authButton addTarget:self action:@selector(authButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:authButton];

}

- (void)authButtonClick:(id)sender
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:self.realm forKey:@"realm"];
    [paramDict setObject:self.character forKey:@"charactername"];

    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"127" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    
    
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        NSLog(@"%@", responseObject);
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"认证成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alert.tag = 102;
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag = 101;
                [alert show];
            }
        }
        [hud hide:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
