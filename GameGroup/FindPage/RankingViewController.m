//
//  RankingViewController.m
//  GameGroup
//
//  Created by admin on 14-2-24.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//
#import "RankingViewController.h"
#import "RankingCell.h"
#import "TestViewController.h"
#import "SendNewsViewController.h"
#import "MePageViewController.h"
#import "ShareToOther.h"
#import "AddCharacterViewController.h"
#import "BinRoleViewController.h"
#import "CharacterAndTitleService.h"
#define kSegmentFriend (0)
#define kSegmentRealm (1)
#define kSegmentCountry (2)

@interface RankingViewController ()

@end

@implementation RankingViewController
{
    NSMutableArray *m_cArray;
    NSMutableArray *m_serverArray;
    NSMutableArray *m_countryArray;
    
    UITableView *m_tableView;
    UITableView *m_tableviewServer;
    UITableView *m_tableviewCountry;
    
    UIScrollView *m_backgroundScroll;
    
    
    
    UIButton       * m_serverBtn;
    UIButton       * m_countryBtn;
    UIButton       * m_friendBtn;
    
    
    

    NSInteger          m_scroll_page;
    
    
    BOOL    isRegisterForMe;
    
    UIImageView *m_underListImageView;
    
    float btnWidth;//判断button的位置
    float btnOfX;
     UIView*         bgView;
    NSInteger       m_ppageCount;
    UIActivityIndicatorView   *loginActivity;
    
    NSInteger   m_infoNum;
    NSInteger m_tableViewNum;
    BOOL  isFirstLoading1;
    BOOL  isFirstLoading2;
    BOOL  isFirstLoading3;
    UIAlertView *alertView1;
    
    NSDictionary *dicClick;
    }

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_cArray = [[NSMutableArray alloc]init];
        m_serverArray = [[NSMutableArray alloc]init];
        m_countryArray = [[NSMutableArray alloc]init];

    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstLoading1 =YES;
    isFirstLoading2 =YES;
    isFirstLoading3 =YES;

    isRegisterForMe =YES;
    [self getSortDataByNet1];
    [self getSortDataByNet2];
    [self getSortDataByNet3];
    [self setTopViewWithTitle:[NSString stringWithFormat:@"%@排行",self.titleOfRanking] withBackButton:YES];
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"shareButton") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"shareButton2") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

  

    
    
    UILabel *lb1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 170, 320, 50)];
    if([self.gameId intValue] ==1){
        lb1.text = @"正在向英雄榜请求数据...";
    }else if ([self.gameId intValue]==2){
        lb1.text=@"正在获取数据中...";
    }
    
    lb1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lb1];

    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    
    //创建头button
    [self buildTopBtnView];
    [self buildScrollview];
    
//    hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];

    
}

-(void)buildScrollview
{
    m_backgroundScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, startX+44, 320, self.view.frame.size.height -startX-44)];
    m_backgroundScroll.pagingEnabled = YES;
    m_backgroundScroll.delegate = self;
    m_backgroundScroll.bounces = NO;
    m_backgroundScroll.showsHorizontalScrollIndicator = NO;
    m_backgroundScroll.showsVerticalScrollIndicator = NO;
    m_backgroundScroll.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_backgroundScroll];
    NSLog(@"self.come-form%@",self.COME_FROM);
    if ([self.COME_FROM isEqualToString:@"0"]) {
        if ([self.cRankvaltype isEqualToString:@"2"]) {
            m_scroll_page=0;
        }
        if ([self.cRankvaltype isEqualToString:@"3"]) {
            m_scroll_page=1;
        }

    }
    else{
        if ([self.cRankvaltype isEqualToString:@"1"]) {
            m_scroll_page=0;
        }
        if ([self.cRankvaltype isEqualToString:@"2"]) {
            m_scroll_page=1;
        }
        if ([self.cRankvaltype isEqualToString:@"3"]) {
            m_scroll_page=2;
        }

    }
    
    m_backgroundScroll.contentOffset = CGPointMake(m_scroll_page *m_backgroundScroll.bounds.size.width, 0);


    
    //好友列表
    m_tableView = [[UITableView alloc]init];
    m_tableView.rowHeight = 70;
    m_tableView.delegate = self;
    m_tableView.dataSource = self;
    m_tableView.showsVerticalScrollIndicator = NO;
    m_tableView.showsHorizontalScrollIndicator = NO;
    [m_backgroundScroll addSubview:m_tableView];
    
    //服务器列表
    m_tableviewServer = [[UITableView alloc]init];
    m_tableviewServer.rowHeight = 70;
    m_tableviewServer.delegate = self;
    m_tableviewServer.dataSource = self;

    m_tableviewServer.showsVerticalScrollIndicator = NO;
    m_tableviewServer.showsHorizontalScrollIndicator = NO;
    [m_backgroundScroll addSubview:m_tableviewServer];
    
    
    //全国列表
    m_tableviewCountry = [[UITableView alloc]init];
    m_tableviewCountry.rowHeight = 70;
    m_tableviewCountry.delegate = self;
    m_tableviewCountry.dataSource = self;
    m_tableviewCountry.showsVerticalScrollIndicator = NO;
    m_tableviewCountry.showsHorizontalScrollIndicator = NO;
    [m_backgroundScroll addSubview:m_tableviewCountry];

    
    
    
    if ([self.COME_FROM isEqualToString:@"0"]) {
        NSLog(@"看别人的");
        m_backgroundScroll.contentSize = CGSizeMake(640, m_backgroundScroll.bounds.size.height);
        m_tableView.hidden = YES;
        m_tableviewServer.frame =CGRectMake(0,0,320,m_backgroundScroll.bounds.size.height);
        m_tableviewCountry.frame =CGRectMake(320,0,320,m_backgroundScroll.bounds.size.height);
        btnOfX = 0;
        m_friendBtn.hidden =YES;
    }
    if([self.COME_FROM isEqualToString:@"1"]){
        NSLog(@"看自己的");
        m_backgroundScroll.contentSize = CGSizeMake(960, m_backgroundScroll.bounds.size.height);
        m_tableView.frame =CGRectMake(0,0,320,m_backgroundScroll.bounds.size.height);
        m_tableviewServer.frame =CGRectMake(320,0,320,m_backgroundScroll.bounds.size.height);
        m_tableviewCountry.frame =CGRectMake(640,0,320,m_backgroundScroll.bounds.size.height);

    }
    
    
