//
//  AddCharacterViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-23.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "AddCharacterViewController.h"
#import "EGOImageView.h"
#import "AboutRoleCell.h"
#import "ImageService.h"
#import "HelpViewController.h"
#import "SelectGameView.h"
@interface AddCharacterViewController ()
{
//    UITextField*  m_gameNameText;
//    UITextField*  m_realmText;
//    UITextField*  m_roleNameText;
    UIAlertView* alertView1;
    BOOL          isRefresh;//从认证界面成功后  直接提交
    UIPickerView *m_serverNamePick;
    EGOImageView* gameImg;
    NSMutableArray *gameInfoArray;
    UILabel* table_label_two;
    UILabel * table_label_three;
    UITableView *m_myTableView;
    NSMutableArray *m_dataArray;
    UIToolbar* toolbar_server;
    UIButton* m_okButton;
    AboutRoleCell *aboutRoleCell;
    UILabel *helplable;
 
    NSMutableArray *nameArray;
    NSMutableArray *imgArray;
    
    SelectGameView *selectGameView;
}

@end

@implementation AddCharacterViewController


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isRefresh) {
//        isRefresh = NO;
        switch (self.viewType) {
            case CHA_TYPE_Add:
                break;
            case CHA_TYPE_Change:
                [self changeByNetWithDictionary:nil];
                break;
            default:
                break;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
//    [GameCommon shareGameCommon].selectRealm = @"";
    
    isRefresh = NO;
    
    switch (self.viewType) {
        case CHA_TYPE_Add:
            [self setTopViewWithTitle:@"添加角色" withBackButton:YES];
            break;
        case CHA_TYPE_Change:
            [self setTopViewWithTitle:@"修改角色" withBackButton:YES];
            break;
        default:
            break;
    }
    
    gameInfoArray = [NSMutableArray array];
    [[GameListManager singleton] getGameListFromLocal:^(id responseObject) {
        if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
            [gameInfoArray addObjectsFromArray:responseObject];
        }
    } reError:^(id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
    
#pragma mark --------------添加namearray和imgarray
    nameArray = [NSMutableArray array];
    imgArray = [NSMutableArray array];
    for (int i=0; i<[gameInfoArray count]; i++) {
        NSDictionary * dic = [gameInfoArray objectAtIndex:i];
        NSString * name = [dic objectForKey:@"name"];
        NSString * img = [dic objectForKey:@"img"];
        [nameArray addObject:name];
        [imgArray addObject:img];
    }

//    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
//    NSMutableDictionary* dict= [[NSMutableDictionary dictionaryWithContentsOfFile:path]objectForKey:@"gamelist"];
//    NSArray *allkeys = [dict allKeys];
//    for (int i = 0; i <allkeys.count; i++) {
//        NSArray *array = [dict objectForKey:allkeys[i]];
//        [gameInfoArray addObjectsFromArray:array];
//    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"选择游戏",@"name",@"",@"content",@"picker",@"type", nil];
    m_dataArray =[NSMutableArray array];
    [m_dataArray addObject:dic];
    
    UIImageView *imageView =[[ UIImageView alloc]initWithFrame:CGRectMake(5, startX+5, 30, 30)];
    imageView.image = KUIImage(@"role_add_title");
    [self.view addSubview:imageView];
    
    UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(40, startX+5, 200, 30)];
    lb.backgroundColor = [UIColor clearColor];
    lb.textColor = [UIColor  grayColor];
    lb.text = @"添加游戏角色";
    lb.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:lb];

    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX+44, 320, self.view.bounds.size.height-startX-44) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.scrollEnabled = NO;

    m_myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:m_myTableView];
    
    m_serverNamePick = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_serverNamePick.dataSource = self;
    m_serverNamePick.delegate = self;
    m_serverNamePick.showsSelectionIndicator = YES;
    
