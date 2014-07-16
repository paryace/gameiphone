//
//  EditInfoViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "EditInfoViewController.h"

@interface EditInfoViewController ()
{
    UITextView *firstTextView;
    UITextView *secondTextView;
}
@end

@implementation EditInfoViewController

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
    
    
    [self setTopViewWithTitle:@"队伍信息设置" withBackButton:YES];
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(saveChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    
    firstTextView = [[UITextView alloc]initWithFrame:CGRectMake(20, startX+10, 280, 70)];
    firstTextView.font = [UIFont systemFontOfSize:14];
    firstTextView.backgroundColor = [UIColor whiteColor];
    firstTextView.text = self.firstStr;
    [self.view addSubview:firstTextView];
    
//    secondTextView =  [[UITextView alloc]initWithFrame:CGRectMake(20, startX+90, 280, 70)];
//    secondTextView.font = [UIFont systemFontOfSize:14];
//    secondTextView.text = self.secondStr;
//    secondTextView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:secondTextView];

//    UIButton *dissolutionRoom = [[UIButton alloc]initWithFrame:CGRectMake(20, startX+180, 280, 44)];
////    [dissolutionRoom setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
////    [dissolutionRoom setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
//    dissolutionRoom.backgroundColor = [UIColor grayColor];
//    [dissolutionRoom setTitle:@"解散群组" forState:UIControlStateNormal];
////    dissolutionRoom.backgroundColor = [UIColor clearColor];
//    [dissolutionRoom addTarget:self action:@selector(dissolutionRoom:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:dissolutionRoom];

    hud = [[MBProgressHUD alloc]initWithView: self.view];
    [self.view addSubview:hud];
    hud.labelText = @"保存中...";
    // Do any additional setup after loading the view.
}

-(void)saveChanged:(id)sender
{
    [hud show:YES];
    [firstTextView resignFirstResponder];
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:self.itemId forKey:@"roomId"];
    if (self.isStyle) {
        [paramDict setObject:firstTextView.text forKey:@"description"];
    }else{
        [paramDict setObject:firstTextView.text forKey:@"options"];
 
    }
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"274" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [self showMessageWindowWithContent:@"修改成功" imageType:0];
 
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];

}




-(void)dissolutionRoom:(id)sender
{
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.itemId forKey:@"roomId"];
    [postDict setObject:paramDict forKey:@"params"];

    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"270" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self showMessageWindowWithContent:@"解散成功" imageType:1];
        
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];
    
 
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
