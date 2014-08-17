//
//  InvitationListViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-25.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "InvitationListViewController.h"
#import "InviationGroupViewController.h"
#import "InvitationMembersViewController.h"
@interface InvitationListViewController ()
{
    NSMutableArray *m_dataArray;
}
@end

@implementation InvitationListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setTopViewWithTitle:@"邀请成员" withBackButton:YES];

        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource =self;
        [self.view addSubview:tableView];
        
        m_dataArray = [NSMutableArray arrayWithObjects:@"邀请好友",@"邀请群组", nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = m_dataArray[indexPath.row];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        InvitationMembersViewController *invMeb = [[InvitationMembersViewController alloc]init];
        invMeb.gameId =self.gameId;
        invMeb.roomId = self.roomId;
//        invMeb.roomInfoDic =
        [self.navigationController pushViewController:invMeb animated:YES];
    }else{
        InviationGroupViewController *invGrp =[[ InviationGroupViewController alloc]init];
        invGrp.gameId =self.gameId;
        invGrp.roomId = self.roomId;
        [self.navigationController pushViewController:invGrp animated:YES];
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
