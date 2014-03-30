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
   // [self readAllnickNameAndImage];
    [self getSayHelloUserInfo];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserUpdate:) name:@"userInfoUpdated" object:nil];
    
}

-(void)getSayHelloUserInfo
{
    NSMutableArray *array = (NSMutableArray *)[DataStoreManager qureyAllThumbMessages];
    [self.dataArray removeAllObjects];
    
    NSMutableArray *unarray = [NSMutableArray array];
    
    unarray = [[NSUserDefaults standardUserDefaults]objectForKey:@"sayHello_wx_info_id"];
    
    for (int i = 0; i <array.count; i++) {
        if (![unarray containsObject:[[array objectAtIndex:i] sender]]&&[[[array objectAtIndex:i] msgType]isEqualToString:@"normalchat"]) {
            NSMutableDictionary * thumbMsgsDict = [NSMutableDictionary dictionary];
            [thumbMsgsDict setObject:[[array objectAtIndex:i] sender] forKey:@"sender"];
            [thumbMsgsDict setObject:[[array objectAtIndex:i] msgContent] forKey:@"msg"];
            NSDate * tt = [[array objectAtIndex:i] sendTime];
            NSTimeInterval uu = [tt timeIntervalSince1970];
            [thumbMsgsDict setObject:[NSString stringWithFormat:@"%.f", uu] forKey:@"time"];
            [thumbMsgsDict setObject:[[array objectAtIndex:i] messageuuid] forKey:@"messageuuid"];
            [thumbMsgsDict setObject:[[array objectAtIndex:i] msgType] forKey:@"msgType"];
            [self.dataArray addObject:thumbMsgsDict];
            
        }
    }
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

    NSURL * theUrl = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@/80",[GameCommon getHeardImgId:[self.imgArray objectAtIndex:indexPath.row]]]];
    if ([[self.imgArray objectAtIndex:indexPath.row]isEqualToString:@""]||[[self.imgArray objectAtIndex:indexPath.row]isEqualToString:@" "]) {
        cell.headImageV.imageURL = nil;
    }else{
        cell.headImageV.imageURL = theUrl;
    }
    cell.contentLabel.text = [[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"msg"];
    cell.nameLabel.text = [self.nickNameArray objectAtIndex:indexPath.row];
    cell.timeLabel.text = [GameCommon CurrentTime:[[GameCommon getCurrentTime] substringToIndex:10]AndMessageTime:[[[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"time"] substringToIndex:10]];

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
    kkchat.nickName = [self.nickNameArray objectAtIndex:indexPath.row];
    kkchat.chatWithUser = [[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"sender"];
    kkchat.chatUserImg = [self.imgArray objectAtIndex:indexPath.row];

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

            [DataStoreManager deleteThumbMsgWithSender:[[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"sender"]];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
