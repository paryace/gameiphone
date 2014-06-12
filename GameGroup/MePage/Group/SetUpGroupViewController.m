//
//  SetUpGroupViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SetUpGroupViewController.h"

@interface SetUpGroupViewController ()
{
    UITextView *m_textView;
}
@end

@implementation SetUpGroupViewController

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
    
    [self setTopViewWithTitle:@"" withBackButton:YES];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, KISHighVersion_7 ? 20 : 0, 220, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:titleLabel];

    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, startX+20, 280, 30)];
    label.backgroundColor =[ UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:label];
    
    
    UIImageView* editIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, startX+60, 280, 150)];
    editIV.backgroundColor=[UIColor whiteColor];
    editIV.image = KUIImage(@"group_info");
    [self.view addSubview:editIV];
    
    
    m_textView =[[ UITextView alloc]initWithFrame:CGRectMake(20, startX+60, 280, 150)];
    m_textView.delegate = self;
    m_textView.font = [UIFont boldSystemFontOfSize:13];
    m_textView.backgroundColor = [UIColor clearColor];
    m_textView.textColor = [UIColor blackColor];
    [self.view addSubview:m_textView];

    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, startX+220, 300, 44);
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button setBackgroundImage:KUIImage(@"group_list_btn1") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(updateInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    if (self.mySetupType ==SETUP_JOIN) {
        titleLabel.text = @"申请加入";
        label.text = @"请填写入群申请";

    }
    else if (self.mySetupType ==SETUP_NAME) {
        titleLabel.text = @"修改群名称";
        label.text = @"请填写群名称";

    }
    else if (self.mySetupType ==SETUP_IMG) {
        titleLabel.text = @"修改群资料";
    }
    else if (self.mySetupType ==SETUP_INFO) {
        titleLabel.text = @"修改群介绍";
    }
    else  {
        titleLabel.text = @"群设置";
    }

    // Do any additional setup after loading the view.
}
-(void)updateInfo:(id)sender
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (self.mySetupType ==SETUP_JOIN) {
        if ([m_textView.text isEqualToString:@""]||!m_textView.text||[m_textView.text isEqualToString:@" "]) {
            [self showAlertViewWithTitle:@"提示" message:@"请填写申请" buttonTitle:@"确定"];
            return;
        }
        [dic setObject:m_textView.text forKey:@"msg"];
        [dic setObject:self.groupid forKey:@"groupId"];
       [ self getInfoToNetWithparamDict:dic method:@"232"];
    }
    else if (self.mySetupType ==SETUP_NAME) {
        if (self.delegate &&[self.delegate respondsToSelector:@selector(comeBackInfoWithController:type:info:)]) {
            [self.delegate comeBackInfoWithController:self type:self.mySetupType info:m_textView.text];
        }
    }
    else if (self.mySetupType ==SETUP_IMG) {
        [ self getInfoToNetWithparamDict:nil method:nil];
    }
    else if (self.mySetupType ==SETUP_INFO) {
        if (self.delegate &&[self.delegate respondsToSelector:@selector(comeBackInfoWithController:type:info:)]) {
            [self.delegate comeBackInfoWithController:self type:self.mySetupType info:m_textView.text];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else  {
        [ self getInfoToNetWithparamDict:nil method:nil];
    }

    
    
}

-(void)getInfoToNetWithparamDict:(NSMutableDictionary *)paramDict method:(NSString *)method
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:method forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self showMessageWindowWithContent:@"提交成功!请等待确认" imageType:0];
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
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
