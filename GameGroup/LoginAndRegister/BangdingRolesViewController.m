//
//  BangdingRolesViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BangdingRolesViewController.h"
#import "AboutRoleCell.h"
#import "HelpViewController.h"
#import "CharacterAndTitleService.h"
#import "SelectGameView.h"
#import "BoundRoleCell.h"
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
    UIScrollView *mainScrollView;
    NSMutableArray *nameArray;
    NSMutableArray *imgArray;
    UITapGestureRecognizer *tap;
    NSInteger number;
    NSString *gameNameStr;
}
@property (nonatomic,strong)SelectGameView *gameTableView;
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification
                                               object:nil];
   
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"选择游戏",@"name",@"",@"content",@"picker",@"type", nil];
    m_dataArray =[NSMutableArray array];
    [m_dataArray addObject:dic];
    
    gameInfoArray = [NSMutableArray new];

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
    
    mainScrollView =[[ UIScrollView alloc]initWithFrame:CGRectMake(0, startX+8, 320, kScreenHeigth-startX-28)];
    mainScrollView.contentSize = CGSizeMake(0, (kScreenHeigth-startX-28)*1.3);
    mainScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainScrollView];
    
    [self setStep_2View];
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGS:)];
    [mainScrollView addGestureRecognizer:tap1];
    
#pragma mark --------------- 创建选择游戏的视图

    self.gameTableView = [[SelectGameView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    self.gameTableView.titleView.text = @"选择游戏";
    self.gameTableView.backgroundColor = [UIColor whiteColor];
    self.gameTableView.selectGameDelegate = self;
    nameArray = [NSMutableArray array];
    imgArray = [NSMutableArray array];
    for (int i=0; i<[gameInfoArray count]; i++) {
        NSDictionary * dic = [gameInfoArray objectAtIndex:i];
        NSString * name = [dic objectForKey:@"name"];
        NSString * img = [dic objectForKey:@"img"];
        [nameArray addObject:name];
        [imgArray addObject:img];
    }
    [self.gameTableView setDateWithNameArray:nameArray andImg:imgArray];
    
    [self.view addSubview:self.gameTableView];
 
       // Do any additional setup after loading the view.
}

-(void)selectGame:(NSInteger)characterDic
{
    //fuzhi给num
   
    number = characterDic;
    //选择游戏界面的代理的实现
    if ([gameInfoArray count] != 0) {
        NSDictionary *dict =[gameInfoArray objectAtIndex:characterDic];
        NSArray *sarchArray ;
        sarchArray =[[dict objectForKey:@"gameParams"]objectForKey:@"bindCharacterParams"];
        
        [m_dataArray removeAllObjects];
        
        NSDictionary *firstDic = [NSDictionary dictionaryWithObjectsAndKeys:@"选择游戏",@"name",[dict objectForKey:@"name"],@"content",@"picker",@"type",[dict objectForKey:@"id"],@"gameid",KISDictionaryHaveKey(dict,@"img"),@"img",nil];
        
        [m_dataArray addObject:firstDic];
        [m_dataArray addObjectsFromArray:[[dict objectForKey:@"gameParams" ] objectForKey:@"commonParams"]];
        [m_dataArray addObjectsFromArray:sarchArray];
        
        m_okButton.hidden = NO;
        m_myTableView.frame = CGRectMake(0, 60, 320, 44*m_dataArray.count);
        m_okButton.frame = CGRectMake(10, 104+44*m_dataArray.count, 300, 40);
        registerButton.frame = CGRectMake(150,  149+44*m_dataArray.count, 100, 40);
        findPasButton.frame = CGRectMake(70,  149+44*m_dataArray.count, 80, 40);
        gameNameStr = [NSString stringWithFormat:@"%@",[nameArray  objectAtIndex:number]];
        [m_myTableView reloadData];
    }

    
}




#pragma mark 第二步
- (void)setStep_2View
{
    UILabel* topLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 50)];
    topLabel.numberOfLines = 2;
    topLabel.font = [UIFont boldSystemFontOfSize:12.0];
    topLabel.textColor = kColorWithRGB(128.0, 128, 128, 1.0);
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.text = @"如果您拥有多名角色，请先绑定最主要的，其他游戏角色可在注册完成之后，在设置面板中添加";
    [mainScrollView addSubview:topLabel];
    
    
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 60, 320, self.view.bounds.size.height-startX-44) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.scrollEnabled = NO;
    
    m_myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [mainScrollView addSubview:m_myTableView];
    
    m_gameNamePick = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_gameNamePick.dataSource = self;
    m_gameNamePick.delegate = self;
    m_gameNamePick.showsSelectionIndicator = YES;
    
   
    
    
    
    toolbar_server1 = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar_server1.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectGameNameOK:)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar_server1.items = @[rb_server];
    
    m_okButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 192, 300, 40)];
