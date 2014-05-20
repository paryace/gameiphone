//
//  SearchJSViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-5-17.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SearchJSViewController.h"
#import "SearchRoleViewController.h"
#import "SearchWithGameViewController.h"
#import "HelpViewController.h"
#import "EGOImageView.h"
@interface SearchJSViewController ()
{
    UIScrollView *m_roleView;
    UITextField *m_gameNameText;
    UITextField *searchContent;
    UITextField *m_roleNameText;
    UIPickerView *m_serverNamePick;
    NSMutableArray *gameInfoArray;
    EGOImageView* gameImg;
    UILabel* table_label_two;
    UILabel* table_label_three;
}
@end

@implementation SearchJSViewController

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
    if (self.myViewType ==SEARCH_TYPE_ROLE) {
        [self setTopViewWithTitle:@"查找游戏角色" withBackButton:YES];
    }else{
        [self setTopViewWithTitle:@"搜索游戏组织" withBackButton:YES];
    }
    
    
    m_roleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-(KISHighVersion_7?0:20))];
    m_roleView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_roleView];

    [self setRoleView];
    
    gameInfoArray = [NSMutableArray new];
    gameInfoArray = [[[NSUserDefaults standardUserDefaults]objectForKey:kOpenData]objectForKey:@"gamelist"];
}
- (void)setRoleView
{
   
    
    UIImageView* table_top = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 300, 40)];
    table_top.image = KUIImage(@"table_top");
    [m_roleView addSubview:table_top];
    
    UIImageView* table_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(290, 36, 12, 8)];
    table_arrow.image = KUIImage(@"arrow_bottom");
    [m_roleView addSubview:table_arrow];
    
    UIImageView* table_middle = [[UIImageView alloc] initWithFrame:CGRectMake(10, 60, 300, 40)];
    table_middle.image = KUIImage(@"table_middle");
    [m_roleView addSubview:table_middle];
    
    UIImageView* table_arrow_two = [[UIImageView alloc] initWithFrame:CGRectMake(290, 76, 12, 8)];
    table_arrow_two.image = KUIImage(@"arrow_bottom");
    [m_roleView addSubview:table_arrow_two];
    
    UIImageView* table_bottom = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 300, 40)];
    table_bottom.image = KUIImage(@"table_bottom");
    [m_roleView addSubview:table_bottom];
    
    UILabel* table_label_one = [[UILabel alloc] initWithFrame:CGRectMake(20, 21, 100, 38)];
    table_label_one.text = @"选择游戏";
    table_label_one.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_one.font = [UIFont boldSystemFontOfSize:15.0];
    [m_roleView addSubview:table_label_one];
    
    table_label_two = [[UILabel alloc] initWithFrame:CGRectMake(20, 61, 80, 38)];
    table_label_two.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_two.font = [UIFont boldSystemFontOfSize:15.0];
    [m_roleView addSubview:table_label_two];
    
    table_label_three = [[UILabel alloc] initWithFrame:CGRectMake(20, 101, 80, 38)];
    table_label_three.textColor = kColorWithRGB(102, 102, 102, 1.0);
    table_label_three.font = [UIFont boldSystemFontOfSize:15.0];
    [m_roleView addSubview:table_label_three];
    table_label_two.hidden = YES;
    table_label_three.hidden = YES;
    
    
    gameImg = [[EGOImageView alloc] initWithFrame:CGRectMake(180, 31, 18, 18)];
    [m_roleView addSubview:gameImg];
    
    m_gameNameText = [[UITextField alloc] initWithFrame:CGRectMake(100, 20, 180, 40)];
    m_gameNameText.returnKeyType = UIReturnKeyDone;
    m_gameNameText.delegate = self;
    m_gameNameText.textAlignment = NSTextAlignmentRight;
    m_gameNameText.font = [UIFont boldSystemFontOfSize:15.0];
    m_gameNameText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_gameNameText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [m_roleView addSubview:m_gameNameText];
    
    
    m_serverNamePick = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_serverNamePick.dataSource = self;
    m_serverNamePick.delegate = self;
    m_serverNamePick.showsSelectionIndicator = YES;
    m_gameNameText.inputView = m_serverNamePick;//点击弹出的是pickview
    
    UIToolbar* toolbar_server = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar_server.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectServerNameOK)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar_server.items = @[rb_server];
    m_gameNameText.inputAccessoryView = toolbar_server;//跟着pickview上移

    
    searchContent = [[UITextField alloc] initWithFrame:CGRectMake(100, 60, 180, 40)];
    searchContent.returnKeyType = UIReturnKeyDone;
    searchContent.textAlignment = NSTextAlignmentRight;
    searchContent.delegate = self;
    searchContent.font = [UIFont boldSystemFontOfSize:15.0];
    searchContent.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    searchContent.clearButtonMode = UITextFieldViewModeWhileEditing;
    [m_roleView addSubview:searchContent];
    
    UIButton* serverButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 60, 180, 40)];
    serverButton.backgroundColor = [UIColor clearColor];
    [serverButton addTarget:self action:@selector(realmSelectClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_roleView addSubview:serverButton];
    //
    
    m_roleNameText = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 180, 40)];
    m_roleNameText.returnKeyType = UIReturnKeyDone;
    m_roleNameText.delegate = self;
    m_roleNameText.textAlignment = NSTextAlignmentRight;
    m_roleNameText.font = [UIFont boldSystemFontOfSize:15.0];
    m_roleNameText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_roleNameText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [m_roleView addSubview:m_roleNameText];
    
