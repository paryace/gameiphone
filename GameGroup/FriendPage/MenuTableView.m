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
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [_mTableView selectRowAtIndexPath:selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark -- UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isSecion) {
        
    }
}
#pragma mark -- UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isSecion) {
        return _menuKeyList.count;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    UILabel *tlb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
    tlb.backgroundColor = [UIColor clearColor];
    tlb.textColor = UIColorFromRGBA(0x8d8d8b, 1);
    tlb.text = @"陌游官方";
    tlb.textAlignment = NSTextAlignmentCenter;
    tlb.font =[ UIFont systemFontOfSize:14];
    [cell.contentView addSubview:tlb];
    return cell;
}


@end
