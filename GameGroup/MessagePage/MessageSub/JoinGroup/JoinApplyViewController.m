//
//  JoinApplyViewController.m
//  GameGroup
//
//  Created by Apple on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "JoinApplyViewController.h"
#import "JoinApplyCell.h"

@interface JoinApplyViewController ()
{
    UITableView * m_ApplyTableView;
    NSMutableArray * m_applyArray;
}
@end

@implementation JoinApplyViewController

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
    [self setTopViewWithTitle:@"申请列表" withBackButton:YES];
    
    m_applyArray = [NSMutableArray array];
    
    m_ApplyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height - startX) style:UITableViewStylePlain];
    m_ApplyTableView.separatorColor = [UIColor clearColor];
    m_ApplyTableView.dataSource = self;
    m_ApplyTableView.delegate = self;
    [self.view addSubview:m_ApplyTableView];
    
    [self getJoinGroupMsg];
}

-(void)getJoinGroupMsg
{
    m_applyArray = [DataStoreManager qureyCommonMessagesWithMsgType:@"joinGroupApplication"];
}
#pragma mark 表格
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_applyArray.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 125;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"joinApplyCell";
    JoinApplyCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JoinApplyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailDeleGate=self;
     cell.tag = indexPath.row;
     NSMutableDictionary *dict = [m_applyArray objectAtIndex:indexPath.row];
   
    NSDictionary *payload = [KISDictionaryHaveKey(dict, @"payload") JSONValue];
    
    cell.groupImageV.placeholderImage = KUIImage(@"placeholder.png");
     cell.groupImageV.imageURL = [ImageService getImageStr:KISDictionaryHaveKey(payload, @"backgroundImg") Width:160];
    cell.groupNameLable.text = KISDictionaryHaveKey(payload, @"groupName");
    
    cell.userImageV.placeholderImage = KUIImage(@"placeholder.png");
    cell.userImageV.imageURL = [ImageService getImageStr:KISDictionaryHaveKey(payload, @"userImg") Width:160];
    cell.userNameLable.text = KISDictionaryHaveKey(payload, @"nickname");
    cell.joinReasonLable.text = KISDictionaryHaveKey(payload, @"msg");
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{

}
-(void)agreeMsg:(JoinApplyCell*)sender
{
    NSInteger index  =  sender.tag ;
    NSMutableDictionary *dict = [m_applyArray objectAtIndex:index];
    NSDictionary *payload = [KISDictionaryHaveKey(dict, @"payload") JSONValue];
    NSString * applicationId = KISDictionaryHaveKey(payload, @"applicationId");
    [self msgEdit:@"1" ApplicationId:applicationId];
}

-(void)desAgreeMsg:(JoinApplyCell*)sender
{
    NSInteger index  =  sender.tag ;
    NSMutableDictionary *dict = [m_applyArray objectAtIndex:index];
    NSDictionary *payload = [KISDictionaryHaveKey(dict, @"payload") JSONValue];
    NSString * applicationId = KISDictionaryHaveKey(payload, @"applicationId");
    [self msgEdit:@"2" ApplicationId:applicationId];
}

-(void)ignoreMsg:(JoinApplyCell*)sender
{
}

-(void)msgEdit:(NSString*)state ApplicationId:(NSString*)applicationId
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:applicationId forKey:@"applicationId"];
    [paramDict setObject:state forKey:@"state"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"233" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"您已经同意加入群的申请"delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
