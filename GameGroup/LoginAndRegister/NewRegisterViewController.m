//
//  NewRegisterViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewRegisterViewController.h"
#import "ShowTextViewController.h"
#import "HelpViewController.h"

@interface NewRegisterViewController ()
{
    UIImageView *m_topImage;//条图
    UILabel *m_titleLabel;//标题
    UIScrollView *m_step1Scroll;
    UIScrollView *m_step2Scroll;
    UIScrollView *m_step3Scroll;
    UITextField *m_phoneNumText;// 手机号验证
    UIScrollView* m_step1Scroll_verCode;
    UITextField *m_verCodeTextField;
    UIButton *m_agreeButton;
    UIButton *m_refreshVCButton;
    
    NSInteger     m_leftTime;
    NSTimer*      m_verCodeTimer;

    UIButton *m_sexWomanButton;
    UIButton *m_sexManButton;
    
    NSString *imagePath;
    UITextField *m_parssWordTf;
//    UITextField *m_emailTf;
    UIButton *m_photoButton;

    NSInteger count;
    
    UILabel *topLabel;
}
@property(nonatomic,retain)NSString *imgID;
@property(nonatomic,retain)UIButton *step1Button;
@property(nonatomic,retain)UIButton* vercodeNextButton;
@property(nonatomic,retain)UIImageView *sexImage;
@property(nonatomic,retain)UIButton *sexButton;
@property(nonatomic,retain)UIButton* step3Button;

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
    [m_phoneNumText becomeFirstResponder];//进入页面自动弹出键盘
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self setTopViewWithTitle:@"" withBackButton:YES];
    
    
    
    self.view.backgroundColor = UIColorFromRGBA(0xf6f6f6, 1);
    
    m_topImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, startX, 320, 28)];
//    m_topImage.image = KUIImage(@"registerStep1");
    [self.view addSubview:m_topImage];
     
    [self setTopViewWithTitle:@"" withBackButton:NO];
    
    // 创建返回按钮
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, KISHighVersion_7 ? 20 : 0, 65, 44)];
    [backButton setBackgroundImage:KUIImage(@"btn_back") forState:UIControlStateNormal];
    [backButton setBackgroundImage:KUIImage(@"btn_back_onclick") forState:UIControlStateHighlighted];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, startX - 44, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
    m_titleLabel.text = @"验证手机";
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:m_titleLabel];

    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, startX+8, kScreenWidth, kScreenHeigth-28-startX)];
    self.scrollView.scrollEnabled = NO;
    self.scrollView.contentSize = CGSizeMake(kScreenWidth*3, 0);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];

    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    
    
    [self buildMainView];
    [self setStep_1View];
    [self setstep1Scroll_verCode];
    [self buildStep2];
}
-(void)buildMainView
{
    m_step1Scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeigth-28-startX)];
    m_step1Scroll.pagingEnabled = NO;
    m_step1Scroll.showsHorizontalScrollIndicator = NO;
    m_step1Scroll.showsVerticalScrollIndicator = NO;
    [self.scrollView addSubview:m_step1Scroll];
    
    
    m_step1Scroll_verCode = [[UIScrollView alloc]initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeigth-28-startX)];
    m_step1Scroll_verCode.pagingEnabled = NO;
    m_step1Scroll_verCode.showsHorizontalScrollIndicator = NO;
    m_step1Scroll_verCode.showsVerticalScrollIndicator = NO;
    [self.scrollView addSubview:m_step1Scroll_verCode];

    
    
    
    m_step2Scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(kScreenWidth*2, 0, kScreenWidth, kScreenHeigth-28-startX)];
    m_step2Scroll.pagingEnabled = NO;
    m_step2Scroll.showsHorizontalScrollIndicator = NO;
    m_step2Scroll.showsVerticalScrollIndicator = NO;
    [self.scrollView addSubview:m_step2Scroll];
    
}

