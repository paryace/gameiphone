//
//  MenuTableView.m
//  GameGroup
//
//  Created by Apple on 14-9-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MenuTableView.h"

@implementation MenuTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _menuDataList = [NSMutableArray array];
        _menuDataDic = [NSMutableDictionary dictionary];
        _menuKeyList = [NSMutableArray array];
        _nowIndexs = 0;
        if (!_mTableView) {
            _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,frame.size.height) style:UITableViewStylePlain];
            _mTableView.backgroundColor = kColorWithRGB(251, 251, 251, 1);
            _mTableView.delegate = self;
            _mTableView.showsVerticalScrollIndicator = NO;
            _mTableView.dataSource = self;
            _mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
            _mTableView.bounces = NO;
            [GameCommon setExtraCellLineHidden:_mTableView];
            [self addSubview:_mTableView];
        }
    }
    return self;
}

-(void)setMenuTagList:(NSMutableArray*)array{
    _menuDataList = array;
    [_mTableView reloadData];
    
    NSIndexPath *firstPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_mTableView selectRowAtIndexPath:firstPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    if (self.delegate) {
        [self.delegate itemClick:self DateDic:[_menuDataList objectAtIndex:0]];
    }
}

-(void)addMenuTagList:(NSMutableArray*)array Reload:(BOOL)reload{
    [_menuDataList addObjectsFromArray:array];
    
    if (_menuDataList && _menuDataList.count>0) {
        NSIndexPath *firstPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_mTableView selectRowAtIndexPath:firstPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        if (self.delegate&&reload) {
            [self.delegate itemClick:self DateDic:[_menuDataList objectAtIndex:0]];
        }
        _nowIndexs = 0;
    }
    [_mTableView reloadData];
}

-(void)setMenuTagList:(NSMutableArray*)keyArray DateDic:(NSMutableDictionary*)dataDic{
    _menuKeyList = keyArray;
    _menuDataDic = dataDic;
    [_mTableView reloadData];
    NSIndexPath *firstPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_mTableView selectRowAtIndexPath:firstPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    if (self.delegate) {
        [self.delegate itemClick:self DateDic:[[_menuDataDic objectForKey:[_menuKeyList objectAtIndex:0]] objectAtIndex:0]];
    }
}

#pragma mark -- UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int newRow = indexPath.row;
    int oldRow = self.lastIndexPath.row;
    _nowIndexs = indexPath.row;
    [_mTableView reloadData];
    if (newRow == oldRow){
        return;
    }
    self.lastIndexPath = indexPath;
    if (self.delegate) {
        if (_isSecion) {
            [self.delegate itemClick:self DateDic:[[_menuDataDic objectForKey:[_menuKeyList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
        }else{
            [self.delegate itemClick:self DateDic:[_menuDataList objectAtIndex:indexPath.row]];
        }
    }
}
#pragma mark -- UITableView DataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (_isSecion) {
        return [_menuKeyList objectAtIndex:section];
    }
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_isSecion) {
        return 30;
    }
    return 0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isSecion) {
        return _menuKeyList.count;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isSecion) {
        return [[_menuDataDic objectForKey:[_menuKeyList objectAtIndex:section]] count];
    }
    return _menuDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * stringCell3 = @"cell";
    GroupTagCell * cell = [tableView dequeueReusableCellWithIdentifier:stringCell3];
    if (!cell) {
        cell = [[GroupTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell3];
    }
    
    if (_isSecion) {
        cell.titleLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey([[_menuDataDic objectForKey:[_menuKeyList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row], @"tagName")];;
    }else {
        cell.titleLabel.text = [[_menuDataList objectAtIndex:indexPath.row] objectForKey:@"tagName"];
    }
    if (indexPath.row == _nowIndexs) {
         cell.titleLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = kColorWithRGB(60, 175, 249, 1);
    }else {
        cell.titleLabel.textColor = UIColorFromRGBA(0x8d8d8b, 1);
        cell.backgroundColor = kColorWithRGB(251, 251, 251, 1);
    }
    return cell;
}


@end
