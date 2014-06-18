//
//  NewRegisterViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewRegisterViewController.h"
#import "MessagePageViewController.h"
//#import "NewFindViewController.h"
#import "MePageViewController.h"
#import "ShowTextViewController.h"
#import "AuthViewController.h"
#import "TempData.h"
#import "ReconnectMessage.h"
#import "UserManager.h"
#import "HelpViewController.h"
#import "EGOImageView.h"
#import "AboutRoleCell.h"

@interface NewRegisterViewController ()
{
    UILabel*     m_titleLabel;
    
    NSString*     characterid;//角色id
    
    UIImageView*  m_topImage;
    
    UIScrollView* m_step1Scroll;
    UITextField*  m_phoneNumText;
    UIButton*     m_agreeButton;
    
    UIScrollView* m_step1Scroll_verCode;
    UITextField*  m_verCodeTextField;
    NSInteger     m_leftTime;
    UIButton*     m_refreshVCButton;
    NSTimer*      m_verCodeTimer;
    
    UIScrollView* m_step2Scroll;
    UIPickerView* m_gameNamePick;
    
    UIScrollView* m_step3Scroll;
    UIButton*     m_photoButton;
    //    UIImage*      m_photoImage;
    NSString * imagePath;
    
    UITextField*  m_userNameText;
    UITextField*  m_passwordText;
    UITextField*  m_birthdayText;
    UIDatePicker* m_birthDayPick;
    UITextField*  m_emailText;
    UIButton*     m_sexManButton;
    UIButton*     m_sexWomanButton;
    
    UIScrollView* m_step4Scroll;
    
    NSMutableArray *gameInfoArray;
    EGOImageView* gameImg;
    NSString * gameNum;
    
    UILabel* table_label_two1;
    UILabel* table_label_three1;
    
    UITableView *m_myTableView;
    NSMutableArray *m_dataArray;
    UIToolbar* toolbar_server1;
    UIButton* m_okButton;
    AboutRoleCell *aboutRoleCell;
    
    NSString *gameidStr;
    
}
@property(nonatomic,retain)NSString *imgID;

@end

@implementation NewRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillDisappear:(BOOL)animated
{
    if ([m_verCodeTimer isValid]) {
        [m_verCodeTimer invalidate];
        m_verCodeTimer = nil;
    }
    
    [super viewWillDisappear: animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_topImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, startX, 320, 28)];
    m_topImage.image = KUIImage(@"register_step_1");
    [self.view addSubview:m_topImage];
    
    [self setTopViewWithTitle:@"" withBackButton:YES];
    
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, startX - 44, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
    m_titleLabel.text = @"验证手机";
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:m_titleLabel];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"选择游戏",@"name",@"",@"content",@"picker",@"type", nil];
    m_dataArray =[NSMutableArray array];
    
    [m_dataArray addObject:dic];
    
    
    
    [self setMainView];
    [self setStep_1View];
    [self setstep1Scroll_verCode];
    [self setStep_2View];
    [self setStep_3View];
    [self setStep_4View];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"获取中...";
    
    
    gameInfoArray = [NSMutableArray new];
    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
    
    NSDictionary *dict= [[NSMutableDictionary dictionaryWithContentsOfFile:path]objectForKey:@"gamelist"];
    
    NSArray *allkeys = [dict allKeys];
    for (int i = 0; i <allkeys.count; i++) {
        NSArray *array = [dict objectForKey:allkeys[i]];
        [gameInfoArray addObjectsFromArray:array];
    }
    
}

- (void)setMainView
{
    m_step1Scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 28 + startX, 320, kScreenHeigth - 28 - startX)];
    m_step1Scroll.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_step1Scroll];
    
    m_step1Scroll_verCode = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 28 + startX, 320, kScreenHeigth - 28 - startX)];
    m_step1Scroll_verCode.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_step1Scroll_verCode];
    m_step1Scroll_verCode.hidden = YES;
    
    m_step2Scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 28 + startX, 320, kScreenHeigth - 28 - startX)];
    m_step2Scroll.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_step2Scroll];
    if (!iPhone5) {
        m_step2Scroll.contentSize = CGSizeMake(320, kScreenHeigth - 28 - startX + 50);
    }
    m_step2Scroll.hidden = YES;
    
    m_step3Scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 28 + startX, 320, kScreenHeigth - 28 - startX)];
    m_step3Scroll.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_step3Scroll];
    m_step3Scroll.contentSize = CGSizeMake(320, iPhone5 ?  kScreenHeigth - 28 - startX + 120 : kScreenHeigth - 28 - startX + 200);
    m_step3Scroll.hidden = YES;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    tapGesture.delegate = self;
    [m_step3Scroll addGestureRecognizer:tapGesture];
    
    m_step4Scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 28 + startX, 320, kScreenHeigth - 28 - startX)];
    m_step4Scroll.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_step4Scroll];
    m_step4Scroll.hidden = YES;
}

