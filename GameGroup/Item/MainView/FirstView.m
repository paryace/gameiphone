//
//  FirstView.m
//  GameGroup
//
//  Created by 魏星 on 14-7-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "FirstView.h"
#import "NewFirstCell.h"
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
        
        self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, frame.size.height) style:UITableViewStylePlain];
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        self.myTableView.bounces = NO;
//        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.myTableView];
        [GameCommon setExtraCellLineHidden:self.myTableView];
        isRun = YES;
        [self buildTableHeaderView];
    }
    return self;
}

-(void)buildTableHeaderView
{
    UIImageView *headImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 156)];
    headImgView.userInteractionEnabled = YES;
    headImgView.image = KUIImage(@"room_bg");
    
    UILabel *lb1 = [GameCommon buildLabelinitWithFrame:CGRectMake(10, 130, 40, 20) font:[UIFont systemFontOfSize:11] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
//    lb1.text = @"申请人数";
    [headImgView addSubview:lb1];
    
    
    self.personCountLb = [GameCommon buildLabelinitWithFrame:CGRectMake(55,130 , 80, 20) font:[UIFont boldSystemFontOfSize:16] textColor:[UIColor blueColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
    [headImgView addSubview:self.personCountLb];
    
    
    UILabel *lb2 = [GameCommon buildLabelinitWithFrame:CGRectMake(218, 130, 40, 20) font:[UIFont systemFontOfSize:11] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
//    lb2.text = @"组队数量";
    [headImgView addSubview:lb2];
    
    self.teamCountLb = [GameCommon buildLabelinitWithFrame:CGRectMake(250, 130, 70, 20) font:[UIFont boldSystemFontOfSize:16] textColor:[UIColor blueColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
    [headImgView addSubview:self.teamCountLb];
    
    
    self.searchRoomBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.searchRoomBtn.center = CGPointMake(160, 90);
    [self.searchRoomBtn addTarget:self action:@selector(enterSearchPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchRoomBtn setBackgroundImage:KUIImage(@"search_room") forState:UIControlStateNormal];
    [headImgView addSubview:self.searchRoomBtn];
    
    self.myTableView.tableHeaderView = headImgView;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.firstDataArray.count;
}
/*
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indifience = @"cell";
    FirstCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
    if (!cell) {
        cell = [[FirstCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }else{
        for (UIView *view in cell.subviews) {
            [view removeFromSuperview];
        }
        cell = [[FirstCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = [self.firstDataArray objectAtIndex:indexPath.row];
    cell.myDelegate = self;
    cell.tag = indexPath.row;
    BOOL isOpen =[KISDictionaryHaveKey(dic, @"isOpen")boolValue];
    
    if (isOpen) {
        cell.isrow = YES;
        [cell.headImgView.layer removeAllAnimations];
    }else{
//        cell.editLabel.text = @"编辑";
        cell.isrow = NO;
        [cell.headImgView.layer removeAllAnimations];

    }
    NSString *str =[NSString stringWithFormat:@"%@支队伍",KISDictionaryHaveKey(dic, @"matchCount")];
    NSLog(@"%@",str);
    cell.editLabel.text = str;

    cell.machCountStr =[NSString stringWithFormat:@"%@支队伍",KISDictionaryHaveKey(dic, @"matchCount")];
    [cell didClickRow];

    cell.nameLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"characterName")];
    cell.realmLabel.text  = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"desc")];
//    cell.editLabel.text = @"编辑";
    cell.gameIconImg.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")]];
 
    return cell;
}
*/
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indifience = @"cell";
    NewFirstCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
    if (!cell) {
        cell = [[NewFirstCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }
    NSDictionary *dic = [self.firstDataArray objectAtIndex:indexPath.row];
    cell.bgView.backgroundColor = [UIColor whiteColor];
    cell.headImageV.placeholderImage = KUIImage(@"placeholder");

    NSString *headImg = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"characterImg");
    cell.headImageV.imageURL = [ImageService getImageStr:headImg Width:100];
    if (![KISDictionaryHaveKey(dic, @"type") isKindOfClass:[NSDictionary class]]) {
        cell.cardLabel.text = @"全部";
    }else{
        cell.cardLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"type"), @"value")];
    }
    cell.nameLabel.text = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"realm");
    cell.distLabel.text = @"开启组队搜索";
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.myDelegate enterEditPageWithRow:indexPath.row isRow:0];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc]init];
//    view.backgroundColor = [UIColor whiteColor];
//    
//    self.searchRoomBtn   = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 300, 40)];
//    [self.searchRoomBtn setTitle:@"搜索组队" forState:UIControlStateNormal];
//    self.searchRoomBtn.backgroundColor =[UIColor blueColor];
//    [self.searchRoomBtn addTarget:self action:@selector(enterSearchPage:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:self.searchRoomBtn];
//    return view;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 50;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc]init];
//    
//   UIView *topView = [self buildViewWithFrame:CGRectMake(0, 0, 320, 40) leftImg:@"item_1" title:@"目前有77人在寻找组队"];
//        [view addSubview:topView];
//    
//    UILabel *lb = [GameCommon buildLabelinitWithFrame:CGRectMake(10, 50, 30, 20) font:[UIFont boldSystemFontOfSize:14] textColor:[UIColor darkGrayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
//    lb.text = @"点击";
//    [view addSubview:lb];
//    
//    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(40, 50, 20, 20)];
//    img.image = KUIImage(@"clazz_0");
//    [view addSubview:img];
//    
//    UILabel *lb1 = [GameCommon buildLabelinitWithFrame:CGRectMake(60, 50, 120, 20) font:[UIFont boldSystemFontOfSize:14] textColor:[UIColor darkGrayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
//    lb1.text = @"开始搜索组队";
//    [view addSubview:lb1];
//    
//    
//
//    return view;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 70;
//}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"设置";
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        NSDictionary *dic = [self.firstDataArray objectAtIndex:indexPath.row];
        
        NSMutableDictionary *paramDict =[ NSMutableDictionary dictionary];
        NSMutableDictionary *postDict =[ NSMutableDictionary dictionary];
        [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")] forKey:@"gameid"];
        [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"preferenceId")] forKey:@"preferenceId"];
        [postDict setObject:paramDict forKey:@"params"];
        [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
        [postDict setObject:@"289" forKey:@"method"];
        [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
        [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.firstDataArray removeObjectAtIndex:indexPath.row];
            NSString *userid = [GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];

            [[NSUserDefaults standardUserDefaults]setObject:self.firstDataArray forKey:[NSString stringWithFormat:@"item_preference_%@",userid]];
            [self.myTableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, id error) {
            if ([error isKindOfClass:[NSDictionary class]]) {
                if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
                {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }
            }
        }];

    }
}




