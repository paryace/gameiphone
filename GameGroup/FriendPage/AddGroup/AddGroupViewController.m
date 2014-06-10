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
}
@end

@implementation AddGroupViewController

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
    
    [self setTopViewWithTitle:@"创建群组" withBackButton:YES];
    m_updataDic = [NSMutableDictionary dictionary];
    addGroup = [[AddGroupView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    addGroup.myDelegate = self;
    [self.view addSubview:addGroup];
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"提交中...";
    // Do any additional setup after loading the view.
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
-(void)didClickPageOneWithDel:(AddGroupView *)gro
{
    [m_updataDic setObject:addGroup.groupNameTf.text forKey:@"groupName"];
}

-(void)didClickCardWithDel:(AddGroupView *)gro dic:(NSMutableDictionary *)dic
{
    CardViewController *cardView  =[[ CardViewController alloc]init];
    cardView.myDelegate = self;
    cardView.listDict = dic;
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
