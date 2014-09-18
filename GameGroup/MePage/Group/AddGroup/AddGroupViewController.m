//
//  AddGroupViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "AddGroupViewController.h"
#import "GroupInformationViewController.h"
@interface AddGroupViewController ()
{
    NSMutableDictionary * m_updataDic;
    AddGroupView *addGroup;
    UIAlertView *noRoleAlertView;
    UIButton *addButton;
}
@end

@implementation AddGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"创建群组" withBackButton:YES];
    
    addButton=[UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [addButton setBackgroundImage:KUIImage(@"okButton") forState:UIControlStateNormal];
    [addButton setBackgroundImage:KUIImage(@"okButton2") forState:UIControlStateHighlighted];
    addButton.hidden = YES;
    [self.view addSubview:addButton];
    [addButton addTarget:self action:@selector(saveMyNews:) forControlEvents:UIControlEventTouchUpInside];
    NSMutableArray * stArray  = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];

    if (!stArray||stArray.count<=0) {
        noRoleAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定角色,无法创建公会,请绑定角色后再创建公会" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [noRoleAlertView show];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification
                                               object:nil];
    

    
    m_updataDic = [NSMutableDictionary dictionary];
    addGroup = [[AddGroupView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    addGroup.myDelegate = self;
    [self.view addSubview:addGroup];
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"提交中...";
}

-(void)saveMyNews:(id)sender
{
    [addGroup enterThirdPage:sender];
}
-(void)didClickGameListWithDel:(AddGroupView *)gro dic:(NSDictionary *)dic
{
    [m_updataDic setObject:KISDictionaryHaveKey(dic, @"id")?KISDictionaryHaveKey(dic, @"id"):@"" forKey:@"gameid"];

}
-(void)didClickRealmListWithDel:(AddGroupView *)gro
{
    if ([addGroup.gameTextField.text isEqualToString:@""]||addGroup.gameTextField.text ==nil) {
        [self showAlertViewWithTitle:@"提示" message:@"请先选择游戏" buttonTitle:@"确定"];
        return;
    }
    RealmsSelectViewController* realmVC = [[RealmsSelectViewController alloc] init];
    realmVC.realmSelectDelegate = self;
    realmVC.gameNum =[m_updataDic objectForKey:@"gameid"];
    realmVC.prama = @"gamerealm";
    [self.navigationController pushViewController:realmVC animated:YES];

}
-(void)didClickPageOneWithDel:(AddGroupView *)gro WithDic:(NSDictionary *)dic
{
    addButton.hidden = NO;
    [m_updataDic setObject:addGroup.groupNameTf.text forKey:@"groupName"];
    [m_updataDic setObject:KISDictionaryHaveKey(dic, @"gameid") forKey:@"gameid"];
    [m_updataDic setObject:KISDictionaryHaveKey(dic, @"id") forKey:@"characterId"];
}

-(void)didClickCardWithDel:(AddGroupView *)gro dic:(NSMutableDictionary *)dic
{
    CardViewController *cardView  =[[ CardViewController alloc]init];
    cardView.myDelegate = self;
    cardView.infoDict = dic;
    [self.navigationController pushViewController:cardView animated:YES];
}
-(void)didClickCardImgWithDel:(AddGroupView *)gro
{
 
}
-(void)didClickContentWithDel:(AddGroupView *)gro content:(NSString *)content
{
    [m_updataDic setObject:content forKey:@"info"];
    [self uploadInfoWithNet];
}

- (void)selectOneRealmWithName:(NSString *)name num:(NSString *)num
{
    addGroup.realmTextField.text = name;
    [m_updataDic setObject:name forKey:@"gameRealm"];
}

-(void)senderCkickInfoWithDel:(CardViewController *)del array:(NSMutableArray *)array
{
    if (array.count>0) {
        
    
    if (array.count==0) {
        return;
    }
    NSString *str ;
    for (int i =0; i<array.count; i++) {
        if (str) {
            str = [NSString stringWithFormat:@"%@,%@",str,KISDictionaryHaveKey(array[i], @"tagId")];
        }else{
            str =KISDictionaryHaveKey(array[i],@"tagId");
        }
    }
    
    NSLog(@"str   %@",str);
    [m_updataDic setObject:str forKey:@"tagIds"];

    [addGroup.cardArray removeAllObjects];
    [addGroup.cardArray addObjectsFromArray:array];
    [addGroup.titleCollectionView reloadData];
    }
}

-(void)uploadInfoWithNet
{
    [hud show:YES];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:m_updataDic forKey:@"params"];
    [postDict setObject:@"229" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        [self showMessageWindowWithContent:@"创建成功" imageType:0];
        GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
        gr.groupId =[GameCommon getNewStringWithId: KISDictionaryHaveKey(responseObject, @"groupId")];
        gr.isAudit = YES;
        [self.navigationController pushViewController:gr animated:YES];
        
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
- (void)keyboardWillShow:(NSNotification *)notification {
    
    if ([addGroup.groupNameTf isFirstResponder]) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        addGroup.firstScrollView.contentOffset =CGPointMake(0, 230);
        [UIView commitAnimations];
        
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        addGroup.secondScrollView.contentOffset = CGPointMake(0, 200);
        [UIView commitAnimations];
        
    }
}
- (void)keyboardWillHide:(NSNotification *)notification {
    
    if ([addGroup.groupNameTf isFirstResponder]) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        addGroup.firstScrollView.contentOffset =CGPointMake(0, 0);
        [UIView commitAnimations];
        
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        addGroup.secondScrollView.contentOffset = CGPointMake(0, 0);
        [UIView commitAnimations];
        
    }

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dealloc
{
    noRoleAlertView.delegate = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
