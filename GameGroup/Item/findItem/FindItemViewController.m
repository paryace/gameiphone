//
//  FindItemViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "FindItemViewController.h"
#import "BaseItemCell.h"
#import "CreateItemViewController.h"
#import "ItemInfoViewController.h"
#import "MyRoomViewController.h"

@interface FindItemViewController ()
{
    UITableView *m_myTabelView;
    NSMutableArray *m_dataArray;
    UITextField *roleTextf;
    UIPickerView *m_gamePickerView;
    ChooseTab *chooseView;
    NSMutableDictionary *roleDict;
}
@end

@implementation FindItemViewController

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
    chooseView.coreArray =[DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"组队" withBackButton:YES];
    
//    UIButton* collectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, KISHighVersion_7 ? 20 : 0, 65, 44)];
    //    [collectionBtn setBackgroundImage:KUIImage(@"btn_back") forState:UIControlStateNormal];
    //    [collectionBtn setBackgroundImage:KUIImage(@"btn_back_onclick") forState:UIControlStateHighlighted];
    
//    [collectionBtn setTitle:@"收藏" forState:UIControlStateNormal];
//    collectionBtn.backgroundColor = [UIColor clearColor];
//    [collectionBtn addTarget:self action:@selector(collectionBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:collectionBtn];
    
    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"createGroup_normal") forState:UIControlStateNormal];
    [createBtn setBackgroundImage:KUIImage(@"createGroup_click") forState:UIControlStateHighlighted];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(didClickCreateItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    
    //初始化数据源
    m_dataArray = [NSMutableArray array];
    //    [m_dataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"萌萌的",@"title",@"本人意识卓越 劲舞团反向19连P。劲乐团困难贵族1600连。泡泡堂海盗14 1V5 ，澄海3C 1控8 DOTA龙骑士守3路无人破。求生之路杀害3名队友后单人通关。魂斗罗一命不开枪通关。拳皇各种满星电脑被我虐。星际2全国第2.传奇全国第一把谷雨.石器时代家族战第一庄园。喝3打啤酒9小时不上厕所。如有此队友哪里找",@"msg", nil]];
    
    roleDict = [NSMutableDictionary dictionary];
    
    m_myTabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth-startX-50) style:UITableViewStylePlain];
    m_myTabelView.delegate = self;
    m_myTabelView.dataSource  = self;
    [GameCommon setExtraCellLineHidden:m_myTabelView];
    [self.view addSubview:m_myTabelView];
    
    UIButton *screenBtn = [[UIButton alloc]initWithFrame:CGRectMake(260, kScreenHeigth-50-startX-(KISHighVersion_7?0:20), 40, 40)];
    screenBtn.backgroundColor = [UIColor blackColor];
    [screenBtn setTitle:@"筛选" forState:UIControlStateNormal];
    [screenBtn addTarget:self action:@selector(didClickScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:screenBtn];
    
    
    chooseView =[[ ChooseTab alloc]initWithFrame:CGRectMake(0, startX+40, 200, 0)];
    chooseView.coreArray =[DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    chooseView.mydelegate = self;
    [self.view addSubview:chooseView];
    [chooseView reloadData];
    
    
    
    // Do any additional setup after loading the view.
}


-(void)collectionBtn:(id)sender
{
    //    [self showMessageWindowWithContent:@"没有收藏" imageType:1];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    
    MyRoomViewController *myRoom = [[MyRoomViewController alloc]init];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    transition.subtype = kCATransitionFromLeft;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [[self navigationController] pushViewController:myRoom animated:NO];
    //    [UIView  beginAnimations:nil context:NULL];
    //    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //    [UIView setAnimationDuration:0.75];
    //    [self.navigationController pushViewController:myRoom animated:NO];
    //    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    //    [UIView commitAnimations];
    
    //    [self.navigationController pushViewController:myRoom animated:YES];
}
-(void)didClickCreateItem:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    
    CreateItemViewController *cretItm = [[CreateItemViewController alloc]init];
    [self.navigationController pushViewController:cretItm animated:YES];
}
-(void)didClickScreen:(UIButton *)sender
{
    sender.titleLabel.textColor = [UIColor grayColor];
    [self getInfoFromNetWithDic:roleDict];
    
}
-(void)didClicknime:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    chooseView.frame = CGRectMake(0, startX+40, 200, 100);
    [UIView commitAnimations];
    
}