//    hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];
//    hud.labelText = @"查询中...";
    
    
    m_tableView.hidden = YES;
    m_tableviewServer.hidden = YES;
    m_tableviewCountry.hidden = YES;
    
    m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    m_tableviewServer.separatorStyle = UITableViewCellSeparatorStyleNone;
    m_tableviewCountry.separatorStyle = UITableViewCellSeparatorStyleNone;


    

}




#pragma mark -- tableview delegate datasourse
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView ==m_tableView) {
        return m_cArray.count;
    }
    if (tableView ==m_tableviewServer) {
        return m_serverArray.count;
    }
    else {
        return m_countryArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"userCell";
    RankingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[RankingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (tableView ==m_tableView) {
        
        NSDictionary *dic = [m_cArray objectAtIndex:indexPath.row];
        NSLog(@"dicdic%@",dic);
        NSInteger i = [KISDictionaryHaveKey(dic, @"rank")integerValue];
        if (i <=3) {
            cell.NumLabel.hidden =YES;
            cell.NumImageView.hidden = NO;
            if (i==1) {
                cell.NumImageView.image =KUIImage(@"01_17");
            }
            if (i==2) {
                cell.NumImageView.image =KUIImage(@"02_17");
            }
            if (i==3) {
                cell.NumImageView.image =KUIImage(@"03_17");
            }
            [cell bringSubviewToFront:cell.NumImageView];
        }else{
            cell.NumImageView.hidden =YES;
            cell.NumLabel.hidden = NO;
            [cell bringSubviewToFront:cell.NumLabel];

        }
//        }else if(i>3&&i<=10) {
//            cell.NumLabel.backgroundColor =UIColorFromRGBA(0x8a5d96, 1);
//        }
//        else{
//            cell.NumLabel.backgroundColor =UIColorFromRGBA(0x828be5, 1);
//        }
        
//        if (i>99) {
//            cell.NumLabel.font = [UIFont systemFontOfSize:14];
//        }
        if ([KISDictionaryHaveKey(dic, @"charactername") isEqualToString:self.characterName]&&[KISDictionaryHaveKey(dic, @"realm") isEqualToString:self.server]) {
            cell.bgImageView1.image = KUIImage(@"me_normal");
            cell.bgImageView2.image = KUIImage(@"me_click");
            m_ppageCount = [KISDictionaryHaveKey(dic, @"rank")intValue];
            
        }else {
            
                cell.bgImageView1.image = KUIImage(@"other_normal1");
                cell.bgImageView2.image = KUIImage(@"other_click1");
            
            
        }
        cell.titleImageView.imageURL = [ImageService getImageUrl4:KISDictionaryHaveKey(dic,@"characterImg")];
        
        cell.NumLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"rank")];
        
        NSString *str =KISDictionaryHaveKey(dic, @"nickname");
        if ([str isEqualToString:@" "]) {
            cell.serverLabel.text = @"未绑定";
            cell.sexImageView.image = KUIImage(@"icon_12");
        }else{
            cell.serverLabel.text = KISDictionaryHaveKey(dic, @"nickname");
            if ([KISDictionaryHaveKey(dic, @"gender")isEqualToString:@"1"]) {
                cell.sexImageView.image= KUIImage(@"icon_09");
            }else{
                cell. sexImageView.image= KUIImage(@"icon_07");
            }
            
        }
        
        cell.titleLabel.text = KISDictionaryHaveKey(dic, @"charactername");
        cell.serverLabel.text = KISDictionaryHaveKey(dic, @"nickname");
        if ([cell.titleLabel.text isEqualToString:@""]) {
            cell.serverLabel.frame = CGRectMake(110, 0, 130, 70);
        }
        cell.CountOfLabel.text =[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"value")];

    }
    
    if (tableView ==m_tableviewServer) {
        
        
        
        
        
        
       NSDictionary * dic = [m_serverArray objectAtIndex:indexPath.row];
        NSLog(@"dicdic%@",dic);
        NSInteger i = [KISDictionaryHaveKey(dic, @"rank")integerValue];
        if (i <=3) {
            cell.NumLabel.hidden =YES;
            cell.NumImageView.hidden = NO;
            if (i==1) {
                cell.NumImageView.image =KUIImage(@"01_17");
            }
            if (i==2) {
                cell.NumImageView.image =KUIImage(@"02_17");
            }
            if (i==3) {
                cell.NumImageView.image =KUIImage(@"03_17");
            }
            [cell bringSubviewToFront:cell.NumImageView];

        }else{
            cell.NumImageView.hidden =YES;
            cell.NumLabel.hidden = NO;
            [cell bringSubviewToFront:cell.NumLabel];

        }
//        }else if(i>3&&i<=10) {
//            cell.NumLabel.backgroundColor =UIColorFromRGBA(0x8a5d96, 1);
//        }
//        else{
//            cell.NumLabel.backgroundColor =UIColorFromRGBA(0x828be5, 1);
//        }
//        
//        if (i>99) {
//            cell.NumLabel.font = [UIFont systemFontOfSize:14];
//        }
        if ([KISDictionaryHaveKey(dic, @"charactername") isEqualToString:self.characterName]&&[KISDictionaryHaveKey(dic, @"realm") isEqualToString:self.server]) {
            cell.bgImageView1.image = KUIImage(@"me_normal");
            cell.bgImageView2.image = KUIImage(@"me_click");
            m_ppageCount = [KISDictionaryHaveKey(dic, @"rank")intValue];
            
        }else {
            cell.bgImageView1.image = KUIImage(@"other_normal1");
            cell.bgImageView2.image = KUIImage(@"other_click1");
        }
        
        
        
        cell.titleImageView.imageURL = [ImageService getImageUrl4:KISDictionaryHaveKey(dic,@"characterImg")];
        
        cell.NumLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"rank")];
        
        
        NSString *str =KISDictionaryHaveKey(dic, @"nickname");
        if ([str isEqualToString:@" "]) {
            cell.serverLabel.text = @"未绑定";
            cell.sexImageView.image = KUIImage(@"icon_12");
        }else{
            cell.serverLabel.text = KISDictionaryHaveKey(dic, @"nickname");
            if ([KISDictionaryHaveKey(dic, @"gender")isEqualToString:@"1"]) {
                cell.sexImageView.image= KUIImage(@"icon_09");
            }else{
                cell. sexImageView.image= KUIImage(@"icon_07");
            }

        }

        cell.titleLabel.text = KISDictionaryHaveKey(dic, @"charactername");
        if ([cell.titleLabel.text isEqualToString:@""]) {
            cell.serverLabel.frame = CGRectMake(110, 0, 130, 70);
        }
        cell.CountOfLabel.text =[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"value")];

    }
    if (tableView ==m_tableviewCountry) {
       NSDictionary * dic = [m_countryArray objectAtIndex:indexPath.row];
        NSLog(@"dicdic%@",dic);
        NSInteger i = [KISDictionaryHaveKey(dic, @"rank")integerValue];

        if (i <=3) {
            cell.NumLabel.hidden =YES;
            cell.NumImageView.hidden = NO;
            if (i==1) {
                cell.NumImageView.image =KUIImage(@"01_17");
            }
            if (i==2) {
                cell.NumImageView.image =KUIImage(@"02_17");
            }
            if (i==3) {
                cell.NumImageView.image =KUIImage(@"03_17");
            }
            [cell bringSubviewToFront:cell.NumImageView];

        }else{
            cell.NumImageView.hidden =YES;
            cell.NumLabel.hidden = NO;
            [cell bringSubviewToFront:cell.NumLabel];
        }
        
        
        if ([KISDictionaryHaveKey(dic, @"charactername") isEqualToString:self.characterName]&&[KISDictionaryHaveKey(dic, @"realm") isEqualToString:self.server]) {
            cell.bgImageView1.image = KUIImage(@"me_normal");
            cell.bgImageView2.image = KUIImage(@"me_click");
            m_ppageCount = [KISDictionaryHaveKey(dic, @"rank")intValue];
            
        }else {
            cell.bgImageView1.image = KUIImage(@"other_normal1");
            cell.bgImageView2.image = KUIImage(@"other_click1");
        }
        
        
        NSLog(@"服务器%@",KISDictionaryHaveKey(dic,@"realm"));
        cell.titleImageView.imageURL = [ImageService getImageUrl4:KISDictionaryHaveKey(dic,@"characterImg")];
        cell.NumLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"rank")];
        cell.titleLabel.text = KISDictionaryHaveKey(dic, @"charactername");
        
        NSString *str =KISDictionaryHaveKey(dic, @"nickname");
        if ([str isEqualToString:@" "]) {
            cell.serverLabel.text = @"未绑定";
            cell.sexImageView.image = KUIImage(@"icon_12");
        }else{
            cell.serverLabel.text = KISDictionaryHaveKey(dic, @"nickname");
            if ([KISDictionaryHaveKey(dic, @"gender")isEqualToString:@"1"]) {
                cell.sexImageView.image= KUIImage(@"icon_09");
            }else{
                cell. sexImageView.image= KUIImage(@"icon_07");
            }
            
        }
        cell.CountOfLabel.text =[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"value")];

    }
    
    if ([cell.NumLabel.text intValue]>10000) {
        cell.NumLabel.font = [UIFont fontWithName:@"汉仪菱心体简" size:16];

    }else{
        cell.NumLabel.font = [UIFont fontWithName:@"汉仪菱心体简" size:18];

    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    m_infoNum = indexPath.row;
    NSDictionary *dic = [[NSDictionary alloc]init];
    if(tableView ==m_tableView){
    dic = [m_cArray objectAtIndex:indexPath.row];
        m_tableViewNum = 1;
    }
    if (tableView ==m_tableviewServer) {
        dic = [m_serverArray objectAtIndex:indexPath.row];
        m_tableViewNum = 2;

    }
    if (tableView ==m_tableviewCountry) {
        dic = [m_countryArray objectAtIndex:indexPath.row];
        m_tableViewNum = 3;

    }
    dicClick=dic;
    NSString * str =KISDictionaryHaveKey(dic, @"nickname");
    if ([str isEqualToString:@" "]) {
        isRegisterForMe = NO;
    }
    if (isRegisterForMe ==YES) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看用户信息",@"举报该角色", nil];
        alertView.tag = 1002;
        [alertView show];


    }else{
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:@"该角色尚未在陌游绑定"
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                                 otherButtonTitles:@"立刻绑定",@"邀请好友绑定", nil];
        alertView.tag = 1001;
        [alertView show];
        isRegisterForMe =YES;
    }

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary *dic = [[NSDictionary alloc]init];
    if(m_tableViewNum == 1){
        dic = [m_cArray objectAtIndex:m_infoNum];
    }
    if (m_tableViewNum == 2) {
        dic = [m_serverArray objectAtIndex:m_infoNum];
    }
    if (m_tableViewNum == 3) {
        dic = [m_countryArray objectAtIndex:m_infoNum];
    }
    
    NSLog(@"%@----%@",KISDictionaryHaveKey(dic, @"nickname"),KISDictionaryHaveKey(dic, @"charactername"));
    if (alertView.tag ==1001)//点击没有被绑定的角色
    {
        if (buttonIndex ==0) {
            NSLog(@"0");
        }else if (buttonIndex ==1)
        {
            NSLog(@"去绑定");//去绑定
            [self bangdingroleWithdic:dic];
        }else{
            
            BinRoleViewController *binRole=[[BinRoleViewController alloc] init];
            binRole.dataDic=dic;
            binRole.type=@"1";
            binRole.gameId=self.gameId;
            [self.navigationController pushViewController:binRole animated:YES];
            isRegisterForMe =YES;

            NSLog(@"通知好友绑定");
        }
    }
    else if (alertView.tag ==18){
                if (buttonIndex != alertView.cancelButtonIndex) {
                    AuthViewController* authVC = [[AuthViewController alloc] init];
                    authVC.gameId =self.gameId;
                    authVC.isComeFromFirstOpen = NO;

                    UITextField *tf = (UITextField *)[self.view viewWithTag:1];
                    UITextField*tf1 = (UITextField *)[self.view viewWithTag:2];
                    authVC.realm = tf.text;
                    authVC.character =tf1.text;
                    authVC.authDelegate = self;
                    [self.navigationController pushViewController:authVC animated:YES];
                }
            }
    
    else//点击已经被绑定的角色
    {
        if (buttonIndex ==0) {
            NSLog(@"0");
        }else if (buttonIndex ==1)
        {
            NSLog(@"去看资料");
            TestViewController *detailVC = [[TestViewController alloc]init];
            detailVC.userId = KISDictionaryHaveKey(dic, @"userid");
            detailVC.nickName = KISDictionaryHaveKey(dic, @"displayName");
            detailVC.isChatPage = NO;
            [self.navigationController pushViewController:detailVC animated:YES];

        }else{
            NSLog(@"去举报");
            BinRoleViewController *binRole=[[BinRoleViewController alloc] init];
            binRole.dataDic=dic;
            binRole.type=@"2";
            binRole.gameId=self.gameId;
            [self.navigationController pushViewController:binRole animated:YES];
            isRegisterForMe =YES;

        }
        
    }

}

