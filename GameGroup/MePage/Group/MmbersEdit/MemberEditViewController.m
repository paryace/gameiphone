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
    [self.view addSubview:m_myTableView];

    
    [self getNearByDataByNet];
    
    // Do any additional setup after loading the view.
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
            [m_dataArray removeAllObjects];
            [m_dataArray addObjectsFromArray:responseObject];
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
    return [m_dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCell";
    MemberEditCell *cell = (MemberEditCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MemberEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary* tempDict = [m_dataArray objectAtIndex:indexPath.row];
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
    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    
    if (m_dataArray==nil||m_dataArray.count==0) {
        return;
    }
    if (self.shiptype ==0) {
        if ([KISDictionaryHaveKey(dic, @"type")intValue]==1) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"管理" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"转让群组",@"取消管理员",@"移除",@"移除并举报", nil];
            [actionSheet showInView:self.view];

        }else if ([KISDictionaryHaveKey(dic, @"type")intValue] ==2){
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"管理" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"转让群组",@"设置管理员",@"移除",@"移除并举报", nil];
        [actionSheet showInView:self.view];
        }

    }else{
        if ([KISDictionaryHaveKey(dic, @"type")intValue]==2) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"管理" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"移除",@"移除并举报", nil];
            [actionSheet showInView:self.view];
            
        }else {
            
        }
    }
  
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