#pragma mark 第一步
- (void)setStep_1View
{
    UIImageView* table_top = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 300, 40)];
    table_top.image = KUIImage(@"text_bg");
    [m_step1Scroll addSubview:table_top];
    
    UILabel* warnLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 16, 80, 38)];
    warnLabel.text = @"手机号";
    warnLabel.textColor = kColorWithRGB(128, 128, 128, 1.0);
    warnLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [m_step1Scroll addSubview:warnLabel];
    
    m_phoneNumText = [[UITextField alloc] initWithFrame:CGRectMake(100, 15, 200, 40)];
    m_phoneNumText.textAlignment = NSTextAlignmentRight;
    m_phoneNumText.keyboardType = UIKeyboardTypeNumberPad;
    m_phoneNumText.returnKeyType = UIReturnKeyDone;
    m_phoneNumText.delegate = self;
    m_phoneNumText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_phoneNumText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [m_step1Scroll addSubview:m_phoneNumText];
    
    m_agreeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 70, 16, 16)];
    [m_agreeButton setBackgroundImage:KUIImage(@"checkbox_normal") forState:UIControlStateNormal];
    [m_agreeButton setBackgroundImage:KUIImage(@"checkbox_click") forState:UIControlStateSelected];
    m_agreeButton.backgroundColor = [UIColor clearColor];
    [m_agreeButton addTarget:self action:@selector(agreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_step1Scroll addSubview:m_agreeButton];
    m_agreeButton.selected = YES;
    
    UILabel* proLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 70, 150, 16)];
    proLabel.text = @"阅读并同意";
    proLabel.textColor = kColorWithRGB(128, 128, 128, 1.0);
    proLabel.font = [UIFont boldSystemFontOfSize:12.0];
    proLabel.backgroundColor = [UIColor clearColor];
    [m_step1Scroll addSubview:proLabel];
    
    UIButton* protocolButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 71, 50, 16)];
    [protocolButton setBackgroundColor:[UIColor clearColor]];
    protocolButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    [protocolButton setTitle:@"用户协议" forState:UIControlStateNormal];
    [protocolButton setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
    protocolButton.tag = 2;
    [protocolButton addTarget:self action:@selector(protocolClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_step1Scroll addSubview:protocolButton];
    
    UIButton* step1Button = [[UIButton alloc] initWithFrame:CGRectMake(10, 96, 300, 40)];
    [step1Button setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [step1Button setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    if ([[TempData sharedInstance] registerNeedMsg]) {
        [step1Button setTitle:@"获取验证码" forState:UIControlStateNormal];
    }else{
        [step1Button setTitle:@"下一步" forState:UIControlStateNormal];
    }
    [step1Button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    step1Button.backgroundColor = [UIColor clearColor];
    [step1Button addTarget:self action:@selector(getVerCodeButton:) forControlEvents:UIControlEventTouchUpInside];
    [m_step1Scroll addSubview:step1Button];
    
    UILabel *tishiLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMidY(step1Button.frame)+15, 300, 50)];
    tishiLabel.text = @"输入您的手机号码,免费注册陌游,陌游不会在任何地方泄露您的手机号码";
    tishiLabel.textColor = [UIColor grayColor];
    tishiLabel.backgroundColor = [UIColor clearColor];
    tishiLabel.font = [UIFont systemFontOfSize:12];
    tishiLabel.numberOfLines= 2;
    [m_step1Scroll addSubview:tishiLabel];
    
    UILabel *helpLbel = [[UILabel alloc]initWithFrame:CGRectMake(10,CGRectGetMidY(tishiLabel.frame)+15,300,40)];
    helpLbel.text = @"注册遇到问题？";
    helpLbel.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    helpLbel.font = [UIFont systemFontOfSize:12];
    helpLbel.textColor = kColorWithRGB(41, 164, 246, 1.0);
    helpLbel.userInteractionEnabled = YES;
    helpLbel.textAlignment = NSTextAlignmentLeft;
    [m_step1Scroll addSubview:helpLbel];
    [helpLbel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterToHelpPage:)]];
    
    
}

-(void)enterToHelpPage:(id)sender
{
    HelpViewController *helpVC = [[HelpViewController alloc]init];
    helpVC.myUrl = @"content.html?4";
    [self.navigationController pushViewController:helpVC animated:YES];
    
}
- (void)agreeButtonClick:(id)sender
{
    m_agreeButton.selected = !m_agreeButton.selected;
}

- (void)protocolClick:(id)sender
{
    ShowTextViewController* viewController = [[ShowTextViewController alloc] init];
    if ([(UIButton*)sender tag] == 1) {
        viewController.myViewTitle = @"隐私政策";
        viewController.fileName = @"";
    }
    else
    {
        viewController.myViewTitle = @"用户协议";
        viewController.fileName = @"protocol";
    }
    [self.navigationController pushViewController:viewController animated:YES];
}
/*判断输入手机号格式是否正确*/
//BOOL validateMobile(NSString* mobile) {
//    //手机号以13， 15，18开头，八个 \d 数字字符
//    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
//    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
//    NSLog(@"phoneTest is %@",phoneTest);
//    return [phoneTest evaluateWithObject:mobile];
//}
- (void)getVerCodeButton:(id)sender//获取验证码
{
    [m_phoneNumText resignFirstResponder];
    //判断字符为空
    if (KISEmptyOrEnter(m_phoneNumText.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入手机号！" buttonTitle:@"确定"];
        return;
    }
    if (m_phoneNumText.text.length!=11) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入正确的手机号！" buttonTitle:@"确定"];
        return;
    }
    if (!m_agreeButton.selected) {
        [self showAlertViewWithTitle:@"提示" message:@"请勾选用户协议！" buttonTitle:@"确定"];
        return;
    }
    //判断手机号格式是不是以 13 15 18 开头的 并且是11位
    //    BOOL phoneRight = validateMobile(m_phoneNumText.text);
    //    if (!phoneRight) {
    //        [self showAlertViewWithTitle:@"提示" message:@"请输入正确的手机号" buttonTitle:@"确定"];
    //        return;
    //    }
    if ([[TempData sharedInstance] registerNeedMsg]) {
        [self getVerificationCode];
    }else{
        NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
        [params setObject:m_phoneNumText.text forKey:@"username"];
        NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
        [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
        [body setObject:params forKey:@"params"];
        [body setObject:@"105" forKey:@"method"];
        
        hud.labelText = @"获取中...";
        [hud show:YES];
        [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [hud hide:YES];
            m_step1Scroll.hidden = YES;
//            m_step1Scroll_verCode.hidden = YES;
//            m_step2Scroll.hidden = NO;
//            m_topImage.image = KUIImage(@"register_step_2");
//            m_titleLabel.text = @"绑定角色";
            m_step1Scroll_verCode.hidden = YES;
            m_step3Scroll.hidden = NO;
            m_topImage.image = KUIImage(@"register_step_3");
            m_titleLabel.text = @"个人信息";

            
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
}
- (void)getVerificationCode
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:m_phoneNumText.text forKey:@"phoneNum"];
    [params setObject:@"register" forKey:@"type"];
    
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"112" forKey:@"method"];
    
    hud.labelText = @"获取中...";
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hide:YES];
        
        m_step1Scroll.hidden = YES;
        m_step1Scroll_verCode.hidden = NO;
        
        UILabel* topLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 50)];
        topLabel.numberOfLines = 2;
        topLabel.font = [UIFont boldSystemFontOfSize:13.0];
        topLabel.textColor = kColorWithRGB(128.0, 128, 128, 1.0);
        topLabel.text = [NSString stringWithFormat:@"验证码已发送至手机号：%@，请注意查收！", m_phoneNumText.text];
        topLabel.backgroundColor = [UIColor clearColor];
        [m_step1Scroll_verCode addSubview:topLabel];
        [self startRefreshTime];
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