#pragma mark 第一步
- (void)setStep_1View
{
//    UIImageView* table_top = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 300, 40)];
//    table_top.image = KUIImage(@"text_bg");
//    table_top.backgroundColor = [UIColor redColor];
//    [m_step1Scroll addSubview:table_top];
    
    UILabel* chinaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 112, 43)];
    chinaLabel.text = @"中国 +86";
    chinaLabel.textColor = kColorWithRGB(41, 164, 246, 1.0);
    chinaLabel.backgroundColor = [UIColor whiteColor];
    chinaLabel.textAlignment = NSTextAlignmentCenter;
//    chinaLabel.textColor = kColorWithRGB(128, 128, 128, 1.0);
    chinaLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [m_step1Scroll addSubview:chinaLabel];
    
    UILabel *backgroudLabel = [[UILabel alloc]initWithFrame:CGRectMake(115, 16, 210, 43)];
    backgroudLabel.userInteractionEnabled = YES;
    backgroudLabel.backgroundColor = [UIColor whiteColor];
    [m_step1Scroll addSubview:backgroudLabel];
    
    m_phoneNumText = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, 183, 43)];
    m_phoneNumText.backgroundColor = [UIColor whiteColor];
    m_phoneNumText.textAlignment = NSTextAlignmentLeft;
    m_phoneNumText.keyboardType = UIKeyboardTypeNumberPad;
    m_phoneNumText.returnKeyType = UIReturnKeyDone;
    m_phoneNumText.delegate = self;
    m_phoneNumText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeButtonImage:) name:UITextFieldTextDidChangeNotification object:nil];
    m_phoneNumText.font = [UIFont systemFontOfSize:20.0];
    m_phoneNumText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [m_phoneNumText addTarget:self action:@selector(changeButtonImage:) forControlEvents:UIControlEventEditingChanged];
    [backgroudLabel addSubview:m_phoneNumText];
    
    m_agreeButton = [[UIButton alloc] initWithFrame:CGRectMake(14, 156, 16, 16)];
    [m_agreeButton setBackgroundImage:KUIImage(@"_png_11") forState:UIControlStateNormal];
    [m_agreeButton setBackgroundImage:KUIImage(@"_png_09") forState:UIControlStateSelected];
    m_agreeButton.backgroundColor = [UIColor clearColor];
    [m_agreeButton addTarget:self action:@selector(agreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_step1Scroll addSubview:m_agreeButton];
    m_agreeButton.selected = YES;
    
    UILabel* proLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 156, 150, 16)];
    proLabel.text = @"阅读并同意";
    proLabel.textColor = kColorWithRGB(128, 128, 128, 1.0);
    proLabel.font = [UIFont boldSystemFontOfSize:13.0];
    proLabel.backgroundColor = [UIColor clearColor];
    [m_step1Scroll addSubview:proLabel];
    
    UIButton* protocolButton = [[UIButton alloc] initWithFrame:CGRectMake(265, 156, 53, 16)];
    [protocolButton setBackgroundColor:[UIColor clearColor]];
    protocolButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    [protocolButton setTitle:@"用户协议" forState:UIControlStateNormal];
    [protocolButton setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
    protocolButton.tag = 2;
    [protocolButton addTarget:self action:@selector(protocolClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_step1Scroll addSubview:protocolButton];
    
    self.step1Button = [[UIButton alloc] initWithFrame:CGRectMake(10, 90, 300, 40)];
//    [self.step1Button setImage:KUIImage(@"1_031.png") forState:UIControlStateNormal];
//    [self.step1Button setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    
    if ([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"REGISTERNEEDMSG"]] isEqualToString:@"1"]) {
        [self.step1Button setImage:KUIImage(@"1_031") forState:UIControlStateNormal];
    }else{
        [self.step1Button setImage:KUIImage(@"1_04") forState:UIControlStateNormal];
    }
    [self.step1Button addTarget:self action:@selector(judgeHaveRegiste) forControlEvents:UIControlEventTouchUpInside];
    [m_step1Scroll addSubview:self.step1Button];

 
    
}
- (void)changeButtonImage:(id)sender
{
     if ([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"REGISTERNEEDMSG"]] isEqualToString:@"1"]) {
    UITextField *field = (UITextField *)sender;
//    count = field.text.length;
    //count 要在.h中申明一个 NSInteger类型变量 可以不用初始化，即使初始化也不能在这个方法里初始化 否则会有问题，每次textField中内容改变时，都会走这个方法，所以如果在这里初始化是达不到效果的
    if (count > field.text.length) {
        //删除
        if (count == 5 || count == 10) {
            NSMutableString *str = [NSMutableString stringWithFormat:@"%@",field.text];
            field.text = [str substringToIndex:count -2];
        }
    }
    else if (count < field.text.length){
        //增加
        if (count == 3 || count == 8) {
            NSMutableString *str = [NSMutableString stringWithFormat:@"%@",field.text];
            [str insertString:@" " atIndex:count];
            field.text = str;
        }
    }
    
    //通过count的值和当前的textField内容的长度比较，如果count大那么证明是删除，反之增加
    count = field.text.length;
    
    //下面是手机号码位数控制处理，如果多余13位 ＝ 11位号码＋2个空格 响应相应事件，自己可以随便写
    if(count < 13){

         [self.step1Button setImage:KUIImage(@"1_031") forState:UIControlStateNormal];
    }
    else if(count == 13){
 
        [self.step1Button setImage:KUIImage(@"a_png_03") forState:UIControlStateNormal];
        [self.step1Button setImage:KUIImage(@"a_png_06") forState:UIControlStateHighlighted];
    }
    else{
        field.text = [field.text substringToIndex:13];
      
        [self.step1Button setImage:KUIImage(@"a_png_03") forState:UIControlStateNormal];
        [self.step1Button setImage:KUIImage(@"a_png_06") forState:UIControlStateHighlighted];
    }
     }else{
         UITextField *field = (UITextField *)sender;
         //    count = field.text.length;
         //count 要在.h中申明一个 NSInteger类型变量 可以不用初始化，即使初始化也不能在这个方法里初始化 否则会有问题，每次textField中内容改变时，都会走这个方法，所以如果在这里初始化是达不到效果的
         if (count > field.text.length) {
             //删除
             if (count == 5 || count == 10) {
                 NSMutableString *str = [NSMutableString stringWithFormat:@"%@",field.text];
                 field.text = [str substringToIndex:count -2];
             }
         }
         else if (count < field.text.length){
             //增加
             if (count == 3 || count == 8) {
                 NSMutableString *str = [NSMutableString stringWithFormat:@"%@",field.text];
                 [str insertString:@" " atIndex:count];
                 field.text = str;
             }
         }
         
         //通过count的值和当前的textField内容的长度比较，如果count大那么证明是删除，反之增加
         count = field.text.length;
         
         //下面是手机号码位数控制处理，如果多余13位 ＝ 11位号码＋2个空格 响应相应事件，自己可以随便写
         if(count < 13){
             self.step1Button.enabled = NO;
             [self.step1Button setImage:KUIImage(@"1_04") forState:UIControlStateNormal];
         }
         else if(count == 13){
             self.step1Button.enabled = YES;
             [self.step1Button setImage:KUIImage(@"_png_032_03") forState:UIControlStateNormal];
             [self.step1Button setImage:KUIImage(@"_png_032_06") forState:UIControlStateHighlighted];
         }
         else{
             field.text = [field.text substringToIndex:13];
             self.step1Button.enabled = YES;
             [self.step1Button setImage:KUIImage(@"_png_032_03") forState:UIControlStateNormal];
             [self.step1Button setImage:KUIImage(@"_png_032_06") forState:UIControlStateHighlighted];
         }
     }
    
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