#pragma mark ---创建顶部分类button
-(void)buildTopBtnView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, startX, 320, 44)];
    view.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:view];
    m_friendBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
    m_countryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    m_serverBtn  = [UIButton  buttonWithType:UIButtonTypeCustom];
    
    [m_friendBtn setBackgroundImage:KUIImage(@"tab_bg") forState:UIControlStateNormal];
    [m_countryBtn setBackgroundImage:KUIImage(@"tab_bg") forState:UIControlStateNormal];
    [m_serverBtn setBackgroundImage:KUIImage(@"tab_bg") forState:UIControlStateNormal];
    

    
    if ([self.COME_FROM isEqualToString:@"0"]) {
        NSLog(@"看别人的");
        btnWidth = 160;
        btnOfX = 0;
        m_friendBtn.hidden =YES;
    }
    if([self.COME_FROM isEqualToString:@"1"]){
        NSLog(@"看自己的");
        btnWidth = 106;
        btnOfX =106;
    }
    m_friendBtn.frame = CGRectMake(btnOfX-btnWidth,0,btnWidth,44);
    m_countryBtn.frame = CGRectMake(btnOfX+btnWidth,0,btnWidth,44);
    m_serverBtn.frame = CGRectMake(btnOfX,0,btnWidth,44);

    m_underListImageView = [[UIImageView alloc]init];
    m_underListImageView.image =KUIImage(@"tab_line");

    if ([self.cRankvaltype isEqualToString:@"1"]) {
        m_friendBtn.selected = YES;
        m_underListImageView.frame =CGRectMake(btnOfX-btnWidth, 41,btnWidth,4);
    }
    if ([self.cRankvaltype isEqualToString:@"2"]) {
        m_serverBtn.selected = YES;
        m_underListImageView.frame =CGRectMake(btnOfX, 41,btnWidth,4);
    }
    if ([self.cRankvaltype isEqualToString:@"3"]) {
        m_countryBtn.selected = YES;
        m_underListImageView.frame =CGRectMake(btnOfX+btnWidth, 41,btnWidth,4);
    }

    
    
    [m_friendBtn setTitle:@"好友" forState:UIControlStateNormal];
    [m_countryBtn setTitle:@"全国" forState:UIControlStateNormal];
    NSString *str = self.server;
    if (str==Nil) {
        str =@"服务器";
    }
    [m_serverBtn setTitle:str forState:UIControlStateNormal];
    