- (void)setstep1Scroll_verCode
{
    UIImageView* table_top = [[UIImageView alloc] initWithFrame:CGRectMake(10, 60, 235, 40)];
    table_top.image = KUIImage(@"text_bg");
    [m_step1Scroll_verCode addSubview:table_top];
    
    UILabel* table_label_one = [[UILabel alloc] initWithFrame:CGRectMake(20, 61, 80, 38)];
    table_label_one.text = @"验证码";
    table_label_one.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_one.font = [UIFont boldSystemFontOfSize:15.0];
    [m_step1Scroll_verCode addSubview:table_label_one];
    
    m_leftTime = 60;
    
    m_verCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 60, 130, 40)];
    m_verCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    m_verCodeTextField.returnKeyType = UIReturnKeyDone;
    m_verCodeTextField.delegate = self;
    m_verCodeTextField.textAlignment = NSTextAlignmentRight;
    m_verCodeTextField.font = [UIFont boldSystemFontOfSize:15.0];
    m_verCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_verCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [m_step1Scroll_verCode addSubview:m_verCodeTextField];
    
    m_refreshVCButton = [[UIButton alloc] initWithFrame:CGRectMake(250, 60, 60, 40)];
    [m_refreshVCButton setBackgroundImage:KUIImage(@"gray_button_normal") forState:UIControlStateNormal];
    [m_refreshVCButton setBackgroundImage:KUIImage(@"gray_button") forState:UIControlStateSelected];
    [m_refreshVCButton setBackgroundImage:KUIImage(@"gray_button_click") forState:UIControlStateHighlighted];
    [m_refreshVCButton setTitleColor:kColorWithRGB(153, 153, 153, 1.0) forState:UIControlStateSelected];
    [m_refreshVCButton setTitleColor:kColorWithRGB(102, 102, 102, 1.0) forState:UIControlStateNormal];
    [m_refreshVCButton addTarget:self action:@selector(refreshVCButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    m_refreshVCButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [m_refreshVCButton setTitle:@"60s" forState:UIControlStateNormal];
    [m_step1Scroll_verCode addSubview:m_refreshVCButton];
    
    UIButton* vercodeNextButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 110, 300, 40)];
    [vercodeNextButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [vercodeNextButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [vercodeNextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [vercodeNextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    vercodeNextButton.backgroundColor = [UIColor clearColor];
    [vercodeNextButton addTarget:self action:@selector(vercodeNextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_step1Scroll_verCode addSubview:vercodeNextButton];
}

- (void)refreshVCButtonClick:(id)sender
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:m_phoneNumText.text forKey:@"phoneNum"];
    [params setObject:@"register" forKey:@"type"];
    
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"112" forKey:@"method"];
    
    hud.labelText = @"获取中...";
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        [self startRefreshTime];
        
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

- (void)startRefreshTime
{
    m_refreshVCButton.selected = YES;
    m_refreshVCButton.userInteractionEnabled = NO;
    m_leftTime = 60;
    
    if ([m_verCodeTimer isValid]) {
        [m_verCodeTimer invalidate];
        m_verCodeTimer = nil;
    }
    [m_refreshVCButton setTitle:@"60s" forState:UIControlStateSelected];
    m_verCodeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refrenshVerCodeTime) userInfo:nil repeats:YES];
}

- (void)refrenshVerCodeTime
{
    m_leftTime--;
    if (m_leftTime == 0) {
        m_refreshVCButton.selected = NO;
        [m_refreshVCButton setTitle:@"重发" forState:UIControlStateNormal];
        m_refreshVCButton.userInteractionEnabled = YES;
        if([m_verCodeTimer isValid])
        {
            [m_verCodeTimer invalidate];
            m_verCodeTimer = nil;
        }
    }
    else
        [m_refreshVCButton setTitle:[NSString stringWithFormat:@"%ds", m_leftTime] forState:UIControlStateSelected];
}

- (void)vercodeNextButtonClick:(id)sender
{
    [m_verCodeTextField resignFirstResponder];
    
    if (KISEmptyOrEnter(m_verCodeTextField.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入验证码！" buttonTitle:@"确定"];
        return;
    }
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:m_phoneNumText.text forKey:@"phoneNum"];
    [params setObject:m_verCodeTextField.text forKey:@"xcode"];
    
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"113" forKey:@"method"];
    
    hud.labelText = @"验证中...";
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hide:YES];
        if ([m_verCodeTimer isValid]) {
            [m_verCodeTimer invalidate];
            m_verCodeTimer = nil;
        }
        
        NSLog(@"%@", responseObject);
        
//        m_step1Scroll_verCode.hidden = YES;
//        m_step2Scroll.hidden = NO;
//        m_topImage.image = KUIImage(@"register_step_2");
//        m_titleLabel.text = @"绑定角色";
        
        
        m_step1Scroll_verCode.hidden = YES;
        m_step3Scroll.hidden = NO;
        m_topImage.image = KUIImage(@"register_step_3");
        m_titleLabel.text = @"个人信息";

        
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