- (void)judgeHaveRegiste
{
    [m_phoneNumText resignFirstResponder];
    //判断字符为空
    if (KISEmptyOrEnter(m_phoneNumText.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入手机号！" buttonTitle:@"确定"];
        return;
    }
    if (m_phoneNumText.text.length!=13) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入正确的手机号！" buttonTitle:@"确定"];
        return;
    }
    if (!m_agreeButton.selected) {
        [self showAlertViewWithTitle:@"提示" message:@"请勾选用户协议！" buttonTitle:@"确定"];
        return;
    }
    NSString *str = [m_phoneNumText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self requestRegist:str];
}

//验证手机号接口
-(void)requestRegist:(NSString*)phoneNum{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:phoneNum forKey:@"username"];
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"105" forKey:@"method"];
    hud.labelText = @"请稍等...";
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        [self startToRegist];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        [self showErrorMsg:error];
    }];
}


//开始注册
-(void)startToRegist{
    if ([self isNeedCode]){//需要验证码
        if ([self iSReQuestCode]) {//需要重新获取验证码
            m_verCodeTextField.text = @"";
            [self getVerificationCode:NO];
        }else{//不需要重新获取验证码，直接跳转输入验证码页面
            [self jumpToNextPage];
        }
    }else{//不需要验证码，直接跳转输入用户信息页面
        self.scrollView.contentOffset = CGPointMake(kScreenWidth*2, 0);
        m_titleLabel.text = @"个人信息";
    }
}


