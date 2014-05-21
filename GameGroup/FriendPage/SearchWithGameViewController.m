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
#import "TestViewController.h"
@interface SearchWithGameViewController ()
{
    NSMutableArray *m_dataArray;
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
    
    m_dataArray = [NSMutableArray array];
    if (self.myInfoType ==COME_GUILD) {
        m_dataArray = [self.dataDic objectForKey:@"guilds"];
        
        [self setTopViewWithTitle:@"查找工会"withBackButton:YES];
    }else{
    
    m_dataArray =[self.dataDic objectForKey:@"characters"];
    
    [self setTopViewWithTitle:[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(self.dataDic, @"characterTotalNum")] withBackButton:YES];
    }
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60;
    [self.view addSubview:tableView];
    
    if ([KISDictionaryHaveKey(self.dataDic, @"characterTotalNum")intValue]>50) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
        titleLabel.backgroundColor = UIColorFromRGBA(0x455ca8, 1);
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = [NSString stringWithFormat:@"共查询到%@条数据,建议输入更具体的信息查询",KISDictionaryHaveKey(self.dataDic,@"characterTotalNum")];
        titleLabel.font = [UIFont systemFontOfSize:12];
        tableView.tableHeaderView = titleLabel;
    }

    UILabel *helpLbel = [[UILabel alloc]initWithFrame:CGRectMake(0,0, 320, 30)];
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
    
    tableView.tableFooterView = helpLbel;
    
    
    
}
-(void)enterToHelpPage:(id)sender
{
    HelpViewController *helpVC = [[HelpViewController alloc]init];
    helpVC.myUrl = @"content.html?4";
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
        
        cell.glazzImgView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(dict, @"img")]]];
        
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
            
            if ([KISDictionaryHaveKey(dic, @"img")isEqualToString:@""]||[KISDictionaryHaveKey(dic, @"img")isEqualToString:@" "]) {
                cell.headImgBtn.imageURL = nil;
            }else{
                cell.headImgBtn.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(dic, @"img")]]];
            }
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

    NSDictionary *dic =[m_dataArray objectAtIndex:indexPath.row];
    
    if (self.myInfoType == COME_GUILD) {
        GuildMembersViewController *guildMember = [[GuildMembersViewController alloc]init];
        guildMember.guildStr = KISDictionaryHaveKey(dic, @"name");
        guildMember.realmStr = KISDictionaryHaveKey(dic, @"gamerealm");
        guildMember.gameidStr = KISDictionaryHaveKey(dic, @"gameid");
        [self.navigationController pushViewController:guildMember animated:YES];

    }else{
        if ([KISDictionaryHaveKey(dic, @"user")isKindOfClass:[NSDictionary class]]) {
            TestViewController *testVC =[[ TestViewController alloc]init];
            testVC.nickName =[GameCommon  getNewStringWithId: KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"nickname")];
            testVC.userId =[GameCommon  getNewStringWithId: KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"id")];
            [self.navigationController pushViewController:testVC animated:YES];
        }else{
            [self showAlertViewWithTitle:@"提示" message:@"此角色尚未在陌游绑定" buttonTitle:@"确定"];
        }
    }
    
    
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
