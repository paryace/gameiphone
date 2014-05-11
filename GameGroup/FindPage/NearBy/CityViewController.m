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
    
    m_mianDict = [NSDictionary dictionary];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"CitiesList" ofType:@"plist"];
    m_mianDict  = [NSDictionary dictionaryWithContentsOfFile:path];
    m_sectionHeadsKeys =[NSArray array];
    
    m_sectionHeadsKeys = [m_mianDict allKeys];
   m_sectionHeadsKeys = [m_sectionHeadsKeys sortedArrayUsingSelector:@selector(compare:)];

    
    UITableView *mTableView =[[ UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX) style:UITableViewStylePlain];
    mTableView.delegate = self;
    mTableView.dataSource = self;
    [self.view addSubview:mTableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return m_sectionHeadsKeys.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [m_sectionHeadsKeys objectAtIndex:section];
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
