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
    UITableView *m_myTableView;
    NSMutableArray *m_dataArray;
    UIToolbar* toolbar_server;
    UIButton* m_okButton;
    AboutRoleCell *aboutRoleCell;
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

  //  [self setRoleView];
    
    gameInfoArray = [NSMutableArray new];
    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
    
    NSDictionary *dict= [[NSMutableDictionary dictionaryWithContentsOfFile:path]objectForKey:@"gamelist"];


    NSArray *allkeys = [dict allKeys];
    for (int i = 0; i <allkeys.count; i++) {
        NSArray *array = [dict objectForKey:allkeys[i]];
        [gameInfoArray addObjectsFromArray:array];
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"选择游戏",@"name",@"",@"content",@"picker",@"type", nil];
    m_dataArray =[NSMutableArray array];

    [m_dataArray addObject:dic];
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX+44, 320, self.view.bounds.size.height-startX-44) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:m_myTableView];
    
    m_serverNamePick = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_serverNamePick.dataSource = self;
    m_serverNamePick.delegate = self;
    m_serverNamePick.showsSelectionIndicator = YES;
    
    toolbar_server = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar_server.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectServerNameOK:)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar_server.items = @[rb_server];

    m_okButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 180, 300, 40)];
    [m_okButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [m_okButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [m_okButton setTitle:@"搜 索" forState:UIControlStateNormal];
    [m_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    m_okButton.backgroundColor = [UIColor clearColor];
    m_okButton.hidden = YES;
    [m_okButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_okButton];

    hud = [[MBProgressHUD alloc]initWithView:self.view];
    hud.labelText = @"搜索中...";
    [self.view addSubview:hud];
    
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
    cell.contentTF.tag = indexPath.row;
    cell.contentTF.placeholder = KISDictionaryHaveKey(dic, @"tip");
    if ([KISDictionaryHaveKey(dic, @"type")isEqualToString:@"list"]||[KISDictionaryHaveKey(dic, @"type")isEqualToString:@"picker"]) {
        cell.rightImageView.hidden = NO;
        if ([KISDictionaryHaveKey(dic, @"type")isEqualToString:@"picker"]) {
            cell.contentTF.inputView =m_serverNamePick;
            cell.contentTF.inputAccessoryView= toolbar_server;
            cell.serverButton.hidden = YES;
            cell.gameImg.hidden = NO;
            cell.gameImg.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString: KISDictionaryHaveKey(dic, @"img")]];
            m_serverNamePick.tag = indexPath.row;
            toolbar_server.tag = indexPath.row;

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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}




- (void)selectServerNameOK:(UIButton *)sender
{
    if ([gameInfoArray count] != 0) {
        NSDictionary *dict =[gameInfoArray objectAtIndex:[m_serverNamePick selectedRowInComponent:0]];

        NSMutableArray *sarchArray = [NSMutableArray array] ;
        [sarchArray removeAllObjects];
        if (self.myViewType == SEARCH_TYPE_ROLE) {
            sarchArray =[[dict objectForKey:@"gameParams" ] objectForKey:@"searchCharacterParams"];
        }else{
            sarchArray =[[dict objectForKey:@"gameParams"]objectForKey:@"searchOrganizationParams"];
            if (![sarchArray isKindOfClass:[NSArray class]]||sarchArray.count<1) {
                [self showAlertViewWithTitle:@"提示" message:@"此游戏暂不支持组织查找" buttonTitle:@"确定"];
                return;
            }
        }
        [m_dataArray removeAllObjects];
        
        NSDictionary *firstDic = [NSDictionary dictionaryWithObjectsAndKeys:@"选择游戏",@"name",[dict objectForKey:@"name"],@"content",@"picker",@"type",[dict objectForKey:@"id"],@"gameid",KISDictionaryHaveKey(dict,@"img"),@"img",nil];
        
        [m_dataArray addObject:firstDic];
        [m_dataArray addObjectsFromArray:[[dict objectForKey:@"gameParams" ] objectForKey:@"commonParams"]];
        [m_dataArray addObjectsFromArray:sarchArray];
        m_okButton.hidden = NO;
        m_myTableView.frame = CGRectMake(0, startX+44, 320, 44*m_dataArray.count);
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
    UITextField *tf = (UITextField *)[self.view viewWithTag:[num intValue]];
    tf.text = name;
}

#pragma mark 角色查找
- (void)searchButtonClick:(id)semder
{
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

- (void)okButtonClick:(UIButton *)sender
{
    [searchContent resignFirstResponder];
    [m_roleNameText resignFirstResponder];
        
    if (self.myViewType ==SEARCH_TYPE_ROLE) {
        [hud show:YES];
        NSMutableDictionary *tempDic= [ NSMutableDictionary dictionary];
        NSMutableDictionary * postDict = [NSMutableDictionary dictionary];

        for (int i =0; i<m_dataArray.count; i++) {
            NSDictionary *dic = m_dataArray[i];
            if (i==0) {
                [tempDic setObject:KISDictionaryHaveKey(dic, @"gameid") forKey:@"gameid"];
            }else{
                UITextField *tf  = (UITextField *)[self.view viewWithTag:i];
                [tempDic setObject:tf.text forKey:KISDictionaryHaveKey(dic, @"param")];
                if (!tf.text||[tf.text isEqualToString:@""]||[tf.text isEqualToString:@" "]) {
                    [self showAlertViewWithTitle:@"提示" message:@"请将信息填写完整" buttonTitle:@"确定"];
                }
                
            }
        }
        [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
        [postDict setObject:@"215" forKey:@"method"];
        [postDict setObject:tempDic forKey:@"params"];
        [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];
        [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            SearchWithGameViewController *secGame = [[SearchWithGameViewController alloc]init];
            NSArray *array = KISDictionaryHaveKey(responseObject, @"characters");
            if (array.count>0) {
            secGame.dataDic = responseObject;
            secGame.myInfoType = COME_ROLE;
            [self.navigationController pushViewController:secGame animated:YES];
            
            [hud hide:YES];
            }else{
            [self showAlertViewWithTitle:@"提示" message:@"搜索无结果" buttonTitle:@"确定"];
            }
            [hud hide:YES];
            }
         
            failure:^(AFHTTPRequestOperation *operation, id error) {
            [hud hide:YES];
                if ([error isKindOfClass:[NSDictionary class]]) {
                    if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
                    {
                        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                        [alert show];
                    }
                }

            }];
    }else{
        [hud show:YES];
    NSMutableDictionary *tempDic1= [ NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
        for (int i =0; i<m_dataArray.count; i++) {
            NSDictionary *dic = m_dataArray[i];
            if (i==0) {
                [tempDic1 setObject:KISDictionaryHaveKey(dic, @"gameid") forKey:@"gameid"];
            }else{
                UITextField *tf  = (UITextField *)[self.view viewWithTag:i];
                [tempDic1 setObject:tf.text forKey:KISDictionaryHaveKey(dic, @"param")];
                if (!tf.text||[tf.text isEqualToString:@""]||[tf.text isEqualToString:@" "]) {
                    [self showAlertViewWithTitle:@"提示" message:@"请将信息填写完整" buttonTitle:@"确定"];
                }

            }
        }

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
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
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