//    m_friendBtn.backgroundColor = [UIColor clearColor];
//    m_countryBtn.backgroundColor = [UIColor clearColor];
//    m_serverBtn.backgroundColor = [UIColor clearColor];
    
    [m_friendBtn setTitleColor:UIColorFromRGBA(0xff9600, 1) forState:UIControlStateSelected];
    [m_friendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [m_countryBtn setTitleColor:UIColorFromRGBA(0xff9600, 1) forState:UIControlStateSelected];
    [m_countryBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [m_serverBtn setTitleColor:UIColorFromRGBA(0xff9600, 1) forState:UIControlStateSelected];
    [m_serverBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [m_friendBtn addTarget:self action:@selector(loadingFriendInfo:) forControlEvents:UIControlEventTouchUpInside];
    [m_countryBtn addTarget:self action:@selector(loadingCountryInfo:) forControlEvents:UIControlEventTouchUpInside];
    [m_serverBtn addTarget:self action:@selector(loadingServerInfo:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:m_friendBtn];
    [view addSubview:m_countryBtn];
    [view addSubview:m_serverBtn];
    [view addSubview:m_underListImageView];


}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ---分享button方法
-(void)shareBtnClick:(UIButton *)sender
{
    if (bgView != nil) {
        [bgView removeFromSuperview];
    }
    bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(328, 0, kScreenHeigth-320, kScreenWidth);
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.4;
    [self.view addSubview:bgView];
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"分享到"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:Nil
                                  otherButtonTitles:@"我的动态",@"新浪微博",@"微信好友",@"微信朋友圈", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [actionSheet showInView:self.view];

}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
        UIGraphicsBeginImageContext(CGSizeMake(kScreenWidth, kScreenHeigth));
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        if (buttonIndex ==0) {
            [self performSelector:@selector(pushSendNews) withObject:nil afterDelay:1.0];
        }
        else if (buttonIndex ==1)
        {
            [[ShareToOther singleton]shareTosina:viewImage];
        }
        else if(buttonIndex ==2)
        {
            [[ShareToOther singleton]changeScene:WXSceneSession];
            
            [[ShareToOther singleton] sendImageContentWithImage:viewImage];
        }
        else if(buttonIndex ==3)
        {
            [[ShareToOther singleton] changeScene:WXSceneTimeline];
            
            [[ShareToOther singleton] sendImageContentWithImage:viewImage];
        }
        if (bgView != nil) {
            [bgView removeFromSuperview];
        }
}

- (void)pushSendNews
{
    //http://www.dapps.net/dev/iphone/iphone-ipad-screenshots-tips.html
    //    CGImageRef UIGetScreenImage();
    //    CGImageRef img = UIGetScreenImage();
    //    UIImage* scImage=[UIImage imageWithCGImage:img];
    UIGraphicsBeginImageContext(CGSizeMake(kScreenWidth, kScreenHeigth));
    //    if(upScroll.center.y < 0)
    //    {
    //        [downScroll.layer renderInContext:UIGraphicsGetCurrentContext()];
    //    }
    //    else
    //    {
    //        CGContextRef cm = UIGraphicsGetCurrentContext();
    //        CGContextTranslateCTM(cm, 200, 0.0);
    //        [upScroll.layer renderInContext:cm];
    //    }
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSString * imageName=[NSString stringWithFormat:@"%@.jpg",uuid];
    NSString * imagePath=[self writeImageToFile:viewImage ImageName:imageName];//完整路径
    if (imagePath) {
        SendNewsViewController* VC = [[SendNewsViewController alloc] init];
        VC.titleImage = viewImage;
        VC.titleImageName=imageName;
        VC.delegate = self;
        VC.isComeFromMe = NO;
        VC.defaultContent = [NSString stringWithFormat:@"分享%@的%@排名",self.characterName,self.titleOfRanking];
        [self.navigationController pushViewController:VC animated:NO];
    }else{
        
    }
}

//将图片保存到本地，返回保存的路径
-(NSString*)writeImageToFile:(UIImage*)thumbimg ImageName:(NSString*)imageName
{
    NSData * imageDate=[self compressImage:thumbimg];
    NSString *path = [RootDocPath stringByAppendingPathComponent:@"tempImage"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path] == NO)
    {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString  *openImgPath = [NSString stringWithFormat:@"%@/%@",path,imageName];
    if ([imageDate writeToFile:openImgPath atomically:YES]) {
        return openImgPath;
    }
    return nil;
}
//压缩图片
-(NSData*)compressImage:(UIImage*)thumbimg
{
    UIImage * a = [NetManager compressImage:thumbimg targetSizeX:640 targetSizeY:1136];
    NSData *imageData = UIImageJPEGRepresentation(a, 0.7);
    return imageData;
}


#pragma mark --顶部分类button方法
-(void)loadingFriendInfo:(UIButton *)sender
{
    
    m_friendBtn.selected = YES;
    m_countryBtn.selected = NO;
    m_serverBtn.selected = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    m_backgroundScroll.contentOffset = CGPointMake(0,0);
    m_underListImageView.frame = CGRectMake(m_friendBtn.frame.origin.x, 41, m_friendBtn.frame.size.width, 4);
    [UIView commitAnimations];

    

}

-(void)loadingServerInfo:(UIButton *)sender
{
    
    if ([self.COME_FROM isEqualToString:@"1"]) {
        m_friendBtn.selected = NO;
        m_countryBtn.selected = NO;
        m_serverBtn.selected = YES;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        m_backgroundScroll.contentOffset = CGPointMake(320, 0);
        
        m_underListImageView.frame = CGRectMake(m_serverBtn.frame.origin.x, 41, m_serverBtn.frame.size.width, 4);
        [UIView commitAnimations];

    }else{
        m_countryBtn.selected = NO;
        m_serverBtn.selected = YES;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        m_backgroundScroll.contentOffset = CGPointMake(0, 0);
        
        m_underListImageView.frame = CGRectMake(m_serverBtn.frame.origin.x, 41, m_serverBtn.frame.size.width, 4);
        [UIView commitAnimations];

    }
    //    if (m_j==YES) {
    //     //   if ([[NSUserDefaults standardUserDefaults]objectForKey:@"serverWXof"]==NULL) {
    //             self.pageCount2 = -1;
    //     //       [self getSortDataByNet2];
    //     //   }else{
    //     //       [m_serverArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"serverWXof"]];
    //          //  [self getSortDataByNet2];
    //    //    }
    //        m_j =NO;
    //    }else{
    //        
    //    }

}


-(void)loadingCountryInfo:(UIButton *)sender
{
    if ([self.COME_FROM isEqualToString:@"1"]) {
    m_friendBtn.selected = NO;
    m_countryBtn.selected = YES;
    m_serverBtn.selected = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    m_backgroundScroll.contentOffset = CGPointMake(640, 0);

    m_underListImageView.frame = CGRectMake(m_countryBtn.frame.origin.x, 41, m_countryBtn.frame.size.width, 4);
    [UIView commitAnimations];
    }else
    {
        m_friendBtn.selected = NO;
        m_countryBtn.selected = YES;
        m_serverBtn.selected = NO;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        m_backgroundScroll.contentOffset = CGPointMake(320, 0);
        
        m_underListImageView.frame = CGRectMake(m_countryBtn.frame.origin.x, 41, m_countryBtn.frame.size.width, 4);
        [UIView commitAnimations];

    }
}

#pragma mark --网络请求
- (void)getSortDataByNet1

{
    
    if (isFirstLoading1) {
        loginActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.view addSubview:loginActivity];
        loginActivity.center = CGPointMake(160, 150);
        loginActivity.color = [UIColor blackColor];
        [loginActivity startAnimating];
        isFirstLoading1 = NO;
    }
     [loginActivity startAnimating];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    NSLog(@"self.drank%@",self.dRankvaltype);
//    if ([self.dRankvaltype isEqualToString:@"pveScore"]||[self.dRankvaltype isEqualToString:@"totalHonorableKills"]) {
//        NSLog(@"传职业");
//        [paramDict setObject:self.custType forKey:@"classid"];
//        
//    }

    [paramDict setObject:self.server forKey:@"realm"];
//    [paramDict setObject:@"1" forKey:@"gameid"];
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:self.characterid forKey:@"characterid"];
    [paramDict setObject:@"1" forKey:@"ranktype"];
    [paramDict setObject:self.dRankvaltype forKey:@"rankvaltype"];
   // [paramDict setObject:@"10" forKey:@"maxSize"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"130" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];

    
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
       // [hud hide:YES];
        
        [loginActivity stopAnimating];
        [loginActivity removeFromSuperview];

        if ([responseObject isKindOfClass:[NSArray class]]) {
            m_tableView.hidden =NO;
            
            
            [m_cArray addObjectsFromArray:responseObject];
            
            [[NSUserDefaults standardUserDefaults]setObject:m_cArray forKey:@"friendWXjs"];
                [m_tableView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                
                
            }
        }
        
       //[hud hide:YES];
    }];
}