//    m_okButton.backgroundColor = [UIColor redColor];
    [m_okButton setBackgroundImage:KUIImage(@"11_08") forState:UIControlStateNormal];
//    [step2Button setBackgroundImage:KUIImage(@"zhuce_click") forState:UIControlStateHighlighted];
    //    [step2Button setTitle:@"绑定上述角色" forState:UIControlStateNormal];
    [m_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    m_okButton.backgroundColor = [UIColor clearColor];
    [m_okButton addTarget:self action:@selector(step2ButtonOK:) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:m_okButton];
    
    
    findPasButton = [[UIButton alloc] initWithFrame:CGRectMake(70, 230, 80, 40)];
    [findPasButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [findPasButton setTitleColor:kColorWithRGB(128, 128, 128, 1.0) forState:UIControlStateNormal];
    findPasButton.backgroundColor = [UIColor clearColor];
    findPasButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [findPasButton addTarget:self action:@selector(backToRegister:) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:findPasButton];
    
    registerButton = [[UIButton alloc] initWithFrame:CGRectMake(150, 230, 100, 40)];
    [registerButton setTitle:@"|     遇到问题" forState:UIControlStateNormal];
    [registerButton setTitleColor:kColorWithRGB(128, 128, 128, 1.0) forState:UIControlStateNormal];
    registerButton.backgroundColor = [UIColor clearColor];
    registerButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [registerButton addTarget:self action:@selector(hitRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:registerButton];

    
}
#pragma mark---------------点击手势 收回键盘
- (void)tapGS:(UIGestureRecognizer*)gs
{
    UITextField *tf = (UITextField *)[self.view viewWithTag:100002];
    [tf resignFirstResponder];
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
    UIButton *bvt = (UIButton *)[self.view viewWithTag:1001];
    [bvt setTitle:@"" forState:UIControlStateNormal];
    
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
        m_myTableView.frame = CGRectMake(0, 60, 320, 44*m_dataArray.count);
        m_okButton.frame = CGRectMake(10, 74+44*m_dataArray.count, 300, 40);
        registerButton.frame = CGRectMake(150,  149+44*m_dataArray.count, 100, 40);
        findPasButton.frame = CGRectMake(70,  149+44*m_dataArray.count, 80, 40);
        [m_myTableView reloadData];
    }
}
#pragma mark ------点击选择游戏的button
//
- (void)didGameNameBt:(id)sender
{
    UITextField *tf = (UITextField *)[self.view viewWithTag:2];
    [tf resignFirstResponder];
    [self.gameTableView showSelf];
}
#pragma mark ------返回到注册
-(void)backToRegister:(id)sender
{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"注册已成功，您需要完成角色绑定以便与其他玩家交流，是否退出绑定？" delegate:self cancelButtonTitle:@"确定退出" otherButtonTitles:@"取消", nil];
    alert.tag = 2003;
    [alert show];
    
}

