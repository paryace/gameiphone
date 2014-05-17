//
//  SearchRoleViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-27.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "SearchRoleViewController.h"

@interface SearchRoleViewController ()
{
    UITextField*  m_gameNameText;
    UITextField*  m_realmText;
    
    UITextField*  m_guildNameText;
    UITextField*  m_clazzNameText;
    UIPickerView* m_clazzNamePick;

    NSMutableArray* m_clazzArray;//职业数组
    NSMutableArray* m_clazzNameArray;

    
}

@end

@implementation SearchRoleViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTopViewWithTitle:@"查找角色" withBackButton:YES];
    
    m_clazzArray = [[NSMutableArray alloc] init];
    m_clazzNameArray = [[NSMutableArray alloc] init];
    
    if ([[GameCommon shareGameCommon].wow_clazzs count] != 0) {
        [m_clazzArray addObjectsFromArray:[GameCommon shareGameCommon].wow_clazzs];
        for (NSDictionary* tempDic in m_clazzArray) {
            [m_clazzNameArray addObject:KISDictionaryHaveKey(tempDic, @"name")];
        }
        
        [self setMainView];
    }
    else
    {
       // [self firtOpen];
    }
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"请求中...";
    [self.view bringSubviewToFront:hud];
}

#pragma mark 开机联网
/*
-(void)firtOpen
{
    [hud show:YES];
    NSMutableDictionary * paramsDic = [NSMutableDictionary dictionary];
    
    [paramsDic setObject:@"" forKey:@"gamelist_millis"];
    [paramsDic setObject:@"" forKey:@"wow_realms_millis"];
    [paramsDic setObject:@"" forKey:@"wow_characterclasses_millis"];
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramsDic forKey:@"params"];
    [postDict setObject:@"142" forKey:@"method"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide: YES];
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            return ;
        }
        NSMutableDictionary* openData = [[NSUserDefaults standardUserDefaults] objectForKey:kOpenData] ? [[NSUserDefaults standardUserDefaults] objectForKey:kOpenData] : [NSMutableDictionary dictionaryWithCapacity:1];
        if ([KISDictionaryHaveKey(responseObject, @"gamelist_update") boolValue]) {
            [openData setObject:KISDictionaryHaveKey(responseObject, @"gamelist") forKey:@"gamelist"];
            [openData setObject:KISDictionaryHaveKey(responseObject, @"gamelist_millis") forKey:@"gamelist_millis"];
        }
        if ([KISDictionaryHaveKey(responseObject, @"wow_characterclasses_update") boolValue]) {
            [openData setObject:KISDictionaryHaveKey(responseObject, @"wow_characterclasses") forKey:@"wow_characterclasses"];
            [openData setObject:KISDictionaryHaveKey(responseObject, @"wow_characterclasses_millis") forKey:@"wow_characterclasses_millis"];
        }
        if ([KISDictionaryHaveKey(responseObject, @"wow_realms_update") boolValue]) {
            [openData setObject:KISDictionaryHaveKey(responseObject, @"wow_realms") forKey:@"wow_realms"];
            [openData setObject:KISDictionaryHaveKey(responseObject, @"wow_realms_millis") forKey:@"wow_realms_millis"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:openData forKey:kOpenData];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([KISDictionaryHaveKey(openData, @"wow_realms") isKindOfClass:[NSDictionary class]]) {//注册服务器数据
            [[GameCommon shareGameCommon].wow_realms addEntriesFromDictionary:KISDictionaryHaveKey(openData, @"wow_realms")];
        }
        if ([KISDictionaryHaveKey(openData, @"wow_characterclasses") isKindOfClass:[NSArray class]]) {
            [[GameCommon shareGameCommon].wow_clazzs addObjectsFromArray:KISDictionaryHaveKey(openData, @"wow_characterclasses")];
        }
        [m_clazzArray addObjectsFromArray:[GameCommon shareGameCommon].wow_clazzs];
        for (NSDictionary* tempDic in m_clazzArray) {
            [m_clazzNameArray addObject:KISDictionaryHaveKey(tempDic, @"name")];
        }
        [self setMainView];
       
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide: YES];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}
*/
- (void)setMainView
{
    UIImageView* table_top = [[UIImageView alloc] initWithFrame:CGRectMake(10, startX + 20, 300, 40)];
    table_top.image = KUIImage(@"table_top");
    [self.view addSubview:table_top];
    
    UIImageView* table_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(290, startX + 36, 12, 8)];
    table_arrow.image = KUIImage(@"arrow_bottom");
    [self.view addSubview:table_arrow];
    
    UIImageView* table_middle = [[UIImageView alloc] initWithFrame:CGRectMake(10, startX + 60, 300, 40)];
    table_middle.image = KUIImage(@"table_middle");
    [self.view addSubview:table_middle];
    
    UIImageView* table_arrow_two = [[UIImageView alloc] initWithFrame:CGRectMake(290, startX + 76, 12, 8)];
    table_arrow_two.image = KUIImage(@"arrow_bottom");
    [self.view addSubview:table_arrow_two];
    
    UIImageView* table_middle_two = [[UIImageView alloc] initWithFrame:CGRectMake(10, startX + 100, 300, 40)];
    table_middle_two.image = KUIImage(@"table_middle");
    [self.view addSubview:table_middle_two];
    
    UIImageView* table_bottom = [[UIImageView alloc] initWithFrame:CGRectMake(10, startX + 140, 300, 40)];
    table_bottom.image = KUIImage(@"table_bottom");
    [self.view addSubview:table_bottom];
    
    UIImageView* table_arrow_three = [[UIImageView alloc] initWithFrame:CGRectMake(290, startX + 156, 12, 8)];
    table_arrow_three.image = KUIImage(@"arrow_bottom");
    [self.view addSubview:table_arrow_three];
    
    UILabel* table_label_one = [[UILabel alloc] initWithFrame:CGRectMake(20, startX + 21, 100, 38)];
    table_label_one.text = @"选择游戏";
    table_label_one.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_one.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:table_label_one];
    
    UILabel* table_label_two = [[UILabel alloc] initWithFrame:CGRectMake(20, startX + 61, 80, 38)];
    table_label_two.text = @"所在服务器";
    table_label_two.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_two.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:table_label_two];
    
    UILabel* table_label_three = [[UILabel alloc] initWithFrame:CGRectMake(20, startX + 101, 80, 38)];
    table_label_three.text = @"公会名称";
    table_label_three.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_three.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:table_label_three];
    
    UILabel* table_label_four = [[UILabel alloc] initWithFrame:CGRectMake(20, startX + 141, 80, 38)];
    table_label_four.text = @"职业";
    table_label_four.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_four.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:table_label_four];
    
    UIImageView* gameImg = [[UIImageView alloc] initWithFrame:CGRectMake(190, startX + 31, 18, 18)];
    gameImg.image = KUIImage(@"wow");
    [self.view addSubview:gameImg];
    
    m_gameNameText = [[UITextField alloc] initWithFrame:CGRectMake(100, startX + 20, 180, 40)];
    m_gameNameText.returnKeyType = UIReturnKeyDone;
    m_gameNameText.delegate = self;
    m_gameNameText.text = @"魔兽世界";
    m_gameNameText.textAlignment = NSTextAlignmentRight;
    m_gameNameText.font = [UIFont boldSystemFontOfSize:15.0];
    m_gameNameText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_gameNameText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:m_gameNameText];
    
    m_realmText = [[UITextField alloc] initWithFrame:CGRectMake(100, 60 + startX, 180, 40)];
    m_realmText.returnKeyType = UIReturnKeyDone;
    m_realmText.delegate = self;
    m_realmText.text = self.getRealmName;
    m_realmText.textAlignment = NSTextAlignmentRight;
    m_realmText.font = [UIFont boldSystemFontOfSize:15.0];
    m_realmText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_realmText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:m_realmText];
    
    UIButton* serverButton = [[UIButton alloc] initWithFrame:CGRectMake(100, startX + 60, 180, 40)];
    serverButton.backgroundColor = [UIColor clearColor];
    [serverButton addTarget:self action:@selector(realmSelectClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:serverButton];
    
    m_guildNameText = [[UITextField alloc] initWithFrame:CGRectMake(100, startX + 100, 180, 40)];
    m_guildNameText.returnKeyType = UIReturnKeyDone;
    m_guildNameText.delegate = self;
    m_guildNameText.textAlignment = NSTextAlignmentRight;
    m_guildNameText.font = [UIFont boldSystemFontOfSize:15.0];
    m_guildNameText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_guildNameText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:m_guildNameText];
    
    m_clazzNameText = [[UITextField alloc] initWithFrame:CGRectMake(100, startX + 140, 180, 40)];
    m_clazzNameText.returnKeyType = UIReturnKeyDone;
    m_clazzNameText.delegate = self;
    m_clazzNameText.textAlignment = NSTextAlignmentRight;
    m_clazzNameText.font = [UIFont boldSystemFontOfSize:15.0];
    m_clazzNameText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_clazzNameText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:m_clazzNameText];
    
    m_clazzNamePick = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_clazzNamePick.dataSource = self;
    m_clazzNamePick.delegate = self;
    m_clazzNamePick.showsSelectionIndicator = YES;
    m_clazzNameText.inputView = m_clazzNamePick;//点击弹出的是pickview
    