//是否需要验证码
-(BOOL)isNeedCode{
    if ([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"REGISTERNEEDMSG"]] isEqualToString:@"1"]){//需要验证码
        return YES;
    }
    return NO;
}
//是否需要重新请求验证码
-(BOOL)iSReQuestCode{
    NSString *phoneNum = [m_phoneNumText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    long long oldTime =([[[NSUserDefaults standardUserDefaults]objectForKey:@"time"] longLongValue]);
    long long nowTime = [self getCurrentTimeLong];
    if ((60-(nowTime-oldTime)>0)&&[phoneNum isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"phoneNumber"]]) {
        return NO;
    }
    return YES;
}

-(long long)getCurrentTimeLong{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    nowTime = nowTime;
    return (long long)nowTime;
}
-(NSString *)getCurrentTimeStr{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    nowTime = nowTime;
    return [NSString stringWithFormat:@"%lld",(long long)nowTime];
}
//获取验证码
- (void)getVerificationCode:(BOOL)isReSend
{
    NSString *phoneNum = [m_phoneNumText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:phoneNum forKey:@"phoneNum"];
    [params setObject:@"register" forKey:@"type"];
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"112" forKey:@"method"];
    hud.labelText = @"获取中...";
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if (!isReSend) {
            [self jumpToNextPage];
        }
        NSUserDefaults *time = [NSUserDefaults standardUserDefaults];
        [time setObject:[self getCurrentTimeStr] forKey:@"time"];
        [time setObject:phoneNum forKey:@"phoneNumber"];
        [self startRefreshTime];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        [self showErrorMsg:error];
    }];
}
//跳转输入验证码页面
-(void)jumpToNextPage{
    self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
    [m_verCodeTextField becomeFirstResponder];
    topLabel.text = [NSString stringWithFormat:@"验证码已发送至手机号：%@，请注意查收！", m_phoneNumText.text];
}
//
-(void)showErrorMsg:(id)error{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }

}
//输入验证码页面
- (void)setstep1Scroll_verCode
{
    m_leftTime = 60;
    topLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 50)];
    topLabel.numberOfLines = 2;
    topLabel.font = [UIFont boldSystemFontOfSize:13.0];
    topLabel.textColor = kColorWithRGB(128.0, 128, 128, 1.0);
    topLabel.text = [NSString stringWithFormat:@"验证码已发送至手机号：%@，请注意查收！", m_phoneNumText.text];
    topLabel.backgroundColor = [UIColor clearColor];
    [m_step1Scroll_verCode addSubview:topLabel];
    
    m_verCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 60, 210, 40)];
    m_verCodeTextField.placeholder = @"请输入短信验证码";
    m_verCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    m_verCodeTextField.returnKeyType = UIReturnKeyDone;
    m_verCodeTextField.delegate = self;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNextTF:) name:UITextFieldTextDidChangeNotification object:nil];
    [m_verCodeTextField addTarget:self action:@selector(didNextTF:) forControlEvents:UIControlEventTouchUpInside];
    m_verCodeTextField.backgroundColor = [UIColor whiteColor];
    m_verCodeTextField.textAlignment = NSTextAlignmentCenter;
    m_verCodeTextField.font = [UIFont boldSystemFontOfSize:15.0];
    m_verCodeTextField.tag = 918;
    m_verCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTextField:) name:UITextFieldTextDidChangeNotification object:nil];
    [m_verCodeTextField addTarget:self action:@selector(changeTextField) forControlEvents:UIControlEventValueChanged];
    m_verCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [m_step1Scroll_verCode addSubview:m_verCodeTextField];
    
    m_refreshVCButton = [[UIButton alloc] initWithFrame:CGRectMake(212, 60, 105, 40)];
    m_refreshVCButton.backgroundColor = [UIColor whiteColor];
    [m_refreshVCButton setTitleColor:kColorWithRGB(153, 153, 153, 1.0) forState:UIControlStateSelected];
    [m_refreshVCButton setTitleColor:kColorWithRGB(102, 102, 102, 1.0) forState:UIControlStateNormal];
    [m_refreshVCButton addTarget:self action:@selector(refreshVCButtonClick1:) forControlEvents:UIControlEventTouchUpInside];
    m_refreshVCButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [m_refreshVCButton setTitle:@"重新发送60s" forState:UIControlStateNormal];
    [m_step1Scroll_verCode addSubview:m_refreshVCButton];
    
    self.vercodeNextButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 130, 300, 40)];
    [self.vercodeNextButton setImage:KUIImage(@"1_04") forState:UIControlStateNormal];
    [self.vercodeNextButton addTarget:self action:@selector(vercodeNextButtonClick2:) forControlEvents:UIControlEventTouchUpInside];
    [m_step1Scroll_verCode addSubview:self.vercodeNextButton];
    
}
- (void)didNextTF:(id)sender
{
    if (m_verCodeTextField.text.length>=6) {
        [self.vercodeNextButton setImage:KUIImage(@"_png_032_03") forState:UIControlStateNormal];
        [self.vercodeNextButton setImage:KUIImage(@"_png_032_06") forState:UIControlStateHighlighted];
    }else{
        [self.vercodeNextButton setImage:KUIImage(@"1_04") forState:UIControlStateNormal];
    }
}
- (void)changeTextField:(id)sender
{
    if (m_verCodeTextField.text.length==6) {
    [self.vercodeNextButton setImage:KUIImage(@"_png_032_03") forState:UIControlStateNormal];
    [self.vercodeNextButton setImage:KUIImage(@"_png_032_06") forState:UIControlStateHighlighted];
    }
   
}
//重发验证码
- (void)refreshVCButtonClick1:(id)sender
{
    [self getVerificationCode:YES];
}
//重新计时
- (void)startRefreshTime{
    m_refreshVCButton.selected = YES;
    m_refreshVCButton.userInteractionEnabled = NO;
    m_leftTime = 60;
    if ([m_verCodeTimer isValid]) {
        [m_verCodeTimer invalidate];
        m_verCodeTimer = nil;
    }
    [m_refreshVCButton setTitle:@"重新发送(60)" forState:UIControlStateSelected];
    m_verCodeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refrenshVerCodeTime) userInfo:nil repeats:YES];
}

