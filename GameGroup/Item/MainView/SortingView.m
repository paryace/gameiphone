//
//  SortingView.m
//  GameGroup
//
//  Created by 魏星 on 14-8-5.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SortingView.h"

@implementation SortingView
{
    UITableView *_sortTb;
    NSMutableArray * _contentArr;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.hidden = YES;
        self.backgroundColor = kColorWithRGB(0, 0, 0, 0.6);
        UITapGestureRecognizer *tapg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickHiddenView:)];
        tapg.delegate = self;
        [self addGestureRecognizer:tapg];
        
        _sortTb = [[UITableView alloc]initWithFrame:CGRectMake(0, frame.size.height, 320, 0)];
        _sortTb.delegate = self;
        _sortTb.dataSource = self;
        [self addSubview:_sortTb];
        
    }
    return self;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    NSLog(@"%@",touch.view);
    if ([touch.view isKindOfClass:[UITableView class]]||[NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"])
    {
        return NO;
    }
    return YES;
}

-(void)showSortingViewInViewForRect:(CGRect)rect arr:(NSArray *)arr
{
    _contentArr = [NSMutableArray arrayWithArray:arr];
    [self showSortingView];
}

-(void)didClickHiddenView:(id)sender
{
    [self hideSortingView];
}


-(BOOL)isShow{
    if (self.hidden ==NO) {
        return YES;
    }
    return NO;
}

-(void)showSortingView{
    if (self.hidden ==YES) {
        [UIView animateWithDuration:0.3 animations:^{
            float height = 50*_contentArr.count+50;
            _sortTb.frame = CGRectMake(0, self.frame.size.height-height, 320, height);
            [_sortTb reloadData];
        }];
    }
    self.hidden = NO;
}
-(void)hideSortingView{
    if (self.hidden == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            _sortTb.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 0);
            self.hidden = YES;
        }];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==0) {
        return _contentArr.count;
    }else{
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        static NSString *identifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.textLabel.text = _contentArr[indexPath.row];
        return cell;
    }else{
        static NSString *identifier = @"cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        NSArray *arr = [NSArray arrayWithObjects:@"全部",@"朋友",@"只看女", nil];
        UISegmentedControl *seg= [[UISegmentedControl alloc ]initWithItems:arr];
        seg.frame = CGRectMake(10, 5, 300, 40);
        
        [seg addTarget:self action:@selector(didClickSegMent:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:seg];
        return cell;
    }
}
-(void)didClickSegMent:(UISegmentedControl*)sender
{
    [self didClickHiddenView:nil];
    
    NSLog(@"%d",sender.selectedSegmentIndex);
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self didClickHiddenView:nil];
    [self.mydelegate comeBackInfoWithTag:indexPath.row];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
