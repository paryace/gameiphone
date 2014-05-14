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
    NSMutableDictionary *m_mianDict;
    UIActivityIndicatorView *m_loginActivity;
    UITableView *m_myTableView;
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

    
    
    m_mianDict = [NSMutableDictionary new];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"CitiesList" ofType:@"plist"];
    m_mianDict  = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    m_sectionHeadsKeys =[NSArray array];
    
    m_sectionHeadsKeys = [m_mianDict allKeys];
   m_sectionHeadsKeys = [m_sectionHeadsKeys sortedArrayUsingSelector:@selector(compare:)];
 
    
    m_myTableView =[[ UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    if (KISHighVersion_7) {
        m_myTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    m_myTableView.sectionIndexMinimumDisplayRowCount = 20;
    
   // mTableView.sectionIndexTrackingBackgroundColor = [UIColor greenColor];
    [self.view addSubview:m_myTableView];
    
    UIImageView *topImageView = [[UIImageView alloc]initWithImage:KUIImage(@"city_top.jpg")];
    topImageView.frame = CGRectMake(0, 0, 320, 200);
    topImageView.userInteractionEnabled = YES;
    [topImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(randomCity:)]];
    m_myTableView.tableHeaderView = topImageView;
    [self getRemenForNet];
}

-(void)getRemenForNet
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:@"211" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [m_loginActivity stopAnimating];
        NSMutableArray *customArray = [NSMutableArray array];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in responseObject) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:KISDictionaryHaveKey(dic, @"cityName") forKey:@"city"];
                [dict setObject:KISDictionaryHaveKey(dic, @"cityCode") forKey:@"cityCode"];
                [dict setObject:[self convertChineseToPinYin:KISDictionaryHaveKey(dic, @"cityName")] forKey:@"pinyin"];
                [customArray addObject:dict];
                
            }
           // NSMutableArray *arr = [m_mianDict objectForKey:[m_sectionHeadsKeys objectAtIndex:0]];
            //[arr removeAllObjects];
            [m_mianDict setObject:customArray forKey:@"#"];
            [m_myTableView reloadData];
        }
        
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
-(NSString *)convertChineseToPinYin:(NSString *)chineseName
{
    NSMutableString * theName = [NSMutableString stringWithString:chineseName];
    CFRange range = CFRangeMake(0, theName.length);
    CFStringTransform((CFMutableStringRef)theName, &range, kCFStringTransformToLatin, NO);
    range = CFRangeMake(0, theName.length);
    CFStringTransform((CFMutableStringRef)theName, &range, kCFStringTransformStripCombiningMarks, NO);
    NSString * dd = [theName stringByReplacingOccurrencesOfString:@" " withString:@""];
    return dd;
}

-(void)randomCity:(id)sender
{
    int i = arc4random()%m_sectionHeadsKeys.count;
    NSArray *array =[m_mianDict objectForKey:m_sectionHeadsKeys[i]];
    int j = arc4random()%array.count;
    if (self.mydelegate &&[self.mydelegate respondsToSelector:@selector(pushCityNumTonextPageWithDictionary:)]) {
        [self.mydelegate pushCityNumTonextPageWithDictionary:array[j]];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