//    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 160, 300, 40)];
//    [okButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
//    [okButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
//    [okButton setTitle:@"搜 索" forState:UIControlStateNormal];
//    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    okButton.backgroundColor = [UIColor clearColor];
//    [okButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [m_roleView addSubview:okButton];
    
//    UILabel* bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 205, 300, 40)];
//    bottomLabel.numberOfLines = 2;
//    bottomLabel.backgroundColor = [UIColor clearColor];
//    bottomLabel.font = [UIFont boldSystemFontOfSize:12.0];
//    bottomLabel.textColor = kColorWithRGB(128.0, 128, 128, 1.0);
//    bottomLabel.text = @"繁体字可使用手写输入法，角色名过于生僻无法输入时，可尝试";
//    [m_roleView addSubview:bottomLabel];
//    
//    UIButton* searchBtn = [CommonControlOrView setButtonWithFrame:CGRectMake(60, 227, 70, 15) title:@"查找不到?" fontSize:Nil textColor:nil bgImage:KUIImage(@"") HighImage:KUIImage(@"") selectImage:nil];
//    searchBtn.backgroundColor = [UIColor clearColor];
//    [searchBtn addTarget:self action:@selector(searchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [m_roleView addSubview:searchBtn];
    
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"搜索中...";
}

- (void)selectServerNameOK
{
    [m_gameNameText resignFirstResponder];
    if ([gameInfoArray count] != 0) {
        NSDictionary *dict =[gameInfoArray objectAtIndex:[m_serverNamePick selectedRowInComponent:0]];
        m_gameNameText.text = [dict objectForKey:@"name"];
        
        gameImg.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[dict objectForKey:@"img"]]];
        table_label_two.hidden = NO;
        table_label_three.hidden = NO;
        NSArray *sarchArray ;
        if (self.myViewType == SEARCH_TYPE_ROLE) {
            sarchArray =[[dict objectForKey:@"gameParams" ] objectForKey:@"searchCharacterParams"];
        }else{
            sarchArray =[[dict objectForKey:@"gameParams"]objectForKey:@"searchOrganizationParams"];
        }
        table_label_two.text = [[[[dict objectForKey:@"gameParams" ] objectForKey:@"commonParams"] objectAtIndex:0]objectForKey:@"name"];
        searchContent.placeholder =[[[[dict objectForKey:@"gameParams" ] objectForKey:@"commonParams"]objectAtIndex:0] objectForKey:@"tip"];
        
        table_label_three.text = [[sarchArray objectAtIndex:0] objectForKey:@"name"];
        m_roleNameText.placeholder =[[sarchArray objectAtIndex:0] objectForKey:@"tip"];
        
        NSLog(@"----%@-----%@",m_roleNameText.placeholder,searchContent.placeholder);
        
    }
    else
        m_gameNameText.text = @"";
    //m_clazzNamePick =nil;
}
- (void)realmSelectClick:(id)sender
{
    if ([m_gameNameText.text isEqualToString:@""]||m_gameNameText.text ==nil) {
        [self showAlertViewWithTitle:@"提示" message:@"请先选择游戏" buttonTitle:@"确定"];
        return;
    }

    RealmsSelectViewController* realmVC = [[RealmsSelectViewController alloc] init];
    realmVC.realmSelectDelegate = self;
    realmVC.gameNum = [[gameInfoArray objectAtIndex:[m_serverNamePick selectedRowInComponent:0]]objectForKey:@"id"];
    [self.navigationController pushViewController:realmVC animated:YES];
}
- (void)selectOneRealmWithName:(NSString *)name
{
    searchContent.text = name;
}

#pragma mark 角色查找
- (void)searchButtonClick:(id)semder
{
//    SearchRoleViewController* searchVC = [[SearchRoleViewController alloc] init];
//    searchVC.searchDelegate = self;
//    searchVC.getRealmName = searchContent.text;
//    [self.navigationController pushViewController:searchVC animated:YES];
    HelpViewController *helpVC = [[HelpViewController alloc]init];
    if (self.myViewType ==SEARCH_TYPE_ROLE) {
        helpVC.myUrl = @"content.html?4";
    }else{
        helpVC.myUrl = @"content.html?4";
    }
    [self.navigationController pushViewController:helpVC animated:YES];

}

