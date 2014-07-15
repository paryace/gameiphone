//
//  RoleTabView.m
//  GameGroup
//
//  Created by 魏星 on 14-7-3.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "RoleTabView.h"
#import "RolesCell.h"
@implementation RoleTabView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.roleTableView = [[UITableView alloc]initWithFrame:CGRectMake(85, 50, 150, 200) style:UITableViewStylePlain];
        self.roleTableView.delegate =self;
        self.roleTableView.dataSource = self;
        self.roleTableView.rowHeight = 30;
        [GameCommon setExtraCellLineHidden:self.roleTableView];

        [self addSubview:self.roleTableView];
        
        
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
    RolesCell *cell = [tableView dequeueReusableCellWithIdentifier:strCell];
    if (!cell) {
        cell = [[RolesCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
    }
    NSDictionary *dic = [self.coreArray objectAtIndex:indexPath.row];
    cell.headImageV.imageURL = [ImageService getImageStr:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"img")] Width:80];
    cell.nameLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"name")];
    cell.distLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"realm")];
    
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