- (void)refrenshVerCodeTime
{
    m_leftTime--;
    if (m_leftTime == 0) {
        m_refreshVCButton.selected = NO;
        [m_refreshVCButton setTitle:@"重新发送" forState:UIControlStateNormal];
        m_refreshVCButton.userInteractionEnabled = YES;
        if([m_verCodeTimer isValid])
        {
            [m_verCodeTimer invalidate];
            m_verCodeTimer = nil;
        }
    }
    else
        [m_refreshVCButton setTitle:[NSString stringWithFormat:@"重新发送(%d)", m_leftTime] forState:UIControlStateSelected];
}

- (void)vercodeNextButtonClick2:(id)sender
{
    [m_verCodeTextField resignFirstResponder];
    
    if (KISEmptyOrEnter(m_verCodeTextField.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入验证码！" buttonTitle:@"确定"];
        return;
    }
    NSString *phoneNum = [m_phoneNumText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:phoneNum forKey:@"phoneNum"];
    [params setObject:m_verCodeTextField.text forKey:@"xcode"];
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"113" forKey:@"method"];
    
    hud.labelText = @"验证中...";
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        m_titleLabel.text = @"个人信息";
        self.scrollView.contentOffset = CGPointMake(kScreenWidth*2, 0);
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        [self showErrorMsg:error];
    }];
}
#pragma mark ---------头像
-(void)buildStep2
{
    // 在step2scroll上添加一个手势，用于回收键盘
    UITapGestureRecognizer *tapS2S = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didS2SAction:)];
    [m_step2Scroll addGestureRecognizer:tapS2S];
