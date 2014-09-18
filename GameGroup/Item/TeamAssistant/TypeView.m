//
//  TypeView.m
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TypeView.h"

@implementation TypeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView * bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 320, 355)];
        bgImageView.image = KUIImage(@"select_character_bg");
        bgImageView.userInteractionEnabled = YES;
        [self addSubview:bgImageView];
        
        UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(5, 49, 320-25-10, 0.5)];
        topView.backgroundColor = [UIColor grayColor];
        UILabel * titleView = [[UILabel alloc]initWithFrame:CGRectMake(12.5, 12.5, 320-25, 50)];
        titleView.backgroundColor = [UIColor whiteColor];
        titleView.layer.masksToBounds = YES;
        titleView.layer.cornerRadius = 2.0;
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.textColor = kColorWithRGB(5,5,5, 0.7);
        titleView.text = @"选择分类";
        titleView.font =[ UIFont boldSystemFontOfSize:15];
        [titleView addSubview:topView];
        [bgImageView addSubview:titleView];
        
        self.typeTableView = [[UITableView alloc]initWithFrame:CGRectMake(12.5, 12.5+50, 320-25, 330-50) style:UITableViewStylePlain];
        self.typeTableView.layer.masksToBounds = YES;
        self.typeTableView.layer.cornerRadius = 2.0;
        self.typeTableView.layer.borderWidth = 0;
        self.typeTableView.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.typeTableView.rowHeight = 50;
        self.typeTableView.backgroundColor =[UIColor whiteColor];
        self.typeTableView.delegate = self;
        self.typeTableView.dataSource = self;
        self.typeTableView.showsVerticalScrollIndicator = NO;
        self.typeTableView.showsHorizontalScrollIndicator = NO;
        self.typeTableView.hidden = YES;
        [GameCommon setExtraCellLineHidden:self.typeTableView];
        [bgImageView addSubview:self.typeTableView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenSelf)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)setDate:(NSMutableArray*)typeArray{
    self.typeArray=typeArray;
    [self resetTableFrame];
}

-(void)resetTableFrame{
    self.typeTableView.hidden =NO;
    self.typeTableView.frame = CGRectMake(12.5, 12.5+50, 320-25, 330-50);
    [self.typeTableView reloadData];
}

-(void)hiddenSelf
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0f;
        self.alpha = 0.2f;
        
    }completion:^(BOOL finished) {
        self.hidden=  YES;
    }];
    
}
-(void)showSelf
{
    self.hidden=  NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.2f;
        self.alpha = 1.0f;
    }completion:^(BOOL finished) {
    }];
    
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    NSLog(@"%@",touch.view);
    if ([touch.view isKindOfClass:[UITableView class]]||[NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"])
    {
        return NO;
    }
    return YES;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.typeArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary* tempDic = [self.typeArray objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"value")];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self hiddenSelf];
    NSMutableDictionary *dic = self.typeArray[indexPath.row];
    if (self.typeDelegate) {
        [self.typeDelegate selectType:dic];
    }
}

@end
