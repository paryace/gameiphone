//
//  BangdingRolesViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BangdingRolesViewController.h"
#import "AboutRoleCell.h"
#import "AuthViewController.h"
#import "HelpViewController.h"
@interface BangdingRolesViewController ()
{
    UITableView *m_myTableView;
    UIPickerView *m_gameNamePick;
    UIToolbar *toolbar_server1;
    NSMutableArray *gameInfoArray;
    NSMutableArray *m_dataArray;
    UIButton *m_okButton;
    NSString *m_realmStr;
    UIButton* findPasButton;
    UIButton* registerButton;
}
@end

@implementation BangdingRolesViewController

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
    self.navigationController.navigationBarHidden = YES;
    [self setTopViewWithTitle:@"绑定角色" withBackButton:NO];
    UIImageView *iageView =[[ UIImageView alloc]initWithFrame:CGRectMake(0, startX, 320, 28)];
    iageView.image = KUIImage(@"registerStep3");
    [self.view addSubview:iageView];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"选择游戏",@"name",@"",@"content",@"picker",@"type", nil];
    m_dataArray =[NSMutableArray array];
    
    [m_dataArray addObject:dic];
    gameInfoArray = [NSMutableArray new];
    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
    
    NSDictionary *dict= [[NSMutableDictionary dictionaryWithContentsOfFile:path]objectForKey:@"gamelist"];
    
    NSArray *allkeys = [dict allKeys];
    for (int i = 0; i <allkeys.count; i++) {
        NSArray *array = [dict objectForKey:allkeys[i]];
        [gameInfoArray addObjectsFromArray:array];
    }
    
    
    [self setStep_2View];
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
  
    // Do any additional setup after loading the view.
}
#pragma mark 第二步
- (void)setStep_2View
{
    UILabel* topLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, startX+28, 300, 50)];
    topLabel.numberOfLines = 2;
    topLabel.font = [UIFont boldSystemFontOfSize:12.0];
    topLabel.textColor = kColorWithRGB(128.0, 128, 128, 1.0);
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.text = @"如果您拥有多名角色，请先绑定最主要的，其他游戏角色可在注册完成之后，在设置面板中添加";
    [self.view addSubview:topLabel];
    
    
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX+88, 320, self.view.bounds.size.height-startX-44) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.scrollEnabled = NO;
    
    m_myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:m_myTableView];
    
    m_gameNamePick = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_gameNamePick.dataSource = self;
    m_gameNamePick.delegate = self;
    m_gameNamePick.showsSelectionIndicator = YES;
    
    toolbar_server1 = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar_server1.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectGameNameOK:)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar_server1.items = @[rb_server];
    
    m_okButton = [[UIButton alloc] initWithFrame:CGRectMake(10, startX +200, 300, 40)];
    [m_okButton setBackgroundImage:KUIImage(@"bindingrole") forState:UIControlStateNormal];
