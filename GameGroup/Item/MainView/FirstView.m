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
        
        
        self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, frame.size.height) style:UITableViewStylePlain];
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        self.myTableView.bounces = NO;
        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.myTableView];
        isRun = YES;

    }
    return self;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.firstDataArray.count;
}

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
        cell.editLabel.text = [NSString stringWithFormat:@"%@支队伍",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"matchCount")]];
    }else{
        cell.editLabel.text = @"编辑";
        cell.isrow = NO;
        [cell.headImgView.layer removeAllAnimations];

    }
    [cell didClickRow];

    cell.nameLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"characterName")];
    cell.realmLabel.text  = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"desc")];
//    cell.editLabel.text = @"编辑";
    cell.gameIconImg.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")]];
 
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    
    self.searchRoomBtn   = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 300, 40)];
    [self.searchRoomBtn setTitle:@"搜索组队" forState:UIControlStateNormal];
    self.searchRoomBtn.backgroundColor =[UIColor blueColor];
    [self.searchRoomBtn addTarget:self action:@selector(enterSearchPage:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.searchRoomBtn];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;

}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    
   UIView *topView = [self buildViewWithFrame:CGRectMake(0, 0, 320, 40) leftImg:@"item_1" title:@"目前有77人在寻找组队"];
        [view addSubview:topView];
    
    UILabel *lb = [GameCommon buildLabelinitWithFrame:CGRectMake(10, 50, 30, 20) font:[UIFont boldSystemFontOfSize:14] textColor:[UIColor darkGrayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
    lb.text = @"点击";
    [view addSubview:lb];
    
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(40, 50, 20, 20)];
    img.image = KUIImage(@"clazz_0");
    [view addSubview:img];
    
    UILabel *lb1 = [GameCommon buildLabelinitWithFrame:CGRectMake(60, 50, 120, 20) font:[UIFont boldSystemFontOfSize:14] textColor:[UIColor darkGrayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
    lb1.text = @"开始搜索组队";
    [view addSubview:lb1];
    
    

    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 70;
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
    NSMutableDictionary *dic = [self.firstDataArray objectAtIndex:cell.tag];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"teamUser"), @"gameid")] forKey:@"gameid"];
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

        [self.firstDataArray removeObjectAtIndex:cell.tag];
        [self.firstDataArray insertObject:dic atIndex:cell.tag];
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