#pragma mark 第二步
- (void)jump3ButtonOK
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"跳过绑定" message:@"不绑定游戏角色会导致你无法使用部分社交功能,你确定吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"跳过", nil];
    [alert show];
}
- (void)setStep_2View
{
    UILabel* topLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 50)];
    topLabel.numberOfLines = 2;
    topLabel.font = [UIFont boldSystemFontOfSize:12.0];
    topLabel.textColor = kColorWithRGB(128.0, 128, 128, 1.0);
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.text = @"如果您拥有多名角色，请先绑定最主要的，其他游戏角色可在注册完成之后，在设置面板中添加";
    [m_step2Scroll addSubview:topLabel];
    
    
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 60, 320, self.view.bounds.size.height-startX-44) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.scrollEnabled = NO;
    
    m_myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [m_step2Scroll addSubview:m_myTableView];
    
    m_gameNamePick = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_gameNamePick.dataSource = self;
    m_gameNamePick.delegate = self;
    m_gameNamePick.showsSelectionIndicator = YES;
    
    toolbar_server1 = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar_server1.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectGameNameOK:)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar_server1.items = @[rb_server];
    
    UIButton* step2Button = [[UIButton alloc] initWithFrame:CGRectMake(160, 230, 140, 40)];
    [step2Button setBackgroundImage:KUIImage(@"zhuce") forState:UIControlStateNormal];
    [step2Button setBackgroundImage:KUIImage(@"zhuce_click") forState:UIControlStateHighlighted];
    //    [step2Button setTitle:@"绑定上述角色" forState:UIControlStateNormal];
    [step2Button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    step2Button.backgroundColor = [UIColor clearColor];
    [step2Button addTarget:self action:@selector(step2ButtonOK:) forControlEvents:UIControlEventTouchUpInside];
    [m_step2Scroll addSubview:step2Button];
    
    UIButton* step3Button = [[UIButton alloc] initWithFrame:CGRectMake(10, 230, 140, 40)];
    [step3Button setBackgroundImage:KUIImage(@"puch") forState:UIControlStateNormal];
    [step3Button setBackgroundImage:KUIImage(@"puch_click") forState:UIControlStateHighlighted];
    //    [step3Button setTitle:@"跳过绑定" forState:UIControlStateNormal];
    [step3Button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    step3Button.backgroundColor = [UIColor clearColor];
    [step3Button addTarget:self action:@selector(jump3ButtonOK) forControlEvents:UIControlEventTouchUpInside];
    [m_step2Scroll addSubview:step3Button];
}
- (void)selectGameNameOK:(UIButton *)sender
{
    if ([gameInfoArray count] != 0) {
        NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gameNamePick selectedRowInComponent:0]];
        NSArray *sarchArray ;
        sarchArray =[[dict objectForKey:@"gameParams"]objectForKey:@"bindCharacterParams"];
        
        [m_dataArray removeAllObjects];
        
        NSDictionary *firstDic = [NSDictionary dictionaryWithObjectsAndKeys:@"选择游戏",@"name",[dict objectForKey:@"name"],@"content",@"picker",@"type",[dict objectForKey:@"id"],@"gameid",KISDictionaryHaveKey(dict,@"img"),@"img",nil];
        
        [m_dataArray addObject:firstDic];
        [m_dataArray addObjectsFromArray:[[dict objectForKey:@"gameParams" ] objectForKey:@"commonParams"]];
        [m_dataArray addObjectsFromArray:sarchArray];
        
        m_okButton.hidden = NO;
        m_myTableView.frame = CGRectMake(0, 60, 320, 44*m_dataArray.count);
        m_okButton.frame = CGRectMake(10, startX+64+44*m_dataArray.count, 300, 40);
        [m_myTableView reloadData];
    }
    
    
}
- (void)realmSelectClick:(UIButton *)sender
{
    RealmsSelectViewController* realmVC = [[RealmsSelectViewController alloc] init];
    realmVC.realmSelectDelegate = self;
    realmVC.indexCount =[NSString stringWithFormat:@"%d",sender.tag];
    realmVC.gameNum = [[m_dataArray objectAtIndex:0]objectForKey:@"gameid"];
    realmVC.prama = [[m_dataArray objectAtIndex:sender.tag]objectForKey:@"param"];
    
    [self.navigationController pushViewController:realmVC animated:YES];
}

- (void)selectOneRealmWithName:(NSString *)name num:(NSString *)num
{
    //    dic = [m_dataArray objectAtIndex:[num intValue]];
    //    [dic setObject:name forKey:@"content"];
    UITextField *tf = (UITextField *)[self.view viewWithTag:[num intValue]+100000];
    tf.text = name;
}

- (void)step2ButtonOK:(id)sender
{
    //    [m_serverNameText resignFirstResponder];
    //    [m_roleNameText resignFirstResponder];
    //
    //    if (KISEmptyOrEnter(m_serverNameText.text)) {
    //        [self showAlertViewWithTitle:@"提示" message:@"请选择服务器！" buttonTitle:@"确定"];
    //        return;
    //    }
    //    if (KISEmptyOrEnter(m_roleNameText.text)) {
    //        [self showAlertViewWithTitle:@"提示" message:@"请输入角色名！" buttonTitle:@"确定"];
    //        return;
    //    }
    //    NSArray *array = [[[NSUserDefaults standardUserDefaults]objectForKey:kOpenData]objectForKey:@"gamelist"];
    if (!m_dataArray||m_dataArray.count<2) {
        [self showAlertViewWithTitle:@"提示" message:@"请将信息填写完整" buttonTitle:@"确定"];
        return;
    }
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    for (int i =0; i<m_dataArray.count; i++) {
        NSDictionary *dic = m_dataArray[i];
        if (i==0) {
            [params setObject:KISDictionaryHaveKey(dic, @"gameid") forKey:@"gameid"];
        }else{
            UITextField *tf  = (UITextField *)[self.view viewWithTag:i+100000];
            if (!tf.text||[tf.text isEqualToString:@""]||[tf.text isEqualToString:@" "]) {
                [self showAlertViewWithTitle:@"提示" message:@"请将信息填写完整" buttonTitle:@"确定"];
                return;
            }
            [params setObject:tf.text forKey:KISDictionaryHaveKey(dic, @"param")];
        }
    }
    
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"115" forKey:@"method"];
    
    hud.labelText = @"获取中...";
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        NSDictionary* dic = responseObject;
        NSLog(@"%@", dic);
        
        [self dismissViewControllerAnimated:YES completion:^{
            if (_delegate && [_delegate respondsToSelector:@selector(NewRegisterViewControllerFinishRegister)]) {
                [_delegate NewRegisterViewControllerFinishRegister];
            }
        }];

        
        characterid = KISDictionaryHaveKey(dic, @"id");//角色id
        [[TempData sharedInstance] setCharacterID:characterid];
        [[TempData sharedInstance] setGamerealm:KISDictionaryHaveKey(dic, @"realm")];
        gameidStr = KISDictionaryHaveKey(dic, @"gameid");
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if ([[error objectForKey:kFailErrorCodeKey] isEqualToString:@"100014"]) {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"您的角色已被绑定,请先跳过绑定完成注册后,在“我”界面再次添加并认证您的角色"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
            else if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }else{
            [self showAlertViewWithTitle:@"提示" message:@"绑定角色失败,请检查网络" buttonTitle:@"确定"];
        }
        [hud hide:YES];
    }];
}

