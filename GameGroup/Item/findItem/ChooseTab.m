//
//  ChooseTab.m
//  GameGroup
//
//  Created by 魏星 on 14-7-1.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ChooseTab.h"

@implementation ChooseTab

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.rowHeight = 30;
        [GameCommon setExtraCellLineHidden:self];

        // Initialization code
    }
    return self;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coreArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCell = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strCell];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
    }
    cell.backgroundColor = [UIColor clearColor];
//    cell.layer.cornerRadius = 5;
    cell.layer.borderWidth = 0.5;
    cell.layer.shadowColor = [[UIColor grayColor]CGColor];
    
    NSDictionary *dict =self.coreArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@--%@",KISDictionaryHaveKey(dict, @"realm"),KISDictionaryHaveKey(dict, @"name")];
    
    cell.textLabel.font =[ UIFont systemFontOfSize:12];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *dic = self.coreArray[indexPath.row];
    
    [self.mydelegate didClickChooseWithView:self info:dic];
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
