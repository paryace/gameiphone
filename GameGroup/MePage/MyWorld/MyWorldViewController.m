//
//  MyWorldViewController.m
//  GameGroup
//
//  Created by Marss on 14-9-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MyWorldViewController.h"
#import "LocationManager.h"
#import "MyWorldCell.h"
#import "MyWorldWithPictureCell.h"
#import "ImgCollCell.h"
@interface MyWorldViewController ()
{
    UITableView *mainTableView;
    int m_currPageCount;
    double longitude;
    double latitude;
    NSMutableArray *timeArray;
    NSMutableArray *userDicArray;
    NSMutableArray *describArray;
    NSMutableArray *areaArray;
    NSMutableArray *imgArray;
    
    UIView *headView;
}
@end

@implementation MyWorldViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化数组
    timeArray = [NSMutableArray array];
    describArray = [NSMutableArray array];
    userDicArray = [NSMutableArray array];
    areaArray = [NSMutableArray array];
    imgArray = [NSMutableArray array];
    
    
    headView = [[UIView alloc]init];
    headView.frame = CGRectMake(0, 0, 320, 100);
    headView.backgroundColor = [UIColor yellowColor];
    // 设置标题
    [self setTopViewWithTitle:@"我的世界" withBackButton:YES];
    mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth-startX)];
    mainTableView.tableHeaderView = headView;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.rowHeight = 150;
    
    [self.view addSubview:mainTableView];
    // 创建加载图片
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    hud.labelText = @"加载中...";
    [self.view addSubview:hud];
    // 数据处理
    [self dataSourse];
}

