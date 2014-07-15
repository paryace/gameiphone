//
//  FirstView.m
//  GameGroup
//
//  Created by 魏星 on 14-7-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "FirstView.h"
@implementation FirstView
{
    BOOL isRun;
    float dd ;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        dd = 10.0f;
        // Initialization code
        
        UILabel *lb = [GameCommon buildLabelinitWithFrame:CGRectMake(10, 10, 30, 20) font:[UIFont systemFontOfSize:13] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        lb.text = @"点击";
        [self addSubview:lb];
        
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(40, 10, 20, 20)];
        img.image = KUIImage(@"clazz_0");
        [self addSubview:img];
        
        UILabel *lb1 = [GameCommon buildLabelinitWithFrame:CGRectMake(60, 10, 120, 20) font:[UIFont systemFontOfSize:13] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        lb1.text = @"开始搜索组队";
        [self addSubview:lb1];

        
        
        self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 30, 320, frame.size.height) style:UITableViewStylePlain];
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.myTableView];
        isRun = YES;

    }
    return self;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indifience = @"cell";
    FirstCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
    if (!cell) {
        cell = [[FirstCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }
    cell.myDelegate = self;
    cell.nameLabel.text = @"吃不套不吐葡萄皮";
    cell.realmLabel.text  = @"塔克拉玛干";
    cell.editLabel.text = @"编辑";
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor grayColor];
    
    self.searchRoomBtn   = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 300, 40)];
    [self.searchRoomBtn setTitle:@"搜索组队" forState:UIControlStateNormal];
    [self.searchRoomBtn addTarget:self action:@selector(enterSearchPage:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.searchRoomBtn];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;
}
-(void)enterSearchPage:(id)sender
{
    if ([self.myDelegate respondsToSelector:@selector(enterSearchRoomPageWithView:)]) {
        [self.myDelegate enterSearchRoomPageWithView:self];
    }
}

#pragma mark ---firstCell delegate
-(void)didClickEnterEditPageWithCell:(FirstCell*)cell
{
    
}


-(void)didClickRowWithCell:(FirstCell*)cell
{
    if (isRun) {
      //
        
//        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        
//        animation.delegate = self;
//        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 1.0)];
//
////        animation.byValue =[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 1.0)];
//        animation.byValue =[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI/2, 0, 0, 1.0)];
//
//
//        //执行时间
//        
//        animation.duration = 10;
//        
//        animation.cumulative = YES;//累积的
//        
//        //执行次数
//        
//        animation.repeatCount = INT_MAX;
//        
//        animation.autoreverses=YES;//是否自动重复
//        
//        [cell.headImgView.layer addAnimation:animation forKey:@"animation"];
        
    }else{
        isRun=YES;
    }
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