#pragma mark ----NET
-(void)getInfoFromNetWithDic:(NSDictionary *)dic
{
    
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"id")] forKey:@"characterId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")] forKey:@"gameid"];
    [paramDict setObject:@"1" forKey:@"typeIds"];
    [paramDict setObject:@"0" forKey:@"firstResult"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"264" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [m_dataArray removeAllObjects];
            [m_dataArray addObjectsFromArray:responseObject];
            [m_myTabelView reloadData];
        }
        
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


#pragma mark ----tableview delegate  datasourse

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indifience = @"cell";
    BaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
    if (!cell) {
        cell = [[BaseItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }
    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    
    cell.headImg.placeholderImage = KUIImage(@"placeholder");
    NSString *imageids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"img")];
    cell.headImg.imageURL =[ImageService getImageStr2:imageids] ;
    
    cell.titleLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"nickname")];
    cell.contentLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"description")];
    
    NSString *timeStr = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];
    NSString *personStr = [NSString stringWithFormat:@"%@/%@人",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberCount")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"maxVol")]];
    
    cell.timeLabel.text = [NSString stringWithFormat:@"%@|%@",timeStr,personStr];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    
    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    
    ItemInfoViewController *itemInfo = [[ItemInfoViewController alloc]init];
    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic , @"user"), @"userid")];
    if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        itemInfo.isCaptain = YES;
    }else{
        itemInfo.isCaptain =NO;
    }
    itemInfo.infoDict = [NSMutableDictionary dictionaryWithDictionary:roleDict];
    itemInfo.itemId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")];
    [self.navigationController pushViewController:itemInfo animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    view.backgroundColor =UIColorFromRGBA(0xf7f7f7, 1);
    
    m_gamePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, startX+40, 200, 200)];
    m_gamePickerView.dataSource = self;
    m_gamePickerView.delegate = self;
    m_gamePickerView.showsSelectionIndicator = YES;
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectServerNameOK:)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar.items = @[rb_server];
    
    roleTextf = [GameCommon buildTextFieldWithFrame:CGRectMake(0, 0, 200, 39) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor whiteColor] textAlignment:NSTextAlignmentCenter placeholder:@"pleaseChooseRoleORgame"];
    //    roleTextf.inputView = m_gamePickerView;
    //    roleTextf.inputAccessoryView = toolbar;
    roleTextf.userInteractionEnabled = NO;
    [view addSubview:roleTextf];
    
    UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 200, 39)];
    btn1.backgroundColor = [UIColor clearColor];
    [btn1 addTarget:self action:@selector(didClicknime:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn1];
    
    
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(201, 0, 119, 39)];
    [button setTitle:@"筛选" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor grayColor];
    button.backgroundColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(didClickScreen:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)didClickChooseWithView:(ChooseTab *)view info:(NSDictionary *)info
{
    roleDict = [NSMutableDictionary dictionaryWithDictionary:info];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    chooseView.frame = CGRectMake(0, startX+40, 200, 0);
    [UIView commitAnimations];
    
    roleTextf.text = KISDictionaryHaveKey(info, @"name");
}

#pragma mark 选择器
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //    return gameInfoArray.count;
    return 10;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger) row forComponent:(NSInteger) component
{
    return [NSString stringWithFormat:@"%ld",(long)row];
}
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
//{
//    NSDictionary *dic = [gameInfoArray objectAtIndex:row];
//    UIView *customView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
//    EGOImageView *imageView = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 5, 20, 20)];
//    imageView.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")]];
//    [customView addSubview:imageView];
//
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 30)];
//    label.backgroundColor = [UIColor clearColor];
//    label.text = [NSString stringWithFormat:@"%@-%@-%@",KISDictionaryHaveKey(dic, @"realm"),KISDictionaryHaveKey(dic, @"value1"),KISDictionaryHaveKey(dic, @"name")];
//    [customView addSubview:label];
//    return customView;
//    
//}


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
