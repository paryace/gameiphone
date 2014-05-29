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
#import "MessageAddressViewController.h"
@interface AddFriendsViewController ()
{
    UITextField * searchContent;
    
    UIScrollView* m_roleView;
    UITextField*  m_gameNameText;
    //    UIPickerView* m_serverNamePick;
    UITextField*  m_roleNameText;
    NSInteger    m_pageNum;
    NSArray *sjArray;
    UITableView *m_myTableview;
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
    sjArray = [NSArray arrayWithObjects:@"查找游戏角色",@"搜索游戏组织",@"手机通讯录", nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignFirstResponder:)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];

    UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15+startX,20, 20)];
    iconImageView.image =KUIImage(@"moyou_icon");
    [self.view addSubview:iconImageView];
    
    UILabel* warnLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10 + startX, 300, 30)];
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
    
//    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(250, 50+startX, 40, 40)];
//    [button setImage:KUIImage(@"search_person") forState:UIControlStateNormal];
//    [button setImageEdgeInsets:UIEdgeInsetsMake(8, 10, 12, 10)];
//
//    [button addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:button];
    
    
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
    
    m_myTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 110+startX, 320, 132)];
    m_myTableview.delegate = self;
    m_myTableview.dataSource = self;
    m_myTableview.rowHeight = 44;
    m_myTableview.bounces =NO;
    m_myTableview.scrollEnabled = NO;

    [self.view addSubview:m_myTableview];
    
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
    
    NSArray *array = [NSArray arrayWithObjects:@"find_role",@"find_guild",@"find_address", nil];
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
    if (indexPath.row ==2) {
        MessageAddressViewController *aaa = [[MessageAddressViewController alloc]init];
        [self.navigationController pushViewController:aaa animated:YES];
    }else{
    if(indexPath.row==0){
        searchp.myViewType = SEARCH_TYPE_ROLE;

    }else{
        searchp.myViewType = SEARCH_TYPE_FORCES;

    }
        [self.navigationController pushViewController:searchp animated:YES];
  
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self okButtonClick:nil];
    return YES;
}
-(BOOL)resignFirstResponder:(UITapGestureRecognizer *)sender
{
	[super resignFirstResponder];
	return [searchContent resignFirstResponder];
}
//手势代理的方法，解决手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]]||[touch.view isKindOfClass:[UITableView class]])
    {
        return NO;
    }
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
