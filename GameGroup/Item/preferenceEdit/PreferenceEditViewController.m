//
//  PreferenceEditViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "PreferenceEditViewController.h"
#import "EGOImageView.h"
#import "ItemManager.h"
@interface PreferenceEditViewController ()
{
    UITableView *m_myTableView;
    NSMutableArray *gameInfoArray;
    NSMutableArray *m_roleArray;
    UIPickerView *m_gamePickerView;
    UIPickerView *m_rolePickerView;
    
    
    NSMutableDictionary *m_listDict;
    UITextField *firstTf;
    UITextField *secondTf;
    UITextField *thirdTf;
    UITextField *forthTf;
    UIToolbar *toolbar;
    UIToolbar *toolbar1;
    UITextView *m_dsTextView;
}
@end

@implementation PreferenceEditViewController

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
    [self setTopViewWithTitle:@"偏好设置" withBackButton:YES];
    
    gameInfoArray  = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"TeamType_%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"createTeamUser"), @"gameid")]] ];
    m_roleArray =[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"FilterId_%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.mainDict, @"gameid")]]];
    
    if (m_roleArray.count<1) {
        
        [[ItemManager singleton]getFilterId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"createTeamUser"), @"gameid")] reSuccess:^(id responseObject) {
            [self getFilter:responseObject];
        } reError:^(id error) {
            [self showErrorAlertView:error];
        }];
    }
    
    
    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [createBtn setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(didUploadInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];

    // Do any additional setup after loading the view.
    
    [self buildThreeTextField];
    
}

-(void)getFilter:(id)responseObject
{
    NSMutableArray * resp = responseObject;
    m_roleArray = resp;
    [m_rolePickerView reloadInputViews];
}

-(void)didUploadInfo:(id)sender
{
    NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];
    NSDictionary *filDic = [m_roleArray objectAtIndex:[m_rolePickerView selectedRowInComponent:0]];
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"teamUser"), @"gameid")] forKey:@"gameid"];
    [paramDict setObject:thirdTf.text forKey:@"description"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.mainDict, @"preferenceId")] forKey:@"preferenceId"];
    [paramDict setObject:m_dsTextView.text forKey:@"description"];
    [paramDict setObject:secondTf.text forKey:@"options"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(filDic, @"constId")] forKey:@"filterId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"constId")]?[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"constId")]:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"type"), @"constId")]forKey:@"typeId"];
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"283" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        //发送通知 刷新我的组队页面
        [[NSNotificationCenter defaultCenter]postNotificationName:@"shuaxinRefreshPreference_wxx" object:nil];
        [self showMessageWindowWithContent:@"修改成功" imageType:0];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self showErrorAlertView:error];
        [hud hide:YES];
    }];

}
//弹出提示框
-(void)showErrorAlertView:(id)error
{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}


-(void)buildThreeTextField
{
    m_gamePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_gamePickerView.dataSource = self;
    m_gamePickerView.delegate = self;
    m_gamePickerView.showsSelectionIndicator = YES;
    
    toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectServerNameOK:)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar.items = @[rb_server];
    
    m_rolePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_rolePickerView.dataSource = self;
    m_rolePickerView.delegate = self;
    m_rolePickerView.showsSelectionIndicator = YES;
    
    toolbar1 = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar1.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server1 = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectServerNameOK:)];
    rb_server1.tintColor = [UIColor blackColor];
    toolbar1.items = @[rb_server1];

    
//    firstTf = [self buildViewWithFrame:CGRectMake(0, startX, 320, 40) leftImg:@"item_1" title:@"角色" rightImg:@"nil" RightImageSize:CGSizeMake(12.5, 8.5) placeholder:nil isPicker:YES isTurn:NO tag:0];
//    firstTf.text = [NSString stringWithFormat:@"%@-%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"teamUser"), @"realm")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"teamUser"), @"characterName")]];
//    firstTf.userInteractionEnabled = NO;
//    firstTf.inputAccessoryView = toolbar1;
//    firstTf.inputView = m_rolePickerView;
    
    UIView *roleView = [self buildViewWithFrame:CGRectMake(0, startX, 320, 40) leftImg:@"item_1" title:@"角色" rightText:[NSString stringWithFormat:@"%@-%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"createTeamUser"), @"realm")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"createTeamUser"), @"characterName")]]];
    
    [self.view addSubview:roleView];
    
    secondTf = [self buildViewWithFrame:CGRectMake(0, startX+41, 320, 40) leftImg:@"item_2" title:@"分类" rightImg:@"arrow_bottom" RightImageSize:CGSizeMake(12.5, 8.5) placeholder:@"点击选择分类"isPicker:NO isTurn:NO tag:0];
    secondTf.inputView = m_gamePickerView;
    secondTf.inputAccessoryView = toolbar;
    
    thirdTf = [self buildViewWithFrame:CGRectMake(0, startX+82, 320, 40) leftImg:@"item_4" title:@"排列方式" rightImg:@"arrow_bottom" RightImageSize:CGSizeMake(12.5, 8.5) placeholder:nil isPicker:NO isTurn:NO tag:1];
    thirdTf.inputView = m_rolePickerView;
    thirdTf.inputAccessoryView = toolbar1;
    
    
    forthTf = [self buildViewWithFrame:CGRectMake(0, startX+123, 320, 40) leftImg:@"item_4" title:@"描述" rightImg:nil RightImageSize:CGSizeZero placeholder:nil isPicker:NO isTurn:NO tag:1];
    forthTf.userInteractionEnabled = NO;
    
    m_dsTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, startX+170, 300, 80)];
    m_dsTextView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:m_dsTextView];
    
    
    firstTf.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.mainDict, @"characterName")];
    secondTf.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"type"), @"value")];
    
    
    thirdTf.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"filter"), @"value")];
    
    m_dsTextView.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.mainDict, @"desc")];

    
    
    
}