#pragma mark ---------------------dataSorce------------------
- (void)dataSourse
{
    [hud show:YES];
    
    //获取经纬度
    [[LocationManager sharedInstance]startCheckLocationWithSuccess:^(double lat, double lon) {
        longitude = lon;
        latitude = lat;
        [self netWork];
    } Failure:^{
        [hud hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"定位失败，请确认设置->隐私->定位服务中陌游的按钮为打开状态" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }];
    
    
}
//封装字典，请求数据
- (void)netWork
{
    //封装字典
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [paramDic setObject:[NSString stringWithFormat:@"%f",longitude] forKey:@"longitude"];
    [paramDic setObject:[NSString stringWithFormat:@"%f",latitude] forKey:@"latitude"];
    [paramDic setObject:@"0" forKey:@"firstResult"];
    [paramDic setObject:@"20" forKey:@"maxSize"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"308" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    //网络请求
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        NSLog(@"responsObject =%@",responseObject);
        //取数据
        for (int i = 0; i<[responseObject count]; i++) {
            NSDictionary *dic = [responseObject objectAtIndex:i];
            [timeArray addObject:KISDictionaryHaveKey(dic, @"createDate")];
            [userDicArray addObject:KISDictionaryHaveKey(dic, @"user")];
            [describArray addObject:KISDictionaryHaveKey(dic, @"msg")];
            [areaArray addObject:KISDictionaryHaveKey(dic, @"pushArea")];
            [imgArray addObject:KISDictionaryHaveKey(dic, @"img")];
        }
         [hud hide:YES];
        [mainTableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        
    }];
}
#pragma mark ---------------------tableView设置－－－－－－－－－－－－
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [timeArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 创建cell
    static NSString *identifier  = @"worldCell";
    MyWorldCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MyWorldCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *dic = [userDicArray objectAtIndex:indexPath.row];
    NSString *imgStr = [imgArray objectAtIndex:indexPath.row];
    // 描述的label
    cell.describLabel.text = [describArray objectAtIndex:indexPath.row];
    cell.describLabel.frame = CGRectMake(55, 33, 250, [self getDescibleLabelSize:cell.describLabel.text]);
    // 昵称label
    cell.nameLabel.text = [dic objectForKey:@"nickname"];
    // 头像button
    NSURL *url =[ImageService getImageStr:[dic objectForKey:@"img"] Width:35];
    [cell.faceBt setImageURL:url];
    // 时间label
    NSString *timeStr = [self getTimeWithMessageTime:[GameCommon getNewStringWithId:[timeArray objectAtIndex:indexPath.row]]];
    cell.timeLabel.text = timeStr;
    // cell上没有图片 调整控件的位置
        if (imgStr.length <5) {
    // 区域label
    cell.areaLabel.text = [areaArray objectAtIndex:indexPath.row];
    cell.areaLabel.frame = CGRectMake(55, 45+[self getDescibleLabelSize:cell.describLabel.text], 250, 20);
    NSString *imgString = [imgArray objectAtIndex:indexPath.row];
    NSArray *oneImgArry = [imgString componentsSeparatedByString:@","];
    [cell getImgWithArray:oneImgArry];
    cell.customPhotoCollectionView.hidden = YES;
    //评论的 button
    cell.openBtn.frame = CGRectMake(270, 45+[self getDescibleLabelSize:cell.describLabel.text], 40, 30);
    cell.openBtn.tag = indexPath.row;
    [cell.openBtn setImage:KUIImage(@"zan_pl_normall") forState:UIControlStateNormal];
    [cell.openBtn setImage:KUIImage(@"zan_pl_click") forState:UIControlStateHighlighted];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
    }
    //创建有图片的cell
    cell.areaLabel.text = [areaArray objectAtIndex:indexPath.row];
    cell.areaLabel.frame = CGRectMake(55, 300+[self getDescibleLabelSize:cell.describLabel.text], 250, 20);
    NSString *imgString = [imgArray objectAtIndex:indexPath.row];
    NSArray *oneImgArry = [imgString componentsSeparatedByString:@","];
    [cell getImgWithArray:oneImgArry];
    cell.customPhotoCollectionView.frame = CGRectMake(65, 45+[self getDescibleLabelSize:cell.describLabel.text]+10, 250, 250);
    //评论的 button
    cell.openBtn.frame = CGRectMake(270, 45+[self getDescibleLabelSize:cell.describLabel.text]+260, 40, 30);
    cell.openBtn.tag = indexPath.row;
    [cell.openBtn setImage:KUIImage(@"zan_pl_normall") forState:UIControlStateNormal];
    [cell.openBtn setImage:KUIImage(@"zan_pl_click") forState:UIControlStateHighlighted];

    // 取消cell 的选中效果
     [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *imgStr = [imgArray objectAtIndex:indexPath.row];
    if (imgStr.length <5){
    NSString *str = [describArray objectAtIndex:indexPath.row];
    return [MyWorldCell getLabelSize:str]+200;
    }
    return 350;
}
//
- (void)didOpenBtAction:(id)sender
{
    UIButton * btn = (UIButton*)sender;
    NSInteger index = btn.tag;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    MyWorldCell * cell = (MyWorldCell *)[[sender superview] superview];
//    MyWorldCell *cell = (MyWorldCell *)[mainTableView cellForRowAtIndexPath:indexPath];
    NSIndexPath * path = [mainTableView indexPathForCell:cell];
    NSLog(@"index row%d", [path row]);
//    cell.menuImageView.hidden = NO;

 
}
// 获得label自动变化的高度
- (CGFloat)getDescibleLabelSize:(NSString *)str
{
    NSDictionary * textDic = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0]};
    // 计算introduce文本显示的范围
    CGRect textRect = [str boundingRectWithSize:CGSizeMake(250, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:textDic context:nil];
    //    计算时需要设置一些参数：文本显示的范围（200 , 任意大），文本再计算时字体的大小。
    CGFloat textHight = textRect.size.height;
    return textHight;
}

#pragma mark --getTime //时间戳方法
- (NSString*)getTimeWithMessageTime:(NSString*)messageTime
{
    NSString* currentString = [GameCommon getCurrentTime];
    if (messageTime.length < 10 || currentString.length < 10) {
        return @"未知";
    }
    // NSString * finalTime;
    NSString* curStr = [currentString substringToIndex:messageTime.length-3];
    NSString* mesStr = [messageTime substringToIndex:messageTime.length-3];
    
    double theCurrentT = [curStr doubleValue];
    double theMessageT = [mesStr doubleValue];
    
    if (((int)(theCurrentT-theMessageT))<60) {
        return @"1分钟以前";
    }
    if (((int)(theCurrentT-theMessageT))<60*59) {
        return [NSString stringWithFormat:@"%.f分钟以前",((theCurrentT-theMessageT)/60+1)];
    }
    if (((int)(theCurrentT-theMessageT))<60*60*24) {
        return [NSString stringWithFormat:@"%.f小时以前",((theCurrentT-theMessageT)/3600)==0?1:((theCurrentT-theMessageT)/3600)];
    }
    if (((int)(theCurrentT-theMessageT))<60*60*48) {
        return @"昨天";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *messageDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    return [messageDateStr substringFromIndex:5];
}















- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
