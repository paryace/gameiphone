//
//  CityViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-5-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CityViewController.h"
#import "JSON.h"
@interface CityViewController ()
{
    NSMutableArray *m_dataArray;
    NSArray *m_sectionHeadsKeys;
    NSDictionary *m_mianDict;
    UIActivityIndicatorView *m_loginActivity;

}
@end

@implementation CityViewController

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
    [self setTopViewWithTitle:@"城市" withBackButton:YES];
    m_loginActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:m_loginActivity];
    m_loginActivity.frame = CGRectMake(90, KISHighVersion_7?27:7, 20, 20);
    m_loginActivity.center = CGPointMake(90, KISHighVersion_7?42:22);
    m_loginActivity.color = [UIColor whiteColor];
    m_loginActivity.activityIndicatorViewStyle =UIActivityIndicatorViewStyleWhite;
    // [m_loginActivity startAnimating];

    
    
    m_mianDict = [NSDictionary dictionary];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"CitiesList" ofType:@"plist"];
    m_mianDict  = [NSDictionary dictionaryWithContentsOfFile:path];
    m_sectionHeadsKeys =[NSArray array];
    
    m_sectionHeadsKeys = [m_mianDict allKeys];
   m_sectionHeadsKeys = [m_sectionHeadsKeys sortedArrayUsingSelector:@selector(compare:)];

    
    UITableView *mTableView =[[ UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX) style:UITableViewStylePlain];
    mTableView.delegate = self;
    mTableView.dataSource = self;
    mTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    mTableView.sectionIndexMinimumDisplayRowCount = 20;
  //  mTableView.sectionIndexTrackingBackgroundColor = [UIColor greenColor];
    [self.view addSubview:mTableView];
    
    UIImageView *topImageView = [[UIImageView alloc]initWithImage:KUIImage(@"city_top.jpg")];
    topImageView.frame = CGRectMake(0, 0, 320, 200);
    topImageView.userInteractionEnabled = YES;
    [topImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(randomCity:)]];
    mTableView.tableHeaderView = topImageView;
    
}

-(void)getRemenForNet
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:@"211" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [m_loginActivity stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [m_loginActivity stopAnimating];
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

-(void)randomCity:(id)sender
{
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return m_sectionHeadsKeys.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:m_sectionHeadsKeys];
    [array removeObjectAtIndex:0];
    NSString *str = @"热门城市";
    [array insertObject:str atIndex:0];
    return [array objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return m_sectionHeadsKeys;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [m_mianDict objectForKey:[m_sectionHeadsKeys objectAtIndex:section]];
    return arr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSArray *sectionArr = [m_mianDict objectForKey:[m_sectionHeadsKeys objectAtIndex:indexPath.section]];
    NSDictionary *dic = [sectionArr objectAtIndex:indexPath.row];
    
    cell.textLabel.text = KISDictionaryHaveKey(dic, @"city");
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionArr = [m_mianDict objectForKey:[m_sectionHeadsKeys objectAtIndex:indexPath.section]];
    NSDictionary *dic = [sectionArr objectAtIndex:indexPath.row];
    
    if (self.mydelegate &&[self.mydelegate respondsToSelector:@selector(pushCityNumTonextPageWithDictionary:)]) {
        [self.mydelegate pushCityNumTonextPageWithDictionary:dic];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
