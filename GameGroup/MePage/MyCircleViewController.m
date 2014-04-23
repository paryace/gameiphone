//
//  MyCircleViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-4-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MyCircleViewController.h"
#import "CircleWithMeViewController.h"
#import "OnceDynamicViewController.h"
#import "EGOImageView.h"
#import "MyCircleCell.h"
@interface MyCircleViewController ()
{
    UITableView *m_myTableView;
    UILabel *nickNameLabel;
    EGOImageView *headImageView;
    UIImageView *topImgaeView;
    NSMutableArray *dataArray;
    NSInteger *PageNum;
}
@end

@implementation MyCircleViewController

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
    
    [self setTopViewWithTitle:@"朋友圈" withBackButton:YES];
    
    PageNum =0;
    dataArray = [NSMutableArray array];
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX) style:UITableViewStylePlain];
    m_myTableView.rowHeight = 130;
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:m_myTableView];
    
    UIView *topVIew =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 300)];
    topVIew.backgroundColor  =[UIColor whiteColor];
    m_myTableView.tableHeaderView = topVIew;
    topImgaeView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 250)];
    
    topImgaeView.image = KUIImage(@"ceshibg.jpg");
    
    [topVIew addSubview:topImgaeView];
    
    nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(138, 210, 85, 30)];
    nickNameLabel.text =self.nickNmaeStr;
    nickNameLabel.layer.cornerRadius = 5;
    nickNameLabel.layer.masksToBounds=YES;
    nickNameLabel.textColor = [UIColor whiteColor];
    nickNameLabel.backgroundColor =[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.2];
    nickNameLabel.textAlignment = NSTextAlignmentRight;
    [topVIew addSubview:nickNameLabel];
    
    headImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(236, 206, 80, 80)];
    headImageView.placeholderImage = KUIImage(@"placeholder");
    headImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseImageUrl,self.imageStr]];
    headImageView.layer.cornerRadius = 5;
    headImageView.layer.masksToBounds=YES;

    [topVIew addSubview:headImageView];
    
    [self getInfoFromNet];
}





-(void)getInfoFromNet
{
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:self.userId forKey:@"userid"];
    [paramDic setObject:@"0" forKey:@"pageIndex"];
    [paramDic setObject:@"20" forKey:@"maxSize"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"192" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
  
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [dataArray addObjectsFromArray:responseObject];
            [m_myTableView reloadData];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];
 
    
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier =@"cell";
    MyCircleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[MyCircleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    NSDictionary *dic = [dataArray objectAtIndex:indexPath.row];
    
    cell.dataLabel.text =[NSString stringWithFormat:@"%d",indexPath.row+1];
    cell.monthLabel.text = @"Mar.2014";
    NSArray* arr = [KISDictionaryHaveKey(dic, @"img") componentsSeparatedByString:@","];


    if (arr.count ==1&&[(NSString *)[arr objectAtIndex:0]isEqualToString:@""]) {
        cell.imgCountLabel.hidden = YES;
        cell.thumbImageView.hidden =YES;
        cell.commentStr = KISDictionaryHaveKey(dic, @"msg");
        [cell refreshCell];

        //cell.titleLabel.center = CGPointMake(cell.titleLabel.center.x, cell.center.y);
        cell.titleLabel.font = [UIFont systemFontOfSize:15];
        cell.titleLabel.backgroundColor = UIColorFromRGBA(0xf0f1f3, 1);
        cell.titleLabel.numberOfLines = 2;
        
    }else{
        cell.imgCountLabel.hidden = NO;
        cell.thumbImageView.hidden =NO;
    //    cell.titleLabel.center = CGPointMake(cell.titleLabel.center.x, cell.titleLabel.center.y);
        cell.titleLabel.frame = CGRectMake(155, 0, 155, 70);
        cell.titleLabel.font = [UIFont systemFontOfSize:12];
        cell.titleLabel.backgroundColor = [UIColor clearColor];
        cell.titleLabel.numberOfLines = 3;

    }

    cell.imgCountLabel.text = [NSString stringWithFormat:@"(共%d张)",arr.count];
    
    
    cell.thumbImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(dic, @"img")]]];
    
   // [cell getImageWithCount:KISDictionaryHaveKey(dic, @"img")];
    cell.titleLabel.text = KISDictionaryHaveKey(dic, @"msg");
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [dataArray objectAtIndex:indexPath.row];
    
    OnceDynamicViewController *detailVC = [[OnceDynamicViewController alloc]init];
    detailVC.messageid = KISDictionaryHaveKey(dict, @"id");
    //    detailVC.urlLink = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"urlLink")];
    
    
    detailVC.timeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")];
    [self.navigationController pushViewController:detailVC animated:YES];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSDictionary *dic = [dataArray objectAtIndex:indexPath.row];
    if ([KISDictionaryHaveKey(dic, @"img")isEqualToString:@""]) {
        CGSize size = [MyCircleCell getContentHeigthWithStr:KISDictionaryHaveKey(dic, @"msg")];
        if (size.height<60) {
            return 60;
        }else{
        return size.height;
        }
    }else{
        return 100;
    }
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
