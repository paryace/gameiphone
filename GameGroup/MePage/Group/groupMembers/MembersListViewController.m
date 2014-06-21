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
    NSMutableArray*     m_dataArray;
    
    
    int            m_pageNum;
    
    NSString *requestType;
    NSMutableArray  *m_imgArray;
    UIAlertView* backpopAlertView;
}

@end

@implementation MembersListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"" withBackButton:YES];
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"GroupRoles") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"GroupMembers") forState:UIControlStateSelected];
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
    
    
    m_dataArray = [NSMutableArray array];
    
    m_imgArray = [NSMutableArray array];
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-(KISHighVersion_7?0:20))];
    m_myTableView.dataSource = self;
    m_myTableView.delegate = self;
    [GameCommon setExtraCellLineHidden:m_myTableView];

    [self.view addSubview:m_myTableView];
    
    requestType =@"members";
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    hud.labelText = @"获取中...";
    [self.view addSubview:hud];
    [self getNearByDataByNetWithType:requestType];

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
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [m_dataArray removeAllObjects];
            
            if ([type isEqualToString:@"members"]) {
                m_titleLabel.text = @"群成员";
            }else{
                m_titleLabel.text = @"群角色";
            }
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
    NSArray *arr = [[m_dataArray objectAtIndex:section]objectForKey:@"list"];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [m_dataArray[section]objectForKey:@"name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCell";
    GroupMembersCell *cell = (GroupMembersCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[GroupMembersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *tempDict = [[m_dataArray[indexPath.section]objectForKey:@"list"]objectAtIndex:indexPath.row];
    
    if ([requestType isEqualToString:@"members"]) {
        cell.sexImageView.hidden =NO;
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

        cell.headImageView.placeholderImage = KUIImage([self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")]);
        NSString * imageIds= KISDictionaryHaveKey(tempDict, @"img");
        
        cell.headImageView.imageURL = [ImageService getImageStr:imageIds Width:80];
        
        NSString *genderimage=[self genderImage:KISDictionaryHaveKey(tempDict, @"gender")];
        cell.sexImageView.image =KUIImage(genderimage);
        
        CGSize nameSize = [cell.nameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(200, 20) lineBreakMode:NSLineBreakByWordWrapping];
        cell.nameLable.frame = CGRectMake(60, 20, nameSize.width, 20);
        cell.sexImageView.frame = CGRectMake(60+nameSize.width+5, 20, 20, 20);

        cell.timeLabel.text = [GameCommon getTimeWithMessageTime:KISDictionaryHaveKey(tempDict, @"updateUserLocationDate")];
        [cell.timeLabel setTextColor:[UIColor grayColor]];
        [cell.timeLabel setFont:[UIFont systemFontOfSize:13]];

    }else{
        cell.nameLable.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"characterInfo")];
        CGSize nameSize = [cell.nameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(200, 20) lineBreakMode:NSLineBreakByWordWrapping];
        cell.nameLable.frame = CGRectMake(60, 20, nameSize.width, 20);
        cell.sexImageView.hidden = YES;
        NSString * imageIds=  [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"characterImg")];
        cell.headImageView.imageURL = [ImageService getImageStr:imageIds Width:80];
        cell.timeLabel.text = [GameCommon getNewStringWithId: KISDictionaryHaveKey(tempDict, @"value")];
        [cell.timeLabel setTextColor:UIColorFromRGBA(0x0077ff,1.0)];
        [cell.timeLabel setFont:[UIFont systemFontOfSize:17]];
    }
    return cell;
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
    
    NSDictionary *tempDict = [[m_dataArray[indexPath.section]objectForKey:@"list"]objectAtIndex:indexPath.row];
    
    TestViewController *VC = [[TestViewController alloc]init];
    VC.userId = KISDictionaryHaveKey(tempDict, @"userid");
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