//     [m_phoneNumText resignFirstResponder];
    m_photoButton = [[UIButton alloc] initWithFrame:CGRectMake(110, 10, 100, 100)];
    [m_photoButton setImage:KUIImage(@"touxiang_03") forState:UIControlStateNormal];
    [m_photoButton setImage:KUIImage(@"未标题-1_03") forState:UIControlStateHighlighted];
    [m_photoButton setBackgroundColor:[UIColor clearColor]];
    m_photoButton.layer.cornerRadius = 5;
    m_photoButton.layer.masksToBounds = YES;
    [m_photoButton addTarget:self action:@selector(photoClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_step2Scroll addSubview:m_photoButton];

    

#pragma mark===============================================
    UIView *sexView = [[UIView alloc]initWithFrame:CGRectMake(0, 135, 320, 45)];
    sexView.backgroundColor = [UIColor whiteColor];
    [m_step2Scroll addSubview:sexView];
    
    UIView *secretView = [[UIView alloc]initWithFrame:CGRectMake(0, 182, 320, 45)];
    secretView.backgroundColor = [UIColor whiteColor];
    [m_step2Scroll addSubview:secretView];
    
    self.sexImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 12, 18, 18)];
    self.sexImage.image = KUIImage(@"nannv");
    [sexView addSubview:self.sexImage];
    
    
    self.sexButton = [[UIButton alloc]initWithFrame:CGRectMake(40, 0, 240, 45)];
    [self.sexButton setTitle:@"请选择性别" forState:UIControlStateNormal];
    [self.sexButton setTitleColor:UIColorFromRGBA(0xd5d5d5, 1) forState:UIControlStateNormal];
    [self.sexButton addTarget:self action:@selector(selectSex:) forControlEvents:UIControlEventTouchUpInside];
    [sexView addSubview:self.sexButton];
    
    
    UIImageView *arrowsImage = [[UIImageView alloc]initWithFrame:CGRectMake(280, 12, 20, 20)];
    arrowsImage.image = KUIImage(@"touxiang_14");
    [sexView addSubview:arrowsImage];


    UIImageView *lockImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 12, 18, 18)];
    lockImage.image = KUIImage(@"suo");
    [secretView addSubview:lockImage];
    
    m_parssWordTf = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, 240, 45)];
    m_parssWordTf.returnKeyType = UIReturnKeyDone;
    m_parssWordTf.placeholder = @"请设置6-16位密码";
    [m_parssWordTf setValue:UIColorFromRGBA(0xd5d5d5, 1) forKeyPath:@"_placeholderLabel.textColor"];
    m_parssWordTf.delegate = self;
    m_parssWordTf.secureTextEntry = YES;//显示密文
//    m_parssWordTf.font = [UIFont boldSystemFontOfSize:15.0];
    m_parssWordTf.textAlignment = NSTextAlignmentCenter;
    m_parssWordTf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFinishButtonImage:) name:UITextFieldTextDidChangeNotification object:nil];
    [m_parssWordTf addTarget:self action:@selector(changeFinishButtonImage:) forControlEvents:UIControlEventTouchUpInside];
    
    m_parssWordTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [secretView addSubview:m_parssWordTf];
    
