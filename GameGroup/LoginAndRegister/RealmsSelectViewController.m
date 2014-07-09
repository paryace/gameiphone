//
//  RealmsSelectViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-23.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "RealmsSelectViewController.h"

@interface RealmsSelectViewController ()
{
    UITableView*    m_realmsTableView;
    
    NSMutableDictionary*   m_realmsDic;
    NSArray* m_realmsIndexArray;
    NSArray *results;
    NSMutableArray *tempKeys;
    
    UISearchBar * mSearchBar;
    UISearchDisplayController *searchController;
}
@end

@implementation RealmsSelectViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self setTopViewWithTitle:@"服务器" withBackButton:YES];
    
    m_realmsDic = [[NSMutableDictionary alloc] initWithCapacity:1];
    m_realmsIndexArray = [[NSArray alloc] init];
    results = [[NSArray alloc] init];
    tempKeys = [NSMutableArray array];
    
    NSString *path  =[RootDocPath stringByAppendingString:[NSString stringWithFormat:@"/openInfogameid_%@_%@",self.gameNum,self.prama]];
     m_realmsDic= [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    
    NSLog(@"%@gameid_%@",path,self.gameNum);
    m_realmsIndexArray = [[m_realmsDic allKeys] sortedArrayUsingSelector:@selector(compare:)];
    m_realmsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-(KISHighVersion_7?0:20))];
    if(KISHighVersion_7){
        m_realmsTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    m_realmsTableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    m_realmsTableView.delegate = self;
    m_realmsTableView.dataSource = self;
    [self.view addSubview:m_realmsTableView];
    [self initContentForSearchText];
    
    
    //初始化搜索条
    mSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    [mSearchBar setPlaceholder:@"关键字搜索服务器"];
    mSearchBar.delegate = self;
    [mSearchBar sizeToFit];
    //初始化UISearchDisplayController
    searchController = [[UISearchDisplayController alloc] initWithSearchBar:mSearchBar contentsController:self];
    [searchController setDelegate:self];
    [searchController setSearchResultsDataSource:self];
    [searchController setSearchResultsDelegate:self];
    m_realmsTableView.tableHeaderView = mSearchBar;
}
#pragma mark 表格
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == searchController.searchResultsTableView) {
        return 1;
    }
    return [m_realmsIndexArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == searchController.searchResultsTableView) {
        return results.count;
    }
    return [KISDictionaryHaveKey(m_realmsDic, [m_realmsIndexArray objectAtIndex:section]) count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myRealm";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (tableView == searchController.searchResultsTableView) {
        if ([results isKindOfClass:[NSArray class]]) {
            cell.textLabel.text = [GameCommon getNewStringWithId:results[indexPath.row]];
        }

    }else{
        NSDictionary* dic = [[m_realmsDic objectForKey:[m_realmsIndexArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            cell.textLabel.text = KISDictionaryHaveKey(dic, @"value");
        }

    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [GameCommon shareGameCommon].selectRealm = [m_realmsTableView cellForRowAtIndexPath:indexPath].textLabel.text;
    [self.realmSelectDelegate selectOneRealmWithName:[tableView cellForRowAtIndexPath:indexPath].textLabel.text num:self.indexCount];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 索引
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (tableView == searchController.searchResultsTableView) {
        return @"";
    }
    return [m_realmsIndexArray objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == searchController.searchResultsTableView) {
        return nil;
    }
   
    return m_realmsIndexArray;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
        [self filterContentForSearchText:searchString];
        [self setTopViewWithTitle:@"服务器" withBackButton:YES];
        return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:mSearchBar.text];
    return YES;
}

-(void)filterContentForSearchText:(NSString*)searchText{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchText];
    NSArray * resultKeys = [tempKeys filteredArrayUsingPredicate:resultPredicate];
    results = resultKeys;
    [m_realmsTableView reloadData];
}


-(void)initContentForSearchText{

    for (int i = 0; i < m_realmsIndexArray.count; i++) {
        NSArray * ssadas = [m_realmsDic objectForKey:m_realmsIndexArray[i]];
        for (int j = 0; j<ssadas.count; j++) {
             NSDictionary *dic = [ssadas objectAtIndex:j];
            [tempKeys addObject:KISDictionaryHaveKey(dic, @"value")];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
