//
//  SearchWithGameViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-5-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SearchWithGameViewController.h"
#import "GuildCell.h"
#import "RoleCell.h"
#import "HelpViewController.h"
#import "GuildMembersViewController.h"
#import "BinRoleViewController.h"
#import "TestViewController.h"
#import "AddCharacterViewController.h"
@interface SearchWithGameViewController ()
{
    NSMutableArray *m_dataArray;
    int m_infoNum;
    UIAlertView *alertView1;
}
@end

@implementation SearchWithGameViewController

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
    // Do any additional setup after loading the view.
    
    [self setTopViewWithTitle:@"查询结果"withBackButton:YES];

    m_dataArray = [NSMutableArray array];
    if (self.myInfoType ==COME_GUILD) {
    m_dataArray = [self.dataDic objectForKey:@"guilds"];
    }else{
    m_dataArray =[self.dataDic objectForKey:@"characters"];
    }
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX-30) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    [self.view addSubview:tableView];
    
    if ([KISDictionaryHaveKey(self.dataDic, @"characterTotalNum")intValue]>50) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
        titleLabel.backgroundColor = UIColorFromRGBA(0x455ca8, 1);
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = [NSString stringWithFormat:@"共查询到%@条数据,建议输入更具体的信息查询",KISDictionaryHaveKey(self.dataDic,@"characterTotalNum")];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:12];
        tableView.tableHeaderView = titleLabel;
    }

    UILabel *helpLbel = [[UILabel alloc]initWithFrame:CGRectMake(0,kScreenHeigth-30, 320, 30)];
    if (self.myInfoType ==COME_GUILD) {

    helpLbel.text = @"查不到公会?";
    }else{
    helpLbel.text = @"查不到角色？";
    }
    helpLbel.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    helpLbel.font = [UIFont systemFontOfSize:12];
    helpLbel.textColor = kColorWithRGB(41, 164, 246, 1.0);
    helpLbel.userInteractionEnabled = YES;
    helpLbel.textAlignment = NSTextAlignmentCenter;
    [helpLbel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterToHelpPage:)]];
    [self.view addSubview:helpLbel];
}
-(void)enterToHelpPage:(id)sender
{
    HelpViewController *helpVC = [[HelpViewController alloc]init];
    if (self.myInfoType ==COME_GUILD) {
        helpVC.myUrl =@"content.html?5";
    }else{
    if ([self.gameid intValue]==1) {
        helpVC.myUrl = @"content.html?5";
    }else {
        helpVC.myUrl = @"content.html?8";
    }
    }
    [self.navigationController pushViewController:helpVC animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.myInfoType ==COME_GUILD) {
    static NSString *staCell = @"cell";
        GuildCell *cell = [tableView dequeueReusableCellWithIdentifier:staCell];
        if (cell ==nil) {
            cell = [[GuildCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:staCell];
        }
        NSDictionary *dic =m_dataArray[indexPath.row];
        cell.guildLabel.text = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"name")];
        cell.guildsNumLabel.text =[NSString stringWithFormat:@"共有%@个成员", KISDictionaryHaveKey(dic, @"guildCharacterNum")];
        
        return cell;
    }else{
       
        static NSString *roleCell = @"roleCell";
        RoleCell *cell = [tableView dequeueReusableCellWithIdentifier:roleCell];
        if (cell ==nil) {
            cell = [[RoleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:roleCell];
        }
        
        NSDictionary *dict = m_dataArray[indexPath.row];
        
//        cell.glazzImgView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(dict, @"img")]]];
        
        if ([self.gameid intValue]==2) {
            cell.glazzImgView.placeholderImage = KUIImage(@"clazz_icon");
        }else{
            cell.glazzImgView.placeholderImage = KUIImage(@"clazz_0");
        }
        
        
        NSString * imageIds=KISDictionaryHaveKey(dict, @"img");
        cell.glazzImgView.imageURL = [ImageService getImageStr2:imageIds];
        
        cell.roleLabel.text =KISDictionaryHaveKey(dict, @"name");
        if ([KISDictionaryHaveKey(dict,@"user")isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = KISDictionaryHaveKey(dict, @"user");
            cell.nickNameLabel.text =KISDictionaryHaveKey(dic, @"nickname");
            
            NSString *sex = KISDictionaryHaveKey(dic, @"gender");
            if ([sex isEqualToString:@"1"]) {
                cell.genderImgView.image = KUIImage(@"gender_girl");
            }else{
                cell.genderImgView.image = KUIImage(@"gender_boy");
            }
            
//            if ([KISDictionaryHaveKey(dic, @"img")isEqualToString:@""]||[KISDictionaryHaveKey(dic, @"img")isEqualToString:@" "]) {
//                cell.headImgBtn.imageURL = nil;
//            }else{
//                
////                cell.headImgBtn.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(dic, @"img")]]];
//            }
            
            
            NSString * imageIds2=KISDictionaryHaveKey(dic, @"img");
            cell.headImgBtn.imageURL = [ImageService getImageStr2:imageIds2];
        }else{
            cell.headImgBtn.imageURL = nil;
            cell.genderImgView.image = KUIImage(@"weibangding");
            cell.nickNameLabel.text = @"未绑定";
        }
        
        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    m_infoNum = indexPath.row;
    NSDictionary *dic =[m_dataArray objectAtIndex:indexPath.row];
    
    if (self.myInfoType == COME_GUILD) {
        GuildMembersViewController *guildMember = [[GuildMembersViewController alloc]init];
        guildMember.guildStr = KISDictionaryHaveKey(dic, @"name");
        guildMember.realmStr = KISDictionaryHaveKey(dic, @"gamerealm");
        guildMember.gameidStr = KISDictionaryHaveKey(dic, @"gameid");
        [self.navigationController pushViewController:guildMember animated:YES];

    }else{
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
            binRole.dataDic=[self getBinDic:dic];;
            binRole.type=@"1";
            binRole.gameId=self.gameid;
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
            detailVC.userId = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"userid");
            detailVC.nickName = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"alias")? KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"alias"): KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"nickname");
            detailVC.isChatPage = NO;
            [self.navigationController pushViewController:detailVC animated:YES];
            
        }else{
            NSLog(@"去举报");
            BinRoleViewController *binRole=[[BinRoleViewController alloc] init];
            binRole.dataDic=[self getBinDic:dic];
            binRole.type=@"2";
            binRole.gameId = self.gameid;
            [self.navigationController pushViewController:binRole animated:YES];
        }
    }
}

