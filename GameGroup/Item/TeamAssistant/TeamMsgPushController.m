//
//  TeamMsgPushController.m
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TeamMsgPushController.h"

@interface TeamMsgPushController ()

@end

@implementation TeamMsgPushController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"组队推送" withBackButton:YES];
    self.view.backgroundColor = UIColorFromRGBA(0xf3f3f3,1);
    
    _m_TableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, self.view.bounds.size.width, self.view.bounds.size.height - startX) style:UITableViewStylePlain];
    _m_TableView.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    _m_TableView.delegate = self;
    _m_TableView.dataSource  = self;
    [GameCommon setExtraCellLineHidden:_m_TableView];
    [self.view addSubview:_m_TableView];
    
    [self getPreferences];
}

#pragma mark ----tableview delegate  datasourse
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3+1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if (section == 3){
        return 1;
    }
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellinde = @"headcell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
        }
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 1)];
        lineView.backgroundColor = kColorWithRGB(225, 225, 225, 1);
        [cell.contentView addSubview:lineView];
        
        UILabel *tlb = [[UILabel alloc]initWithFrame:CGRectMake(20, 13, 320-25, 20)];
        tlb.backgroundColor = [UIColor clearColor];
        tlb.textColor = [UIColor blackColor];
        tlb.text = @"接受以下推送(4)";
        tlb.font =[ UIFont systemFontOfSize:16];
        [cell.contentView addSubview:tlb];
        
        UISwitch *soundSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(320-80, 8, 60, 30)];
        soundSwitch.on = YES;
        [soundSwitch addTarget:self action:@selector(infomationAccording:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:soundSwitch];
        
        return cell;
    }else if (indexPath.section == 3) {
        static NSString *cellinde = @"footercell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellinde];
        if (cell ==nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellinde];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 1)];
        lineView.backgroundColor = kColorWithRGB(225, 225, 225, 1);
        [cell.contentView addSubview:lineView];
        
        UILabel *tlb = [[UILabel alloc]initWithFrame:CGRectMake(20, 13, 320-25, 20)];
        tlb.backgroundColor = [UIColor clearColor];
        tlb.textColor = kColorWithRGB(139, 169, 209, 1);
        tlb.text = @"添加推送";
        tlb.font =[ UIFont systemFontOfSize:16];
        [cell.contentView addSubview:tlb];
        return cell;
    }
    static NSString *indifience = @"TeamMsgPushCell";
    TeamMsgPushCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
    if (!cell) {
        cell = [[TeamMsgPushCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.titleLabel.text = @"公会招募";
    cell.contentLabel.text = @"队长是妹子的队伍";
    return cell;
}
-(void)infomationAccording:(UISwitch*)sender
{
    if ([sender isOn]) {
        NSLog(@"----onOpen----");
        
    }else{
        NSLog(@"----onClose----");
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 46;
    }else if (indexPath.section ==3){
        return 46;
    }
    return 65;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
       
    }else if (indexPath.section == 3){
        AddTeamMsgPushController *detailVC = [[AddTeamMsgPushController alloc]init];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    NSLog(@"---onClickItem---");
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
        view.backgroundColor = kColorWithRGB(245, 245, 245, 1);
        return view;
    }else if (section == 3){
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
        view.backgroundColor = kColorWithRGB(245, 245, 245, 1);
        return view;
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 35)];
    view.backgroundColor = kColorWithRGB(245, 245, 245, 1);
    EGOImageView * gamgImageView =[[EGOImageView alloc]initWithFrame:CGRectMake(20, 10, 15, 15)];
    NSString * gameImage = [GameCommon putoutgameIconWithGameId:[GameCommon getNewStringWithId:@"1"]];
    gamgImageView.imageURL = [ImageService getImageUrl4:gameImage];

    [view addSubview:gamgImageView];
    
    UILabel *label  =[[UILabel alloc]initWithFrame:CGRectMake(40, 0, 320-45, 35)];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = kColorWithRGB(164, 164, 164, 1);
    label.backgroundColor = [UIColor clearColor];
    label.text =@"石爪峰--征服者";
    [view addSubview:label];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 35, 320, 1)];
    lineView.backgroundColor = kColorWithRGB(225, 225, 225, 1);
    [view addSubview:lineView];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 30;
    }else if (section == 3){
        return 30;
    }
    return 35;
}
#pragma mark ---
-(void)getPreferences
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"276" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"------%@------",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self showErrorAlert:error];
    }];
}
-(void)showErrorAlert:(id)error
{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
