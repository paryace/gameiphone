//
//  MemberEditViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MemberEditViewController.h"
#import "MemberEditCell.h"
@interface MemberEditViewController ()
{
    UITableView *m_myTableView;
    NSMutableDictionary *m_dataDic;
    NSDictionary *didClickDict;
}
@end

@implementation MemberEditViewController

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
    [self setTopViewWithTitle:@"群成员管理" withBackButton:YES];
    m_dataDic = [NSMutableDictionary dictionary];
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];
    didClickDict = [NSMutableDictionary dictionary];
    
    [self getNearByDataByNet];
    
    // Do any additional setup after loading the view.
}
- (void)getNearByDataByNet
{
    [hud show:YES];
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc]init];
    [paramDict setObject:self.groupId forKey:@"groupId"];
    [paramDict setObject:@"members" forKey:@"type"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon]getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"238" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [m_dataDic removeAllObjects];
            m_dataDic =responseObject;
            [m_myTableView reloadData];
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            NSString* warn = [error objectForKey:kFailMessageKey];
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", warn] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];
    // [refreshView stopLoading:NO];
    
}

#pragma mark - table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *arr = [m_dataDic allKeys];
    return arr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *keyArr = [NSMutableArray arrayWithArray:[m_dataDic allKeys]];
    [keyArr sortUsingSelector:@selector(compare:)];
    NSArray *arr = [m_dataDic objectForKey:[keyArr objectAtIndex:section]];
    
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableArray *keyArr = [NSMutableArray arrayWithArray:[m_dataDic allKeys]];
    [keyArr sortUsingSelector:@selector(compare:)];
    return keyArr[section];

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCell";
    MemberEditCell *cell = (MemberEditCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MemberEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSMutableArray *keyArr = [NSMutableArray arrayWithArray:[m_dataDic allKeys]];
    [keyArr sortUsingSelector:@selector(compare:)];
    NSArray *arr = [m_dataDic objectForKey:keyArr[indexPath.section]];
    NSDictionary* tempDict = [arr objectAtIndex:indexPath.row];
    cell.nameLable.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"nickname")];
    NSString * imageIds= KISDictionaryHaveKey(tempDict, @"img");
    cell.headImageView.imageURL = [ImageService getImageStr:imageIds Width:80];
    
    NSInteger i = [KISDictionaryHaveKey(tempDict, @"type") intValue];
    switch (i) {
        case 0:
         cell.sfLb.text = @"群主";
            break;
        case 1:
            cell.sfLb.text = @"管理员";
            break;
        case 2:
            cell.sfLb.text = @"";
            break;
     
        default:
            break;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *keyArr = [NSMutableArray arrayWithArray:[m_dataDic allKeys]];
    [keyArr sortUsingSelector:@selector(compare:)];
    NSArray *arr = [m_dataDic objectForKey:keyArr[indexPath.section]];

    NSDictionary *dic = [arr objectAtIndex:indexPath.row];
    didClickDict = dic;
    if (self.shiptype ==0) {
        if ([KISDictionaryHaveKey(dic, @"type")intValue]==1) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"管理" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"转让群组",@"取消管理员",@"移除",@"移除并举报", nil];
            actionSheet.tag = 111;
            [actionSheet showInView:self.view];

        }else if ([KISDictionaryHaveKey(dic, @"type")intValue] ==2){
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"管理" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"转让群组",@"设置管理员",@"移除",@"移除并举报", nil];
            actionSheet.tag =222;
        [actionSheet showInView:self.view];
        }

    }else{
        if ([KISDictionaryHaveKey(dic, @"type")intValue]==2) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"管理" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"移除",@"移除并举报", nil];
            actionSheet.tag =333;
            [actionSheet showInView:self.view];
            
        }else {
            
        }
    }
  
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case 111:
            switch (buttonIndex) {
                case 0:
                    [self showAlertViewWithTitle:nil message:@"转让群组" buttonTitle:@"取消"];
                    break;
                case 1:
                    [self editIdentityForNetWithUserid:KISDictionaryHaveKey(didClickDict, @"userid") type:@"2"];
                    break;
                case 2:
                    [self showAlertViewWithTitle:nil message:@"踢人" buttonTitle:@"取消"];
                    break;
                case 3:
                    [self showAlertViewWithTitle:nil message:@"踢人并且举报" buttonTitle:@"取消"];
                    break;
                default:
                    break;
            }
            break;
        case 222:
            switch (buttonIndex) {
                case 0:
                    [self showAlertViewWithTitle:nil message:@"转让群组" buttonTitle:@"取消"];
                    break;
                case 1:
                    [self editIdentityForNetWithUserid:KISDictionaryHaveKey(didClickDict, @"userid") type:@"1"];
                    break;
                case 2:
                    [self showAlertViewWithTitle:nil message:@"踢人" buttonTitle:@"取消"];
                    break;
                    
                default:
                    [self showAlertViewWithTitle:nil message:@"踢人并且举报" buttonTitle:@"取消"];
                    break;
            }
            break;
        case 333:
            switch (buttonIndex) {
                case 0:
                    [self showAlertViewWithTitle:nil message:@"踢人" buttonTitle:@"取消"];
                    break;
                case 1:
                    [self showAlertViewWithTitle:nil message:@"踢人并且举报" buttonTitle:@"取消"];
                    break;
                default:
                    break;
            }

            break;
   
        default:
            break;
    }
}
- (void)editIdentityForNetWithUserid:(NSString *)userid type:(NSString *)type
{
    [hud show:YES];
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc]init];
    
    [paramDict setObject:self.groupId forKey:@"groupId"];
    [paramDict setObject:type forKey:@"type"];
    [paramDict setObject:userid forKey:@"memberUserid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon]getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"253" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if ([responseObject isKindOfClass:[NSArray class]]) {
//            [m_dataArray removeAllObjects];
//            [m_dataArray addObjectsFromArray:responseObject];
//            [m_myTableView reloadData];
//            
//        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            NSString* warn = [error objectForKey:kFailMessageKey];
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", warn] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];
    // [refreshView stopLoading:NO];
    
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
