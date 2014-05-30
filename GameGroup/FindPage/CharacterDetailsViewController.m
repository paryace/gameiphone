//
//  CharacterDetailsViewController.m
//  GameGroup
//
//  Created by admin on 14-2-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CharacterDetailsViewController.h"
#import "CharaInfo.h"
#import "CharacterDetailsView.h"
#import "CharaDaCell.h"
#import "RankingViewController.h"
#import "SendNewsViewController.h"
#import "WXApiObject.h"
#import "ShareToOther.h"
#import "HelpViewController.h"

@interface CharacterDetailsViewController ()
@end

@implementation CharacterDetailsViewController
{
    UITableView          * m_contentTableView;
    UITableView          * m_reamlTableView;
    UITableView          * m_countryTableView;
    CharaInfo            * m_charaInfo;
    CharacterDetailsView * m_charaDetailsView;
    NSMutableArray       * titleImageArray;
    NSArray              * titleArray;
    NSInteger              m_pageNum;
    float startX;
//    NSString           *m_characterId;
//    NSString           *m_zhiyeId;
    NSString           *m_characterName;
    BOOL            isInTheQueue;//获取刷新数据队列中
    UIAlertView* alertView1;
    BOOL            isGoToNextPage;
    UIView              *bgView;
    UIActivityIndicatorView   *loginActivity;
    
    
    NSMutableDictionary * m_titleDic;
    NSMutableArray * m_nameArray;
    NSMutableDictionary * m_infoDic;
    
    NSMutableArray * m_tabListArray;
    
}
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
    
    
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isInTheQueue =NO;
    isGoToNextPage = YES;
    [self setTopViewWithTitle:@"角色详情" withBackButton:YES];
    
    
    m_titleDic =[NSMutableDictionary dictionary];
    m_nameArray = [NSMutableArray array];
    m_infoDic = [NSMutableDictionary dictionary];
    m_tabListArray = [NSMutableArray array];
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"share_normal.png") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"share_click.png") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    m_charaDetailsView =[[CharacterDetailsView alloc]initWithFrame:CGRectMake(0, KISHighVersion_7?64:44, 320, self.view.frame.size.height - (KISHighVersion_7?64:44))];

    [m_charaDetailsView.helpLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterTohelpPage:)]];

    m_charaDetailsView.contentSize = CGSizeMake(320, 610);
    m_charaDetailsView.myCharaterDelegate = self;
    
    m_charaDetailsView.topImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gameTopImg_%@.jpg",self.gameId]];
    if (self.myViewType ==CHARA_INFO_MYSELF) {
        [m_charaDetailsView comeFromMy];
    }else if(self.myViewType ==CHARA_INFO_PERSON){
        [m_charaDetailsView comeFromPerson];
    }
    [self.view addSubview:m_charaDetailsView];
    
    
    [self buildScrollView];//创建下面的表格
    

    m_charaDetailsView.reloadingBtn.userInteractionEnabled = NO;
    loginActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [m_charaDetailsView addSubview:loginActivity];
    loginActivity.center = CGPointMake(160, 290);
    loginActivity.color = [UIColor blackColor];
    [loginActivity startAnimating];

    
    [self getUserInfoByNet];

}

