//
//  LoginViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-6.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "MessagePageViewController.h"
#import "FriendPageViewController.h"
#import "NewFindViewController.h"
#import "MePageViewController.h"
#import "Custom_tabbar.h"
#import "FindPasswordViewController.h"
#import "ReconnectMessage.h"
#import "UserManager.h"

#define kLabelFont (14.0)

@interface LoginViewController ()
{
    UITextField* phoneTextField;
    UITextField* passwordTextField;
}
@end

@implementation LoginViewController

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

    [self setTopViewWithTitle:@"用户登录" withBackButton:YES];
    [self setMainView];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"登录中...";
}

- (void)setMainView
{
    UIImageView* table_top = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15 + startX, 300, 40)];
    table_top.image = KUIImage(@"table_top");
    [self.view addSubview:table_top];
    
    UIImageView* table_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(280, 31 + startX, 12, 8)];
    table_arrow.image = KUIImage(@"arrow_bottom");
    [self.view addSubview:table_arrow];
    
    UIImageView* table_middle = [[UIImageView alloc] initWithFrame:CGRectMake(10, 55 + startX, 300, 40)];
    table_middle.image = KUIImage(@"table_middle");
    [self.view addSubview:table_middle];
    
    UIImageView* table_bottom = [[UIImageView alloc] initWithFrame:CGRectMake(10, 95 + startX, 300, 40)];
    table_bottom.image = KUIImage(@"table_bottom");
    [self.view addSubview:table_bottom];
    
    UILabel* table_label_one = [[UILabel alloc] initWithFrame:CGRectMake(20, 16 + startX, 100, 38)];
    table_label_one.text = @"中国(+86)";
    table_label_one.textColor = kColorWithRGB(128, 128, 128, 1.0);
    table_label_one.font = [UIFont boldSystemFontOfSize:kLabelFont];
    [self.view addSubview:table_label_one];
    
    UILabel* table_label_two = [[UILabel alloc] initWithFrame:CGRectMake(20, 56 + startX, 80, 38)];
    table_label_two.text = @"手机号";
    table_label_two.textColor = kColorWithRGB(128, 128, 128, 1.0);
    table_label_two.font = [UIFont boldSystemFontOfSize:kLabelFont];
    [self.view addSubview:table_label_two];
    
    UILabel* table_label_three = [[UILabel alloc] initWithFrame:CGRectMake(20, 96 + startX, 80, 38)];
    table_label_three.text = @"密 码";
    table_label_three.textColor = kColorWithRGB(128, 128, 128, 1.0);
    table_label_three.font = [UIFont boldSystemFontOfSize:kLabelFont];
    [self.view addSubview:table_label_three];
    
    phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(60, 55 + startX, 240, 40)];
    phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    phoneTextField.returnKeyType = UIReturnKeyDone;
    phoneTextField.delegate = self;
    phoneTextField.textAlignment = NSTextAlignmentRight;
    phoneTextField.font = [UIFont boldSystemFontOfSize:15.0];
    phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:phoneTextField];
    
    
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(60, 95 + startX, 240, 40)];
    passwordTextField.keyboardType = UIKeyboardTypeEmailAddress;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.delegate = self;
    passwordTextField.textAlignment = NSTextAlignmentRight;
    passwordTextField.font = [UIFont boldSystemFontOfSize:15.0];
    passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:passwordTextField];
    
    UIButton* loginButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 150 + startX, 300, 40)];
    [loginButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [loginButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [loginButton setTitle:@"登 录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.backgroundColor = [UIColor clearColor];
    [loginButton addTarget:self action:@selector(hitLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    UIButton* findPasButton = [[UIButton alloc] initWithFrame:CGRectMake(70, 210 + startX, 80, 40)];
    [findPasButton setTitle:@"找回密码" forState:UIControlStateNormal];
    [findPasButton setTitleColor:kColorWithRGB(128, 128, 128, 1.0) forState:UIControlStateNormal];
    findPasButton.backgroundColor = [UIColor clearColor];
    findPasButton.titleLabel.font = [UIFont boldSystemFontOfSize:kLabelFont];
    [findPasButton addTarget:self action:@selector(hitFindSectetButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:findPasButton];
    
    UIButton* registerButton = [[UIButton alloc] initWithFrame:CGRectMake(150, 210 + startX, 100, 40)];
    [registerButton setTitle:@"|    新用户注册" forState:UIControlStateNormal];
    [registerButton setTitleColor:kColorWithRGB(128, 128, 128, 1.0) forState:UIControlStateNormal];
    registerButton.backgroundColor = [UIColor clearColor];
    registerButton.titleLabel.font = [UIFont boldSystemFontOfSize:kLabelFont];
    [registerButton addTarget:self action:@selector(hitRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerButton];

}

#pragma mark 登陆
- (void)hitLoginButton:(id)sender
{
    [self hideKeyBoard];
    
    if (KISEmptyOrEnter(phoneTextField.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入手机号！" buttonTitle:@"确定"];
        return;
    }
    if (KISEmptyOrEnter(passwordTextField.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入密码！" buttonTitle:@"确定"];
        return;
    }
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];

    [params setObject:phoneTextField.text forKey:@"username"];
    [params setObject:passwordTextField.text forKey:@"password"];
//    [params setObject:@"15811212096" forKey:@"username"];
//    [params setObject:@"111111" forKey:@"password"];

//    NSString * deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:PushDeviceToken];
    [params setObject:[GameCommon shareGameCommon].deviceToken forKey:@"deviceToken"];
    [params setObject:appType forKey:@"appType"];

    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"101" forKey:@"method"];

    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];

        [[NSUserDefaults standardUserDefaults] setValue:phoneTextField.text forKey:PhoneNumKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSDictionary* dic = responseObject;
        [[NSUserDefaults standardUserDefaults]setObject:[[dic objectForKey:@"token"] objectForKey:@"userid"] forKey:@"MyUserId"];
        [[NSUserDefaults standardUserDefaults]setObject:[[dic objectForKey:@"token"] objectForKey:@"token"] forKey:kMyToken];
        [DataStoreManager setDefaultDataBase:[[dic objectForKey:@"token"] objectForKey:@"userid"] AndDefaultModel:@"LocalStore"];
        
        [[NSUserDefaults standardUserDefaults] setObject:KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"chatServer"), @"address") forKey:@"host"];
        [[NSUserDefaults standardUserDefaults] setObject:KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"chatServer"), @"name") forKey:@"domain"];
        
        [self upLoadUserLocationWithLat:[[TempData sharedInstance] returnLat] Lon:[[TempData sharedInstance] returnLon]];
        
        
        [[ReconnectMessage singleton] getChatServer];
        

//        [SFHFKeychainUtils storeUsername:LOCALTOKEN andPassword:[[dic objectForKey:@"token"] objectForKey:@"token"] forServiceName:LOCALACCOUNT updateExisting:YES error:nil];
//        
//        [SFHFKeychainUtils storeUsername:ACCOUNT andPassword:phoneTextField.text forServiceName:LOCALACCOUNT updateExisting:YES error:nil];
//        
//        [SFHFKeychainUtils storeUsername:PASSWORD andPassword:passwordTextField.text forServiceName:LOCALACCOUNT updateExisting:YES error:nil];
      
        
        
       // [GameCommon cleanLastData];//因1.0是用username登陆xmpp 后面版本是userid 必须清掉聊天消息和关注表

        [self loginSuccess];

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

- (void)loginSuccess
{
    
    
    
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
//    NSLog()
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark 上传用户位置 经度 纬度
-(void)upLoadUserLocationWithLat:(double)userLatitude Lon:(double)userLongitude
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSDictionary * locationDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",userLongitude],@"longitude",[NSString stringWithFormat:@"%f",userLatitude],@"latitude", nil];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyUserId"] forKey:@"userid"];
    [postDict setObject:@"108" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];
    [postDict setObject:locationDict forKey:@"params"];

    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        
    }];
}

