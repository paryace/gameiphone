//
//  BillboardViewController.m
//  GameGroup
//
//  Created by Apple on 14-6-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BillboardViewController.h"
#import "BillBoardCell.h"
#import "KKChatController.h"

@interface BillboardViewController ()
{
    UITableView*     m_billboardTabel;
    NSMutableArray*  m_dataArray;

}
@end

@implementation BillboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"群公告" withBackButton:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedBillboardMsg:) name:Billboard_msg object:nil];
    
    UIButton *delButton=[UIButton buttonWithType:UIButtonTypeCustom];
    delButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [delButton setBackgroundImage:KUIImage(@"deleteButton") forState:UIControlStateNormal];
    [delButton setBackgroundImage:KUIImage(@"deleteButton2") forState:UIControlStateHighlighted];
    [self.view addSubview:delButton];
    [delButton addTarget:self action:@selector(cleanBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    m_billboardTabel = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth- startX)];
    m_billboardTabel.delegate = self;
    m_billboardTabel.dataSource = self;
    [GameCommon setExtraCellLineHidden:m_billboardTabel];
    [self.view addSubview:m_billboardTabel];
    [self getJoinGroupMsg];
}

-(void)getJoinGroupMsg
{
    m_dataArray = [DataStoreManager queryDSGroupApplyMsgByMsgType:@"groupBillboard"];
    [m_billboardTabel reloadData];
}
#pragma mark 收到公告消息
-(void)receivedBillboardMsg:(NSNotification*)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:0 forKey:Billboard_msg_count];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [m_dataArray insertObject:sender.userInfo atIndex:0];
    [m_billboardTabel reloadData];
}

#pragma mark -清空公告按钮
- (void)cleanBtnClick:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"将会清除所有的公告" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 345;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 345) {
        if (buttonIndex==1) {
            [DataStoreManager deleteJoinGroupApplicationByMsgType:@"groupBillboard"];
            [m_dataArray removeAllObjects];
            [m_billboardTabel reloadData];
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BillBoardCell *cell = (BillBoardCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    float heigth = cell.billContentLable.frame.size.height + 35;
    return heigth < 60 ? 60 : heigth;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"billBoardCell";
    BillBoardCell *cell = (BillBoardCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[BillBoardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
     NSMutableDictionary *tempDic=[NSMutableDictionary dictionaryWithDictionary:[m_dataArray objectAtIndex:indexPath.row]];
    NSString * groupName = KISDictionaryHaveKey(tempDic, @"groupName");
    NSString * billboard = KISDictionaryHaveKey(tempDic, @"billboard");
    NSString * createDate = KISDictionaryHaveKey(tempDic, @"createDate");
    NSString * backgroundImg = KISDictionaryHaveKey(tempDic, @"backgroundImg");
    
    cell.groupHeadImage.placeholderImage=KUIImage(@"people_man.png");
    cell.groupHeadImage.imageURL=[ImageService getImageStr:backgroundImg Width:80];
    
    cell.groupNameLable.text=groupName;
    cell.billTimeLable.text = [NSString stringWithFormat:@"%@", [self getMsgTime:createDate]];
    CGSize textSize = [cell.billTimeLable.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    cell.billTimeLable.frame=CGRectMake(320 - textSize.width-10, 4, textSize.width, 25);
    cell.billContentLable.text=billboard;
    //计算高度, 刷新Cell
    if([[tempDic allKeys]containsObject:@"commentCellHeight"])
    {
        float height = [KISDictionaryHaveKey(tempDic, @"commentCellHeight") floatValue];
        cell.billContentLable.frame = CGRectMake(65, 28, 245, height);
    }
    else{
        CGSize sizeThatFits = [cell.billContentLable sizeThatFits:CGSizeMake(245, MAXFLOAT)];
        float height1= sizeThatFits.height;
        cell.billContentLable.frame = CGRectMake(65, 28, 245, height1);
        [tempDic setObject:@(height1) forKey:@"commentCellHeight"];
    }
    return cell;
}
//格式化时间
-(NSString*)getMsgTime:(NSString*)senderTime
{
    NSString *time = [senderTime substringToIndex:10];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSString* strNowTime = [NSString stringWithFormat:@"%d",(int)nowTime];
    NSString* strTime = [NSString stringWithFormat:@"%d",[time intValue]];
    return [GameCommon getTimeWithChatStyle:strNowTime AndMessageTime:strTime];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_billboardTabel deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary *tempDic=[NSMutableDictionary dictionaryWithDictionary:[m_dataArray objectAtIndex:indexPath.row]];
    KKChatController * kkchat = [[KKChatController alloc] init];
    kkchat.chatWithUser = KISDictionaryHaveKey(tempDic, @"groupId");
    kkchat.type = @"group";
    [self.navigationController pushViewController:kkchat animated:YES];

}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        NSDictionary *dic =[m_dataArray objectAtIndex:indexPath.row];
        NSString *messageId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"msgId")];
        [m_dataArray removeObjectAtIndex:indexPath.row];
        [DataStoreManager deleteJoinGroupApplicationWithMsgId:messageId];
        [m_billboardTabel reloadData];
        
    }
}
-(void)dealloc
{
    m_billboardTabel.delegate = nil;
    m_billboardTabel.dataSource = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
