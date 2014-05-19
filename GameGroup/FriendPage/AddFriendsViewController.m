//
//  AddFriendsViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-5-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "SearchResultViewController.h"
#import "SearchJSViewController.h"
@interface AddFriendsViewController ()
{
    UITextField * searchContent;
    
    UIScrollView* m_roleView;
    UITextField*  m_gameNameText;
    //    UIPickerView* m_serverNamePick;
    UITextField*  m_roleNameText;
    NSInteger    m_pageNum;
    NSArray *sjArray;
}
@end

@implementation AddFriendsViewController

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
    
    [self setTopViewWithTitle:@"添加好友" withBackButton:YES];
    sjArray = [NSArray arrayWithObjects:@"查找游戏角色",@"搜索游戏组织", nil];

    UILabel* warnLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10 + startX, 300, 30)];
    warnLabel.textColor = kColorWithRGB(154, 154, 154, 1.0);
    warnLabel.shadowColor = [UIColor whiteColor];
    [warnLabel setFont:[UIFont systemFontOfSize:15.0]];
    warnLabel.backgroundColor = [UIColor clearColor];
    warnLabel.text = @"查找陌游用户";

    [self.view addSubview:warnLabel];
    
    UIImageView* table_top = [[UIImageView alloc] initWithFrame:CGRectMake(10, 45 + startX, 300, 40)];
    table_top.image = KUIImage(@"text_bg");
    [self.view addSubview:table_top];
    
    searchContent = [[UITextField alloc] initWithFrame:CGRectMake(15, 45 + startX, 290, 40)];
    searchContent.returnKeyType = UIReturnKeyDone;
    searchContent.delegate = self;
    searchContent.font = [UIFont boldSystemFontOfSize:15.0];
    searchContent.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    searchContent.placeholder = @"陌游ID/陌游昵称/手机号";
    searchContent.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:searchContent];
    
//    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 110 + startX, 300, 40)];
//    [okButton setBackgroundImage:KUIImage(@"blue_button_normal") forState:UIControlStateNormal];
//    [okButton setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
//    [okButton setTitle:@"搜 索" forState:UIControlStateNormal];
//    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    okButton.backgroundColor = [UIColor clearColor];
//    [okButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:okButton];
    
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"搜索中...";

    // Do any additional setup after loading the view.
    
    UITableView *tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 110+startX, 320, 88)];
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.rowHeight = 44;
    tableview.bounces =NO;
    tableview.scrollEnabled = NO;

    [self.view addSubview:tableview];
    
}
- (void)okButtonClick:(id)sender
{
    [searchContent resignFirstResponder];
    [m_roleNameText resignFirstResponder];
    
    if (KISEmptyOrEnter(searchContent.text)) {
        [self showAlertViewWithTitle:@"提示" message:@"请把搜索内容填写完整！" buttonTitle:@"确定"];
        return;
    }
        SearchResultViewController *SV = [[SearchResultViewController alloc]init];
        SV.nickNameList =searchContent.text;
//        SV.myViewType = SearchResult_FromNet;

        [self.navigationController pushViewController:SV animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sjArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =[[ UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    NSArray *array = [NSArray arrayWithObjects:@"find_role",@"find_guild", nil];
    UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 24, 24)];
    iconImageView.image = KUIImage(array[indexPath.row]);
    [cell.contentView addSubview:iconImageView];
    
    
    UIImageView *rightView = [[UIImageView alloc]initWithFrame:CGRectMake(300, 14, 8, 12)];
    rightView.image = KUIImage(@"right_arrow");
    [cell.contentView addSubview:rightView];
    
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, 200, 40)];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = [sjArray objectAtIndex:indexPath.row];
    [cell.contentView addSubview:titleLabel];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

        SearchJSViewController *searchp = [[SearchJSViewController alloc]init];
    if (indexPath.row ==0) {
        searchp.myViewType = SEARCH_TYPE_ROLE;
    }else{
        searchp.myViewType = SEARCH_TYPE_FORCES;
    }
    [self.navigationController pushViewController:searchp animated:YES];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self okButtonClick:nil];
    return YES;
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
