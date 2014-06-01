//
//  CharacterEditViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-20.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "CharacterEditViewController.h"
#import "AuthViewController.h"
#import "AddCharacterViewController.h"

@interface CharacterEditViewController ()
{
    UITableView*    m_myTabelView;
    
    NSMutableArray*        m_characterArray;
}
@end

@implementation CharacterEditViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getCharacterByNet];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"我的角色" withBackButton:NO];
    
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(5, KISHighVersion_7 ? 20 : 0, 65, 42)];
    [backButton setBackgroundImage:KUIImage(@"btn_back") forState:UIControlStateNormal];
    [backButton setBackgroundImage:KUIImage(@"btn_back_onclick") forState:UIControlStateHighlighted];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    
    m_characterArray = [[NSMutableArray alloc] init];
    
    m_myTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-(KISHighVersion_7?0:20))];
    m_myTabelView.delegate = self;
    m_myTabelView.dataSource = self;
    [self.view addSubview:m_myTabelView];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"获取中...";
}

- (void)getCharacterByNet
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] forKey:@"userid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"202" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        NSLog(@"%@", responseObject);
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [m_characterArray removeAllObjects];
            [m_characterArray addObjectsFromArray:responseObject];
             [m_myTabelView reloadData];
        }
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

- (void)addButtonClick:(id)sender
{
    AddCharacterViewController* addVC = [[AddCharacterViewController alloc] init];
    addVC.viewType = CHA_TYPE_Add;
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark 表格
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footView = [[UIView alloc] init];
    footView.backgroundColor = [UIColor whiteColor];
    
    if (KISHighVersion_7) {
        UIImageView* lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 10, 2)];
        lineImg.image = KUIImage(@"line");
       // lineImg.backgroundColor = [UIColor clearColor];
        [footView addSubview:lineImg];
    }

    UIButton* addButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 300, 40)];
    [addButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
    [addButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
    [addButton setTitle:@"添加新角色" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addButton.backgroundColor = [UIColor clearColor];
    [addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:addButton];
    
    return footView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_characterArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCharacter";
    MyCharacterEditCell *cell = (MyCharacterEditCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MyCharacterEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary* tempDic = [m_characterArray objectAtIndex:indexPath.row];
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"auth")] isEqualToString:@"1"]) {//已认证
        cell.authBtn.hidden = YES;
        cell.authBg.hidden = NO;
    }
    else
    {
        cell.authBtn.hidden = NO;
        cell.authBg.hidden = YES;
    }

    if ([KISDictionaryHaveKey(tempDic, @"failedmsg") isEqualToString:@"404"])//角色不存在
    {
        cell.realmLabel.text = @"角色不存在";
        cell.editBtn.hidden = NO;
        cell.authBtn.hidden = YES;
    }
    else
    {
        NSString* realm = [KISDictionaryHaveKey(tempDic, @"raceObj") isKindOfClass:[NSDictionary class]] ? KISDictionaryHaveKey(KISDictionaryHaveKey(tempDic, @"raceObj"), @"sidename") : @"";
        cell.realmLabel.text = [KISDictionaryHaveKey(tempDic, @"realm") stringByAppendingString:realm];
        cell.editBtn.hidden = YES;
    }
    
    
    NSString * gameImageId=KISDictionaryHaveKey(tempDic, @"img");
    if ([GameCommon isEmtity:gameImageId]) {
        cell.heardImg.image = [UIImage imageNamed:@"clazz_0.png"];
    }else{
        cell.heardImg.imageURL = [ImageService getImageUrl4:gameImageId];
    }
    
    cell.myIndexPath = indexPath;
    cell.myDelegate = self;
    NSString * gameid=KISDictionaryHaveKey(tempDic, @"gameid");
    NSString * imageId=[GameCommon putoutgameIconWithGameId:[GameCommon getNewStringWithId:gameid]];
    
    if ([GameCommon isEmtity:imageId]) {
        cell.gameImg.imageURL=nil;
    }else{
        cell.gameImg.imageURL=[ImageService getImageUrl3:imageId Width:80];
    }
    cell.nameLabel.text = KISDictionaryHaveKey(tempDic, @"name");
    return cell;
}

#pragma mark 按钮
- (void)authButtonClick:(MyCharacterEditCell*)myCell
{
    int selectRow = myCell.myIndexPath.row;
    
    AuthViewController* authVC = [[AuthViewController alloc] init];
    NSDictionary* dic = [m_characterArray objectAtIndex:selectRow];
    authVC.gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")];
    authVC.realm = KISDictionaryHaveKey(dic, @"realm");
    authVC.character = KISDictionaryHaveKey(dic, @"name");

    [self.navigationController pushViewController:authVC animated:YES];
}

- (void)deleButtonClick:(MyCharacterEditCell*)myCell
{
    if ([m_characterArray count] == 1) {
        [self showAlertViewWithTitle:@"提示" message:@"您只有一个角色啦，不能删除！" buttonTitle:@"确定"];
        return;
    }
    UIAlertView* alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要删除该角色吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    alter.tag = myCell.myIndexPath.row + 1;
    [alter show];
}

- (void)editButtonClick:(MyCharacterEditCell*)myCell
{
    NSDictionary* dic = [m_characterArray objectAtIndex:myCell.myIndexPath.row];
    
    AddCharacterViewController* changeVC = [[AddCharacterViewController alloc] init];
    changeVC.viewType = CHA_TYPE_Change;
    
    changeVC.realm = KISDictionaryHaveKey(dic, @"realm");
    changeVC.gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")];
    changeVC.characterId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"id")];
    changeVC.character = KISDictionaryHaveKey(dic, @"name");
    
    [self.navigationController pushViewController:changeVC animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        return;
    }
    //删除角色
    if (buttonIndex != alertView.cancelButtonIndex) {
        hud.labelText = @"删除中...";
        [hud show:YES];
        
        NSDictionary* dic = [m_characterArray objectAtIndex:alertView.tag - 1];
        NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
//        [params setObject:@"1" forKey:@"gameid"];
        [params setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")] forKey:@"gameid"];
        [params setObject:KISDictionaryHaveKey(dic, @"id") forKey:@"characterid"];
        
        NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
        [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
        [body setObject:params forKey:@"params"];
        [body setObject:@"119" forKey:@"method"];
        [body setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
        
        [NetManager requestWithURLStr:BaseClientUrl Parameters:body  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [hud hide:YES];
            
            [m_characterArray removeObjectAtIndex:alertView.tag - 1];
            [m_myTabelView reloadData];
            
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
}
//-(void)backButtonClick:(UIButton *)sender
//{
//    if (self.isFromMeet) {
//        NewFindViewController *nf = [[NewFindViewController alloc]init];
//        [self.navigationController popToViewController:nf animated:YES];
//
//    }else{
//        [self.navigationController popViewControllerAnimated:YES];
//
//    }
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)backButtonClick:(id)sender
{
    if (self.isFromMeet ==YES) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else
    [self.navigationController popViewControllerAnimated:YES];
}

@end