#pragma mark 角色查找
- (void)searchButtonClick:(id)semder
{
    //    SearchRoleViewController* searchVC = [[SearchRoleViewController alloc] init];
    //    searchVC.searchDelegate = self;
    //    searchVC.getRealmName = m_serverNameText.text;
    //    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)searchRoleSuccess:(NSString*)roleName realm:(NSString*)realm
{
    //    m_roleNameText.text = roleName;
    //    m_serverNameText.text = realm;
}

#pragma mark alertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //    if (alertView.tag == 18) {
    //        if (buttonIndex != alertView.cancelButtonIndex) {
    //            AuthViewController* authVC = [[AuthViewController alloc] init];
    //
    //            authVC.gameId = @"1";
    //            authVC.realm = m_serverNameText.text;
    //            authVC.character = m_roleNameText.text;
    //
    //            [self.navigationController pushViewController:authVC animated:YES];
    //        }
    //    }
    if(alertView.tag == 67)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
            [self continueStep3Net:@""];
    }else
    {
        if (buttonIndex != alertView.cancelButtonIndex){
            m_step2Scroll.hidden = YES;
            m_step3Scroll.hidden = NO;
            m_topImage.image = KUIImage(@"register_step_3");
            //    m_userNameText.text = m_roleNameText.text;
            m_titleLabel.text = @"个人信息";
            [[TempData sharedInstance] setPassBindingRole:YES];
        }
    }
}

#pragma mark 第三步
- (void)setStep_3View
{
    //    UILabel* topLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 50)];
    //    topLabel.numberOfLines = 2;
    //    topLabel.font = [UIFont boldSystemFontOfSize:12.0];
    //    topLabel.textColor = kColorWithRGB(128.0, 128, 128, 1.0);
    //    topLabel.text = @"提示：您可以修改用户名，以使得他与您的角色名不一致，这个用户名会用在您在陌游里与他人联络时显示用";
    //    [m_step3Scroll addSubview:topLabel];
    //
    //    UILabel* bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 300, 300, 50)];
    //    bottomLabel.numberOfLines = 3;
    //    bottomLabel.font = [UIFont boldSystemFontOfSize:12.0];
    //    bottomLabel.textColor = kColorWithRGB(128.0, 128, 128, 1.0);
    //    bottomLabel.text = @"找回邮箱用以在您忘记密码后，又无法使用自己手机找回时，提供第二种供您找回密码的方式，请务必如实填写";
    //    [m_step3Scroll addSubview:bottomLabel];
    //
    m_photoButton = [[UIButton alloc] initWithFrame:CGRectMake(103, 20, 114, 114)];
    [m_photoButton setImage:KUIImage(@"photo_select_normal") forState:UIControlStateNormal];
    [m_photoButton setImage:KUIImage(@"photo_select_clcik") forState:UIControlStateHighlighted];
    [m_photoButton setBackgroundColor:[UIColor clearColor]];
    m_photoButton.layer.cornerRadius = 57;
    m_photoButton.layer.masksToBounds = YES;
    [m_photoButton addTarget:self action:@selector(photoClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_step3Scroll addSubview:m_photoButton];
    
    m_sexManButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 150, 65, 35)];
    [m_sexManButton setImage:KUIImage(@"man_normal") forState:UIControlStateNormal];
    [m_sexManButton setImage:KUIImage(@"man_click") forState:UIControlStateSelected];
    //    m_sexManButton.selected = YES;
    //    [m_sexManButton setTitle:@"男" forState:UIControlStateNormal];
    //    [m_sexManButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    m_sexManButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    //    m_sexManButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40);
    [m_sexManButton addTarget:self action:@selector(sexButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_step3Scroll addSubview:m_sexManButton];
    
    UIImageView* textWarn = [[UIImageView alloc] initWithFrame:CGRectMake(225, 40, 80, 50)];
    textWarn.image = KUIImage(@"warn_text");
    textWarn.backgroundColor = [UIColor clearColor];
    [m_step3Scroll addSubview:textWarn];
    
    m_sexWomanButton = [[UIButton alloc] initWithFrame:CGRectMake(185, 150, 65, 35)];
    [m_sexWomanButton setImage:KUIImage(@"women_normal") forState:UIControlStateNormal];
    [m_sexWomanButton setImage:KUIImage(@"women_click") forState:UIControlStateSelected];
    m_sexWomanButton.selected = NO;
    //    [m_sexWomanButton setTitle:@"女" forState:UIControlStateNormal];
    //    [m_sexWomanButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    m_sexWomanButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    //    m_sexWomanButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40);
    [m_sexWomanButton addTarget:self action:@selector(sexButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_step3Scroll addSubview:m_sexWomanButton];
    
    UIImageView* table_top = [[UIImageView alloc] initWithFrame:CGRectMake(10, 200, 300, 40)];
    table_top.image = KUIImage(@"table_top");
    [m_step3Scroll addSubview:table_top];
    
    UIImageView* table_middle = [[UIImageView alloc] initWithFrame:CGRectMake(10, 240, 300, 40)];
    table_middle.image = KUIImage(@"table_middle");
    [m_step3Scroll addSubview:table_middle];
    
    UIImageView* table_middle_two = [[UIImageView alloc] initWithFrame:CGRectMake(10, 280, 300, 40)];
    table_middle_two.image = KUIImage(@"table_middle");
    [m_step3Scroll addSubview:table_middle_two];
    
    UIImageView* table_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(290, 256, 12, 8)];
    table_arrow.image = KUIImage(@"arrow_bottom");
    [m_step3Scroll addSubview:table_arrow];
    
    UIImageView* table_bottom = [[UIImageView alloc] initWithFrame:CGRectMake(10, 320, 300, 40)];
    table_bottom.image = KUIImage(@"table_bottom");
    [m_step3Scroll addSubview:table_bottom];
    
    UILabel* table_label_one = [[UILabel alloc] initWithFrame:CGRectMake(20, 201, 100, 38)];
    table_label_one.text = @"昵称";
    table_label_one.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_one.font = [UIFont boldSystemFontOfSize:15.0];
    [m_step3Scroll addSubview:table_label_one];
    
    UILabel* table_label_five = [[UILabel alloc] initWithFrame:CGRectMake(20, 241, 80, 38)];
    table_label_five.text = @"生日";
    table_label_five.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_five.font = [UIFont boldSystemFontOfSize:15.0];
    [m_step3Scroll addSubview:table_label_five];
    
    UILabel* table_label_two = [[UILabel alloc] initWithFrame:CGRectMake(20, 281, 100, 38)];
    table_label_two.text = @"密码";
    table_label_two.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_two.font = [UIFont boldSystemFontOfSize:15.0];
    [m_step3Scroll addSubview:table_label_two];
    
    
    UILabel* table_label_six = [[UILabel alloc] initWithFrame:CGRectMake(20, 321, 80, 38)];
    table_label_six.text = @"邮箱";
    table_label_six.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_six.font = [UIFont boldSystemFontOfSize:15.0];
    [m_step3Scroll addSubview:table_label_six];
    
    m_userNameText = [[UITextField alloc] initWithFrame:CGRectMake(100, 200, 180, 40)];
    m_userNameText.returnKeyType = UIReturnKeyDone;
    m_userNameText.delegate = self;
    m_userNameText.font = [UIFont boldSystemFontOfSize:15.0];
    m_userNameText.textAlignment = NSTextAlignmentRight;
    m_userNameText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_userNameText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [m_step3Scroll addSubview:m_userNameText];
    
    m_birthdayText = [[UITextField alloc] initWithFrame:CGRectMake(100, 240, 180, 40)];
    m_birthdayText.returnKeyType = UIReturnKeyDone;
    m_birthdayText.textAlignment = NSTextAlignmentRight;
    m_birthdayText.delegate = self;
    m_birthdayText.font = [UIFont boldSystemFontOfSize:15.0];
    m_birthdayText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_birthdayText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [m_step3Scroll addSubview:m_birthdayText];
    
    m_birthDayPick = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    [m_birthDayPick setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    m_birthDayPick.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 280, 320, 236);
    //    m_birthDayPick.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    m_birthDayPick.datePickerMode = UIDatePickerModeDate;
    m_birthDayPick.date = [[NSDate alloc] initWithTimeIntervalSince1970:631123200];
    m_birthDayPick.maximumDate = [NSDate date];
    m_birthdayText.inputView = m_birthDayPick;//点击弹出的是pickview
    
    UIToolbar* toolbar_server = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar_server.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectBirthdayOK)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar_server.items = @[rb_server];
    m_birthdayText.inputAccessoryView = toolbar_server;//跟着pickview上移
    
    m_passwordText = [[UITextField alloc] initWithFrame:CGRectMake(100, 280, 180, 40)];
    m_passwordText.returnKeyType = UIReturnKeyDone;
    m_passwordText.secureTextEntry = YES;
    m_passwordText.delegate = self;
    m_passwordText.font = [UIFont boldSystemFontOfSize:15.0];
    m_passwordText.textAlignment = NSTextAlignmentRight;
    m_passwordText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_passwordText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [m_step3Scroll addSubview:m_passwordText];
    
    m_emailText = [[UITextField alloc] initWithFrame:CGRectMake(100, 320, 180, 40)];
    m_emailText.returnKeyType = UIReturnKeyDone;
    m_emailText.keyboardType = UIKeyboardTypeEmailAddress;
    m_emailText.delegate = self;
    m_emailText.textAlignment = NSTextAlignmentRight;
    m_emailText.font = [UIFont boldSystemFontOfSize:15.0];
    m_emailText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_emailText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [m_step3Scroll addSubview:m_emailText];
    
    
    UIButton* step3Button = [[UIButton alloc] initWithFrame:CGRectMake(10, 375, 300, 40)];
    [step3Button setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [step3Button setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [step3Button setTitle:@"完成注册" forState:UIControlStateNormal];
    [step3Button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    step3Button.backgroundColor = [UIColor clearColor];
    [step3Button addTarget:self action:@selector(step3ButtonOK:) forControlEvents:UIControlEventTouchUpInside];
    [m_step3Scroll addSubview:step3Button];
}

- (void)sexButtonClick:(id)sender
{
    [self showAlertViewWithTitle:@"提示" message:@"性别一经选定, 将无法通过任何途径修改" buttonTitle:@"确定"];
    UIButton* tempButton = (UIButton*)sender;
    if (m_sexManButton == tempButton) {
        if(m_sexManButton.selected)
            return;
        m_sexManButton.selected = YES;
        m_sexWomanButton.selected = NO;
    }
    else if (m_sexWomanButton == tempButton) {
        if(m_sexWomanButton.selected)
            return;
        m_sexWomanButton.selected = YES;
        m_sexManButton.selected = NO;
    }
}

- (void)selectBirthdayOK
{
    [m_birthdayText resignFirstResponder];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];//location设置为中国
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    NSString* newDate = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate: m_birthDayPick.date]];
    NSLog(@"newDate:%@", newDate);
    m_birthdayText.text = newDate;
}