-(void)buildScrollView
{
    
    if (self.myViewType ==CHARA_INFO_MYSELF) {
        m_charaDetailsView.isComeTo = YES;
        
        m_contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 300) style:UITableViewStylePlain];
        [m_charaDetailsView.listScrollView addSubview:m_contentTableView];
        m_contentTableView.dataSource = self;
        m_contentTableView.delegate = self;
        m_contentTableView.bounces = NO;
        m_contentTableView.rowHeight = 55;
        
        m_countryTableView = [[UITableView alloc] initWithFrame:CGRectMake(640, 0, 320, 300) style:UITableViewStylePlain];
        [m_charaDetailsView.listScrollView addSubview:m_countryTableView];
        m_countryTableView.dataSource = self;
        m_countryTableView.delegate = self;
        m_countryTableView.bounces = NO;
        m_countryTableView.rowHeight = 55;
        
        m_reamlTableView = [[UITableView alloc] initWithFrame:CGRectMake(320, 0, 320, 300) style:UITableViewStylePlain];
        [m_charaDetailsView.listScrollView addSubview:m_reamlTableView];
        m_reamlTableView.dataSource = self;
        m_reamlTableView.delegate = self;
        m_reamlTableView.bounces = NO;
        m_reamlTableView.rowHeight = 55;
        
    }else if(self.myViewType ==CHARA_INFO_PERSON){
        m_charaDetailsView.isComeTo = NO;
        m_contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 300) style:UITableViewStylePlain];
        [m_charaDetailsView.listScrollView addSubview:m_contentTableView];
        m_contentTableView.dataSource = self;
        m_contentTableView.delegate = self;
        m_contentTableView.bounces = NO;
        m_contentTableView.rowHeight = 55;
        m_contentTableView.hidden =YES;
        
        
        m_countryTableView = [[UITableView alloc] initWithFrame:CGRectMake(320, 0, 320, 300) style:UITableViewStylePlain];
        [m_charaDetailsView.listScrollView addSubview:m_countryTableView];
        m_countryTableView.dataSource = self;
        m_countryTableView.delegate = self;
        m_countryTableView.bounces = NO;
        m_countryTableView.rowHeight = 55;
        
        
        m_reamlTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 300) style:UITableViewStylePlain];
        [m_charaDetailsView.listScrollView addSubview:m_reamlTableView];
        m_reamlTableView.dataSource = self;
        m_reamlTableView.delegate = self;
        m_reamlTableView.bounces = NO;
        m_reamlTableView.rowHeight = 55;
     
        
        
    }
    
    m_contentTableView.hidden =YES;
    m_reamlTableView.hidden = YES;
    m_countryTableView.hidden =YES;
}