-(UIView *)buildViewWithFrame:(CGRect)frame  leftImg:(NSString *)leftImg title:(NSString *)title rightText:(NSString *)rightText
{
    UIView *customView = [[UIView alloc]initWithFrame:frame];
    customView.backgroundColor =[ UIColor whiteColor];
    
    UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
    imageView.image = KUIImage(leftImg);
    [customView addSubview:imageView];
    
    UILabel *titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(35, 0, 100, 40) font:[UIFont systemFontOfSize:14] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
    titleLabel.text = title;
    [customView addSubview:titleLabel];
    
    
    UILabel *rightLb = [GameCommon buildLabelinitWithFrame:CGRectMake(140, 0, 155, 40) font:[UIFont systemFontOfSize:14] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentRight ];
    rightLb.text = rightText;
    [customView addSubview:rightLb];
    return customView;
}




//创建快捷方式
-(UITextField *)buildViewWithFrame:(CGRect)frame  leftImg:(NSString *)leftImg title:(NSString *)title rightImg:(NSString *)rightImg RightImageSize:(CGSize)rightImageSize placeholder:(NSString *)placeholder isPicker:(BOOL)ispicker isTurn:(BOOL)isTurn tag:(NSInteger)tag
{
    UIView *customView = [[UIView alloc]initWithFrame:frame];
    customView.backgroundColor =[ UIColor whiteColor];
    
    UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
    imageView.image = KUIImage(leftImg);
    [customView addSubview:imageView];
    
    UILabel *titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(35, 0, 100, 40) font:[UIFont systemFontOfSize:14] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
    titleLabel.text = title;
    [customView addSubview:titleLabel];
    
    UIImageView *rightImgView = [[UIImageView alloc]initWithFrame:CGRectMake(300, 15, rightImageSize.width, rightImageSize.height)];
    rightImgView.image = KUIImage(rightImg);
    [customView addSubview:rightImgView];
    
    UITextField* tf = [GameCommon buildTextFieldWithFrame:CGRectMake(140, 0, 155, 40) font:[UIFont systemFontOfSize:14] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentRight placeholder:placeholder];
    if (ispicker) {
        tf.inputView = m_gamePickerView;
        tf.inputAccessoryView = toolbar;
    }
    if (isTurn) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        [button addTarget:self action:@selector(enterOtherPage:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        button.tag = tag;
        [customView addSubview:button];
        tf.userInteractionEnabled = NO;
    }else{
        tf.userInteractionEnabled = YES;
    }
    [customView addSubview:tf];
    
    [self.view addSubview:customView];
    return tf;
}
//点击toolbar 确定button
-(void)selectServerNameOK:(UIToolbar*)sender
{
    
    if ([thirdTf isFirstResponder]) {
        if ([m_roleArray count] != 0) {
            NSDictionary *dict =[m_roleArray objectAtIndex:[m_rolePickerView selectedRowInComponent:0]];
            thirdTf.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"value")];
            [thirdTf resignFirstResponder];
            
        }
    }
    
    else if ([secondTf isFirstResponder]){
    if ([gameInfoArray count] != 0) {
        NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];
        secondTf.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"value")];
        [secondTf resignFirstResponder];
        
    }
    }
}
#pragma mark 选择器
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView ==m_rolePickerView) {
        return m_roleArray.count;
    }else{
    return gameInfoArray.count;
    }
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger) row forComponent:(NSInteger) component
{
    if (pickerView ==m_rolePickerView) {
        NSDictionary *dic = [m_roleArray objectAtIndex:row];
        return [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"value")];
    }else{
    NSString *title = KISDictionaryHaveKey([gameInfoArray objectAtIndex:row], @"value");
    return title;
    }
}
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
//{
//    NSDictionary *dic = [gameInfoArray objectAtIndex:row];
//    UIView *customView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
//    EGOImageView *imageView = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 5, 20, 20)];
//    imageView.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")]];
//    [customView addSubview:imageView];
//    
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 30)];
//    label.backgroundColor = [UIColor clearColor];
//    label.text = [NSString stringWithFormat:@"%@-%@-%@",KISDictionaryHaveKey(dic, @"simpleRealm"),KISDictionaryHaveKey(dic, @"value1"),KISDictionaryHaveKey(dic, @"name")];
//    [customView addSubview:label];
//    return customView;
//    
//}
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
