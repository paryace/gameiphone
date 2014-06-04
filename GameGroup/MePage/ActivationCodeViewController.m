//
//  ActivationCodeViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-3-27.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ActivationCodeViewController.h"
#import "CharacterEditViewController.h"
#import "CharaterOfmCell.h"
@interface ActivationCodeViewController ()
{
    NSMutableArray *charaArray;
    UITextField *textField1;
    NSString *charaterId ;
    UITextField *textField;
    UIAlertView *alertView1;
}
@end

@implementation ActivationCodeViewController

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
    charaterId = [[NSString alloc]init];
    [self setTopViewWithTitle:@"兑换码" withBackButton:YES];
    
    charaArray = [NSMutableArray array];
    [charaArray removeAllObjects];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"CharacterArrayOfAllForYou"]&&[[[NSUserDefaults standardUserDefaults]objectForKey:@"CharacterArrayOfAllForYou"] isKindOfClass:[NSArray class]]) {
            [charaArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"CharacterArrayOfAllForYou"]];
    }else{
        alertView1 = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定角色,不能使用兑换码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去绑定", nil];
        alertView1.tag = 10001;
        [alertView1 show];

    }
    
    UITableView *tableView =[[ UITableView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height, 300, 200)style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    //tableView.hidden = YES;
    [self.view addSubview:tableView];

    
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, startX, 300, 53)];
    titleLabel.text = @"请输入兑换码:";
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.view addSubview:titleLabel];
    
    
    
    
    textField = [[UITextField alloc]initWithFrame:CGRectMake(10, startX+53, 300, 40)];
    textField.placeholder = @"兑换码";
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.delegate = self;
    textField.keyboardType =UIKeyboardTypeDefault;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:textField];
    
    textField1 = [[UITextField alloc]initWithFrame:CGRectMake(10, startX+110, 300, 40)];
    textField1.placeholder = @"请选择您的一个角色";
    textField1.clearButtonMode = UITextFieldViewModeNever;
    textField1.borderStyle = UITextBorderStyleRoundedRect;
    textField1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField1.adjustsFontSizeToFitWidth = YES;
    textField1.delegate = self;
    textField1.keyboardType =UIKeyboardTypeDefault;
    textField1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField1.autocorrectionType = UITextAutocorrectionTypeNo;
    textField1.inputView = tableView;
    [self.view addSubview:textField1];

    UIImageView *imageView =[[ UIImageView alloc]initWithFrame:CGRectMake(280, 16, 14, 8)];
    imageView.image = KUIImage(@"xiala");
    [textField1 addSubview:imageView];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, startX+160, 300, 44);
    [button setBackgroundImage:KUIImage(@"chack") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    

    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(regfiset)]];
    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    
    
    
}

-(void)regfiset
{
    [textField1 resignFirstResponder];
    [textField resignFirstResponder];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    return YES;
}