- (void)getSortDataByNet2

{
    
    if (isFirstLoading1) {
        loginActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.view addSubview:loginActivity];
        loginActivity.center = CGPointMake(160, 150);
        loginActivity.color = [UIColor blackColor];
        [loginActivity startAnimating];
        isFirstLoading1 = NO;
    }
    [loginActivity startAnimating];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
//    NSLog(@"self.drank%@",self.dRankvaltype);
//    if ([self.dRankvaltype isEqualToString:@"pveScore"]||[self.dRankvaltype isEqualToString:@"totalHonorableKills"]) {
//        NSLog(@"传职业");
//        [paramDict setObject:self.custType forKey:@"classid"];
//        
//    }
    
    
    [paramDict setObject:self.server forKey:@"realm"];
//    [paramDict setObject:@"1" forKey:@"gameid"];
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:self.characterid forKey:@"characterid"];
    [paramDict setObject:@"2" forKey:@"ranktype"];
    [paramDict setObject:self.dRankvaltype forKey:@"rankvaltype"];
    // [paramDict setObject:@"10" forKey:@"maxSize"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"130" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];
    
    
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [loginActivity stopAnimating];
        [loginActivity removeFromSuperview];
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
         m_tableviewServer.hidden =NO;
            NSMutableArray *array = [NSMutableArray array];
            [array addObjectsFromArray:responseObject];