#pragma mark 选择照片
- (void)photoClick:(id)sender
{
    [m_userNameText resignFirstResponder];
    [m_passwordText resignFirstResponder];
    [m_birthdayText resignFirstResponder];
    [m_emailText resignFirstResponder];
    UIActionSheet* action  = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
    action.tag = 230;
    [action showInView:self.view];
}

#pragma mark - actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 230) {
        switch (buttonIndex) {
            case 0:
            {
                UIImagePickerController * imagePicker;
                if (imagePicker==nil) {
                    imagePicker=[[UIImagePickerController alloc]init];
                    imagePicker.delegate=self;
                    imagePicker.allowsEditing = YES;
                }
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                    
                    [self presentViewController:imagePicker animated:YES completion:^{
                        
                    }];
                }
                else {
                    UIAlertView *cameraAlert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的设备不支持相机" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
                    [cameraAlert show];
                }
            }break;
            case 1:
            {
                UIImagePickerController * imagePicker;
                if (imagePicker==nil) {
                    imagePicker=[[UIImagePickerController alloc]init];
                    imagePicker.delegate=self;
                    imagePicker.allowsEditing = YES;
                }
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                    
                    [self presentViewController:imagePicker animated:YES completion:^{
                        
                    }];
                }
                else {
                    UIAlertView *libraryAlert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的设备不支持相册" delegate:self cancelButtonTitle:@"了解" otherButtonTitles:nil];
                    [libraryAlert show];
                }
            }break;
            default:
                break;
        }
    }
}

#pragma mark - imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage*selectImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    [m_photoButton setImage:selectImage forState:UIControlStateNormal];
    
    imagePath=[self writeImageToFile:selectImage ImageName:@"register.jpg"];
    
    //    m_photoImage = selectImage;
}