-(void)enterSearchPage:(id)sender
{
    if ([self.myDelegate respondsToSelector:@selector(enterSearchRoomPageWithView:)]) {
        [self.myDelegate enterSearchRoomPageWithView:self];
    }
}

#pragma mark ---firstCell delegate
-(void)didClickEnterEditPageWithCell:(FirstCell*)cell isrow:(BOOL)row
{
    [self.myDelegate enterEditPageWithRow:cell.tag isRow:row];
}

#pragma mark ---点击雷达 向后台发送偏好开关

-(void)didClickRowWithCell:(FirstCell*)cell isRow:(BOOL)isRow
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self.firstDataArray objectAtIndex:cell.tag]];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")] forKey:@"gameid"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"preferenceId")] forKey:@"preferenceId"];
    BOOL isOpen = [KISDictionaryHaveKey(dic, @"isOpen")boolValue];
    
    NSLog(@"%@---%hhd",KISDictionaryHaveKey(dic, @"isOpen"),isOpen);
    if (isOpen) {
        [paramDict setObject:@"0" forKey:@"isOpen"];
    }else{
        [paramDict setObject:@"1" forKey:@"isOpen"];
    }
    
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"284" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (isOpen) {
            [dic setObject:@"0" forKey:@"isOpen"];
            cell.isrow =NO;

        }else{
            [dic setObject:@"1" forKey:@"isOpen"];
            cell.isrow = YES;

        }
        [cell didClickRow];

        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.firstDataArray];
        NSLog(@"--=%@",[[arr objectAtIndex:cell.tag]objectForKey:@"isOpen"]);
        
        
        [arr replaceObjectAtIndex:cell.tag withObject:dic];
        
        NSLog(@"==-%@",[[arr objectAtIndex:cell.tag]objectForKey:@"isOpen"]);
        self.firstDataArray = arr;
        NSString *userid = [GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
        
        [[NSUserDefaults standardUserDefaults]setObject:self.firstDataArray forKey:[NSString stringWithFormat:@"item_preference_%@",userid]];
//        [self.firstDataArray replaceObjectAtIndex:cell.tag withObject:dic];
        
//        [self.firstDataArray insertObject:dic atIndex:cell.tag];
        //        [firstView.myTableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}







//创建快捷方式
-(UIView *)buildViewWithFrame:(CGRect)frame  leftImg:(NSString *)leftImg title:(NSString *)title
{
    UIView *customView = [[UIView alloc]initWithFrame:frame];
    customView.backgroundColor =[ UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1];
    
    UIImageView *imageView =[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
    imageView.image = KUIImage(leftImg);
    [customView addSubview:imageView];
    
    UILabel *titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(35, 0, 200, 40) font:[UIFont systemFontOfSize:14] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
    titleLabel.text = title;
    [customView addSubview:titleLabel];
    
    return customView;
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
