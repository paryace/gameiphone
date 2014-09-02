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
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"加载中...";
    [self.view addSubview:hud];
    [self getInfo];
}

-(void)getInfo
{
    [hud show:YES];
    [[ItemManager singleton]getMyGameLocation:self.gameid reSuccess:^(id responseObject) {
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [arr removeAllObjects];
            [arr addObjectsFromArray:responseObject];
            [m_mytableView reloadData];
        }
    } reError:^(id error) {
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
}

@end