//获取网络数据
- (void)getUserInfoByNet
{
   
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:self.characterId forKey:@"characterid"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"224" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        m_contentTableView.hidden =NO;
        m_reamlTableView.hidden = NO;
        m_countryTableView.hidden =NO;
        m_charaDetailsView.unlessLabel.hidden =YES;
        [loginActivity stopAnimating];
        [loginActivity removeFromSuperview];

        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            m_titleDic = KISDictionaryHaveKey(responseObject, @"headMap");
            m_nameArray = KISDictionaryHaveKey(responseObject, @"bodyList");
            m_infoDic = KISDictionaryHaveKey(responseObject, @"ranking");
            m_tabListArray = KISDictionaryHaveKey(responseObject, @"tabList");
            
            if (self.myViewType ==CHARA_INFO_PERSON){
                [m_charaDetailsView.realmBtn setTitle:KISDictionaryHaveKey(m_tabListArray[1], @"name") forState:UIControlStateNormal];
                [m_charaDetailsView.countryBtn setTitle:KISDictionaryHaveKey(m_tabListArray[2], @"name") forState:UIControlStateNormal];
                [m_charaDetailsView.realmBtn setTitle:KISDictionaryHaveKey(m_tabListArray[1], @"name") forState:UIControlStateSelected];
                [m_charaDetailsView.countryBtn setTitle:KISDictionaryHaveKey(m_tabListArray[2], @"name") forState:UIControlStateSelected];
                
            }else{
                [m_charaDetailsView.myFriendBtn setTitle:KISDictionaryHaveKey(m_tabListArray[0], @"name") forState:UIControlStateNormal];
                [m_charaDetailsView.realmBtn setTitle:KISDictionaryHaveKey(m_tabListArray[1], @"name") forState:UIControlStateNormal];
                [m_charaDetailsView.countryBtn setTitle:KISDictionaryHaveKey(m_tabListArray[2], @"name") forState:UIControlStateNormal];
                [m_charaDetailsView.myFriendBtn setTitle:KISDictionaryHaveKey(m_tabListArray[0], @"name") forState:UIControlStateSelected];
                [m_charaDetailsView.realmBtn setTitle:KISDictionaryHaveKey(m_tabListArray[1], @"name") forState:UIControlStateSelected];
                [m_charaDetailsView.countryBtn setTitle:KISDictionaryHaveKey(m_tabListArray[2], @"name") forState:UIControlStateSelected];
            }
            
            
            
            m_charaDetailsView.NickNameLabel.text = KISDictionaryHaveKey(m_titleDic, @"name");
            NSString *guildStr =[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(m_titleDic, @"value1")];
            NSString *guilStr = nil;
            if (guildStr.length>8 ) {
                guilStr =[NSString stringWithFormat:@"%@..." ,[guildStr substringToIndex:8]];
                m_charaDetailsView.guildLabel.text = [NSString stringWithFormat:@"<%@>",guilStr];
                m_charaDetailsView.NickNameLabel.frame = CGRectMake(70, 0, 200, 35);
            }else{
                if ([guildStr isEqualToString:@""]||[guildStr isEqualToString:@" "]||!guildStr) {
                    m_charaDetailsView.guildLabel.text =@"";
                    m_charaDetailsView.NickNameLabel.frame = CGRectMake(70, 12, 200, 35);
                }
                else{
                    m_charaDetailsView.guildLabel.text = [NSString stringWithFormat:@"<%@>",guildStr];
                m_charaDetailsView.NickNameLabel.frame = CGRectMake(70, 0, 200, 35);
                }
            }
            
            //计算view的franme
            CGSize size = [KISDictionaryHaveKey(m_titleDic, @"value3") sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(200, 20) lineBreakMode:NSLineBreakByCharWrapping];
            
            m_charaDetailsView.realmView.frame = CGRectMake(310-size.width, 28,size.width, 20);
            m_charaDetailsView.gameIdView.frame = CGRectMake(295-size.width-7, 32, 15, 15);
//            m_charaDetailsView.gameIdView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon putoutgameIconWithGameId:self.gameId]]];
            
            NSString * gameImageId=[GameCommon putoutgameIconWithGameId:self.gameId];
            m_charaDetailsView.gameIdView.imageURL=[ImageService getImageUrl4:gameImageId];
            
            m_characterName =KISDictionaryHaveKey(m_titleDic, @"name");
            
            m_charaDetailsView.realmView.text = KISDictionaryHaveKey(m_titleDic, @"value3");
            
            m_charaDetailsView.levelLabel.text =KISDictionaryHaveKey(m_titleDic, @"value2");
            m_charaDetailsView.levelLabel.frame =CGRectMake(200,8,110,25);

            m_charaDetailsView.headerImageView.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
            
            NSString *charaInfoImageId=KISDictionaryHaveKey(m_titleDic, @"thumbnail");
            if ([GameCommon isEmtity:charaInfoImageId]) {
                m_charaDetailsView.headerImageView.imageURL = nil;
            }else{
//                NSString * imageId=m_charaInfo.thumbnail;
                m_charaDetailsView.headerImageView.imageURL=[ImageService getImageUrl3:charaInfoImageId Width:80];
                
//                m_charaDetailsView.headerImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@/80/80",m_charaInfo.thumbnail]];
            }
            
            if ([[KISDictionaryHaveKey(responseObject, @"ranking") allKeys] containsObject:@"rankingtime"]) {
                
                NSString *changeBtnTitle=[self getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"ranking"), @"rankingtime") ]];
                
                
                [[NSUserDefaults standardUserDefaults]setObject:KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"ranking"), @"rankingtime") forKey:@"WX_reloadBtnTitle_wx"];
                
                [m_charaDetailsView.reloadingBtn setTitle:[NSString stringWithFormat:@"上次更新时间:%@",changeBtnTitle] forState:UIControlStateNormal];
            }
            if ([KISDictionaryHaveKey(m_titleDic, @"auth")boolValue]) {
                m_charaDetailsView.certificationImage.image = KUIImage(@"6");
            }else
            {
                m_charaDetailsView.certificationImage.image = KUIImage(@"5");
            }
            //获取表格信息
            
            
            
            [m_contentTableView reloadData];
            [m_countryTableView reloadData];
            [m_reamlTableView reloadData];
            
            m_charaDetailsView.reloadingBtn.userInteractionEnabled = YES;

            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [loginActivity stopAnimating];
        [loginActivity removeFromSuperview];
        m_charaDetailsView.reloadingBtn.userInteractionEnabled = YES;
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }else{
            
        }
    }];
    
}


