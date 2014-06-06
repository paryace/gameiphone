//
//  BlackListViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-5.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BlackListViewController.h"
#import "BlackListCell.h"
#import "TestViewController.h"
@interface BlackListViewController ()
{
    UITableView *m_myTableView;
    NSMutableArray *m_dataArray;
}
@end

@implementation BlackListViewController

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
    [self setTopViewWithTitle:@"黑名单" withBackButton:YES];
    
    m_dataArray = [NSMutableArray array];
    
    
    m_dataArray =[DataStoreManager queryAllBlackListInfo];
    
    if (m_dataArray.count<1) {
        [self showAlertViewWithTitle:@"提示" message:@"您的黑名单是空的哟" buttonTitle:@"确定"];
    }
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];
    
    // Do any additional setup after loading the view.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *newCell = @"cell";
    BlackListCell *cell = [tableView dequeueReusableCellWithIdentifier:newCell];
    if (!cell) {
        cell = [[BlackListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newCell];
    }
    DSBlackList *blackList = [m_dataArray objectAtIndex:indexPath.row];
    cell.headImageV.imageURL = [ImageService getImageStr:blackList.headimg Width:80];
    
    cell.nameLabel.text = blackList.nickname;
    cell.distLabel.text = [NSString stringWithFormat:@"拉黑时间:%@",[self getTimeWithMessageTime:blackList.time]];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DSBlackList *dBl = m_dataArray[indexPath.row];
    TestViewController *testView = [[TestViewController alloc]init];
    testView.userId = dBl.userid;
    testView.nickName = dBl.nickname;
    [self.navigationController pushViewController:testView animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DSBlackList *dBlack = m_dataArray[indexPath.row];
    

    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        [self getUserInfoByNetWithUserid:dBlack.userid];
        [DataStoreManager deletePersonFromBlackListWithUserid:dBlack.userid];
        m_dataArray = [DataStoreManager queryAllBlackListInfo];
        [m_myTableView reloadData];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
#pragma mark --删除黑名单成员
- (void)getUserInfoByNetWithUserid:(NSString *)userid
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:userid forKey:@"userid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"227" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];

    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];
}
- (NSString*)getTimeWithMessageTime:(NSString*)messageTime
{
    NSString* currentString = [GameCommon getCurrentTime];
    if (messageTime.length < 10 || currentString.length < 10) {
        return @"未知";
    }
    NSString* curStr = [currentString substringToIndex:messageTime.length-3];
    NSString* mesStr = [messageTime substringToIndex:messageTime.length-3];
    
    double theCurrentT = [curStr doubleValue];
    double theMessageT = [mesStr doubleValue];
    
    NSLog(@"%f--%f",theCurrentT,theMessageT);
    NSLog(@"++%f",theCurrentT-theMessageT);
//    if (((int)(theCurrentT-theMessageT))<60) {
//        return @"1分钟以前";
//    }
//    if (((int)(theCurrentT-theMessageT))<60*59) {
//        return [NSString stringWithFormat:@"%.f分钟以前",((theCurrentT-theMessageT)/60+1)];
//    }
//    if (((int)(theCurrentT-theMessageT))<60*60*24&&((int)(theCurrentT-theMessageT))>60*59) {
//        return [NSString stringWithFormat:@"%.f小时以前",((theCurrentT-theMessageT)/3600)==0?1:((theCurrentT-theMessageT)/3600)];
//    }
//    if (((int)(theCurrentT-theMessageT))<60*60*48) {
//        return @"昨天";
//    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *messageDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    return [messageDateStr substringFromIndex:5];
}

- (void)dealloc
{
    m_myTableView.delegate = nil;
    m_myTableView.dataSource = nil;
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
