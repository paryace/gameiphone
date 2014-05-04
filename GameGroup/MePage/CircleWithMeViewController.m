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
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    
    [shareButton setBackgroundImage:KUIImage(@"published_circle_normal") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"published_circle_click") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(publishInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    dataArray = [NSMutableArray array];
    m_currentPage = 0;
    dataArray = (NSMutableArray *)[DataStoreManager queryallDynamicAboutMeWithUnRead:@"0"];

    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.rowHeight =80;
    [self.view addSubview:m_myTableView];
    
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    [button setTitle:@"查看更多" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
    sleep(2);
    [m_myTableView reloadData];
    [hud hide:YES];
    [sender.superview removeFromSuperview];
}
-(void)publishInfo:(UIButton *)sender
{
    SendNewsViewController* sendNews = [[SendNewsViewController alloc] init];
    sendNews.delegate = self;
    sendNews.isComeFromMe = YES;
    [self.navigationController pushViewController:sendNews animated:YES];
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
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
     DSCircleWithMe *dCircle = [dataArray objectAtIndex:indexPath.row];
    
    if ([dCircle.headImg isEqualToString:@""]||[dCircle.headImg isEqualToString:@" "]) {
        cell.headImgBtn.imageURL = nil;
    }else{
        cell.headImgBtn.imageURL = [NSURL URLWithString:[GameCommon isNewOrOldWithImage:[GameCommon getHeardImgId:dCircle.headImg] width:80 hieght:80 a:@"80"]];
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
        NSString* imageContet = [BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:dCircle.myMsgImg]];
        NSURL *imageContetURL = [NSURL URLWithString:[imageContet stringByAppendingFormat:@"/60/60"]];
        cell.contentImageView.imageURL = imageContetURL;
    }
    
    
    if ([dCircle.myType intValue]==4) {
        cell.titleLabel.text = @"赞了该内容";
        cell.commentStr = @"赞了该内容";
    }
    else if ([dCircle.myType intValue]==5||[dCircle.myType intValue]==7){
        cell.titleLabel.text =dCircle.comment;
        cell.commentStr=dCircle.comment;
    }
    cell.timeLabel.text = [self getTimeWithMessageTime:[GameCommon getNewStringWithId:dCircle.createDate]];
    
    [cell refreshCell];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DSCircleWithMe *dCircle = [dataArray objectAtIndex:indexPath.row];
    
    OnceDynamicViewController *detailVC = [[OnceDynamicViewController alloc]init];
    detailVC.messageid = dCircle.myMsgid;
    //    detailVC.urlLink = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"urlLink")];
    
    NSString* imageName = [GameCommon getHeardImgId:dCircle.headImg];
    
    detailVC.imgStr =[BaseImageUrl stringByAppendingString:imageName];
    detailVC.nickNameStr = dCircle.nickname;
    
    
    detailVC.timeStr =dCircle.createDate;

    [self.navigationController pushViewController:detailVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DSCircleWithMe *dcircle =[dataArray objectAtIndex:indexPath.row];
    float heigth = [CircleMeCell getContentHeigthWithStr:(dcircle.comment)] + 50;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
