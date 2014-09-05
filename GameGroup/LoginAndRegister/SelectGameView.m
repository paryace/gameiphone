//
//  SelectGameView.m
//  GameGroup
//
//  Created by Marss on 14-9-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SelectGameView.h"
#import "SelectGameCell.h"
@implementation SelectGameView

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
        self.titleView = [[UILabel alloc]initWithFrame:CGRectMake(12.5, 12.5, 320-25, 50)];
        self.titleView.backgroundColor = [UIColor whiteColor];
        self.titleView.layer.masksToBounds = YES;
        self.titleView.layer.cornerRadius = 2.0;
        self.titleView.textAlignment = NSTextAlignmentCenter;
        self.titleView.textColor = kColorWithRGB(5,5,5, 0.7);
        self.titleView.text = @"选择角色";
        self.titleView.font =[ UIFont boldSystemFontOfSize:15];
        [self.titleView addSubview:topView];
        [bgImageView addSubview:self.titleView];
        
        self.roleTableView = [[UITableView alloc]initWithFrame:CGRectMake(12.5, 12.5+50, 320-25, 330-50) style:UITableViewStylePlain];
        self.roleTableView.layer.masksToBounds = YES;
        self.roleTableView.layer.cornerRadius = 2.0;
        self.roleTableView.layer.borderWidth = 0;
        self.roleTableView.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.roleTableView.rowHeight = 70;
        self.roleTableView.backgroundColor =[UIColor whiteColor];
        self.roleTableView.delegate = self;
        self.roleTableView.dataSource = self;
        self.roleTableView.showsVerticalScrollIndicator = NO;
        self.roleTableView.showsHorizontalScrollIndicator = NO;
        self.roleTableView.hidden = YES;
        [GameCommon setExtraCellLineHidden:self.roleTableView];
        [bgImageView addSubview:self.roleTableView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenSelf)];
        tap.delegate = self;
//        [self addGestureRecognizer:tap];
    }
    return self;
}
-(void)setDate:(NSMutableArray*)characterArray{
    self.characterArray=characterArray;
    [self resetTableFrame];
}
-(void)setDateWithNameArray:(NSMutableArray*)nameArray andImg:(NSMutableArray*)imgArray
{
    self.characterArray = nameArray;
    self.imgArray = imgArray;
    [self resetTableFrame];

}
-(void)resetTableFrame{
    self.roleTableView.hidden =NO;
    self.roleTableView.frame = CGRectMake(12.5, 12.5+60, 320-25, 330-50);
    [self.roleTableView reloadData];
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
    return self.characterArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    
    SelectGameCell *cell = (SelectGameCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SelectGameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.gameLabel.text = [self.characterArray objectAtIndex:indexPath.row];
//    cell.gameIcon.image =
    NSString *str = [self.imgArray objectAtIndex:indexPath.row];
    NSURL *url = [ImageService getImageStr2: str];
    EGOImageView * EGOimage = [[EGOImageView alloc]init];
    EGOimage.imageURL = url;
    
    cell.gameIcon.image = EGOimage.image;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self hiddenSelf];

    if (self.selectGameDelegate) {
        [self.selectGameDelegate selectGame:indexPath.row];
    }
}
@end