-(void)submit:(UIButton *)sender
{
    if (KISEmptyOrEnter(textField.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"兑换码不能为空" buttonTitle:@"确定"];
        return;
    }
    if (KISEmptyOrEnter(textField1.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择一个角色" buttonTitle:@"确定"];
        return;
    }
    if (charaterId ==nil) {
        [self showAlertViewWithTitle:@"提示" message:@"请重新选择角色" buttonTitle:@"确定"];
        return;
    }
    [self getUserInfoByNetWithExchangeCode:textField.text CharaterId:charaterId];
}

- (void)getUserInfoByNetWithExchangeCode:(NSString *)exchangeCode CharaterId:(NSString *)charaId
{
    hud.labelText = @"获取中...";
    [hud show:YES];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:exchangeCode ,@"exchangeCode",charaId,@"characterId",nil];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"168" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [postDict setObject:dic forKey:@"params"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:KISDictionaryHaveKey(responseObject, @"codeMemo") delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 1000;

        [alertView show];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];

        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100046"])
                {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                    return ;
                }
                
                if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100047"])
                {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                    return ;

                }
                if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100048"])
                {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                    return ;

                }
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==1000) {
        if (buttonIndex ==0) {
            NSLog(@"1");
            return;
        }
        if (buttonIndex ==1) {
            [self goOnUploadWithExchangeCode:textField.text CharaterId:charaterId];
            return;
        }
    }
    if (alertView.tag ==10001) {
        if (buttonIndex ==1) {
            CharacterEditViewController *CVC = [[CharacterEditViewController alloc]init];
            CVC.isFromMeet = YES;
            [self.navigationController pushViewController:CVC animated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

}

-(void)goOnUploadWithExchangeCode:(NSString *)exchangeCode CharaterId:(NSString *)charaId
{
    hud.labelText = @"提交中";
    [hud show:YES];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:exchangeCode ,@"exchangeCode",charaId,@"characterId",nil];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"167" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [postDict setObject:dic forKey:@"params"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        sleep(1);
        hud.labelText = @"提交成功";
        [hud hide:YES afterDelay:2];
        
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


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return charaArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndef = @"cell";
    CharaterOfmCell *cell  =[tableView dequeueReusableCellWithIdentifier:cellIndef];;
    if (cell ==nil) {
        cell =[[CharaterOfmCell alloc ]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndef];
    }
    NSDictionary *dic = [charaArray objectAtIndex:indexPath.row];
    NSString * imageId=KISDictionaryHaveKey(dic, @"img");
    NSString * gameid=KISDictionaryHaveKey(dic, @"gameid");
    NSString * failedmsg=KISDictionaryHaveKey(dic, @"failedmsg");
      NSString* realm = [KISDictionaryHaveKey(dic, @"raceObj") isKindOfClass:[NSDictionary class]] ? KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"raceObj"), @"sidename") : @"";
    if ([failedmsg isEqualToString:@"404"]) {
        cell.heardImg.image  =[UIImage imageNamed:[NSString stringWithFormat:@"clazz_0"]];
        cell.realmLabel.text =@"角色不存在";
    }else{
        if ([GameCommon isEmtity:[GameCommon getNewStringWithId:imageId]]) {
            cell.heardImg.image  =[UIImage imageNamed:[NSString stringWithFormat:@"clazz_0"]];
        }else{
            cell.heardImg.imageURL=[ImageService getImageUrl4:imageId];
        }
//        cell.realmLabel.text =[NSString stringWithFormat:@"%@-%@",KISDictionaryHaveKey(dic, @"realm"),realm];
        cell.realmLabel.text =[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"realm")];
    }
    cell.nameLabel.text = KISDictionaryHaveKey(dic, @"name");
    
    NSString * gameImageid=[GameCommon putoutgameIconWithGameId:gameid];
    
    cell.gameImg.imageURL=[ImageService getImageUrl4:gameImageid];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [charaArray objectAtIndex:indexPath.row];
    NSString* realm = [KISDictionaryHaveKey(dic, @"raceObj") isKindOfClass:[NSDictionary class]] ? KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"raceObj"), @"sidename") : @"";
    NSString * faileMsg=KISDictionaryHaveKey(dic, @"failedmsg");
    if ([faileMsg isEqualToString:@"404"])//角色不存在
    {
        return;
    }
  
    [textField1 resignFirstResponder];
    textField1.text =[NSString stringWithFormat:@"%@ %@ %@",KISDictionaryHaveKey(dic,@"name"),KISDictionaryHaveKey(dic,@"realm"),realm];
    charaterId = KISDictionaryHaveKey(dic, @"id");
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *tbView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    tbView.text = @"请选择角色";
    tbView.backgroundColor = [UIColor whiteColor];
    tbView.textAlignment = NSTextAlignmentCenter;
    tbView.backgroundColor =[UIColor grayColor];
    return tbView;

}
-(void)dealloc
{
    alertView1.delegate = nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
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