//            for (int i = 0; i<array.count; i++) {
//                if ([KISDictionaryHaveKey([array objectAtIndex:i], @"characterid")intValue] ==[self.characterid intValue]&&[KISDictionaryHaveKey([array objectAtIndex:i], @"ranking")intValue]>15) {
//                    
//                   // [array insertObject:@"1111" atIndex:10];
//                }
//            }
            
            
            
         [m_serverArray addObjectsFromArray:responseObject];
        
         [[NSUserDefaults standardUserDefaults]setObject:m_serverArray forKey:@"friendWXjs"];
         [m_tableviewServer reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        
        //[hud hide:YES];
    }];
}


- (void)getSortDataByNet3

{
    if (isFirstLoading1) {
        loginActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.view addSubview:loginActivity];
        loginActivity.center = CGPointMake(160, 150);
        loginActivity.color = [UIColor blackColor];
        [loginActivity startAnimating];
        isFirstLoading1 = NO;
    }
    [loginActivity startAnimating];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    NSLog(@"self.drank%@",self.dRankvaltype);
    [paramDict setObject:self.server forKey:@"realm"];
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:self.characterid forKey:@"characterid"];
    [paramDict setObject:@"3" forKey:@"ranktype"];
    [paramDict setObject:self.dRankvaltype forKey:@"rankvaltype"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"130" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [loginActivity stopAnimating];
        [loginActivity removeFromSuperview];
        
       if ([responseObject isKindOfClass:[NSArray class]]) {
         m_tableviewCountry.hidden =NO;
         [m_countryArray addObjectsFromArray:responseObject];
         
         NSLog(@"要加载更多");
         [[NSUserDefaults standardUserDefaults]setObject:m_countryArray forKey:@"friendWXjs"];
         [m_tableviewCountry reloadData];
       }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                
                
            }
        }
        
        //[hud hide:YES];
    }];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == m_backgroundScroll) {
        m_scroll_page = (NSInteger)m_backgroundScroll.contentOffset.x/m_backgroundScroll.bounds.size.width;
        if ([self.COME_FROM isEqualToString:@"1"])  {
            NSLog(@"PageNum%d",m_scroll_page);
            
            if (m_scroll_page==0) {
                [self loadingFriendInfo:m_friendBtn];
                m_friendBtn.selected = YES;
                m_countryBtn.selected = NO;
                m_serverBtn.selected = NO;
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.4];
                m_underListImageView.frame = CGRectMake(0, 41, 106, 4);
                [UIView commitAnimations];
                
            }
            if (m_scroll_page==1) {
                [self loadingServerInfo:m_serverBtn];
                m_friendBtn.selected = NO;
                m_countryBtn.selected = NO;
                m_serverBtn.selected = YES;
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.4];
                m_underListImageView.frame = CGRectMake(106, 41, 106, 4);
                [UIView commitAnimations];
                
            }
            if (m_scroll_page==2) {
                [self loadingCountryInfo:m_countryBtn];
                m_friendBtn.selected = NO;
                m_countryBtn.selected = YES;
                m_serverBtn.selected = NO;
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.4];
                m_underListImageView.frame = CGRectMake(212, 41, 106, 4);
                [UIView commitAnimations];
                
            }
        }
        else{
            if (m_scroll_page ==0) {
                [self loadingServerInfo:m_serverBtn];
                m_countryBtn.selected = NO;
                m_serverBtn.selected = YES;
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.4];
                m_underListImageView.frame = CGRectMake(0, 41, 160, 4);
                [UIView commitAnimations];
            }
            if (m_scroll_page ==1) {
                [self loadingCountryInfo:m_countryBtn];
                
                m_friendBtn.selected = NO;
                m_countryBtn.selected = YES;
                m_serverBtn.selected = NO;
                
                m_countryBtn.selected = YES;
                m_serverBtn.selected = NO;
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.4];
                m_underListImageView.frame = CGRectMake(160, 41,160, 4);
                [UIView commitAnimations];
            }
            
            
        }
        
    }
    
}