-(NSMutableDictionary*)getBinDic:(NSDictionary*)dict
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *userDic=KISDictionaryHaveKey(dict, @"user");
    [dictionary setObject:KISDictionaryHaveKey(dict, @"img") forKey:@"characterImg"];
     [dictionary setObject:KISDictionaryHaveKey(dict, @"id") forKey:@"characterid"];
     [dictionary setObject:KISDictionaryHaveKey(dict, @"name") forKey:@"charactername"];
     [dictionary setObject:KISDictionaryHaveKey(dict, @"realm") forKey:@"realm"];
    [dictionary setObject:@"" forKey:@"value"];
    if (userDic&&![userDic isEqual:@" "]) {
        [dictionary setObject:KISDictionaryHaveKey(userDic, @"img") forKey:@"img"];
        [dictionary setObject:KISDictionaryHaveKey(userDic, @"gender") forKey:@"gender"];
    }
    return dictionary;
}
-(void)bangdingroleWithdic:(NSDictionary *)dict
{
    [hud show:YES];
    hud.labelText = @"绑定中...";
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [params setObject:self.gameid forKey:@"gameid"];
    [params setObject:KISDictionaryHaveKey(dict, @"realm") forKey:@"gamerealm"];
    [params setObject:KISDictionaryHaveKey(dict, @"name") forKey:@"gamename"];
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
