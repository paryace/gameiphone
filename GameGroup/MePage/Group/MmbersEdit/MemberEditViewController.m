//
//  MemberEditViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MemberEditViewController.h"
#import "MemberEditCell.h"
#import "GroupInformationViewController.h"
#import "TestViewController.h"
@interface MemberEditViewController ()
{
    UITableView *m_myTableView;
    NSMutableArray *m_dataArray;
    NSMutableDictionary *didClickDict;
    UIAlertView *yjAlertView;
    UIAlertView *ascensionGlyAlertView;
    UIAlertView *cancelAlertView;
    UIAlertView *removeAlertView;
    NSInteger clickSection;
    
}
@end

@implementation MemberEditViewController

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
    cell.headCkickDelegate = self;
    NSDictionary* tempDict = [[[m_dataArray objectAtIndex:indexPath.section]objectForKey:@"list"]objectAtIndex:indexPath.row];
    cell.indexPath= indexPath;
    cell.nameLable.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"nickname")];
    NSString * imageIds= KISDictionaryHaveKey(tempDict, @"img");
    cell.headImageView.placeholderImage = KUIImage([self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")]);
    cell.headImageView.imageURL = [ImageService getImageStr:imageIds Width:80];
    NSString *genderimage=[self genderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    cell.sexImg.image =KUIImage(genderimage);
    
    CGSize nameSize = [cell.nameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(200, 20) lineBreakMode:NSLineBreakByWordWrapping];
    cell.nameLable.frame = CGRectMake(65, 25, nameSize.width, 20);
    cell.sexImg.frame = CGRectMake(65+nameSize.width+5, 25, 20, 20);
    
    cell.sfLb.text = [GameCommon getTimeWithMessageTime:KISDictionaryHaveKey(tempDict, @"updateUserLocationDate")];
    CGSize timeSize = [cell.sfLb.text sizeWithFont:[UIFont boldSystemFontOfSize:12.0] constrainedToSize:CGSizeMake(200, 20) lineBreakMode:NSLineBreakByWordWrapping];
    cell.sfLb.frame = CGRectMake(320-timeSize.width-10, 25, timeSize.width, 20);
    return cell;
}
- (void)userHeadImgClick:(id)Sender{
    MemberEditCell * iCell = (MemberEditCell*)Sender;
    NSDictionary* dic = [[[m_dataArray objectAtIndex:iCell.indexPath.section]objectForKey:@"list"]objectAtIndex:iCell.indexPath.row];
    TestViewController *itemInfo = [[TestViewController alloc]init];
    itemInfo.userId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")];
    [self.navigationController pushViewController:itemInfo animated:YES];
}

//格式化时间
-(NSString*)getMsgTime:(NSString*)senderTime
{
    NSString *time = [senderTime substringToIndex:10];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSString* strNowTime = [NSString stringWithFormat:@"%d",(int)nowTime];
    NSString* strTime = [NSString stringWithFormat:@"%d",[time intValue]];
    return [GameCommon getTimeWithChatStyle:strNowTime AndMessageTime:strTime];
}
//头像默认图片
-(NSString*)headPlaceholderImage:(NSString*)gender
{
    if ([[GameCommon getNewStringWithId:gender] isEqualToString:@"0"]) {//男♀♂
        return @"people_man.png";
    }
    else
    {
        return @"people_woman.png";
    }
}
//性别图标
-(NSString*)genderImage:(NSString*)gender
{
    if ([gender intValue]==0)
    {
        return @"gender_boy";
    }else
    {
        return @"gender_girl";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary *dic = [[[m_dataArray objectAtIndex:indexPath.section]objectForKey:@"list"]objectAtIndex:indexPath.row];
    didClickDict = dic;
    if (self.shiptype ==0) {
        if ([KISDictionaryHaveKey(dic, @"type")intValue]==1) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"管理" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"转让群主",@"取消管理员",@"移除", nil];
            actionSheet.tag = 111;
            [actionSheet showInView:self.view];

        }else if ([KISDictionaryHaveKey(dic, @"type")intValue] ==2){
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"管理" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"转让群主",@"设置管理员",@"移除", nil];
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
            removeAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您确定移除该用户?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            removeAlertView.tag = 1002;
            [removeAlertView show];
     
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
            removeAlertView.tag = 1002;
            [removeAlertView show];
        }
 
    }else if(actionSheet.tag ==333){
        if (buttonIndex ==0) {
            removeAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您确定移除该用户?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            removeAlertView.tag = 1002;
            [removeAlertView show];
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
            if (buttonIndex ==0) {
                NSLog(@"1");
            }else{
                NSLog(@"2");
            [self editIdentityForNetWithDic:tempDict method:@"252" Successinfo:@"转让成功"];

            }
            break;
        case 1002:
            if (buttonIndex ==0) {
                NSLog(@"1");
            }else{
                NSLog(@"2");

            [self editIdentityForNetWithDic:tempDict method:@"249" Successinfo:@"移除成功"];
            }
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
        if ([method isEqualToString:@"252"]) {
            self.shiptype = [KISDictionaryHaveKey(responseObject, @"type")intValue]?[KISDictionaryHaveKey(responseObject, @"type")intValue ]:2;
            for(UIViewController *controller in self.navigationController.viewControllers) {
                if([controller isKindOfClass:[GroupInformationViewController class]]){
                    GroupInformationViewController*owr = (GroupInformationViewController *)controller;
                    owr.shiptypeCount =[KISDictionaryHaveKey(responseObject, @"type")intValue]?[KISDictionaryHaveKey(responseObject, @"type")intValue ]:2;
                    [self.navigationController popToViewController:owr animated:YES];
                }
            }
            
            
            
        }
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
}
- (void)dealloc
{
    ascensionGlyAlertView.delegate = nil;
    removeAlertView.delegate = nil;
}

@end