//队列
-(void)getUserLineInfoByNet
{
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:self.characterId forKey:@"characterid"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"159" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    //[hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"res%@",responseObject);
        if ([KISDictionaryHaveKey(responseObject, @"systemstate")isEqualToString:@"ok"]) {
            
            [self reLoadingUserInfoFromNet];
            return ;
        }
        if ([KISDictionaryHaveKey(responseObject, @"systemstate")isEqualToString:@"busy"]) {
            m_charaDetailsView.reloadingBtn.userInteractionEnabled =YES;
            
            NSString *timeStr =[NSString stringWithFormat:@"%d",[KISDictionaryHaveKey(responseObject, @"time")intValue]/60000];
            NSString *str = nil;
            if ([timeStr isEqualToString:@"0"]) {
                str = @"小于1分钟";
            }else{
                str =[NSString stringWithFormat:@"%@分钟",timeStr];
            }
            
            NSString *indexStr = KISDictionaryHaveKey(responseObject, @"index");
            MBProgressHUD *  hud1 = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud1];
            hud1.mode =  MBProgressHUDModeIndeterminate;
            hud1.labelText = nil;
            hud1.detailsLabelText = [NSString stringWithFormat:@"进入更新队列,目前队列位置：%@，预计更新时间：%@",indexStr,str];
            [hud1 showAnimated:YES whileExecutingBlock:^{
                sleep(3);
                
            }];
            return;
        }
            m_charaDetailsView.reloadingBtn.userInteractionEnabled = YES;
        
        m_infoDic = responseObject;
        [m_contentTableView reloadData];
        [m_reamlTableView reloadData];
        [m_countryTableView reloadData];
        
        MBProgressHUD *  hud2 = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud2];
        hud2.labelText = @"获取成功";
        hud2.mode =  MBProgressHUDModeCustomView;
        hud2.customView = [[UIImageView alloc]initWithImage:KUIImage(@"37x-Checkmark")];
        [hud2 showAnimated:YES whileExecutingBlock:^{
            sleep(2);
            
        }];
        NSString *changeBtnTitle =[NSString stringWithFormat:@"上次更新时间：%@",[self getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"rankingtime")]]];
        
        [[NSUserDefaults standardUserDefaults]setObject:KISDictionaryHaveKey(responseObject, @"rankingtime") forKey:@"WX_reloadBtnTitle_wx"];
        
        [m_charaDetailsView.reloadingBtn setTitle:changeBtnTitle forState:UIControlStateNormal];

    } failure:^(AFHTTPRequestOperation *operation, id error) {
        m_charaDetailsView.reloadingBtn.userInteractionEnabled =YES;

        [hud hide:YES];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}
//刷新数据
-(void)reLoadingUserInfoFromNet
{
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    hud.labelText = @"正拼命从英雄榜获取中...";
    hud.detailsLabelText = nil;
    
    m_charaDetailsView.reloadingBtn.userInteractionEnabled =NO;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:self.characterId forKey:@"characterid"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"160" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        m_charaDetailsView.reloadingBtn.userInteractionEnabled =YES;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [hud hide:YES];
            m_infoDic = responseObject;
            
            [m_contentTableView reloadData];
            [m_countryTableView reloadData];
            [m_reamlTableView reloadData];
            
            NSString *changeBtnTitle =[NSString stringWithFormat:@"上次更新时间：%@",[GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"rankingtime")]]];
            
            [[NSUserDefaults standardUserDefaults]setObject:KISDictionaryHaveKey(responseObject, @"rankingtime") forKey:@"WX_reloadBtnTitle_wx"];
            
            [m_charaDetailsView.reloadingBtn setTitle:changeBtnTitle forState:UIControlStateNormal];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        m_charaDetailsView.reloadingBtn.userInteractionEnabled =YES;

        [hud hide:YES];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                
            }
        }
        else
        {
            alertView1 = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请求数据失败，请检查网络！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alertView1.tag = 56;
            [alertView1 show];
        }

    }];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView ==m_contentTableView) {
        return m_nameArray.count;
    }else if (tableView ==m_contentTableView)
    {
        return m_nameArray.count;
    }else{
        return m_nameArray.count;
    }
}

-(NSMutableArray *)finishingDisgustingDataWithDic:(NSDictionary *)dic num:(NSString *)num
{
    NSDictionary *contentDic = [NSDictionary dictionary];
    contentDic = KISDictionaryHaveKey(dic, num);
    NSMutableArray *arr = [NSMutableArray array];
    for (int i =0; i<m_nameArray.count; i++) {
        NSMutableDictionary *dict = m_nameArray[i];
        [dict setObject:KISDictionaryHaveKey(contentDic, KISDictionaryHaveKey(dict, @"key")) forKey:@"disgustingData"];
        [arr addObject:dict];
    }
    return arr;
}




-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"userCell";
    CharaDaCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CharaDaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *dic  =m_nameArray[indexPath.row];
    