//    m_clazzNamePick = [[UIPickerView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-200, 320, 200)];
//    m_clazzNamePick.dataSource = self;
//    m_clazzNamePick.delegate = self;
//    m_clazzNamePick.showsSelectionIndicator = YES;
//    //m_clazzNameText.inputView = m_clazzNamePick;//点击弹出的是pickview
//    [self.view.window addSubview:m_clazzNamePick];
//    
    
    UIToolbar* toolbar_server = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar_server.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectClazzNameOK)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar_server.items = @[rb_server];
    m_clazzNameText.inputAccessoryView = toolbar_server;//跟着pickview上移
    
    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(10, startX + 200, 300, 40)];
    [okButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [okButton setTitle:@"查找相关角色" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor clearColor];
    [okButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okButton];
    
    UILabel* bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, startX + 240, 300, 40)];
    bottomLabel.numberOfLines = 2;
    bottomLabel.font = [UIFont boldSystemFontOfSize:12.0];
    bottomLabel.textColor = kColorWithRGB(128.0, 128, 128, 1.0);
    bottomLabel.text = @"若公会名过于生僻无法输入，请尝试复制粘贴等方式";
    bottomLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomLabel];
}


- (void)realmSelectClick:(id)sender
{
    RealmsSelectViewController* realmVC = [[RealmsSelectViewController alloc] init];
    realmVC.realmSelectDelegate = self;
    [self.navigationController pushViewController:realmVC animated:YES];
}

