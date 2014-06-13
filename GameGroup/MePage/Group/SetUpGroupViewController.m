//
//  SetUpGroupViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SetUpGroupViewController.h"
#import "EGOImageView.h"
@interface SetUpGroupViewController ()
{
    UITextView *m_textView;
    UITextField *m_searchTf;
    UIPickerView *m_gamePickerView;
    NSMutableArray *gameInfoArray;
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
    
    [self setTopViewWithTitle:@"申请加入" withBackButton:YES];

    gameInfoArray  = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];

    
    m_gamePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_gamePickerView.dataSource = self;
    m_gamePickerView.delegate = self;
    m_gamePickerView.showsSelectionIndicator = YES;
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectServerNameOK:)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar.items = @[rb_server];

    m_searchTf = [[UITextField alloc]initWithFrame:CGRectMake(10, startX+20, 300, 40)];
    m_searchTf.backgroundColor = [UIColor clearColor];
    m_searchTf.borderStyle = UITextBorderStyleRoundedRect;
    m_searchTf.placeholder = @"请选择游戏角色";
    m_searchTf.clearButtonMode = UITextFieldViewModeUnlessEditing;
    m_searchTf.autocorrectionType = UITextAutocorrectionTypeNo;
    m_searchTf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_searchTf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    m_searchTf.returnKeyType =UIReturnKeyGo;
    m_searchTf.inputView = m_gamePickerView;
    m_searchTf.inputAccessoryView= toolbar;
    m_searchTf.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:m_searchTf];
    

    
    UIImageView* editIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, startX+80, 280, 150)];
    editIV.backgroundColor=[UIColor whiteColor];
    editIV.image = KUIImage(@"group_info");
    [self.view addSubview:editIV];
    
    
    m_textView =[[ UITextView alloc]initWithFrame:CGRectMake(20, startX+80, 280, 150)];
    m_textView.delegate = self;
    m_textView.font = [UIFont boldSystemFontOfSize:13];
    m_textView.backgroundColor = [UIColor clearColor];
    m_textView.textColor = [UIColor blackColor];
    [self.view addSubview:m_textView];

    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, startX+230, 300, 44);
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button setBackgroundImage:KUIImage(@"group_list_btn1") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(updateInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
  
    // Do any additional setup after loading the view.
}

-(void)updateInfo:(id)sender
{
    NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if ([m_textView.text isEqualToString:@""]||!m_textView.text||[m_textView.text isEqualToString:@" "]) {
        [self showAlertViewWithTitle:@"提示" message:@"请填写申请" buttonTitle:@"确定"];
        return;
    }
    [dic setObject:m_textView.text forKey:@"msg"];
    [dic setObject:self.groupid forKey:@"groupId"];
    [dic setObject:KISDictionaryHaveKey(dict, @"id") forKey:@"characterId"];
    [dic setObject:KISDictionaryHaveKey(dict, @"gameid") forKey:@"gameid"];
    [ self getInfoToNetWithparamDict:dic method:@"232"];
}

-(void)getInfoToNetWithparamDict:(NSMutableDictionary *)paramDict method:(NSString *)method
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:method forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self showMessageWindowWithContent:@"提交成功" imageType:0];
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
    }];
    
}

-(void)selectServerNameOK:(id)sender
{
    if ([gameInfoArray count] != 0) {
        NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];
        m_searchTf.text = [NSString stringWithFormat:@"%@-%@",KISDictionaryHaveKey(dict, @"realm"),KISDictionaryHaveKey(dict, @"name")];
        [m_searchTf resignFirstResponder];
    }
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

//- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger) row forComponent:(NSInteger) component
//{
//    NSString *title = KISDictionaryHaveKey([gameInfoArray objectAtIndex:row], @"name");
//    return title;
//}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
{
    NSDictionary *dic = [gameInfoArray objectAtIndex:row];
    UIView *customView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    EGOImageView *imageView = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 5, 20, 20)];
    imageView.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")]];
    [customView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 30)];
    label.text = [NSString stringWithFormat:@"%@-%@-%@",KISDictionaryHaveKey(dic, @"realm"),KISDictionaryHaveKey(dic, @"value1"),KISDictionaryHaveKey(dic, @"name")];
    [customView addSubview:label];
    return customView;
    
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