- (void)searchRoleSuccess:(NSString*)roleName realm:(NSString*)realm
{
    m_roleNameText.text = roleName;
    searchContent.text = realm;
}

- (void)okButtonClick:(id)sender
{
    [searchContent resignFirstResponder];
    [m_roleNameText resignFirstResponder];
    
    if (KISEmptyOrEnter(searchContent.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请把搜索内容填写完整！" buttonTitle:@"确定"];
        return;
    }
    else if(self.myViewType == SEARCH_TYPE_ROLE && KISEmptyOrEnter(m_roleNameText.text))
    {
        [self showAlertViewWithTitle:@"提示" message:@"请把搜索内容填写完整！" buttonTitle:@"确定"];
        return;
    }
    
    NSDictionary *dic = [gameInfoArray objectAtIndex:[m_serverNamePick selectedRowInComponent:0]];
    
    NSArray *roleArray = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"gameParams"), @"commonParams");

    if (self.myViewType ==SEARCH_TYPE_ROLE) {
        
        NSArray* sarchArray =[[dic objectForKey:@"gameParams" ] objectForKey:@"searchCharacterParams"];

        
        
        NSMutableDictionary *tempDic= [ NSMutableDictionary dictionary];
        NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
        
        [tempDic setObject:searchContent.text forKey:KISDictionaryHaveKey(roleArray[0], @"param")];
        [tempDic setObject:KISDictionaryHaveKey(dic,@"id") forKey:@"gameid"];
        [tempDic setObject:m_roleNameText.text  forKey:KISDictionaryHaveKey([sarchArray objectAtIndex:0], @"param")];
        
        [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
        [postDict setObject:@"215" forKey:@"method"];
        [postDict setObject:tempDic forKey:@"params"];
        [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];
        [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            SearchWithGameViewController *secGame = [[SearchWithGameViewController alloc]init];
            NSArray *array = KISDictionaryHaveKey(responseObject, @"characters");
            if (array.count>0) {

            secGame.dataDic = responseObject;
            secGame.realmStr = searchContent.text;
            secGame.myInfoType = COME_ROLE;
            [self.navigationController pushViewController:secGame animated:YES];
            
            [hud hide:YES];
            }else{
            [self showAlertViewWithTitle:@"提示" message:@"搜索无结果" buttonTitle:@"确定"];
            }
            }
            failure:^(AFHTTPRequestOperation *operation, id error) {
            [hud hide:YES];
                              }];
    }else{
    NSArray* sarchArray =[[dic objectForKey:@"gameParams" ] objectForKey:@"searchOrganizationParams"];

    NSMutableDictionary *tempDic1= [ NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [tempDic1 setObject:KISDictionaryHaveKey(dic, @"id") forKey:@"gameid"];
    [tempDic1 setObject: searchContent.text forKey:KISDictionaryHaveKey(roleArray[0], @"param")];
    [tempDic1 setObject:m_roleNameText.text forKey:KISDictionaryHaveKey(sarchArray[0], @"param")];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"217" forKey:@"method"];
    [postDict setObject:tempDic1 forKey:@"params"];

    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];
        
        [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [hud hide:YES];
            SearchWithGameViewController *secGame = [[SearchWithGameViewController alloc]init];
            
            NSArray *array = KISDictionaryHaveKey(responseObject, @"guilds");
            if (array.count>0) {
            secGame.dataDic = [NSDictionary new];
            secGame.dataDic = responseObject;
            secGame.realmStr = searchContent.text;
            secGame.myInfoType = COME_GUILD;
            [self.navigationController pushViewController:secGame animated:YES];
            }else{
                [self showAlertViewWithTitle:@"提示" message:@"搜索无结果" buttonTitle:@"确定"];
                return ;
            }
        }
    failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
    }];
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


#pragma mark textField
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField ==m_roleNameText) {
        [self okButtonClick:nil];
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == m_roleNameText&&(m_gameNameText.text ==nil||[m_gameNameText.text isEqualToString:@""]||[m_gameNameText.text isEqualToString:NULL])) {
        [self showAlertViewWithTitle:@"提示" message:@"请先选择游戏" buttonTitle:@"确定"];
        return NO;
    }
    return YES;
}
#pragma mark 手势
- (void)tapTopViewClick:(id)sender
{
    [m_gameNameText resignFirstResponder];
    [searchContent resignFirstResponder];
    [m_roleNameText resignFirstResponder];
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
