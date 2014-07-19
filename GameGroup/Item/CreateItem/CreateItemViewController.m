//
//  CreateItemViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CreateItemViewController.h"
#import "EGOImageView.h"
#import "ChooseListView.h"
#import "ItemManager.h"

@interface CreateItemViewController ()
{
    UITableView *m_myTableView;
    NSMutableArray *gameInfoArray;
    UIPickerView *m_gamePickerView;
    NSMutableDictionary *m_listDict;
    UITextField *firstTf;
    UITextField *secondTf;
    UITextField *thirdTf;
    UITextField *forthTf;
    UIToolbar *toolbar;
    ChooseListView * dropDownView;
    
    NSMutableDictionary * selectCharacter ;
    NSMutableDictionary * selectType;
    NSArray *arrayType;
}
@end

@implementation CreateItemViewController

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
    
    [self setTopViewWithTitle:@"创建组队" withBackButton:YES];
    arrayType = [NSArray array];
    
    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [createBtn setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(createItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];


    gameInfoArray  = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    m_listDict = [NSMutableDictionary dictionary];
    m_gamePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_gamePickerView.dataSource = self;
    m_gamePickerView.delegate = self;
    m_gamePickerView.showsSelectionIndicator = YES;
    
    toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectServerNameOK:)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar.items = @[rb_server];

    
    
    firstTf = [self buildViewWithFrame:CGRectMake(0, startX, 320, 40) leftImg:@"item_1" title:@"角色" rightImg:@"arrow_bottom" RightImageSize:CGSizeMake(12.5, 8.5) placeholder:@"点击选择角色"isPicker:YES isTurn:NO tag:0];
    
    secondTf = [self buildViewWithFrame:CGRectMake(0, startX+41, 320, 40) leftImg:@"item_2" title:@"分类" rightImg:@"arrow_bottom" RightImageSize:CGSizeMake(12.5, 8.5) placeholder:@"点击选择分类"isPicker:NO isTurn:YES tag:3];
    thirdTf = [self buildViewWithFrame:CGRectMake(0, startX+82, 320, 40) leftImg:@"item_4" title:@"描述" rightImg:@"right" RightImageSize:CGSizeMake(12.5, 12.5) placeholder:@"填写描述"isPicker:NO isTurn:YES tag:1];
    forthTf =  [self buildViewWithFrame:CGRectMake(0, startX+140, 320, 40) leftImg:@"item_5" title:@"高级" rightImg:@"right" RightImageSize:CGSizeMake(12.5, 12.5) placeholder:@"高级条件"isPicker:NO isTurn:YES tag:2];

    dropDownView = [[ChooseListView alloc] initWithFrame:CGRectMake(0, startX+41, 320, 40) dataSource:self delegate:self];
    dropDownView.backgroundColor = [UIColor clearColor];
    dropDownView.mSuperView = self.view;
    [self.view addSubview:dropDownView];
    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"提交中...";

    
}
#pragma mark --
-(void) chooseAtSection:(NSInteger)index
{
    selectType = [arrayType objectAtIndex:index];
    secondTf.text = KISDictionaryHaveKey(selectType, @"value");
}
-(BOOL)onClick:(UIButton *)btn IsShow:(BOOL)isShow{
    if (isShow) {
        if(!selectCharacter){//还未选择游戏的状态
            [self showAlertViewWithTitle:@"提示" message:@"请先选择游戏角色" buttonTitle:@"OK"];
            return NO;
        }
         [[ItemManager singleton] getTeamType:KISDictionaryHaveKey(selectCharacter, @"gameid") reSuccess:^(id responseObject) {
             [self updateTeamType:responseObject];
         } reError:^(id error) {
             [self showErrorAlert:error];
         }];
        return YES;
    }
    return YES;
}
#pragma mark --
-(NSInteger)numberOfRowsInSection{
    return arrayType.count;
}
-(NSString *)titleInSection:(NSInteger) index
{
    if (arrayType.count>0) {
        return KISDictionaryHaveKey([arrayType objectAtIndex:index], @"value");
    }
    return @"";
}
-(NSInteger)defaultShowSection:(NSInteger)section
{
    return 0;
}
#pragma mark -- 分类请求成功通知
-(void)updateTeamType:(id)responseObject
{
    if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
        arrayType = responseObject;
        [dropDownView.mTableView reloadData];
    }
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

#pragma mark --创建
-(void)createItem:(id)sender
{
    if (!selectCharacter) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择游戏" buttonTitle:@"OK"];
        return;
    }
    if (!selectType) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择分类" buttonTitle:@"OK"];
        return;
    }
    if ([GameCommon isEmtity:thirdTf.text]) {
        [self showAlertViewWithTitle:@"提示" message:@"组队描述内容不能为空" buttonTitle:@"OK"];
        return;
    }
    [hud show:YES];
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"id")] forKey:@"characterId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")] forKey:@"gameid"];
    [paramDict setObject:thirdTf.text forKey:@"description"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectType, @"constId")] forKey:@"typeId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectType, @"mask")] forKey:@"maxVol"];
    [paramDict setObject:@"" forKey:@"options"];
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"265" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        //发送通知 刷新我的组队页面
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTeamList_wx" object:nil];
        [self showMessageWindowWithContent:@"创建成功" imageType:0];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self showErrorAlert:error];
        [hud hide:YES];
    }];
}

-(void)showErrorAlert:(id)error
{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }

}

//点击进入其他界面输入上传资料
-(void)enterOtherPage:(UIButton *)sender
{
    if (sender.tag ==1) {//描述
        FillInInfoViewController *fill = [[FillInInfoViewController alloc]init];
        fill.mydelegate = self;
        [self.navigationController pushViewController:fill animated:YES];
    }
    else if (sender.tag ==2)
    {
         NSLog(@"123123131231");//高级
    }
}
//点击toolbar 确定button
-(void)selectServerNameOK:(id)sender
{
    if ([gameInfoArray count] != 0) {
        selectCharacter =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];
        firstTf.text = [NSString stringWithFormat:@"%@-%@",KISDictionaryHaveKey(selectCharacter, @"simpleRealm"),KISDictionaryHaveKey(selectCharacter, @"name")];
        [firstTf resignFirstResponder];
        m_listDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"gameid")],@"gameid",[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectCharacter, @"id")],@"characterId", nil];
        
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
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"%@-%@-%@",KISDictionaryHaveKey(dic, @"simpleRealm"),KISDictionaryHaveKey(dic, @"value1"),KISDictionaryHaveKey(dic, @"name")];
    [customView addSubview:label];
    return customView;
    
}
-(void)coreBackWithVC:(FillInInfoViewController*)vc info:(NSString *)info
{
    thirdTf.text = info;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
