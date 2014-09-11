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
        
        if (!_mTableView) {
            _mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,frame.size.height) style:UITableViewStylePlain];
            _mTableView.backgroundColor = kColorWithRGB(251, 251, 251, 1);
            _mTableView.delegate = self;
            _mTableView.showsVerticalScrollIndicator = NO;
            _mTableView.dataSource = self;
            _mTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
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

-(void)addMenuTagList:(NSMutableArray*)array{
    [_menuDataList addObjectsFromArray:array];
    [_mTableView reloadData];
    if (_menuDataList && _menuDataList.count>0) {
        NSIndexPath *firstPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_mTableView selectRowAtIndexPath:firstPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        if (self.delegate) {
            [self.delegate itemClick:self DateDic:[_menuDataList objectAtIndex:0]];
        }
    }
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
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int newRow = indexPath.row;
    int oldRow = self.lastIndexPath.row;
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
    static NSString *identifier = @"myCell00";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.backgroundColor = kColorWithRGB(251, 251, 251, 1);
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = kColorWithRGB(60, 175, 249, 1);
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = UIColorFromRGBA(0x8d8d8b, 1);
    if (_isSecion) {
        cell.textLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey([[_menuDataDic objectForKey:[_menuKeyList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row], @"tagName")];;
    }else {
        cell.textLabel.text = [[_menuDataList objectAtIndex:indexPath.row] objectForKey:@"tagName"];
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font =[ UIFont systemFontOfSize:14];
    return cell;
}


@end