//    cell.titleImgView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString: KISDictionaryHaveKey(dic, @"img")]];
    
    NSString * imageId=KISDictionaryHaveKey(dic, @"img");
    cell.titleImgView.imageURL = [ImageService getImageUrl4:imageId];
    
    cell.titleLabel.text = KISDictionaryHaveKey(dic, @"value1");
    cell.topImgView.image = KUIImage(@"paiming_ico");
    cell.CountLabel.text = KISDictionaryHaveKey(dic, @"value2");

    NSDictionary *contentDic = [NSDictionary dictionary];
    if (tableView ==m_contentTableView) {
        contentDic = KISDictionaryHaveKey(m_infoDic, @"1");
    }else if (tableView ==m_reamlTableView){
        contentDic = KISDictionaryHaveKey(m_infoDic, @"2");
    }else{
        contentDic = KISDictionaryHaveKey(m_infoDic, @"3");
    }

    NSDictionary *dict =KISDictionaryHaveKey(contentDic, KISDictionaryHaveKey(dic, @"key"));
    cell.dataLabel.text =[GameCommon getNewStringWithId: KISDictionaryHaveKey(dict, @"value")];
    NSString *str =KISDictionaryHaveKey(dict, @"rank");
    cell.rankingLabel.text = [NSString stringWithFormat:@"第%@名",str];

    NSLog(@"dict-----------%@",dict);
    NSLog(@"dic----------%@",dic);

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    RankingViewController *ranking = [[RankingViewController alloc]init] ;

    if (tableView ==m_contentTableView) {
        ranking.cRankvaltype = @"1" ;

    }else if (tableView ==m_reamlTableView){
        ranking.cRankvaltype = @"2" ;
    }else{
        ranking.cRankvaltype = @"3" ;
    }
    NSDictionary *dic  =m_nameArray[indexPath.row];
    
    for (int i =0; i<m_tabListArray.count; i++) {
        NSDictionary *dicta = m_tabListArray[i];
        if ([KISDictionaryHaveKey(dicta, @"key")intValue]==2) {
            ranking.server = KISDictionaryHaveKey(dicta, @"name");
        }
    }
    ranking.characterid =self.characterId;
    ranking.userId = self.userId;
    ranking.pageCount1 = -1;
    ranking.pageCount2 = -1;
    ranking.pageCount3 = -1;
    ranking.characterName =m_characterName;
    ranking.dRankvaltype = KISDictionaryHaveKey(dic, @"key");
    
    ranking.titleOfRanking = KISDictionaryHaveKey(dic, @"value1");
    ranking.COME_FROM =[NSString stringWithFormat:@"%u",self.myViewType];
    ranking.gameId=self.gameId;
    [self.navigationController pushViewController:ranking animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"contentOfjuese" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"typePerson" object:nil];
    
    
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
    if (((int)(theCurrentT-theMessageT))<60) {
        return @"1分钟以前";
    }
    if (((int)(theCurrentT-theMessageT))<60*59) {
        return [NSString stringWithFormat:@"%.f分钟以前",((theCurrentT-theMessageT)/60+1)];
    }
    if (((int)(theCurrentT-theMessageT))<60*60*24&&((int)(theCurrentT-theMessageT))>60*59) {
        return [NSString stringWithFormat:@"%.f小时以前",((theCurrentT-theMessageT)/3600)==0?1:((theCurrentT-theMessageT)/3600)];
    }
    if (((int)(theCurrentT-theMessageT))<60*60*48) {
        return @"昨天";
    }   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *messageDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    return [messageDateStr substringFromIndex:5];
}

- (void)reLoadingList:(CharacterDetailsView *)characterdetailsView
{
    m_charaDetailsView.reloadingBtn.userInteractionEnabled =NO;
        [self getUserLineInfoByNet];
        NSLog(@"刷新数据");
    
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
                                  otherButtonTitles:@"我的动态",@"新浪微博",@"微信好友",@"微信朋友圈",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [actionSheet showInView:self.view];
    

    }
-(BOOL)isDirectShareInIconActionSheet
{
    return YES;
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
    UIGraphicsBeginImageContext(CGSizeMake(kScreenWidth, kScreenHeigth));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    SendNewsViewController* VC = [[SendNewsViewController alloc] init];
    VC.titleImage = viewImage;
    VC.delegate = self;
    VC.isComeFromMe = NO;
   // VC.defaultContent = [NSString stringWithFormat:@"分享了%@的角色详情",self.characterName];
    VC.defaultContent = [NSString stringWithFormat:@"分享了%@的数据",m_characterName];
    [self.navigationController pushViewController:VC animated:NO];
}
-(void)enterTohelpPage:(id)sender
{
    HelpViewController *helpVC = [[HelpViewController alloc]init];
    helpVC.myUrl = @"content.html?1";
    [self.navigationController pushViewController:helpVC animated:YES];
}


@end



