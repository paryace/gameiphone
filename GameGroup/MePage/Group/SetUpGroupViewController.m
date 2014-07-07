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
    UILabel * placeholderL;
    
    UIPickerView *m_gamePickerView;
    NSMutableArray *gameInfoArray;
}
@end

@implementation SetUpGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"申请加入" withBackButton:YES];
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    tapGr.delegate = self;
    [self.view addGestureRecognizer:tapGr];
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

    UIImageView* table_arrow_two = [[UIImageView alloc] initWithFrame:CGRectMake(10,startX+10, 300, 40)];
    table_arrow_two.image = KUIImage(@"group_cardtf");
    [self.view addSubview:table_arrow_two];
    
    UIButton* table_arrow = [[UIButton alloc] initWithFrame:CGRectMake(270, startX+10, 40, 40)];
    [table_arrow setImageEdgeInsets:UIEdgeInsetsMake(16, 14, 16, 14)];
    [table_arrow setImage:KUIImage(@"arrow_bottom") forState:UIControlStateNormal];
    [table_arrow addTarget:self action:@selector(result:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:table_arrow];

    
    UILabel* table_label_three = [[UILabel alloc] initWithFrame:CGRectMake(20, startX+10, 80, 38)];
    table_label_three.text = @"角色名";
    table_label_three.backgroundColor = [UIColor clearColor];
    table_label_three.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_three.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:table_label_three];

    m_searchTf = [[UITextField alloc] initWithFrame:CGRectMake(80, startX+10, 180, 40)];
    m_searchTf.returnKeyType = UIReturnKeyDone;
    m_searchTf.inputView = m_gamePickerView;
    m_searchTf.inputAccessoryView= toolbar;
    m_searchTf.adjustsFontSizeToFitWidth = YES;
    m_searchTf.placeholder = @"请选择角色";
    m_searchTf.textAlignment = NSTextAlignmentRight;
    m_searchTf.textColor = [UIColor grayColor];
    m_searchTf.font = [UIFont systemFontOfSize:15.0];
    m_searchTf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_searchTf.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.view addSubview:m_searchTf];
    
    m_textView =[[ UITextView alloc]initWithFrame:CGRectMake(10, startX+80, 300, 150)];
    m_textView.delegate = self;
    m_textView.font = [UIFont boldSystemFontOfSize:15];
    m_textView.textColor = kColorWithRGB(102, 102, 102, 1.0);
    m_textView.backgroundColor = [UIColor whiteColor];
    m_textView.layer.cornerRadius = 5;
    m_textView.layer.masksToBounds = YES;
    m_textView.layer.borderWidth=1;
    m_textView.layer.borderColor=[kColorWithRGB(200, 200, 200, 1.0) CGColor];
    [self.view addSubview:m_textView];
    
    placeholderL = [[UILabel alloc]initWithFrame:CGRectMake(15, startX+83, 300, 20)];
    placeholderL.backgroundColor = [UIColor clearColor];
    placeholderL.textColor = [UIColor grayColor];
    placeholderL.text = @"选择角色自动生成申请理由";
    placeholderL.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:placeholderL];

    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(updateInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

}

-(void)result:(id)sender
{
    [m_searchTf becomeFirstResponder];
}
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    if([m_searchTf isFirstResponder]){
        [m_searchTf resignFirstResponder];
    }
    if([m_textView isFirstResponder]){
        [m_textView resignFirstResponder];
    }
}
#pragma mark - text view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length>0 || text.length != 0) {
        placeholderL.text = @"";
    }else{
        placeholderL.text = @"选择角色自动生成申请理由";
    }
    return YES;
}

-(void)updateInfo:(id)sender
{
    NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];

        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if ([m_textView.text isEqualToString:@""]||!m_textView.text||[m_textView.text isEqualToString:@" "]) {
            [self showAlertViewWithTitle:@"提示" message:@"请填写申请" buttonTitle:@"确定"];
            return;
        }
    NSInteger ziNum = 30 - [[GameCommon shareGameCommon] unicodeLengthOfString:m_textView.text];
    if (ziNum < 0) {
        [self showAlertViewWithTitle:@"提示" message:@"输入字数超过上限，请修改！" buttonTitle:@"确定"];
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
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}
-(void)selectServerNameOK:(id)sender
{
    if ([gameInfoArray count] != 0) {
        placeholderL.text = @"";
        NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];
        m_textView.text = [NSString stringWithFormat:@"%@-%@ 申请入群\n",KISDictionaryHaveKey(dict, @"realm"),KISDictionaryHaveKey(dict, @"name")];
        m_searchTf.text =[NSString stringWithFormat:@"%@-%@",KISDictionaryHaveKey(dict, @"realm"),KISDictionaryHaveKey(dict, @"name")];
        [m_searchTf resignFirstResponder];
        [m_textView becomeFirstResponder];
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
    customView.backgroundColor = [UIColor clearColor];
    imageView.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")]];
    [customView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 30)];
    label.text = [NSString stringWithFormat:@"%@-%@-%@",KISDictionaryHaveKey(dic, @"realm"),KISDictionaryHaveKey(dic, @"value1"),KISDictionaryHaveKey(dic, @"name")];
    label.backgroundColor =[ UIColor clearColor];
    [customView addSubview:label];
    return customView;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