- (void)realmSelectClickA:(UIButton *)sender
{
    RealmsSelectViewController* realmVC = [[RealmsSelectViewController alloc] init];
    realmVC.realmSelectDelegate = self;
    realmVC.indexCount =[NSString stringWithFormat:@"%d",sender.tag];
    realmVC.gameNum = [[m_dataArray objectAtIndex:0]objectForKey:@"gameid"];
    realmVC.prama = [[m_dataArray objectAtIndex:sender.tag-1000]objectForKey:@"param"];
    
    [self.navigationController pushViewController:realmVC animated:YES];
}
#pragma mark -----------------------realmStr ---------
- (void)selectOneRealmWithName:(NSString *)name num:(NSString *)num
{
    //    dic = [m_dataArray objectAtIndex:[num intValue]];
    //    [dic setObject:name forKey:@"content"];
//    UITextField *tf = (UITextField *)[self.view viewWithTag:[num intValue]+100000];
    
    UIButton *bvtt = (UIButton *)[self.view viewWithTag:[num intValue]];
    [bvtt setTitle:name forState:UIControlStateNormal];
    [bvtt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    tf.text = name;
    m_realmStr = name;
}



#pragma  mark---- pickview选择确认键方法
- (void)step2ButtonOK:(id)sender
{
    hud.labelText = @"获取中...";
    [hud show:YES];
    if (!m_dataArray||m_dataArray.count<2) {
        [self showAlertViewWithTitle:@"提示" message:@"请将信息填写完整" buttonTitle:@"确定"];
        [hud hide:YES];
        return;
    }
    NSLog(@"dataArray=%@",m_dataArray);
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    for (int i =0; i<m_dataArray.count; i++) {
        NSDictionary *dic = m_dataArray[i];
        if (i==0) {
            [params setObject:KISDictionaryHaveKey(dic, @"gameid") forKey:@"gameid"];
        }else if(i == 1){
            UIButton * bvtt = (UIButton *)[self.view viewWithTag:1001];
            if (!bvtt.titleLabel.text||[bvtt.titleLabel.text isEqualToString:@""]||[bvtt.titleLabel.text isEqualToString:@" "]) {
                [self showAlertViewWithTitle:@"提示" message:@"请选择正确的服务器" buttonTitle:@"确定"];
                [hud hide:YES];
                return;
            }
            [params setObject:bvtt.titleLabel.text forKey:KISDictionaryHaveKey(dic, @"param")];
        }else if(i == 2){
            UITextField * bvt = (UITextField *)[self.view viewWithTag:100000+i];
            if (!bvt.text||[bvt.text isEqualToString:@""]||[bvt.text isEqualToString:@" "]) {
                [self showAlertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"请输入您的%@",KISDictionaryHaveKey(dic, @"name")] buttonTitle:@"确定"];
                [hud hide:YES];
                return;
            }
            [params setObject:bvt.text forKey:KISDictionaryHaveKey(dic, @"param")];
        }
    }
    
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"115" forKey:@"method"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        NSDictionary* dic = responseObject;
        NSLog(@"%@", dic);
        
        hud.labelText = @"添加中...";
        
        NSMutableDictionary* params_two = [[NSMutableDictionary alloc]init];
        [params_two setObject:KISDictionaryHaveKey(dic, @"gameid") forKey:@"gameid"];
        [params_two setObject:KISDictionaryHaveKey(dic, @"id") forKey:@"characterId"];
        NSLog(@"%@",params_two);
        NSMutableDictionary* body_two = [[NSMutableDictionary alloc]init];
        [body_two addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
        [body_two setObject:params_two forKey:@"params"];
        [body_two setObject:@"262" forKey:@"method"];
        [body_two setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
        
        [NetManager requestWithURLStr:BaseClientUrl Parameters:body_two   success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [hud hide:YES];
            
            NSLog(@"%@", responseObject);
            [[UserManager singleton]requestUserFromNet:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
            [[CharacterAndTitleService singleton] getCharacterInfo:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
            [[TempData sharedInstance]isBindingRolesWithBool:YES];
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
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"    已被其他玩家绑定，若该角色为您所有，您可点击认证将其认证到您名下"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"认证", nil];
                alert.tag =2001;
                [alert show];
            }
            else if ([[error objectForKey:kFailErrorCodeKey] isEqualToString:@"200001"]){
                if ([gameNameStr isEqualToString:@"Dota2"]==YES) {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }else{
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
                alert.tag =2002;
                [alert show];
                }
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
#pragma mark 设置tableview---------------------------------

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == (UITableView *)self.gameTableView) {
        return 1;
    }else{
    return m_dataArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifint = @"Rolecell";
    BoundRoleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifint];
    
    if (cell ==nil) {
        cell = [[BoundRoleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifint];
    }
    cell.serverButton.tag = indexPath.row +1000;
    cell.contentTF.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = m_dataArray[indexPath.row];
    cell.contentTF.text = KISDictionaryHaveKey(dic, @"content");
    cell.contentTF.tag = indexPath.row+100000;
    
    if ([KISDictionaryHaveKey(dic, @"type")isEqualToString:@"list"]||[KISDictionaryHaveKey(dic, @"type")isEqualToString:@"picker"]) {
        cell.rightImageView.hidden = NO;
        if ([KISDictionaryHaveKey(dic, @"type")isEqualToString:@"picker"]) {
            cell.gameNameBt.hidden = NO;
            cell.contentTF.hidden = NO;
            cell.contentTF.enabled = NO;
            cell.serverButton.hidden = YES;
            cell.gameImg.hidden = NO;
            cell.titleLabel.hidden = YES;
            [cell.gameNameBt addTarget:self action:@selector(didGameNameBt:) forControlEvents:UIControlEventTouchUpInside];
            NSString * imageId=KISDictionaryHaveKey(dic, @"img");
            cell.gameImg.imageURL = [ImageService getImageUrl4:imageId];
            
            
            // 第二个cell的显示内容
        }else if([KISDictionaryHaveKey(dic, @"type")isEqualToString:@"list"]){
            cell.serverButton.hidden =NO;
            cell.smallImg.hidden = NO;
            cell.gameImg.hidden = YES;
            cell.contentTF.hidden = YES;
            cell.contentTF.enabled = NO;
            [cell.serverButton setTitle:@"请选择您的服务器" forState:UIControlStateNormal];
            [cell.serverButton addTarget:self action:@selector(realmSelectClickA:) forControlEvents:UIControlEventTouchUpInside];
            [cell.serverButton setTitleColor:UIColorFromRGBA(0xd5d5d5, 1) forState:UIControlStateNormal];
            cell.smallImg.image = KUIImage(@"r-1_08");
        }
        
    }else{
        cell.serverButton.hidden = YES;
        cell.gameImg.hidden = YES;
        cell.serverButton.hidden = YES;
        cell.rightImageView.hidden = YES;
        cell.contentTF.inputView =nil;
        cell.smallImg.hidden = NO;
        cell.contentTF.placeholder = [NSString stringWithFormat:@"请输入您的%@",KISDictionaryHaveKey(dic, @"name")];
        cell.contentTF.tag = indexPath.row;
        cell.smallImg.image = KUIImage(@"r-1_10");
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeImage:) name:UITextFieldTextDidChangeNotification object:nil];
        [cell.contentTF addTarget:self action:@selector(changeImage:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}
- (void)changeImage:(id)sender
{
    UITextField *tf = (UITextField *)[self.view viewWithTag:100002];
    if (tf.text.length>0) {
        [m_okButton setImage:KUIImage(@"r11_06") forState:UIControlStateHighlighted];
        [m_okButton setImage:KUIImage(@"r11_03") forState:UIControlStateNormal];
    }else{
        [m_okButton setImage:KUIImage(@"r-1_102") forState:UIControlStateNormal];
    }
}
#pragma mark ------------往下一个页面传zhi
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==2001) {
        if (buttonIndex ==1) {
            AuthViewController* authVC = [[AuthViewController alloc] init];
            NSDictionary *dict =[gameInfoArray objectAtIndex:number];
            authVC.gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"id")];
            authVC.realm = m_realmStr;
            authVC.Type =@"register";
            authVC.authDelegate =self;
            UITextField *tf  = (UITextField *)[self.view viewWithTag:2+100000];
//            UIButton * bt = (UIButton *)[self.view viewWithTag:1001];
            authVC.isComeFromFirstOpen = YES;
            authVC.character = tf.text;
//            authVC.character = bt.titleLabel.text;
            [self.navigationController pushViewController:authVC animated:YES];
        }
    }else if(alertView.tag == 2002){
        if (buttonIndex ==1) {
            [self bindingnonerole];
        }
    }else if(alertView.tag == 2003){
        if (buttonIndex ==0) {
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
    }
}

-(void)bindingnonerole
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    for (int i =0; i<m_dataArray.count; i++) {
        NSDictionary *dic = m_dataArray[i];
              if (i==0) {
            [params setObject:KISDictionaryHaveKey(dic, @"gameid") forKey:@"gameid"];
        }else if(i ==1){

            UIButton * bvtt = (UIButton *)[self.view viewWithTag:1001];
            if (!bvtt.titleLabel.text||[bvtt.titleLabel.text isEqualToString:@""]||[bvtt.titleLabel.text isEqualToString:@" "]) {
                [self showAlertViewWithTitle:@"提示" message:@"请选择正确的服务器" buttonTitle:@"确定"];
                return;
            }
            [params setObject:bvtt.titleLabel.text forKey:KISDictionaryHaveKey(dic, @"param")];
        
        }else if(i == 2){
                 UITextField * bvt = (UITextField *)[self.view viewWithTag:100000+i];
            
                 if (!bvt.text||[bvt.text isEqualToString:@""]||[bvt.text isEqualToString:@" "]) {
                     [self showAlertViewWithTitle:@"提示" message:@"请填写角色名" buttonTitle:@"确定"];
                     return;
                 }
            [params setObject:bvt.text forKey:KISDictionaryHaveKey(dic, @"param")];
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
    NSLog(@"body******************************%@",body);
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        [[TempData sharedInstance]isBindingRolesWithBool:YES];
         [[UserManager singleton]requestUserFromNet:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if ([[error objectForKey:kFailErrorCodeKey] isEqualToString:@"100014"]) {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"该角色已被其他玩家绑定，若该角色为您所有，您可点击认证将其认证到您名下"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"认证", nil];
                alert.tag =2001;
                [alert show];
            }
            else if ([[error objectForKey:kFailErrorCodeKey] isEqualToString:@"200001"]){
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag =2002;
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
- (void)keyboardWillShow:(NSNotification *)notification {
    UITextField *tf  = (UITextField *)[self.view viewWithTag:2+100000];

    if ([tf isFirstResponder]) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        mainScrollView.contentOffset =CGPointMake(0, 140);
        [UIView commitAnimations];
        
    }
  
}
- (void)keyboardWillHide:(NSNotification *)notification {
    UITextField *tf  = (UITextField *)[self.view viewWithTag:2+100000];
    if ([tf isFirstResponder]) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        mainScrollView.contentOffset =CGPointMake(0, 0);
        [UIView commitAnimations];
        
    }
    
}

- (void)authCharacterRegist
{
//    [self dismissViewControllerAnimated:NO completion:^{
//    
//    }];
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
