//
//  TemporaryFriendController.m
//  GameGroup
//
//  Created by Apple on 14-8-22.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TemporaryFriendController.h"
#import "NewPersonalTableViewCell.h"
#import "TestViewController.h"
#import "MenuTableView.h"

@interface TemporaryFriendController (){
    NSMutableArray * dataArray;
    UITableView*  m_myTableView;
}

@end

@implementation TemporaryFriendController

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
     [self setTopViewWithTitle:@"好友列表" withBackButton:YES];
     self.view.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    
    UIButton *delButton=[UIButton buttonWithType:UIButtonTypeCustom];
    delButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [delButton setBackgroundImage:KUIImage(@"deleteButton") forState:UIControlStateNormal];
    [delButton setBackgroundImage:KUIImage(@"deleteButton2") forState:UIControlStateHighlighted];
    [self.view addSubview:delButton];
    [delButton addTarget:self action:@selector(cleanBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX)];
    m_myTableView.dataSource = self;
    m_myTableView.delegate = self;
    m_myTableView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    [self.view addSubview:m_myTableView];
    
    
    
}

//举报邀请
-(void)cleanBtnClick:(id)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:@"选择性别" delegate:self cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil otherButtonTitles:@"先生",@"女士",@"未知",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}
//通知方式
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==0) {
        [self getFriendListFromNet:@"0"];
    }
    else if (buttonIndex ==1)
    {
        [self getFriendListFromNet:@"1"];
    }
    else if (buttonIndex ==2)
    {
        [self getFriendListFromNet:@""];
    }
}
//返回组的数量
#pragma mark 表格
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  1;
}
//返回每个组里面的数据条数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;

    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * stringCell3 = @"cell";
    NewPersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:stringCell3];
    if (!cell) {
        cell = [[NewPersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell3];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary * tempDict =[dataArray objectAtIndex:indexPath.row];
    if (tempDict&&[tempDict isKindOfClass:[NSDictionary class]]) {
        NSString * headplaceholderImage= [self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")];
        cell.headImageV.placeholderImage = [UIImage imageNamed:headplaceholderImage];
        NSString * imageids=KISDictionaryHaveKey(tempDict, @"img");
        cell.headImageV.imageURL=[ImageService getImageStr:imageids Width:80];
        NSString *genderimage=[self genderImage:KISDictionaryHaveKey(tempDict, @"gender")];
        cell.sexImg.image =KUIImage(genderimage);
        NSString * nickName=[tempDict objectForKey:@"type"];
        if (nickName) {
            cell.nameLabel.text = nickName;
        }
        
    }
    return cell;
}
//头像默认图片
-(NSString*)headPlaceholderImage:(NSString*)gender
{
    if (!gender) {
        return @"people_man.png";
    }
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
    if (!gender) {
        return @"gender_boy";
    }
    if ([gender intValue]==0)
    {
        return @"gender_boy";
    }else
    {
        return @"gender_girl";
    }
}
//点击Table进入个人详情
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    NSDictionary * tempDict =[dataArray objectAtIndex:indexPath.row];
    TestViewController *detailVC = [[TestViewController alloc]init];
    detailVC.userId = KISDictionaryHaveKey(tempDict, @"userid");
    [self.navigationController pushViewController:detailVC animated:YES];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
#pragma mark 请求数据
- (void)getFriendListFromNet:(NSString*)gender
{
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:gender forKey:@"gender"];
    [paramDict setObject:[GameCommon getNewStringWithId:self.gameid] forKey:@"gameid"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"295" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        dataArray = responseObject;
        [m_myTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, id error) {

    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
