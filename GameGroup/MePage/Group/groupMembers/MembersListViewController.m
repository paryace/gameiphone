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
    NSMutableArray*     m_tabelData;
    
    
    int            m_pageNum;
    

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
    
    
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, KISHighVersion_7 ? 20 : 0, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
    m_titleLabel.text = @"查询结果";
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:m_titleLabel];
    
    
    m_tabelData = [[NSMutableArray alloc] init];
    m_imgArray = [NSMutableArray array];
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-(KISHighVersion_7?0:20))];
    m_myTableView.dataSource = self;
    m_myTableView.delegate = self;
    [self.view addSubview:m_myTableView];
    
    [self getNearByDataByNet];

}
- (void)getNearByDataByNet
{
    [hud show:YES];
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc]init];
    [paramDict setObject:self.groupId forKey:@"groupId"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon]getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"238" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [m_tabelData removeAllObjects];
            [m_tabelData addObjectsFromArray:responseObject];
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
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_tabelData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCell";
    GroupMembersCell *cell = (GroupMembersCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[GroupMembersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary* tempDict = [m_tabelData objectAtIndex:indexPath.row];
    cell.nameLable.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"nickname")];
    
    
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"gender")] isEqualToString:@"0"]) {//男♀♂
        cell.sexImageView.image = KUIImage(@"");
        cell.headImageView.placeholderImage = [UIImage imageNamed:@"people_man.png"];
    }
    else
    {
        cell.sexImageView.image = KUIImage(@"");
        cell.headImageView.placeholderImage = [UIImage imageNamed:@"people_woman.png"];
    }
    
     NSString * imageIds= KISDictionaryHaveKey(tempDict, @"img");
    cell.headImageView.imageURL = [ImageService getImageStr:imageIds Width:80];
    
    cell.timeLabel.text = [GameCommon getTimeWithMessageTime:KISDictionaryHaveKey(tempDict, @"updateUserLocationDate")];
    
    cell.clazzImageView.imageURL = [ImageService getImageStr2:KISDictionaryHaveKey(tempDict, @"characterImg")];
    cell.roleLabel.text = KISDictionaryHaveKey(tempDict, @"characterInfo");
    cell.numLabel.text = KISDictionaryHaveKey(tempDict, @"value1");
    cell.numOfLabel.text = KISDictionaryHaveKey(tempDict, @"value2");
//    [cell refreshCell];
    
//    NSArray * gameidss=[GameCommon getGameids:[tempDict objectForKey:@"gameids"]];
//    [cell setGameIconUIView:gameidss];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (m_tabelData==nil||m_tabelData.count==0) {
        return;
    }
    NSDictionary* recDict = [m_tabelData objectAtIndex:indexPath.row];
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