#pragma mark 注册
- (void)hitRegisterButton:(id)sender
{
    [self hideKeyBoard];
    
    RegisterViewController *viewController = [[RegisterViewController alloc]init];
    viewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark 找回密码
- (void)hitFindSectetButton:(id)sender
{
    [self hideKeyBoard];
    
//    UIActionSheet* actionSheet = [[UIActionSheet alloc]
//                                  initWithTitle:@"找回密码"
//                                  delegate:self
//                                  cancelButtonTitle:@"取消"
//                                  destructiveButtonTitle:Nil
//                                  otherButtonTitles:@"通过手机号找回密码", @"通过邮箱找回密码", nil];
//    [actionSheet showInView:self.view];
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"找回密码"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:Nil
                                  otherButtonTitles:@"通过手机号找回密码", nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    FindPasswordViewController *viewController = [[FindPasswordViewController alloc]init];
    viewController.hidesBottomBarWhenPushed = YES;
    if (buttonIndex == 0) {
        viewController.viewType = FINDPAS_TYPE_PHONENUM;
    }
//    else if(buttonIndex == 1){
//        viewController.viewType = FINDPAS_TYPE_EMAIL;
//    }
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark 隐藏键盘
- (void)hideKeyBoard
{
    [phoneTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
}

#pragma mark textField and touch delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (phoneTextField == textField) {
        if (phoneTextField.text.length >= 11 && range.length == 0)//只允许输入11位
        {
            return  NO;
        }
        else//只允许输入数字
        {
            if (range.length == 1)//如果是输入字符，range的length会为0,删除字符为1
            {//判断如果是删除字符，就直接返回yes
                return YES;
            }
            NSCharacterSet *cs;
            cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];

            NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];

            BOOL canChange = [string isEqualToString:filtered];
            
            return canChange;
        }
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
/*
 {
 characters =         {
 1 =             (
 {
 achievementPoints = 9615;
 auth = 1;
 battlegroup = "Battle Group 11";
 classObj =                     {
 id = 3;
 mask = 4;
 name = "\U730e\U4eba";
 powerType = focus;
 };
 clazz = 3;
 content = " ";
 failedmsg = "";
 failednum = 5;
 filepath = "/home/appusr/characters/\U5361\U62c9\U8d5e/\U8840\U6027\U706c\U6b87.zip";
 gender = 1;
 guild = "\U8056\U5b89\U5730\U5217\U65af";
 guildRealm = "\U5361\U62c9\U8d5e";
 id = 155316;
 iscatch = 1;
 itemlevel = 541;
 itemlevelequipped = 468;
 lastModified = 1397319000000;
 level = 90;
 mountsnum = 85;
 name = "\U8840\U6027\U706c\U6b87";
 pveScore = 980;
 pvpScore = 0;
 race = 10;
 raceObj =                     {
 id = 10;
 mask = 512;
 name = "\U8840\U7cbe\U7075";
 side = horde;
 sidename = "\U90e8\U843d";
 };
 rank = 5;
 realm = "\U5361\U62c9\U8d5e";
 thumbnail = 178953;
 totalHonorableKills = 11436;
 },
 {
 achievementPoints = 9705;
 auth = 1;
 battlegroup = " ";
 classObj =                     {
 id = 1;
 mask = 1;
 name = "\U6218\U58eb";
 powerType = rage;
 };
 clazz = 1;
 content = " ";
 failedmsg = "";
 failednum = 0;
 filepath = "/home/appusr/characters/\U51b0\U971c\U4e4b\U5203/\U4e0b\U4e00\U7ad9\U706c\U505c\U7559.zip";
 gender = 0;
 guild = "\U4e0d\U52a8\U5982\U5c71\U4e36\U4fb5\U63a0\U5982\U706b";
 guildRealm = "\U51b0\U971c\U4e4b\U5203";
 id = 163125;
 iscatch = 1;
 itemlevel = 541;
 itemlevelequipped = 541;
 lastModified = 1397328930000;
 level = 90;
 mountsnum = 86;
 name = "\U4e0b\U4e00\U7ad9\U706c\U505c\U7559";
 pveScore = 760;
 pvpScore = 0;
 race = 10;
 raceObj =                     {
 id = 10;
 mask = 512;
 name = "\U8840\U7cbe\U7075";
 side = horde;
 sidename = "\U90e8\U843d";
 };
 rank = " ";
 realm = "\U51b0\U971c\U4e4b\U5203";
 thumbnail = 178982;
 totalHonorableKills = 283;
 },
 {
 achievementPoints = 9615;
 auth = 1;
 battlegroup = "Battle Group 11";
 classObj =                     {
 id = 11;
 mask = 1024;
 name = "\U5fb7\U9c81\U4f0a";
 powerType = mana;
 };
 clazz = 11;
 content = " ";
 failedmsg = "";
 failednum = 1;
 filepath = "/home/appusr/characters/\U5361\U62c9\U8d5e/mlyy.zip";
 gender = 0;
 guild = "\U7ea2\U5c18\U5ba2\U6808";
 guildRealm = "\U5361\U62c9\U8d5e";
 id = 216151;
 iscatch = 1;
 itemlevel = 503;
 itemlevelequipped = 397;
 lastModified = 1397319154000;
 level = 90;
 mountsnum = 85;
 name = mlyy;
 pveScore = 140;
 pvpScore = 0;
 race = 6;
 raceObj =                     {
 id = 6;
 mask = 32;
 name = "\U725b\U5934\U4eba";
 side = horde;
 sidename = "\U90e8\U843d";
 };
 rank = 5;
 realm = "\U5361\U62c9\U8d5e";
 thumbnail = 162333;
 totalHonorableKills = 0;
 },
 {
 achievementPoints = 4085;
 auth = 1;
 battlegroup = "Battle Group 11";
 classObj =                     {
 id = 8;
 mask = 128;
 name = "\U6cd5\U5e08";
 powerType = mana;
 };
 clazz = 8;
 content = " ";
 failedmsg = "";
 failednum = 0;
 filepath = "/home/appusr/characters/\U963f\U7eb3\U514b\U6d1b\U65af/\U82e6\U82e5\U79cb\U53f6.zip";
 gender = 1;
 guild = "\U5927\U7ea2\U83b2\U9a91\U58eb\U56e2";
 guildRealm = "\U963f\U7eb3\U514b\U6d1b\U65af";
 id = 215796;
 iscatch = 1;
 itemlevel = 523;
 itemlevelequipped = 451;
 lastModified = 1397319270000;
 level = 90;
 mountsnum = 20;
 name = "\U82e6\U82e5\U79cb\U53f6";
 pveScore = 200;
 pvpScore = 0;
 race = 7;
 raceObj =                     {
 id = 7;
 mask = 64;
 name = "\U4f8f\U5112";
 side = alliance;
 sidename = "\U8054\U76df";
 };
 rank = 4;
 realm = "\U963f\U7eb3\U514b\U6d1b\U65af";
 thumbnail = 170878;
 totalHonorableKills = 1551;
 },
 {
 achievementPoints = 9615;
 auth = 1;
 battlegroup = " ";
 classObj =                     {
 id = 4;
 mask = 8;
 name = "\U6f5c\U884c\U8005";
 powerType = energy;
 };
 clazz = 4;
 content = " ";
 failedmsg = "";
 failednum = 0;
 filepath = "/home/appusr/characters/\U5361\U62c9\U8d5e/\U6674\U7a7a\U4e4b\U661f.zip";
 gender = 0;
 guild = "\U50b3\U4e28\U8aaa";
 guildRealm = "\U5361\U62c9\U8d5e";
 id = 219496;
 iscatch = 1;
 itemlevel = 511;
 itemlevelequipped = 446;
 lastModified = 1397319102000;
 level = 90;
 mountsnum = 85;
 name = "\U6674\U7a7a\U4e4b\U661f";
 pveScore = 706;
 pvpScore = 0;
 race = 5;
 raceObj =                     {
 id = 5;
 mask = 16;
 name = "\U4ea1\U7075";
 side = horde;
 sidename = "\U90e8\U843d";
 };
 rank = 8;
 realm = "\U5361\U62c9\U8d5e";
 thumbnail = 178846;
 totalHonorableKills = 5909;
 },
 {
 achievementPoints = 4135;
 auth = 1;
 battlegroup = "Battle Group 3";
 classObj =                     {
 id = 5;
 mask = 16;
 name = "\U7267\U5e08";
 powerType = mana;
 };
 clazz = 5;
 content = " ";
 failedmsg = "";
 failednum = 0;
 filepath = "/home/appusr/characters/\U51b0\U971c\U4e4b\U5203/\U6de1\U6de1\U5730\U4f24.zip";
 gender = 1;
 guild = "\U7231\U4e0e\U6b63\U4e49\U7684";
 guildRealm = "\U51b0\U971c\U4e4b\U5203";
 id = 162845;
 iscatch = 1;
 itemlevel = 536;
 itemlevelequipped = 462;
 lastModified = 1397319364000;
 level = 90;
 mountsnum = 18;
 name = "\U6de1\U6de1\U5730\U4f24";
 pveScore = 1813;
 pvpScore = 0;
 race = 10;
 raceObj =                     {
 id = 10;
 mask = 512;
 name = "\U8840\U7cbe\U7075";
 side = horde;
 sidename = "\U90e8\U843d";
 };
 rank = 6;
 realm = "\U51b0\U971c\U4e4b\U5203";
 thumbnail = 170877;
 totalHonorableKills = 1111;
 }
 );
 };
 chatServer =         {
 address = "221.122.114.216:5222";
 id = " ";
 name = "@gamepro.com";
 version = " ";
 };
 clientUpdate = 0;
 dynamicmsg =         {
 alias = " ";
 commentnum = 0;
 createDate = 1397286905000;
 id = 155134;
 img = "";
 msg = "\U4e00\U5927\U6ce2\U5c0f\U4f19\U4f34\U6765\U4e86";
 nickname = "\U4e00\U76f4\U5f88\U5b89\U9759";
 rarenum = 0;
 superstar = 0;
 thumb = " ";
 title = " ";
 titleObj =             {
 characterid = 155316;
 charactername = "\U8840\U6027\U706c\U6b87";
 clazz = 3;
 gameid = 1;
 hasDate = 1395040668000;
 hide = 0;
 id = 316135;
 realm = "\U5361\U62c9\U8d5e";
 sortnum = 1;
 titleObj =                 {
 createDate = 1388826466000;
 evolution = 0;
 gameid = 1;
 icon = " ";
 id = 56;
 img = 436;
 rank = 1;
 ranktype = "1,2,3";
 rankvaltype = qunxinzhinu;
 rarememo = "18.97%";
 rarenum = 4;
 remark = "\U592a\U9633\U4e4b\U4e95\U7684\U80fd\U91cf\U6d41\U904d\U7d22\U5229\U8fbe\U5c14\U7684\U5f13\U8eab, \U800c\U5c04\U51fa\U7684\U661f\U5149\U4eff\U4f5b\U5728\U8ffd\U5fc6\U90a3\U4e2a\U9065\U8fdc\U7684\U5e74\U4ee3.";
 remarkDetail = "\U57282010-8-31(\U5deb\U5996\U738b\U5f00\U653e)\U4e4b\U540e\U83b7\U5f97\U7d22\U5229\U8fbe\U5c14\Uff0c\U7fa4\U661f\U4e4b\U6012";
 simpletitle = "\U7d22\U5229\U8fbe\U5c14\Uff0c\U7fa4\U661f\U4e4b\U6012";
 sortnum = 1;
 title = "\U7d22\U5229\U8fbe\U5c14\Uff0c\U7fa4\U661f\U4e4b\U6012";
 titlekey = " ";
 titletype = "\U83b7\U53d6\U65f6\U95f4";
 };
 titleid = 56;
 userid = 10000201;
 userimg = " ";
 };
 type = 3;
 urlLink = " ";
 userid = 10000201;
 userimg = "177174,1149138,1149201,1149179,2220143,2220142,2433293,2479264,";
 username = 15510106271;
 zan = 0;
 zannum = 0;
 };
 fansnum = 83;
 gamelist =         (
 {
 ename = wow;
 id = 1;
 name = "\U9b54\U517d\U4e16\U754c";
 }
 );
 
 title =         ;
 token =         {
 createDate = 1397375653789;
 expire = "-1";
 invalidType = " ";
 token = C860ACAD3E63420182F64B71BFA3B154;
 userid = 10000201;
 version = " ";
 };
 user =         {
 active = 2;
 age = 24;
 appType = 91;
 backgroundImg = " ";
 birthdate = 19890311;
 city = " ";
 constellation = "\U53cc\U9c7c\U5ea7";
 createTime = 1393747788000;
 deviceToken = "ef52debc 3144b492 c6518c9d 27931937 77686f38 2b53a9f8 83035c74 0616cbb2";
 email = "345301696@qq.com";
 fan = 83;
 gender = 0;
 hobby = " ";
 id = 10000201;
 ifFraudulent = " ";
 img = "177174,1149138,1149201,1149179,2220143,2220142,2433293,2479264,";
 lastForbiddenTime = " ";
 modTime = 1397213300000;
 nickname = "\U4e00\U76f4\U5f88\U5b89\U9759";
 password = "oCtbyM+Flw5HS1ux54qMHg==";
 phoneNumber = " ";
 realname = " ";
 remark = "\U6280\U672f\U5b85";
 signature = "\U597d\U4e0d\U5bb9\U6613\U6765\U4e86\U4e00\U4e2a\U5c0f\U4f19\U4f34\Uff0c\U5446\U4e86\U4e00\U5929\U5c31\U8d70\U4e86\U3002";
 state = 0;
 superremark = " ";
 superstar = 0;
 username = 15510106271;
 };
 zannum = 43;
 };
 errorcode = 0;
 sn = C02F47CF83E741C7A697813B3824DFD8;
 }
 
 
 
 */