//    m_emailTf = [[UITextField alloc] initWithFrame:CGRectMake(100, 160, 180, 40)];
//    m_emailTf.returnKeyType = UIReturnKeyDone;
//    m_emailTf.textAlignment = NSTextAlignmentRight;
//    m_emailTf.delegate = self;
//    m_emailTf.placeholder = @"用来找回密码";
//    m_emailTf.font = [UIFont boldSystemFontOfSize:15.0];
//    m_emailTf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    m_emailTf.clearButtonMode = UITextFieldViewModeWhileEditing;
//    [m_step2Scroll addSubview:m_emailTf];
    
    
    self.step3Button = [[UIButton alloc] initWithFrame:CGRectMake(10, 292, 300, 40)];
    [self.step3Button setImage:KUIImage(@"未标题-1_06") forState:UIControlStateNormal];
//    [step3Button setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [self.step3Button setTitle:@"完成注册" forState:UIControlStateNormal];
    [self.step3Button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.step3Button.backgroundColor = [UIColor clearColor];
    [self.step3Button addTarget:self action:@selector(step33ButtonOK:) forControlEvents:UIControlEventTouchUpInside];
    [m_step2Scroll addSubview:self.step3Button];
    m_step2Scroll.contentSize  = CGSizeMake(0, iPhone5?kScreenHeigth:kScreenHeigth+40);
    
}
#pragma mark ====================完成按钮的butoton  image
- (void)changeFinishButtonImage:(id)sender
{
    
    if (m_parssWordTf.text.length >16 || m_parssWordTf.text.length <6) {
        [self.step3Button setImage:KUIImage(@"未标题-1_06") forState:UIControlStateNormal];
    }else{
       [self.step3Button setImage:KUIImage(@"touxiang_19") forState:UIControlStateNormal];
       [self.step3Button setImage:KUIImage(@"touxiang_22") forState:UIControlStateHighlighted];
    }
}
- (void)didS2SAction:(id)sender
{
    [m_parssWordTf resignFirstResponder];
}
- (void)selectSex:(id)sender
{
    [m_parssWordTf resignFirstResponder];
    UIActionSheet *sexAction = [[UIActionSheet alloc]initWithTitle:@"选择性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
    sexAction.tag = 231;
    [sexAction showInView:self.view];
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

#pragma 最后一步
- (void)step33ButtonOK:(id)sender
{
    [m_parssWordTf resignFirstResponder];
    if ([self.sexButton.titleLabel.text isEqualToString:@"请选择性别"]) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择性别！" buttonTitle:@"确定"];
        return;
    }
    if (m_parssWordTf.text.length < 6 ) {
        [self showAlertViewWithTitle:@"提示" message:@"密码最短6个字符！" buttonTitle:@"确定"];
        return;
    }else if(m_parssWordTf.text.length > 16){
        [self showAlertViewWithTitle:@"提示" message:@"密码最长16个字符！" buttonTitle:@"确定"];
        return;
    }
    [self uploadImage:imagePath];
}

- (void)continueStep3Net:(NSString*)imageId
{
    NSString *phoneNum = [m_phoneNumText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:phoneNum forKey:@"username"];
    [params setObject:imageId forKey:@"img"];
    [params setObject:m_parssWordTf.text forKey:@"password"];
    [params setObject:[self.sexButton.titleLabel.text isEqualToString:@"男生"]?@"0":@"1" forKey:@"gender"];
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
        [[NSUserDefaults standardUserDefaults] setValue:phoneNum forKey:PhoneNumKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSDictionary* dic = responseObject;
        [[NSUserDefaults standardUserDefaults]setObject:[[dic objectForKey:@"user"]objectForKey:@"active" ] forKey:@"active_wx"];
        
        NSString * host = KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"chatServer"), @"address");
        NSString * domain = KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"chatServer"), @"name");
        
        [[NSUserDefaults standardUserDefaults] setObject:host forKey:@"host"];
        [[NSUserDefaults standardUserDefaults] setObject:domain forKey:kDOMAIN];
        [[NSUserDefaults standardUserDefaults]setObject:[[dic objectForKey:@"token"] objectForKey:@"userid"] forKey:kMYUSERID];
        [[NSUserDefaults standardUserDefaults]setObject:[[dic objectForKey:@"token"] objectForKey:@"token"] forKey:kMyToken];
        [DataStoreManager setDefaultDataBase:[[dic objectForKey:@"token"] objectForKey:@"userid"] AndDefaultModel:@"LocalStore"];
        AppDelegate* app=(AppDelegate*)[UIApplication sharedApplication].delegate;
        [app.xmppHelper connect];
        
        [[UserManager singleton]getSayHiUserId];//获取打招呼id
        [[GameCommon shareGameCommon]LoginOpen];//获取游戏列表信息
        
        
        NSMutableDictionary *userDic=KISDictionaryHaveKey(dic, @"gameproUser");
        [userDic setObject:KISDictionaryHaveKey(userDic, @"id") forKey:@"userid"];
        [userDic setObject:KISDictionaryHaveKey(userDic, @"birthdate") forKey:@"birthday"];
        [[UserManager singleton] saveUserInfoToDb:userDic ShipType:@"unknow"];
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