//将图片保存到本地，返回保存的路径
-(NSString*)writeImageToFile:(UIImage*)thumbimg ImageName:(NSString*)imageName
{
    NSData * imageData = [self compressImage:thumbimg];
    
    NSString *path = [RootDocPath stringByAppendingPathComponent:@"tempImage"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path] == NO)
    {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString  *openImgPath = [NSString stringWithFormat:@"%@/%@",path,imageName];
    if ([imageData writeToFile:openImgPath atomically:YES]) {
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

-(void)uploadImage:(NSString*)uploadImagePath
{
    if (uploadImagePath!=nil) {
        if (_imgID ==nil) {
            [hud show:YES];
            UpLoadFileService * up = [[UpLoadFileService alloc] init];
            [up simpleUpload:uploadImagePath UpDeleGate:self];
        }else{
            [self continueStep3Net:_imgID];
        }
    }else{
        UIAlertView* alterView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"尚未设置头像, 头像会更方便的让其它玩家注意到你. 建议您点击返回设置您的头像. 点击确定将忽略" delegate:self cancelButtonTitle:@"返回设置" otherButtonTitles:@"确定", nil];
        alterView.tag = 67;
        [alterView show];
    }
}
//
//#pragma mark 上传头像
//- (void)upLoadMyPhoto
//{
//    if (m_photoImage != nil)
//    {
//       // hud.labelText = @"上传头像中...";
//        if (_imgID ==nil) {
//
//
//            [hud show:YES];
//
//            [NetManager uploadImageWithRegister:m_photoImage WithURLStr:BaseUploadImageUrl ImageName:@"1"  TheController:self  Progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite){
//                hud.labelText = [NSString stringWithFormat:@"%.2f％",((double)totalBytesWritten/(double)totalBytesExpectedToWrite) * 100];
//            }Success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                NSLog(@"-------------------------------------%@", responseObject);
//                [hud hide:YES];
////                if ([responseObject isKindOfClass:[NSNumber class]]) {
//                    [self continueStep3Net:[NSString stringWithFormat:@"%@", responseObject]];
//                    _imgID =[NSString stringWithFormat:@"%@", responseObject];
////                }
////                else
////                    [self continueStep3Net:@""];
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                [hud hide:YES];
//                [self continueStep3Net:@""];
//            }];
//        }else {
//            [self continueStep3Net:_imgID];
//        }
//    }
//    else
//    {
//        UIAlertView* alterView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"尚未设置头像, 头像会更方便的让其它玩家注意到你. 建议您点击返回设置您的头像. 点击确定将忽略" delegate:self cancelButtonTitle:@"返回设置" otherButtonTitles:@"确定", nil];
//        alterView.tag = 67;
//        [alterView show];
//    }
//}



// 上传进度
- (void)uploadProgressUpdated:(NSString *)theFilePath percent:(float)percent
{
    //    hud.labelText = [NSString stringWithFormat:@"%.2f％",percent];
    float pp= percent*100;
    hud.labelText = [NSString stringWithFormat:@"%.0f％",pp];
}
//上传成功代理回调
- (void)uploadSucceeded:(NSString *)theFilePath ret:(NSDictionary *)ret
{
    NSString *response = [GameCommon getNewStringWithId:KISDictionaryHaveKey(ret, @"key")];//图片id
    [self continueStep3Net:[NSString stringWithFormat:@"%@", response]];
    _imgID =[NSString stringWithFormat:@"%@", response];
}
//上传失败代理回调
- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    [self continueStep3Net:@""];
}




#pragma 最后一步
- (void)step3ButtonOK:(id)sender
{
    [m_userNameText resignFirstResponder];
    [m_passwordText resignFirstResponder];
    [m_birthdayText resignFirstResponder];
    [m_emailText resignFirstResponder];
    
    if (KISEmptyOrEnter(m_userNameText.text) || KISEmptyOrEnter(m_birthdayText.text) || KISEmptyOrEnter(m_emailText.text) || KISEmptyOrEnter(m_passwordText.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请把信息输入完整！" buttonTitle:@"确定"];
        return;
    }
    if (!m_sexManButton.selected && !m_sexWomanButton.selected) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择性别！" buttonTitle:@"确定"];
        return;
    }
    if ([[GameCommon shareGameCommon] asciiLengthOfString:m_userNameText.text] > 12) {
        [self showAlertViewWithTitle:@"提示" message:@"用户名最长12个字符（即6个汉字）！" buttonTitle:@"确定"];
        return;
    }
    if (m_passwordText.text.length < 6 || m_passwordText.text.length > 16) {
        [self showAlertViewWithTitle:@"提示" message:@"密码最长16个字符,最短6个字符！" buttonTitle:@"确定"];
        return;
    }
    if (![[GameCommon shareGameCommon] isValidateEmail:m_emailText.text])
    {
        [self showAlertViewWithTitle:@"提示" message:@"请输入正确的邮箱格式！" buttonTitle:@"确定"];
        return;
    }
    //    [self upLoadMyPhoto];
    [self uploadImage:imagePath];
}

- (void)continueStep3Net:(NSString*)imageId
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    if (gameidStr) {
        [params setObject:gameidStr forKey:@"gameid"];
    }