//    [step2Button setBackgroundImage:KUIImage(@"zhuce_click") forState:UIControlStateHighlighted];
    //    [step2Button setTitle:@"绑定上述角色" forState:UIControlStateNormal];
    [m_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    m_okButton.backgroundColor = [UIColor clearColor];
    [m_okButton addTarget:self action:@selector(step2ButtonOK:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_okButton];
    
    
    findPasButton = [[UIButton alloc] initWithFrame:CGRectMake(70, 238 + startX, 80, 40)];
    [findPasButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [findPasButton setTitleColor:kColorWithRGB(128, 128, 128, 1.0) forState:UIControlStateNormal];
    findPasButton.backgroundColor = [UIColor clearColor];
    findPasButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [findPasButton addTarget:self action:@selector(backToRegister:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:findPasButton];
    
    registerButton = [[UIButton alloc] initWithFrame:CGRectMake(150, 238 + startX, 100, 40)];
    [registerButton setTitle:@"|     遇到问题" forState:UIControlStateNormal];
    [registerButton setTitleColor:kColorWithRGB(128, 128, 128, 1.0) forState:UIControlStateNormal];
    registerButton.backgroundColor = [UIColor clearColor];
    registerButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [registerButton addTarget:self action:@selector(hitRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerButton];

    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
}

-(void)hitRegisterButton:(id)sender
{
    NSDictionary *dic = [gameInfoArray objectAtIndex:[m_gameNamePick selectedRowInComponent:0]];

    HelpViewController *helpVC = [[HelpViewController alloc]init];
    if ([KISDictionaryHaveKey(dic, @"id")intValue]==1) {
        helpVC.myUrl = @"content.html?7";
    }else{
        helpVC.myUrl = @"content.html?8";
    }
    [self.navigationController pushViewController:helpVC animated:YES];

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
        m_myTableView.frame = CGRectMake(0, startX+60+28, 320, 44*m_dataArray.count);
        m_okButton.frame = CGRectMake(10, startX+74+28+44*m_dataArray.count, 300, 40);
        registerButton.frame = CGRectMake(150,  startX+124+28+44*m_dataArray.count, 100, 40);
        findPasButton.frame = CGRectMake(70,  startX+124+28+44*m_dataArray.count, 80, 40);
        [m_myTableView reloadData];
    }
}
-(void)backToRegister:(id)sender
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"102" forKey:@"method"];//退出登陆
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"layoutresponseObject%@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        
    }];
    [GameCommon loginOut];
    
    IntroduceViewController *intro = [[IntroduceViewController alloc]init];
    intro.delegate = self.delegate;
    [self.navigationController pushViewController:intro animated:NO];

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
    m_realmStr = name;
}



#pragma  mark---- pickview选择确认键方法
- (void)step2ButtonOK:(id)sender
{
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
        
        hud.labelText = @"添加中...";
        
        NSMutableDictionary* params_two = [[NSMutableDictionary alloc]init];
        [params_two setObject:KISDictionaryHaveKey(dic, @"gameid") forKey:@"gameid"];
        [params_two setObject:KISDictionaryHaveKey(dic, @"id") forKey:@"characterId"];
        
        NSMutableDictionary* body_two = [[NSMutableDictionary alloc]init];
        [body_two addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
        [body_two setObject:params_two forKey:@"params"];
        [body_two setObject:@"262" forKey:@"method"];
        [body_two setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
        
        [NetManager requestWithURLStr:BaseClientUrl Parameters:body_two   success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [hud hide:YES];
            
            NSLog(@"%@", responseObject);
            
            [[TempData sharedInstance]isBindingRolesWithBool:NO];
            [self dismissViewControllerAnimated:YES completion:^{
            [self showMessageWindowWithContent:@"添加成功" imageType:0];
 
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

        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if ([[error objectForKey:kFailErrorCodeKey] isEqualToString:@"100014"]) {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"该角色已被其他玩家绑定，若该角色为您所有，您可点击认证将其认证到您名下"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"认证", nil];
                alert.tag =1001;
                [alert show];
            }
            else if ([[error objectForKey:kFailErrorCodeKey] isEqualToString:@"200001"]){
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
                alert.tag =1002;
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==1001) {
        if (buttonIndex ==1) {
            AuthViewController* authVC = [[AuthViewController alloc] init];
            NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gameNamePick selectedRowInComponent:0]];
            authVC.gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"gameid")];
            authVC.realm = m_realmStr;
            authVC.Type =@"register";
            UITextField *tf  = (UITextField *)[self.view viewWithTag:2+100000];
            authVC.isComeFromFirstOpen = YES;
            authVC.character = tf.text;
            
            [self.navigationController pushViewController:authVC animated:YES];
        }
    }else if(alertView.tag ==1002){
        if (buttonIndex ==1) {
            [self bindingnonerole];
        }
    }
}

-(void)bindingnonerole
{
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
    [params setObject:@"register" forKey:@"type"];
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"260" forKey:@"method"];
    [body setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ]forKey:@"token"];
    hud.labelText = @"获取中...";
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        [[TempData sharedInstance]isBindingRolesWithBool:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if ([[error objectForKey:kFailErrorCodeKey] isEqualToString:@"100014"]) {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"该角色已被其他玩家绑定，若该角色为您所有，您可点击认证将其认证到您名下"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"认证", nil];
                alert.tag =1001;
                [alert show];
            }
            else if ([[error objectForKey:kFailErrorCodeKey] isEqualToString:@"200001"]){
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag =1002;
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