//    toolbar_server = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
//    toolbar_server.tintColor = [UIColor blackColor];
//    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectServerNameOK:)];
//    rb_server.tintColor = [UIColor blackColor];
//    toolbar_server.items = @[rb_server];
    
    m_okButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 180, 300, 40)];
    [m_okButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [m_okButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    switch (self.viewType) {
        case CHA_TYPE_Add:
            [m_okButton setTitle:@"添 加" forState:UIControlStateNormal];
            break;
        case CHA_TYPE_Change:
        {
            [m_okButton setTitle:@"修 改" forState:UIControlStateNormal];
        } break;
        default:
            break;
    }
    
    helplable = [[UILabel alloc]initWithFrame:CGRectMake(10, startX+35+65, 280, 30)];
    helplable.backgroundColor =[ UIColor clearColor];
    helplable.textColor =kColorWithRGB(41, 164, 246, 1.0);
    helplable.font = [UIFont systemFontOfSize:12];
    helplable.textAlignment = NSTextAlignmentRight;
    helplable.text = @"角色为何无法添加/绑定?";
    helplable.userInteractionEnabled = YES;
    helplable.hidden =YES;
    [helplable addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterHelp:)]];
    [self.view addSubview:helplable];
    
    
    
    [m_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    m_okButton.backgroundColor = [UIColor clearColor];
    m_okButton.hidden = YES;
    [m_okButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_okButton];

    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    hud.labelText = @"请求中..";
    [self.view addSubview:hud];
    
    
    selectGameView = [[SelectGameView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    selectGameView.selectGameDelegate = self;
    selectGameView.titleView.text = @"选择游戏";
    selectGameView.backgroundColor = [UIColor whiteColor];
    [selectGameView setDateWithNameArray:nameArray andImg:imgArray];
    [self.view addSubview:selectGameView];
    
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
    
    if ([KISDictionaryHaveKey(dic, @"type")isEqualToString:@"list"]||[KISDictionaryHaveKey(dic, @"type")isEqualToString:@"picker"]) {
        cell.rightImageView.hidden = NO;
        if ([KISDictionaryHaveKey(dic, @"type")isEqualToString:@"picker"]) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickSelectGame:)];
            [cell.contentTF addGestureRecognizer:tap];
            cell.serverButton.hidden = YES;
            cell.gameImg.hidden = NO;
            cell.rightImageView.enabled = NO;
            NSString * imageId=KISDictionaryHaveKey(dic, @"img");
            cell.gameImg.imageURL=[ImageService getImageUrl4:imageId];

            
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
- (void)clickSelectGame:(id)sender
{
    [selectGameView showSelf];
    
}
#pragma mark -------选择游戏界面的代理
-(void)selectGame:(NSInteger)characterDic
{
    UITextField *tf = (UITextField *)[self.view viewWithTag:2];
    [tf resignFirstResponder];
    if ([gameInfoArray count] != 0) {
        NSDictionary *dict =[gameInfoArray objectAtIndex:characterDic];
        //  m_gameNameText.text = [dict objectForKey:@"name"];
        NSArray *sarchArray ;
        sarchArray =[[dict objectForKey:@"gameParams"]objectForKey:@"bindCharacterParams"];
        
        
        [m_dataArray removeAllObjects];
        
        NSDictionary *firstDic = [NSDictionary dictionaryWithObjectsAndKeys:@"选择游戏",@"name",[dict objectForKey:@"name"],@"content",@"picker",@"type",[dict objectForKey:@"id"],@"gameid",KISDictionaryHaveKey(dict,@"img"),@"img",nil];
        
        [m_dataArray addObject:firstDic];
        [m_dataArray addObjectsFromArray:[[dict objectForKey:@"gameParams" ] objectForKey:@"commonParams"]];
        [m_dataArray addObjectsFromArray:sarchArray];
        m_okButton.hidden = NO;
        m_myTableView.frame = CGRectMake(0, startX+44, 320, 44*m_dataArray.count);
        helplable.hidden =NO;
        helplable.frame = CGRectMake(10, startX+64+44*m_dataArray.count, 280, 30);
        m_okButton.frame = CGRectMake(10, startX+94+44*m_dataArray.count, 300, 40);
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

- (void)okButtonClick:(id)sender
{
    
//    if (KISEmptyOrEnter(m_realmText.text)) {
//        [self showAlertViewWithTitle:@"提示" message:@"请选择服务器！" buttonTitle:@"确定"];
//        return;
//    }
//    if (KISEmptyOrEnter(m_roleNameText.text)) {
//        [self showAlertViewWithTitle:@"提示" message:@"请输入角色名！" buttonTitle:@"确定"];
//        return;
//    }
    [self isHaveThisRole];
}

#pragma mark ----选定角色
- (void)selectServerNameOK:(UIButton *)sender
{
    
    // [m_gameNameText resignFirstResponder];
    if ([gameInfoArray count] != 0) {
        NSDictionary *dict =[gameInfoArray objectAtIndex:[m_serverNamePick selectedRowInComponent:0]];
        //  m_gameNameText.text = [dict objectForKey:@"name"];
        NSArray *sarchArray ;
        sarchArray =[[dict objectForKey:@"gameParams"]objectForKey:@"bindCharacterParams"];

        
        [m_dataArray removeAllObjects];
        
        NSDictionary *firstDic = [NSDictionary dictionaryWithObjectsAndKeys:@"选择游戏",@"name",[dict objectForKey:@"name"],@"content",@"picker",@"type",[dict objectForKey:@"id"],@"gameid",KISDictionaryHaveKey(dict,@"img"),@"img",nil];
        
        [m_dataArray addObject:firstDic];
        [m_dataArray addObjectsFromArray:[[dict objectForKey:@"gameParams" ] objectForKey:@"commonParams"]];
        [m_dataArray addObjectsFromArray:sarchArray];
        m_okButton.hidden = NO;
        m_myTableView.frame = CGRectMake(0, startX+44, 320, 44*m_dataArray.count);
        helplable.hidden =NO;
        helplable.frame = CGRectMake(10, startX+64+44*m_dataArray.count, 280, 30);
        m_okButton.frame = CGRectMake(10, startX+94+44*m_dataArray.count, 300, 40);
        [m_myTableView reloadData];
    }

    
    
    
    
}

#pragma mark ---判断角色是否存在
-(void)isHaveThisRole
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    for (int i =0; i<m_dataArray.count; i++) {
        NSDictionary *dic = m_dataArray[i];
        if (i==0) {
            [params setObject:KISDictionaryHaveKey(dic, @"gameid") forKey:@"gameid"];
        }else{
            UITextField *tf  = (UITextField *)[self.view viewWithTag:i];
            [params setObject:tf.text forKey:KISDictionaryHaveKey(dic, @"param")];
            [tf resignFirstResponder];
            if (!tf.text||[tf.text isEqualToString:@""]||[tf.text isEqualToString:@" "]) {
                [self showAlertViewWithTitle:@"提示" message:@"请将信息填写完整" buttonTitle:@"确定"];
                return;
            }
        }
    }
    
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"115" forKey:@"method"];
    [body setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        switch (self.viewType) {
            case CHA_TYPE_Add:
                [self addCharacterByNetWithDictionary:responseObject];
                break;
            case CHA_TYPE_Change:
                [self changeByNetWithDictionary:responseObject];
                break;
            default:
                break;
        }
        } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if ([[error objectForKey:kFailErrorCodeKey] isEqualToString:@"100014"]) {//已被绑定
                alertView1 = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"认证", nil];
                alertView1.tag = 18;
                [alertView1 show];
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




#pragma mark ---添加角色
- (void)addCharacterByNetWithDictionary:(NSDictionary *)dic
{
    hud.labelText = @"添加中...";
    
    NSMutableDictionary* params_two = [[NSMutableDictionary alloc]init];
    [params_two setObject:KISDictionaryHaveKey(dic, @"gameid") forKey:@"gameid"];
    [params_two setObject:KISDictionaryHaveKey(dic, @"id") forKey:@"characterid"];
    
    NSMutableDictionary* body_two = [[NSMutableDictionary alloc]init];
    [body_two addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body_two setObject:params_two forKey:@"params"];
    [body_two setObject:@"118" forKey:@"method"];
    [body_two setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body_two   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        NSLog(@"%@", responseObject);
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kUpdataUserInfoFromNet" object:nil];

        [self showMessageWindowWithContent:@"添加成功" imageType:0];
        [self.navigationController popViewControllerAnimated:YES];
        
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



#pragma mark 角色查找
//- (void)searchButtonClick:(id)semder
//{
//    SearchRoleViewController* searchVC = [[SearchRoleViewController alloc] init];
//    searchVC.searchDelegate = self;
//    searchVC.getRealmName = m_realmText.text;
//    [self.navigationController pushViewController:searchVC animated:YES];
//}

//- (void)searchRoleSuccess:(NSString*)roleName realm:(NSString*)realm
//{
//    m_roleNameText.text = roleName;
//    m_realmText.text = realm;
//}

#pragma mark ----删除角色接口

- (void)changeByNetWithDictionary:(NSDictionary *)dic
{
    hud.labelText = @"修改中...";
    [hud show:YES];
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:self.gameId forKey:@"gameid"];
    [params setObject:self.characterId forKey:@"characterid"];
    
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"119" forKey:@"method"];//删除
    [body setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if (isRefresh) {
            isRefresh =NO;
        }else{
            [self addCharacterByNetWithDictionary:dic];//添加

        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kUpdataUserInfoFromNet" object:nil];

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

#pragma mark alertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 18) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            AuthViewController* authVC = [[AuthViewController alloc] init];
            
            authVC.gameId = [m_dataArray[0] objectForKey:@"gameid"];
            UITextField *tf = (UITextField *)[self.view viewWithTag:1];
            UITextField*tf1 = (UITextField *)[self.view viewWithTag:2];
            authVC.realm = tf.text;
            authVC.isComeFromFirstOpen = NO;

            authVC.character =tf1.text;
            authVC.authDelegate = self;
            [self.navigationController pushViewController:authVC animated:YES];
        }
    }
}

-(void)authCharacterSuccess
{
    isRefresh = YES;
}

#pragma mark textField
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    if (textField == m_roleNameText&&(m_gameNameText.text ==nil||[m_gameNameText.text isEqualToString:@""]||[m_gameNameText.text isEqualToString:NULL])) {
//        [self showAlertViewWithTitle:@"提示" message:@"请先选择游戏" buttonTitle:@"确定"];
//        return NO;
//    }
//    return YES;
//}
//
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"%@aaa", textField.text);
    return YES;
}

-(void)enterHelp:(id)sender
{
    NSDictionary *dic = [gameInfoArray objectAtIndex:[m_serverNamePick selectedRowInComponent:0]];
    HelpViewController *helpVC = [[HelpViewController alloc]init];
    if ([KISDictionaryHaveKey(dic, @"id")intValue]==1) {
        helpVC.myUrl = @"content.html?7";
    }else{
        helpVC.myUrl = @"content.html?8";
    }
    [self.navigationController pushViewController:helpVC animated:YES];

}

#pragma mark 手势
//- (void)tapTopViewClick:(id)sender
//{
//    [m_roleNameText resignFirstResponder];
//}
-(void)dealloc
{
    alertView1.delegate = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)searchRoleSuccess:(NSString*)roleName realm:(NSString*)realm
{
    
}
@end
