//
//  LocationViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-8-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController ()
{
    NSMutableArray *arr;
    UITableView *m_mytableView;
}
@end

@implementation LocationViewController

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
    arr = [NSMutableArray array];
    [self setTopViewWithTitle:@"选择位置" withBackButton:YES];
    m_mytableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX) style:UITableViewStylePlain];
    m_mytableView.delegate = self;
    m_mytableView.dataSource = self;
    [self.view addSubview:m_mytableView];
    
    [GameCommon setExtraCellLineHidden:m_mytableView];
    [self getInfo];
    // Do any additional setup after loading the view.
}

-(void)getInfo
{
    [[ItemManager singleton]getMyGameLocation:self.gameid reSuccess:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [arr removeAllObjects];
            [arr addObjectsFromArray:responseObject];
            [m_mytableView reloadData];
        }
    } reError:^(id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier= @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *dic = arr[indexPath.row];
    cell.textLabel.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"value")];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.mydelegate respondsToSelector:@selector(returnChooseInfoFrom:info:)]) {
        [self.mydelegate returnChooseInfoFrom:self info:arr[indexPath.row]];
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
