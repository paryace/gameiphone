//
//  SearchResultView.m
//  GameGroup
//
//  Created by Apple on 14-9-15.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SearchResultView.h"
#import "NewPersonalTableViewCell.h"

@implementation SearchResultView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
        _searchResultView = [NSMutableArray array];
        if (!_mTableView) {
            
            _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,frame.size.height) style:UITableViewStylePlain];
            _mTableView.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
            _mTableView.delegate = self;
            _mTableView.showsVerticalScrollIndicator = NO;
            _mTableView.dataSource = self;
            [GameCommon setExtraCellLineHidden:_mTableView];
            [self addSubview:_mTableView];
            _m_searchBar = [[MySearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
            [_m_searchBar setPlaceholder:@"关键字搜索服务器"];
            _m_searchBar.delegate = self;
             _m_searchBar.showsCancelButton=NO;
            [_m_searchBar sizeToFit];
            _mTableView.tableHeaderView = _m_searchBar;
            
        }
    }
    return self;
}
-(void)bgTappedAction:(UITapGestureRecognizer *)tap
{
    [self hideSelf];
}
-(void)setResultList:(NSMutableArray*)resultArray{
    _searchResultView = resultArray;
    [_mTableView reloadData];
}


#pragma mark -- UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideSelf];
    if (self.delegate) {
        [self.delegate itemClick:self DateDic:[_searchResultView objectAtIndex:indexPath.row]];
    }
}
#pragma mark -- UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchResultView.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * stringCell3 = @"cell";
    NewPersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:stringCell3];
    if (!cell) {
        cell = [[NewPersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell3];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary * tempDict = [_searchResultView objectAtIndex:indexPath.row];
    NSString * headplaceholderImage= [self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    cell.headImageV.placeholderImage = [UIImage imageNamed:headplaceholderImage];
    NSString * imageids=KISDictionaryHaveKey(tempDict, @"img");
    cell.headImageV.imageURL=[ImageService getImageStr:imageids Width:80];
    NSString *genderimage=[self genderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    cell.sexImg.image =KUIImage(genderimage);
    NSString * nickName=[tempDict objectForKey:@"alias"];
    if ([GameCommon isEmtity:nickName]) {
        nickName=[tempDict objectForKey:@"nickname"];
    }
    cell.nameLabel.text = nickName;
    
    NSString *titleName=KISDictionaryHaveKey(tempDict, @"titleName");
    cell.distLabel.text = (titleName==nil||[titleName isEqualToString:@""]) ? @"暂无头衔" : titleName;
    cell.distLabel.textColor = [GameCommon getAchievementColorWithLevel:[KISDictionaryHaveKey(tempDict, @"rarenum") integerValue]];
    CGSize nameSize = [cell.nameLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    cell.nameLabel.frame = CGRectMake(65, 5, nameSize.width + 5, 20);
    cell.sexImg.frame = CGRectMake(65 + nameSize.width, 5, 20, 20);
    NSArray * gameids=[GameCommon getGameids:KISDictionaryHaveKey(tempDict, @"gameids")];
    [cell setGameIconUIView:gameids];
    return cell;
}
//头像默认图片
-(NSString*)headPlaceholderImage:(NSString*)gender
{
    if ([[GameCommon getNewStringWithId:gender] isEqualToString:@"0"]) {//男♀♂
        return @"people_man.png";
    }
    else
    {
        return @"people_woman.png";
    }
}
//性别图标
-(NSString*)genderImage:(NSString*)gender
{
    if ([gender intValue]==0)
    {
        return @"gender_boy";
    }else
    {
        return @"gender_girl";
    }
}

#pragma mark ----取消按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [_m_searchBar setShowsCancelButton:NO animated:YES];
    [self.delegate hideSearchResultView];
}

#pragma mark ----键盘搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.delegate reloadSearchList:searchBar.text];
}

#pragma mark ----失去焦点
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
//    [_m_searchBar setShowsCancelButton:NO animated:YES];
//    [self.delegate hideSearchResultView];
    return YES;
}
#pragma mark ----获得焦点
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_m_searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

#pragma mark---searchbar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        [_searchResultView removeAllObjects];
        [_mTableView reloadData];
        return;
    }
    [self.delegate reloadSearchList:searchText];
}

-(void)showSelf{
    [_m_searchBar becomeFirstResponder];
}
-(void)hideSelf{
    if ([_m_searchBar becomeFirstResponder]) {
        [_m_searchBar resignFirstResponder];
    }
}


@end
