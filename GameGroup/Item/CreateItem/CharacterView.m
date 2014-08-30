//
//  CharacterView.m
//  GameGroup
//
//  Created by Apple on 14-8-26.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CharacterView.h"

@implementation CharacterView

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
        titleView.text = @"选择角色";
        titleView.font =[ UIFont boldSystemFontOfSize:15];
        [titleView addSubview:topView];
        [bgImageView addSubview:titleView];
        
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
        [self addGestureRecognizer:tap];
    }
    return self;
}
-(void)setDate:(NSMutableArray*)characterArray{
    self.characterArray=characterArray;
    [self resetTableFrame];
}

-(void)resetTableFrame{
    self.roleTableView.hidden =NO;
    if (self.characterArray.count>1&&self.characterArray.count<5) {
        self.roleTableView.frame = CGRectMake(12.5, 12.5+50, 320-25, self.characterArray.count*70-3);
    }else{
        self.roleTableView.frame = CGRectMake(12.5, 12.5+50, 320-25, 330-50);
    }
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

    CharacterCell *cell = (CharacterCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CharacterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary* tempDic = [self.characterArray objectAtIndex:indexPath.row];
    
    NSString * imageId=[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"img")];
    NSString * fialMsg=[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"failedmsg")];
    NSString* realm = [NSString stringWithFormat:@"%@ %@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"simpleRealm")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"value1")]];
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
    [self hiddenSelf];
    NSMutableDictionary *dic = self.characterArray[indexPath.row];
    if (self.characterDelegate) {
        [self.characterDelegate selectCharacter:dic];
    }
}

@end
