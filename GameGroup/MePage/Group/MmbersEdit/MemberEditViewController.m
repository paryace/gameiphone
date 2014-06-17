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
    NSMutableArray *m_dataArray;
    NSMutableDictionary *didClickDict;
    UIAlertView *yjAlertView;
    UIAlertView *ascensionGlyAlertView;
    UIAlertView *cancelAlertView;
    UIAlertView *removeAlertView;
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
    m_dataArray = [NSMutableArray array];
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [GameCommon setExtraCellLineHidden:m_myTableView];

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
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [m_dataArray removeAllObjects];
            [m_dataArray addObjectsFromArray: responseObject];
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
    return m_dataArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [m_dataArray[section]objectForKey:@"list"];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [m_dataArray[section]objectForKey:@"name"];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCell";
    MemberEditCell *cell = (MemberEditCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MemberEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary* tempDict = [[[m_dataArray objectAtIndex:indexPath.section]objectForKey:@"list"]objectAtIndex:indexPath.row];
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
    NSMutableDictionary *dic = [[[m_dataArray objectAtIndex:indexPath.section]objectForKey:@"list"]objectAtIndex:indexPath.row];
    didClickDict = dic;
    if (self.shiptype ==0) {
        if ([KISDictionaryHaveKey(dic, @"type")intValue]==1) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"管理" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"转让群组",@"取消管理员",@"移除", nil];
            actionSheet.tag = 111;
            [actionSheet showInView:self.view];

        }else if ([KISDictionaryHaveKey(dic, @"type")intValue] ==2){
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"管理" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"转让群组",@"设置管理员",@"移除", nil];
            actionSheet.tag =222;
        [actionSheet showInView:self.view];
        }

    }else{
        if ([KISDictionaryHaveKey(dic, @"type")intValue]==2) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"管理" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"移除", nil];
            actionSheet.tag =333;
            [actionSheet showInView:self.view];
            
        }else {
            
        }
    }
  
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag ==111) {
        if (buttonIndex ==0) {
            ascensionGlyAlertView =[[ UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"您确定将群移交给 %@ 吗?",KISDictionaryHaveKey(didClickDict,@"nickname")] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            ascensionGlyAlertView.tag = 1001;
            [ascensionGlyAlertView show];
            
        }
        else if(buttonIndex ==1){
        [self editIdentityForNetWithUserid:KISDictionaryHaveKey(didClickDict, @"userid") type:@"2"];
        }
        else if(buttonIndex ==2){
            [self showAlertViewWithTitle:nil message:@"踢人" buttonTitle:@"取消"];
     
        }

    }else if(actionSheet.tag ==222){
        if (buttonIndex ==0) {
            ascensionGlyAlertView =[[ UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"您确定将群移交给 %@ 吗?",KISDictionaryHaveKey(didClickDict,@"nickname")] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            ascensionGlyAlertView.tag = 1001;
            [ascensionGlyAlertView show];
            
        }
        else if(buttonIndex ==1){
            [self editIdentityForNetWithUserid:KISDictionaryHaveKey(didClickDict, @"userid") type:@"1"];
        }
        else if(buttonIndex ==2){
            
            removeAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您确定移除该用户?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            removeAlertView.tag = 222;
            
        }
 
    }else if(actionSheet.tag ==333){
        if (buttonIndex ==0) {
            removeAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您确定移除该用户?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            removeAlertView.tag = 222;

        }
    }

    
 }

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
    [tempDict setObject:self.groupId forKey:@"groupId"];
    [tempDict setObject:[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(didClickDict, @"userid")] forKey:@"memberUserid"];
    switch (alertView.tag) {
        case 1001:
    [self editIdentityForNetWithDic:tempDict method:@"252" Successinfo:@"转让成功"];
            break;
        case 1002:
            [self editIdentityForNetWithDic:tempDict method:@"249" Successinfo:@"移除成功"];
            break;
            
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
        [self getNearByDataByNet];
        
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


- (void)editIdentityForNetWithDic:(NSDictionary *)dic method:(NSString *)method Successinfo:(NSString *)str
{
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc]init];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon]getNetCommomDic]];
    [postDict setObject:dic forKey:@"params"];
    [postDict setObject:method forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self showMessageWindowWithContent:str imageType:0];
        [self getNearByDataByNet];
        
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
- (void)dealloc
{
    ascensionGlyAlertView.delegate = nil;
    removeAlertView.delegate = nil;
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
