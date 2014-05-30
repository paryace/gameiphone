//
//  GuildMembersViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-5-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GuildMembersViewController.h"
#import "TestViewController.h"
#import "AddCharacterViewController.h"
#import "MJRefresh.h"
#import "BinRoleViewController.h"
@interface GuildMembersViewController ()
{
    MJRefreshHeaderView *m_head;
    MJRefreshFooterView *m_foot;
    UITableView *m_myTableView;
    NSMutableArray *m_dataArray;
    UIAlertView *alertView1;
    int m_infoNum;
   int  m_pageCount;
}
@end

@implementation GuildMembersViewController

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
    [self setTopViewWithTitle:self.guildStr withBackButton:YES];
    
    m_dataArray = [NSMutableArray array];
    m_pageCount = 0;
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.rowHeight = 60;
    [self.view addSubview:m_myTableView];
    UIImageView *topImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 176)];
    topImg.image = KUIImage(@"guildTop.jpg");
    m_myTableView.tableHeaderView = topImg;
    
    
  //  [self addheadView];
    [self addFootView];
    [self getguildMembersFromNet];
    
}
-(void)getguildMembersFromNet
{
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *postDic =[ NSMutableDictionary dictionary];
    [tempDic setObject:self.guildStr forKey:@"organizationName"];
    [tempDic setObject:self.gameidStr forKey:@"gameid"];
    [tempDic setObject:self.realmStr forKey:@"gamerealm"];
    [tempDic setObject:@(m_pageCount) forKey:@"pageIndex"];
    [tempDic setObject:@"20" forKey:@"maxSize"];
    [postDic setObject:tempDic forKey:@""];
    [postDic addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDic setObject:tempDic forKey:@"params"];
    [postDic setObject:@"219" forKey:@"method"];
    [postDic setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
            if (m_pageCount ==0) {
                [m_dataArray removeAllObjects];
                [m_dataArray addObjectsFromArray:responseObject];
            }else{
                [m_dataArray addObjectsFromArray:responseObject];
            }
            
            m_pageCount ++;
            [m_myTableView reloadData];
            [m_head endRefreshing];
            [m_foot endRefreshing];
        }
        } failure:^(AFHTTPRequestOperation *operation, id error) {
            if ([error isKindOfClass:[NSDictionary class]]) {
                if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
                {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }
            }
            [m_head endRefreshing];
            [m_foot endRefreshing];
        }];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    RoleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[RoleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *dict = m_dataArray[indexPath.row];
    

//    cell.glazzImgView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(dict, @"img")]]];
    
    NSString * imageIds=KISDictionaryHaveKey(dict, @"img");
    cell.glazzImgView.imageURL = [ImageService getImageStr2:imageIds];
    
    
    cell.roleLabel.text =KISDictionaryHaveKey(dict, @"name");
    if ([KISDictionaryHaveKey(dict,@"user")isKindOfClass:[NSDictionary class]]) {
        cell.headImgBtn.hidden =NO;
        NSDictionary *dic = KISDictionaryHaveKey(dict, @"user");
        cell.nickNameLabel.text =KISDictionaryHaveKey(dic, @"nickname");
        
        NSString *sex = KISDictionaryHaveKey(dic, @"gender");
        if ([sex isEqualToString:@"1"]) {
            cell.genderImgView.image = KUIImage(@"gender_girl");
            cell.headImgBtn.placeholderImage = KUIImage(@"people_woman");
        }else{
            cell.genderImgView.image = KUIImage(@"gender_boy");
            cell.headImgBtn.placeholderImage = KUIImage(@"people_man");

        }
        NSString * imageids=KISDictionaryHaveKey(dic, @"img");
        
        if ([GameCommon isEmtity:imageids]) {
            cell.headImgBtn.imageURL = nil;
        }else{
//            cell.headImgBtn.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(dic, @"img")]]];
            
            cell.headImgBtn.imageURL = [ImageService getImageStr2:imageIds];
        }
    }else{
        cell.headImgBtn.hidden = YES;
        cell.headImgBtn.imageURL = nil;
        cell.genderImgView.image = KUIImage(@"weibangding");
        cell.headImgBtn.placeholderImage = KUIImage(@"");
        cell.nickNameLabel.text = @"未绑定";
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    m_infoNum = indexPath.row;
    
    
    NSDictionary *dic =m_dataArray[indexPath.row];
    if ([KISDictionaryHaveKey(dic, @"user")isKindOfClass:[NSDictionary class]]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看角色信息",@"举报该用户", nil];
        alertView.tag = 1002;
        [alertView show];
        
        
    }else{
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该角色尚未在陌游绑定" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立刻绑定",@"邀请好友绑定", nil];
        alertView.tag = 1001;
        [alertView show];
    }

    
    
    
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary *dic = [[NSDictionary alloc]init];
    dic = [m_dataArray objectAtIndex:m_infoNum];
    
    NSLog(@"%@----%@",KISDictionaryHaveKey(dic, @"nickname"),KISDictionaryHaveKey(dic, @"charactername"));
    if (alertView.tag ==1001)//点击没有被绑定的角色
    {
        if (buttonIndex ==0) {
            NSLog(@"0");
        }else if (buttonIndex ==1)
        {
            NSLog(@"去绑定");//去绑定
//            AddCharacterViewController *addVC = [[AddCharacterViewController alloc]init];
//            addVC.viewType = CHA_TYPE_Add;
//            // addVC.contentDic =
//            [self.navigationController pushViewController:addVC animated:YES];
            [self bangdingroleWithdic:dic];
        }else{
            
            BinRoleViewController *binRole=[[BinRoleViewController alloc] init];
            binRole.dataDic=dic;
            binRole.type=@"1";
            binRole.gameId=KISDictionaryHaveKey(dic, @"id");
            [self.navigationController pushViewController:binRole animated:YES];
            
            NSLog(@"通知好友绑定");
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
            detailVC.userId = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"id");
            detailVC.nickName = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"alias")? KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"alias"): KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"nickname");
            detailVC.isChatPage = NO;
            [self.navigationController pushViewController:detailVC animated:YES];
            
        }else{
            NSLog(@"去举报");
            BinRoleViewController *binRole=[[BinRoleViewController alloc] init];
            binRole.dataDic=dic;
            binRole.type=@"2";
            binRole.gameId = KISDictionaryHaveKey(dic, @"id");
            [self.navigationController pushViewController:binRole animated:YES];
            
        }
        
    }
}

//添加下拉刷新
-(void)addheadView
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = m_myTableView;
    
    header.scrollView = m_myTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        m_pageCount = 0;
        [self getguildMembersFromNet];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
    //  [header beginRefreshing];
    m_head = header;
}

//添加上拉加载更多
-(void)addFootView
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    CGRect headerRect = footer.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    footer.arrowImage.frame = headerRect;
    footer.activityView.center = footer.arrowImage.center;
    footer.scrollView = m_myTableView;
    
    footer.scrollView = m_myTableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self getguildMembersFromNet];
    };
    m_foot = footer;
}

-(void)bangdingroleWithdic:(NSDictionary *)dict
{
    [hud show:YES];
    hud.labelText = @"绑定中...";
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [params setObject:self.gameidStr forKey:@"gameid"];
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
            
            NSLog(@"%@", responseObject);
            
            
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
