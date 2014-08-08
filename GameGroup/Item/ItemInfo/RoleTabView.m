//
//  RoleTabView.m
//  GameGroup
//
//  Created by 魏星 on 14-7-3.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "RoleTabView.h"
#import "RolesCell.h"
#import "EnteroCell.h"
@implementation RoleTabView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.roleTableView = [[UITableView alloc]initWithFrame:CGRectMake(45, 50, 230, 250) style:UITableViewStylePlain];
        self.roleTableView.delegate =self;
        self.roleTableView.dataSource = self;
        self.roleTableView.rowHeight = 70;
        [GameCommon setExtraCellLineHidden:self.roleTableView];

        [self addSubview:self.roleTableView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenMe:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        // Initialization code
    }
    return self;
}
-(void)hiddenMe:(id)sender
{
    self.hidden=  YES;
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
    return self.coreArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
//    RolesCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (!cell) {
//        cell = [[RolesCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
//    }
//    NSDictionary *dic = [self.coreArray objectAtIndex:indexPath.row];
//    cell.headImageV.imageURL = [ImageService getImageStr:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"img")] Width:80];
//    cell.nameLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"name")];
//    cell.distLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"simpleRealm")];
//    
//    
//    return cell;
    
    EnteroCell *cell = (EnteroCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[EnteroCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.4];
    
    NSDictionary* tempDic = [self.coreArray objectAtIndex:indexPath.row];
    
    NSString * imageId=[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"img")];
    NSString * fialMsg=[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"name")];
    NSString* realm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"simpleRealm")];
    NSString * gameid=KISDictionaryHaveKey(tempDic, @"gameid");
    cell.headerImageView.placeholderImage = [UIImage imageNamed:[NSString stringWithFormat:@"clazz_icon.png"]];
    if ([fialMsg isEqualToString:@"404"])//角色不存在
    {
        cell.headerImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"clazz_icon.png"]];
        cell.serverLabel.text=@"角色不存在";
    }else{
        if ([GameCommon isEmtity:imageId]) {
            cell.headerImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"clazz_icon.png"]];
        }else{
            cell.headerImageView.imageURL = [ImageService getImageUrl4:imageId];
        }
        cell.serverLabel.text = realm;//realm
    }
    cell.titleLabel.text = KISDictionaryHaveKey(tempDic, @"name");
    NSString * gameImageId =[GameCommon putoutgameIconWithGameId:[GameCommon getNewStringWithId:gameid]];
    cell.gameTitleImage.imageURL = [ImageService getImageUrl4:gameImageId];
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
