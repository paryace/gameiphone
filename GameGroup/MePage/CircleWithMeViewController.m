//
//  CircleWithMeViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-4-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CircleWithMeViewController.h"
#import "TestViewController.h"
#import "OnceDynamicViewController.h"
#import "CircleMeCell.h"
#import "SendNewsViewController.h"
#import "MJRefresh.h"
#import "DSCircleWithMe.h"

@interface CircleWithMeViewController ()
{
    UITableView *m_myTableView;
    NSMutableArray *dataArray;
    NSInteger m_currentPage;
}
@end

@implementation CircleWithMeViewController

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
    
    [self setTopViewWithTitle:@"与我相关" withBackButton:YES];
    
    self.view.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);

    UIButton *delbutton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    
    [delbutton setBackgroundImage:KUIImage(@"deleteButton") forState:UIControlStateNormal];
    [delbutton setBackgroundImage:KUIImage(@"deleteButton2") forState:UIControlStateHighlighted];
    delbutton.backgroundColor = [UIColor clearColor];
    [delbutton addTarget:self action:@selector(deleteInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:delbutton];

    dataArray = [NSMutableArray array];
    m_currentPage = 0;
    dataArray = (NSMutableArray *)[DataStoreManager queryallDynamicAboutMeWithUnRead:@"0"];

    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.rowHeight =80;
    m_myTableView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    [self.view addSubview:m_myTableView];
    
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIView *upLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 310, 1)];
    upLineView.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    [footView addSubview:upLineView];
    
    UIView *downLineView = [[UIView alloc]initWithFrame:CGRectMake(43, 10, 310, 1)];
    downLineView.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    [footView addSubview:downLineView];

    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
     button.frame = CGRectMake(0, 1, 320, 40);
    [button setTitle:@"查看更多" forState:UIControlStateNormal];
    [button setBackgroundImage:KUIImage(@"addmorecomment") forState:UIControlStateNormal] ;
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:button];
    
    m_myTableView.tableFooterView = footView;
    
    hud =[[ MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"加载中...";
    
    
    // Do any additional setup after loading the view.
}
-(void)loadMore:(UIButton *)sender
{
    [hud show:YES];
    NSArray *array = [DataStoreManager queryallDynamicAboutMeWithUnRead:@"1"];
    [dataArray removeAllObjects];
    [dataArray addObjectsFromArray:array];
    [m_myTableView reloadData];
    [hud hide:YES];
    [sender.superview removeFromSuperview];
}
-(void)deleteInfo:(UIButton *)sender
{
    UIAlertView *delAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否确定删除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [delAlertView show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1) {
        [ DataStoreManager deleteAllcomment];
        [dataArray removeAllObjects];
        [m_myTableView reloadData];
    }else{
        return;
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    CircleMeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[CircleMeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
     DSCircleWithMe *dCircle = [dataArray objectAtIndex:indexPath.row];
    
    if ([GameCommon isEmtity:dCircle.headImg]) {
        cell.headImgBtn.imageURL = nil;
    }else{
        cell.headImgBtn.imageURL=[ImageService getImageStr:dCircle.headImg Width:160];
    }
    
    [cell.headImgBtn addTarget:self action:@selector(enterPersonInfoPage:) forControlEvents:UIControlEventTouchUpInside];
    cell.headImgBtn.tag = indexPath.row;
    cell.nickNameLabel.text =dCircle.nickname;
    
    
    //右边的样式
    if ([dCircle.myMsgImg isEqualToString:@""]||[dCircle.myMsgImg isEqualToString:@" "]) {
        cell.contentsLabel.hidden = NO;
        cell.contentImageView.hidden = YES;
        NSString *str = [NSString stringWithFormat:@"%@",dCircle.myMsg];
        CGSize titleSize = [str sizeWithFont:cell.contentsLabel.font constrainedToSize:CGSizeMake(60, 60) lineBreakMode:NSLineBreakByCharWrapping];
        cell.contentsLabel.frame = CGRectMake(CGRectGetMinX(cell.contentsLabel.frame), CGRectGetMinY(cell.contentsLabel.frame), titleSize.width, titleSize.height);
        cell.contentsLabel.text = dCircle.myMsg;
        
    }else{
        cell.contentsLabel.hidden =YES;
        cell.contentImageView.hidden = NO;
        cell.contentImageView.imageURL = [ImageService getImageStr:dCircle.myMsgImg Width:120];
        
    }
    
    NSString *str;
    if ([dCircle.myType intValue]==4) {
        str = @"赞了该内容";
        cell.titleLabel.text = str;
        cell.commentStr = str;
    }
    else if ([dCircle.myType intValue]==5||[dCircle.myType intValue]==7){
        [cell.titleLabel setEmojiText:dCircle.comment];
        str = [UILabel getStr:dCircle.comment];
        cell.commentStr=str;
    }
    
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(170, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
   float  heigth = size.height;
        cell.titleLabel.frame = CGRectMake(60, 30, 170, heigth);
    
    
    cell.timeLabel.text = [self getTimeWithMessageTime:[GameCommon getNewStringWithId:dCircle.createDate]];
    cell.timeLabel.frame  = CGRectMake(60, 33+heigth, 170, 30);
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];

    DSCircleWithMe *dCircle = [dataArray objectAtIndex:indexPath.row];
    
    OnceDynamicViewController *detailVC = [[OnceDynamicViewController alloc]init];
    detailVC.messageid = dCircle.myMsgid;
    
    detailVC.imgStr = [ImageService getImageString:dCircle.headImg];
    
    detailVC.nickNameStr = dCircle.nickname;
    detailVC.timeStr =dCircle.createDate;

    [self.navigationController pushViewController:detailVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float heigth = 0.0f;
    
    DSCircleWithMe *dcircle =[dataArray objectAtIndex:indexPath.row];

    NSString *str=dcircle.comment;
    
    if (str==nil) {
        str=@"赞了该内容";
    }
    str = [UILabel getStr:str];
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(170, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    heigth = size.height + 60;
    return heigth < 80 ? 80 : heigth;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//待添加网络删除数据
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        DSCircleWithMe *circleM =[dataArray objectAtIndex:indexPath.row];
        NSLog(@"-------------------------------%@",circleM);
        [DataStoreManager deletecommentWithMsgId:circleM.msgid];

        [dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }//231850
}

-(void)enterPersonInfoPage:(UIButton *)sender
{
    TestViewController *tsVC = [[TestViewController alloc]init];
    DSCircleWithMe *dCircle = [dataArray objectAtIndex:sender.tag];
    
    tsVC.nickName =dCircle.nickname;
    tsVC.userId =dCircle.userid;
    [self.navigationController pushViewController:tsVC animated:YES];
    
}
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
    
    NSLog(@"%f--%f",theCurrentT,theMessageT);
    NSLog(@"++%f",theCurrentT-theMessageT);
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
