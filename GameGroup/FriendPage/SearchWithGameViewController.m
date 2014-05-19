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
    
    if (self.myInfoType ==COME_GUILD) {
        m_dataArray = [self.dataDic objectForKey:@"guilds"];
        [self setTopViewWithTitle:@"查找工会"withBackButton:YES];
    }else{
    
    m_dataArray =[self.dataDic objectForKey:@"characters"];
    
    [self setTopViewWithTitle:KISDictionaryHaveKey(self.dataDic, @"characterTotalNum") withBackButton:YES];
    }
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
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
            
            cell.guildLabel = KISDictionaryHaveKey(m_dataArray[indexPath.row], @"name");
            cell.guildsNumLabel = KISDictionaryHaveKey(m_dataArray[indexPath.row], @"guildCharacterNum");
            
            return cell;
        }
    }else{
       
        static NSString *roleCell = @"roleCell";
        RoleCell *cell = [tableView dequeueReusableCellWithIdentifier:roleCell];
        if (cell ==nil) {
            cell = [[RoleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:roleCell];
        }
        NSDictionary *dict = m_dataArray[indexPath.row];
        cell.glazzImgView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(dict, @"img")]]];
        cell.roleLabel.text =KISDictionaryHaveKey(dict, @"name");
        if ([KISDictionaryHaveKey(dict,@"user")isKindOfClass:[NSArray class]]) {
            NSDictionary *dic = KISDictionaryHaveKey(dict, @"user");
            cell.nickNameLabel.text =KISDictionaryHaveKey(dic, @"nickname");
            NSString *sex = KISDictionaryHaveKey(dic, @"gender");
            if ([sex intValue]==1) {
                cell.genderImgView.image = KUIImage(@"nv");
            }else{
        cell.genderImgView.image = KUIImage(@"nan");
            }
            cell.headImgBtn.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(dic, @"img")]]];
        }else{
            cell.headImgBtn.imageURL = nil;
            cell.genderImgView.image = nil;
            cell.nickNameLabel.text = @"未绑定";
        }

        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