-(void)bangdingroleWithdic:(NSDictionary *)dict
{
    [hud show:YES];
    hud.labelText = @"绑定中...";
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [params setObject:self.gameId forKey:@"gameid"];
    [params setObject:KISDictionaryHaveKey(dict, @"realm") forKey:@"gamerealm"];
    [params setObject:KISDictionaryHaveKey(dict, @"charactername") forKey:@"gamename"];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"115" forKey:@"method"];
    [body setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* dic = responseObject;
        
        
        NSMutableDictionary* params_two = [[NSMutableDictionary alloc]init];
        [params_two setObject:KISDictionaryHaveKey(dic, @"gameid") forKey:@"gameid"];
        [params_two setObject:KISDictionaryHaveKey(dic, @"id") forKey:@"characterid"];
        
        NSMutableDictionary* body_two = [[NSMutableDictionary alloc]init];
        [body_two addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
        [body_two setObject:params_two forKey:@"params"];
        [body_two setObject:@"118" forKey:@"method"];
        [body_two setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
        
        [NetManager requestWithURLStr:BaseClientUrl Parameters:body_two   success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [hud hide:YES];
            
            [[CharacterAndTitleService singleton] getCharacterInfo:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];

            
            [self showMessageWindowWithContent:@"添加成功" imageType:0];
            [self.navigationController popViewControllerAnimated:YES];
            
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
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if ([[error objectForKey:kFailErrorCodeKey] isEqualToString:@"100014"]) {//已被绑定
                alertView1 = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"认证", nil];
                alertView1.tag = 18;
                [alertView1 show];
            }
            else if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];
}
-(void)dealloc
{
    alertView1.delegate = nil;
}

@end