//    if (characterid) {
//        [params setObject:characterid forKey:@"characterid"];
//    }
    [params setObject:m_phoneNumText.text forKey:@"username"];
    [params setObject:imageId forKey:@"img"];
    [params setObject:m_userNameText.text forKey:@"nickname"];
    [params setObject:m_passwordText.text forKey:@"password"];
    [params setObject:m_sexManButton.selected ? @"0" : @"1" forKey:@"gender"];
    [params setObject:m_birthdayText.text forKey:@"birthdate"];
    [params setObject:m_emailText.text forKey:@"email"];
    // [params setObject:m_verCodeTextField.text forKey:@"xcode"];
    [params setObject:[GameCommon shareGameCommon].deviceToken forKey:@"deviceToken"];
    [params setObject:appType forKey:@"appType"];
    
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"261" forKey:@"method"];
    
    hud.labelText = @"注册中...";
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        [[NSUserDefaults standardUserDefaults] setValue:m_phoneNumText.text forKey:PhoneNumKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSDictionary* dic = responseObject;
        [[NSUserDefaults standardUserDefaults]setObject:[[dic objectForKey:@"user"]objectForKey:@"active" ] forKey:@"active_wx"];
        
        [[NSUserDefaults standardUserDefaults]setObject:[[dic objectForKey:@"token"] objectForKey:@"userid"] forKey:kMYUSERID];
        [[NSUserDefaults standardUserDefaults]setObject:[[dic objectForKey:@"token"] objectForKey:@"token"] forKey:kMyToken];
        [DataStoreManager setDefaultDataBase:[[dic objectForKey:@"token"] objectForKey:@"userid"] AndDefaultModel:@"LocalStore"];
        AppDelegate* app=(AppDelegate*)[UIApplication sharedApplication].delegate;
        [app.xmppHelper connect];
        
        
        m_step3Scroll.hidden = YES;
//        m_step1Scroll_verCode.hidden = YES;
        m_step2Scroll.hidden = NO;
        m_topImage.image = KUIImage(@"register_step_2");
        m_titleLabel.text = @"绑定角色";

        
        
        [[UserManager singleton]getSayHiUserId];//获取打招呼id
//        [UserManager getBlackListFromNet];//获取黑名单信息
        [[GameCommon shareGameCommon]LoginOpen];//获取游戏列表信息
        
        NSMutableDictionary *userDic=KISDictionaryHaveKey(dic, @"gameproUser");
        [userDic setObject:KISDictionaryHaveKey(userDic, @"id") forKey:@"userid"];
        [userDic setObject:KISDictionaryHaveKey(userDic, @"birthdate") forKey:@"birthday"];
        [DataStoreManager newSaveAllUserWithUserManagerList:userDic withshiptype:@"unknow"] ;
        [self upLoadUserLocationWithLat:[[TempData sharedInstance] returnLat] Lon:[[TempData sharedInstance] returnLon]];
        [self dismissViewControllerAnimated:YES completion:^{
            if (_delegate && [_delegate respondsToSelector:@selector(NewRegisterViewControllerFinishRegister)]) {
                [_delegate NewRegisterViewControllerFinishRegister];
            }
        }];
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


-(void)upLoadUserLocationWithLat:(double)userLatitude Lon:(double)userLongitude
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSDictionary * locationDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",userLongitude],@"longitude",[NSString stringWithFormat:@"%f",userLatitude],@"latitude", nil];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] forKey:@"userid"];
    [postDict setObject:@"108" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [postDict setObject:locationDict forKey:@"params"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

#pragma mark 第四步
- (void)setStep_4View
{
    UIImageView* topImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 125)];
    topImage.image = KUIImage(@"register_step4_top");
    [m_step4Scroll addSubview:topImage];
    
    UIButton* step4Button = [[UIButton alloc] initWithFrame:CGRectMake(10, m_step4Scroll.frame.size.height - 60, 300, 40)];
    [step4Button setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [step4Button setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [step4Button setTitle:@"快去看看吧" forState:UIControlStateNormal];
    [step4Button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    step4Button.backgroundColor = [UIColor clearColor];
    [step4Button addTarget:self action:@selector(step4ButtonOK:) forControlEvents:UIControlEventTouchUpInside];
    [m_step4Scroll addSubview:step4Button];
}

- (void)step4ButtonOK:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)setOneLineWithImageId:(NSString*)imageI
{
    
}
#pragma mark 选择器
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return gameInfoArray.count;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger) row forComponent:(NSInteger) component
{
    NSString *title = KISDictionaryHaveKey([gameInfoArray objectAtIndex:row], @"name");
    return title;
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    //    NSString *title = KISDictionaryHaveKey([gameInfoArray objectAtIndex:row], @"name");
    //    gameNum = KISDictionaryHaveKey([gameInfoArray objectAtIndex:row], @"id");
    //    m_gameNameText.text =title;
    //    [m_gameNameText resignFirstResponder];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifint = @"cell";
    AboutRoleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifint];
    if (cell ==nil) {
        cell = [[AboutRoleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifint];
    }
    cell.contentTF.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = m_dataArray[indexPath.row];
    cell.titleLabel.text =KISDictionaryHaveKey(dic, @"name");
    cell.contentTF.text = KISDictionaryHaveKey(dic, @"content");
    cell.contentTF.tag = indexPath.row+100000;
    
    if ([KISDictionaryHaveKey(dic, @"type")isEqualToString:@"list"]||[KISDictionaryHaveKey(dic, @"type")isEqualToString:@"picker"]) {
        cell.rightImageView.hidden = NO;
        if ([KISDictionaryHaveKey(dic, @"type")isEqualToString:@"picker"]) {
            cell.contentTF.inputView =m_gameNamePick;
            cell.contentTF.inputAccessoryView= toolbar_server1;
            cell.serverButton.hidden = YES;
            cell.gameImg.hidden = NO;
            //            cell.gameImg.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString: KISDictionaryHaveKey(dic, @"img")]];
            
            NSString * imageId=KISDictionaryHaveKey(dic, @"img");
            cell.gameImg.imageURL = [ImageService getImageUrl4:imageId];
            //            m_gameNamePick.tag = indexPath.row;
            //            toolbar_server1.tag = indexPath.row;
            
        }else if([KISDictionaryHaveKey(dic, @"type")isEqualToString:@"list"]){
            cell.serverButton.hidden =NO;
            cell.gameImg.hidden = YES;
            [cell.serverButton addTarget:self action:@selector(realmSelectClick:) forControlEvents:UIControlEventTouchUpInside];
            cell.serverButton.tag = indexPath.row;
        }
        
    }else{
        cell.gameImg.hidden = YES;
        cell.serverButton.hidden = YES;
        cell.rightImageView.hidden = YES;
        cell.contentTF.inputView =nil;
    }
    
    return cell;
}




#pragma mark textField and touch delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (m_phoneNumText == textField) {
        if (m_phoneNumText.text.length >= 11 && range.length == 0)//只允许输入11位
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
    else if(m_verCodeTextField == textField)
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
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    if (textField == m_gameNameText) {
//        [self showAlertViewWithTitle:@"提示" message:@"暂不支持其他游戏" buttonTitle:@"确定"];
//        return NO;
//    }
//    return YES;
//}

#pragma mark 手势
- (void)tapClick:(id)sender
{
    [m_userNameText resignFirstResponder];
    [m_passwordText resignFirstResponder];
    [m_birthdayText resignFirstResponder];
    [m_emailText resignFirstResponder];
}

- (void)tapTopViewClick:(id)sender
{
    [m_phoneNumText resignFirstResponder];
    
    [m_verCodeTextField resignFirstResponder];
    
    //    [m_gameNameText resignFirstResponder];
    //    [m_serverNameText resignFirstResponder];
    //    [m_roleNameText resignFirstResponder];
    
    [m_userNameText resignFirstResponder];
    [m_passwordText resignFirstResponder];
    [m_birthdayText resignFirstResponder];
    [m_emailText resignFirstResponder];
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
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
