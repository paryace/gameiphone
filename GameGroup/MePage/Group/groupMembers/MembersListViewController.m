//
//  MembersListViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MembersListViewController.h"
#import "GroupMembersCell.h"
#import "TestViewController.h"
@interface MembersListViewController ()
{
    UILabel*            m_titleLabel;
    
    UITableView*        m_myTableView;
    NSMutableDictionary*     m_tabelData;
    
    
    int            m_pageNum;
    
    NSString *requestType;
    NSMutableArray  *m_imgArray;
    UIAlertView* backpopAlertView;
}

@end

@implementation MembersListViewController

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
    // Do any additional setup after loading the view.
    [self setTopViewWithTitle:@"" withBackButton:YES];
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"share_normal.png") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"share_click.png") forState:UIControlStateSelected];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, KISHighVersion_7 ? 20 : 0, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
    m_titleLabel.text = @"群成员";
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:m_titleLabel];
    
    
    m_tabelData = [NSMutableDictionary dictionary];
    m_imgArray = [NSMutableArray array];
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-(KISHighVersion_7?0:20))];
    m_myTableView.dataSource = self;
    m_myTableView.delegate = self;
    [self.view addSubview:m_myTableView];
    
    requestType =@"members";
    [self getNearByDataByNetWithType:requestType];
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];

}

-(void)shareBtnClick:(UIButton *)sender
{
    if (sender.selected) {
        requestType =@"members";
        sender.selected =NO;
  
    }else{
        requestType =@"characters";
        sender.selected = YES;
    }
    [self getNearByDataByNetWithType:requestType];

}

- (void)getNearByDataByNetWithType:(NSString*)type
{
    [hud show:YES];
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc]init];
    [paramDict setObject:self.groupId forKey:@"groupId"];
    [paramDict setObject:type forKey:@"type"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon]getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"238" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [m_tabelData removeAllObjects];
            
            if ([type isEqualToString:@"members"]) {
                m_titleLabel.text = @"群成员";
            }else{
                m_titleLabel.text = @"群角色";
            }
            
            
            
            m_tabelData = responseObject;
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
    NSMutableArray *arary = [NSMutableArray arrayWithArray:[m_tabelData allKeys]];

    return arary.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arary = [m_tabelData allKeys];
    NSArray *sortedArray = [arary sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSArray *arr = [m_tabelData objectForKey:sortedArray[section]];
    
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableArray *arr  =[NSMutableArray arrayWithArray:[m_tabelData allKeys]];
    NSArray *sortedArray = [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    return sortedArray[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCell";
    GroupMembersCell *cell = (GroupMembersCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[GroupMembersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSArray *arary = [m_tabelData allKeys];
    NSArray *sortedArray = [arary sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];

    NSArray *arr = [m_tabelData objectForKey:sortedArray[indexPath.section]];

    NSDictionary* tempDict = [arr objectAtIndex:indexPath.row];
    
    
    if ([requestType isEqualToString:@"members"]) {
        cell.nameLable.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"nickname")];
        
        
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"gender")] isEqualToString:@"0"]) {//男♀♂
            cell.sexImageView.image = KUIImage(@"gender_boy");
            cell.headImageView.placeholderImage = [UIImage imageNamed:@"people_man.png"];
        }
        else
        {
            cell.sexImageView.image = KUIImage(@"gender_girl");
            cell.headImageView.placeholderImage = [UIImage imageNamed:@"people_woman.png"];
        }
        
        NSString * imageIds= KISDictionaryHaveKey(tempDict, @"img");
        cell.headImageView.imageURL = [ImageService getImageStr:imageIds Width:80];
        
        cell.timeLabel.text = [GameCommon getTimeWithMessageTime:KISDictionaryHaveKey(tempDict, @"updateUserLocationDate")];
        [cell.timeLabel setTextColor:[UIColor grayColor]];
        [cell.timeLabel setFont:[UIFont systemFontOfSize:13]];

    }else{
        cell.nameLable.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"characterInfo")];
        
        
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"gender")] isEqualToString:@"0"]) {//男♀♂
            cell.sexImageView.image = KUIImage(@"gender_boy");
            cell.headImageView.placeholderImage = [UIImage imageNamed:@"people_man.png"];
        }
        else
        {
            cell.sexImageView.image = KUIImage(@"gender_girl");
            cell.headImageView.placeholderImage = [UIImage imageNamed:@"people_woman.png"];
        }
        
        NSString * imageIds=  [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"characterImg")];
        cell.headImageView.imageURL = [ImageService getImageStr:imageIds Width:80];
        cell.timeLabel.text = [GameCommon getNewStringWithId: KISDictionaryHaveKey(tempDict, @"value")];
        [cell.timeLabel setTextColor:[UIColor blueColor]];
        [cell.timeLabel setFont:[UIFont systemFontOfSize:17]];

    }
  
    
//    cell.clazzImageView.imageURL = [ImageService getImageStr2:[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"characterImg")]];
//    cell.roleLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"characterInfo")];
//    cell.numLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"value1")];
//    cell.numOfLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"value2")];
//    [cell refreshCell];
    
//    NSArray * gameidss=[GameCommon getGameids:[tempDict objectForKey:@"gameids"]];
//    [cell setGameIconUIView:gameidss];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *arary = [m_tabelData allKeys];
    NSArray *sortedArray = [arary sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];

    NSArray *arr = [m_tabelData objectForKey:sortedArray[indexPath.section]];


    NSDictionary* recDict = [arr objectAtIndex:indexPath.row];
    TestViewController *VC = [[TestViewController alloc]init];
    VC.userId = KISDictionaryHaveKey(recDict, @"userid");
    [self.navigationController pushViewController:VC animated:YES];
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