#pragma mark ----上传图片
#pragma mark 选择照片
- (void)photoClick:(id)sender
{
    [m_parssWordTf resignFirstResponder];
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
         }else if(actionSheet.tag ==231){
             switch (buttonIndex) {
                 case 0:
                 {
                     [self showAlertViewWithTitle:@"提示" message:@"性别一经选定, 将无法通过任何途径修改" buttonTitle:@"确定"];
                    self.sexImage.image = KUIImage(@"boy");
                     [self.sexButton setTitle:@"男生" forState:UIControlStateNormal];
                     [self.sexButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                 }break;
                  case 1:
                 {
                     [self showAlertViewWithTitle:@"提示" message:@"性别一经选定, 将无法通过任何途径修改" buttonTitle:@"确定"];
                    self.sexImage.image = KUIImage(@"girl");
                     [self.sexButton setTitle:@"女生" forState:UIControlStateNormal];
                     [self.sexButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                 }break;
                     
                 default:
                     break;
             }
             
             
         }

}

#pragma mark - imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
    
    }];
    [m_phoneNumText resignFirstResponder];
    UIImage*selectImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];    
    if (picker.sourceType ==UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(selectImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    [m_photoButton setImage:selectImage forState:UIControlStateNormal];
   
    imagePath=[self writeImageToFile:selectImage ImageName:@"register.jpg"];
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
   
//    [m_verCodeTextField resignFirstResponder];
    [picker dismissViewControllerAnimated:YES completion:^{}];
    [m_phoneNumText resignFirstResponder];
//    [m_verCodeTextField resignFirstResponder];
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

// 上传进度
- (void)uploadProgressUpdated:(NSString *)theFilePath percent:(float)percent
{
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





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark textField and touch delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (m_phoneNumText == textField) {
       if (m_phoneNumText == textField){
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
        if (range.location == 6)
            return NO;
        return YES;
    }else if (m_parssWordTf == textField)
    {
        if (range.location == 16)
        {
            return NO;
        }else if ([string isEqualToString:@" "])
        {
            return NO;
        }
            return YES;
    }
   return YES;
}
#pragma mark alertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 67)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
            [self continueStep3Net:@""];
    }else
    {
        if (buttonIndex != alertView.cancelButtonIndex){
            m_step2Scroll.hidden = YES;
            m_step3Scroll.hidden = NO;
            m_titleLabel.text = @"个人信息";
            [[TempData sharedInstance] setPassBindingRole:YES];
        }
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == m_parssWordTf) {
        [self animateTextField: textField up: YES];
    }else if (textField == m_phoneNumText){
       
    }
  }
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == m_parssWordTf) {
        [self animateTextField: textField up: NO];
    }
}
- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 40;
    const float movementDuration = 0.3f;
    int movement = (up ? -movementDistance : movementDistance);
    [UIView beginAnimations: @"viewMoveup" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)backButtonAction:(id)sender
{
    CGPoint a = self.scrollView.contentOffset;
    if (a.x == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if (a.x == 320){
         self.scrollView.contentOffset = CGPointMake(0, 0);
        topLabel.text = @"";
    }else if (a.x ==640){
        self.scrollView.contentOffset = CGPointMake(0, 0);
    }
}
@end
