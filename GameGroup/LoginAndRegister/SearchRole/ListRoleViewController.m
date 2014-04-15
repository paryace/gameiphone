//
//  ListRoleViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-30.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "ListRoleViewController.h"
#import "HelpViewController.h"
@interface ListRoleViewController ()
{
    UITableView*    m_myTableView;
    NSArray*        m_indexArray;
    
    NSString*       m_result;//最终选择的
}
@end

@implementation ListRoleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:self.guildStr withBackButton:YES];
    
    if ([[self.dataDic allKeys] count] != 0) {
        
        m_indexArray = [[self.dataDic allKeys] sortedArrayUsingSelector:@selector(compare:)];
        //        m_realmsIndexArray = [m_realmsDic allKeys];
    }
    
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-(KISHighVersion_7?0:20)-30)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, m_myTableView.bounds.size.height+startX+(KISHighVersion_7?0:20), 320, 1)];
    view.backgroundColor = UIColorFromRGBA(0xd3d3d3, 1);
    [self.view addSubview:view];
    UILabel *helpLbel = [[UILabel alloc]initWithFrame:CGRectMake(0, m_myTableView.bounds.size.height+startX+(KISHighVersion_7?0:20)+1, 320, 30)];
    helpLbel.text = @"角色为何在公会里查不到？";
    helpLbel.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    helpLbel.font = [UIFont systemFontOfSize:12];
    helpLbel.textColor = kColorWithRGB(41, 164, 246, 1.0);
    helpLbel.userInteractionEnabled = YES;
    helpLbel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:helpLbel];
    [helpLbel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterToHelpPage:)]];
    
    
    
}

-(void)enterToHelpPage:(id)sender
{
    HelpViewController *helpVC = [[HelpViewController alloc]init];
    helpVC.myUrl = @"content.html?3";
    [self.navigationController pushViewController:helpVC animated:YES];

}

#pragma mark 表格
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [m_indexArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [KISDictionaryHaveKey(self.dataDic, [m_indexArray objectAtIndex:section]) count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myRealm";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    NSDictionary* dic = [[self.dataDic objectForKey:[m_indexArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    if ([dic isKindOfClass:[NSDictionary class]]) {
        cell.textLabel.text = KISDictionaryHaveKey(dic, @"charactername");
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@级%@", [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"level")], KISDictionaryHaveKey(dic, @"characterclass")];
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:13.0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    m_result = [m_myTableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"您确定选择角色：%@吗？", m_result] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 234;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 234) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self.myDelegate selectRoleOKWithName:m_result];
            
            NSInteger currentIndex = 2;
            for (int i = 0; i < [self.navigationController.viewControllers count]; i++) {
                if ((UIViewController*)[self.navigationController.viewControllers objectAtIndex:i] == self) {
                    currentIndex = i;
                }
            }
//            [self.navigationController popViewControllerAnimated:YES];
            [self.navigationController popToViewController:(UIViewController*)[self.navigationController.viewControllers objectAtIndex:currentIndex - 2] animated:YES];
        }
    }
}

#pragma mark 索引
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    //    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
    //        return @"";
    //    }
    return [m_indexArray objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return m_indexArray;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
