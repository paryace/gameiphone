//
//  AttentionMessageViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-31.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "AttentionMessageViewController.h"
//#import "MyNormalTableCell.h"
#import "MessageCell.h"
#import "TestViewController.h"
#import "KKChatController.h"
@interface AttentionMessageViewController ()
{
    UITableView*  m_myTableView;
    
    NSMutableArray * allMsgUnreadArray;
    
    NSMutableArray * allSayHelloArray;//id
    NSMutableArray * sayhellocoArray;//内容

}
@end

@implementation AttentionMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [m_myTableView reloadData];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTopViewWithTitle:[NSString stringWithFormat:@"打招呼(%d)",self.personCount] withBackButton:YES];
    self.dataArray = [NSMutableArray array];

    allSayHelloArray = [NSMutableArray array];
    allMsgUnreadArray = [NSMutableArray array];
    

    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth-startX-(KISHighVersion_7?0:20))];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];
    [self getSayHelloUserInfo];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserUpdate:) name:@"userInfoUpdated" object:nil];
    
}

-(void)getSayHelloUserInfo
{
    self.dataArray = (NSMutableArray *)[DataStoreManager qureyAllThumbMessagesWithType:@"2"];
    [m_myTableView reloadData];

}
- (void)backButtonClick:(id)sender
{
   // m_myTableView.editing = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteButtonClick:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确认要清除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.tag = 345;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 345) {
        if (alertView.cancelButtonIndex != buttonIndex) {
            [DataStoreManager deleteAllHello];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}



#pragma mark 表格
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"userCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.headImageV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];

    NSURL * theUrl = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@/80",[GameCommon getHeardImgId:[[self.dataArray objectAtIndex:indexPath.row]senderimg]]]];
    if ([[[self.dataArray objectAtIndex:indexPath.row]senderimg]isEqualToString:@""]||[[[self.dataArray objectAtIndex:indexPath.row]senderimg]isEqualToString:@" "]) {
        cell.headImageV.imageURL = nil;
    }else{
        cell.headImageV.imageURL = theUrl;
    }
    cell.contentLabel.text = [[self.dataArray objectAtIndex:indexPath.row]msgContent];
    cell.nameLabel.text = [[self.dataArray objectAtIndex:indexPath.row]senderNickname];
    cell.timeLabel.text = [GameCommon CurrentTime:[[GameCommon getCurrentTime] substringToIndex:10]AndMessageTime:[[[self.dataArray objectAtIndex:indexPath.row]sendTimeStr] substringToIndex:10]];

    return cell;
}

-(NSString *)getHead:(NSString *)headImgStr
{
    NSArray* i = [headImgStr componentsSeparatedByString:@","];
    if (i.count>0) {
        for (NSString* a in i) {
            if (a.length > 0 && ![a isEqualToString:@" "])
                return a;
        }
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    KKChatController *kkchat = [[KKChatController alloc]init];
    kkchat.nickName = [[self.dataArray objectAtIndex:indexPath.row]senderNickname];
    kkchat.chatWithUser = [NSString stringWithFormat:@"%@",[[self.dataArray objectAtIndex:indexPath.row]sender]];
    kkchat.chatUserImg = [[self.dataArray objectAtIndex:indexPath.row]senderimg];

    [self.navigationController pushViewController:kkchat animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        //NSDictionary* tempDic = [self.dataArray objectAtIndex:indexPath.row];

            [DataStoreManager deleteThumbMsgWithSender:[NSString stringWithFormat:@"%@",[[self.dataArray objectAtIndex:indexPath.row]sender]]];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