-(void)selectOneRealmWithName:(NSString *)name
{
    m_realmText.text = name;
}

- (void)selectClazzNameOK
{
    [m_gameNameText resignFirstResponder];
    if ([m_clazzNameArray count] != 0) {
        m_gameNameText.text = [m_clazzNameArray objectAtIndex:[m_clazzNamePick selectedRowInComponent:0]];
    }
    else
        m_clazzNameText.text = @"";
    //m_clazzNamePick =nil;
}

- (void)okButtonClick:(id)sender
{
    [m_clazzNameText resignFirstResponder];
    [m_guildNameText resignFirstResponder];
    
    if (KISEmptyOrEnter(m_realmText.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择服务器" buttonTitle:@"确定"];
        return;
    }
    if (KISEmptyOrEnter(m_guildNameText.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请输入公会名" buttonTitle:@"确定"];
        return;
    }
    if (KISEmptyOrEnter(m_clazzNameText.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择职业" buttonTitle:@"确定"];
        return;
    }
    
//    if (m_clazzNamePick !=nil) {
//        NSLog(@"123");
//        m_clazzNamePick =nil;
//        return;
//    }
    NSLog(@"picker%@",m_clazzNamePick);
    
    NSString* clazzId = [[m_clazzArray objectAtIndex:[m_clazzNamePick selectedRowInComponent:0]] objectForKey:@"id"];
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:@"1" forKey:@"gameid"];
    [params setObject:m_realmText.text forKey:@"realm"];
    [params setObject:m_guildNameText.text forKey:@"guild"];
    [params setObject:clazzId forKey:@"classid"];

    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"122" forKey:@"method"];
//    [body setObject:@"D8AE3A8AE4634E799029AF2BFB5B13DD" forKey:@"token"];
    
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];

        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            return;
        }
        ListRoleViewController* listVC = [[ListRoleViewController alloc] init];
        listVC.guildStr = m_guildNameText.text;
        listVC.dataDic = responseObject;
        listVC.myDelegate = self;
        [self.navigationController pushViewController:listVC animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if ([[error objectForKey:kFailErrorCodeKey] isEqualToString:@"100014"]) {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"认证", nil];
                alert.tag = 18;
                [alert show];
            }
            else if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];
}

#pragma mark 角色选择成功
- (void)selectRoleOKWithName:(NSString*)role
{
    [self.searchDelegate searchRoleSuccess:role realm:m_realmText.text];
}

#pragma mark 选择器
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [m_clazzNameArray count];
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger) row forComponent:(NSInteger) component
{
    return [m_clazzNameArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == m_clazzNamePick) {
        m_clazzNameText.text = [m_clazzNameArray objectAtIndex:[m_clazzNamePick selectedRowInComponent:0]];

    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == m_gameNameText) {
        [self showAlertViewWithTitle:@"提示" message:@"暂不支持其他游戏" buttonTitle:@"确定"];
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [m_gameNameText resignFirstResponder];
    [m_realmText resignFirstResponder];
    [m_guildNameText resignFirstResponder];
    [m_clazzNameText resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
