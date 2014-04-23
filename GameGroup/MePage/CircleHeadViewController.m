//
//  CircleHeadViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-4-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CircleHeadViewController.h"
#import "OnceDynamicViewController.h"
#import "CircleWithMeViewController.h"
#import "MyCircleViewController.h"
#import "CircleHeadCell.h"
#import "MJRefresh.h"
#import "UserManager.h"
@interface CircleHeadViewController ()
{
    UITableView *m_myTableView;
    NSMutableArray *m_dataArray;
    NSInteger  m_currPageCount;
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;
    UILabel *nickNameLabel;
    UIImageView *topImgaeView;
    EGOImageView *headImageView;
    EGOImageView *imageView;
    UIButton *friendZanBtn;
    
    UIButton *abobtMeBtn;
    
}
@end

@implementation CircleHeadViewController

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
    
    NSDictionary* user=[[UserManager singleton] getUser:self.userId];

    nickNameLabel.text = KISDictionaryHaveKey(user, @"nickName");
    headImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(user, @"img")]]];
    
    m_dataArray = [NSMutableArray array];
    m_currPageCount = 0;
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];
    
    UIView *topVIew =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 350)];
    topVIew.backgroundColor  =[UIColor whiteColor];
    m_myTableView.tableHeaderView = topVIew;
    topImgaeView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 250)];
    
    friendZanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    friendZanBtn.frame = CGRectMake(10, 210, 85, 25);
    [friendZanBtn setBackgroundImage:KUIImage(@"朋友在赞_02") forState:UIControlStateNormal];
    [topVIew addSubview:friendZanBtn];
    
    
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"topImage_wx"]) {
        topImgaeView.image =[UIImage imageWithData:[[NSUserDefaults standardUserDefaults]objectForKey:@"topImage_wx"]];
    }else{
        topImgaeView.image = KUIImage(@"ceshibg.jpg");
    }
    
    topImgaeView.userInteractionEnabled =YES;
    [topImgaeView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeTopImage:)]];
    [topVIew addSubview:topImgaeView];
    
    nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(138, 210, 85, 30)];
    nickNameLabel.text =self.nickNmaeStr;
    nickNameLabel.layer.cornerRadius = 5;
    nickNameLabel.layer.masksToBounds=YES;
    nickNameLabel.text = KISDictionaryHaveKey(user, @"nickname");

    nickNameLabel.textColor = [UIColor whiteColor];
    nickNameLabel.backgroundColor =[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.2];
    nickNameLabel.textAlignment = NSTextAlignmentRight;
    [topVIew addSubview:nickNameLabel];
    
    headImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(236, 206, 80, 80)];
    headImageView.placeholderImage = KUIImage(@"placeholder");
    headImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseImageUrl,self.imageStr]];
    headImageView.layer.cornerRadius = 5;
    headImageView.layer.masksToBounds=YES;
    headImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(user, @"img")]]];
    
    [topVIew addSubview:headImageView];

    abobtMeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    abobtMeBtn.frame = CGRectMake(68, 300, 184, 37);
    [abobtMeBtn setBackgroundImage:KUIImage(@"新消息_03") forState:UIControlStateNormal];
    [abobtMeBtn setTitle:@"N条新消息" forState:UIControlStateNormal];
    [abobtMeBtn addTarget:self action:@selector(enterAboutMePage:) forControlEvents:UIControlEventTouchUpInside];
    [topVIew addSubview:abobtMeBtn];
    
    
    [self getInfoFromNet];
    
    // Do any additional setup after loading the view.
}
-(void)enterAboutMePage:(id)sender
{
    CircleWithMeViewController *cir = [[CircleWithMeViewController alloc]init];
    cir.userId = [[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:haveMyNews];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.navigationController pushViewController:cir animated:YES];
}
-(void)getInfoFromNet
{
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:self.userId forKey:@"userid"];
    [paramDic setObject:@"20" forKey:@"maxSize"];
    [paramDic setObject:@(m_currPageCount) forKey:@"pageIndex"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"189" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            if (m_currPageCount==0) {
                [m_dataArray removeAllObjects];
                [m_dataArray addObjectsFromArray:responseObject];
                
            }else{
                [m_dataArray addObjectsFromArray:responseObject];
            }
            m_currPageCount++;
            [m_header endRefreshing];
            [m_footer endRefreshing];
            [m_myTableView reloadData];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [m_header endRefreshing];
        [m_footer endRefreshing];
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
    return m_dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

     NSString *identifier =[NSString stringWithFormat: @"cell%d",indexPath.row];
    CircleHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[CircleHeadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *dict = [m_dataArray objectAtIndex:indexPath.row];

    cell.headImgBtn.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img")]]];
    cell.nickNameLabel.text =KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"nickname");
    cell.titleLabel.text = KISDictionaryHaveKey(dict, @"msg");
    cell.commentStr = KISDictionaryHaveKey(dict, @"msg");
    
    
    CGSize size = [CircleHeadCell getContentHeigthWithStr:KISDictionaryHaveKey(dict, @"msg")];
    
    cell.titleLabel.frame = CGRectMake(60, 27, 170, size.height);

    [cell buildImagePathWithImage:KISDictionaryHaveKey(dict, @"img")];


    cell.timeLabel.text = [self getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")]];

    cell.titleLabel.frame = CGRectMake(60, 27, 170, size.height);
    
    if (![KISDictionaryHaveKey(dict, @"img") isEqualToString:@""]&&[KISDictionaryHaveKey(dict, @"img")isEqualToString:@" "]) {
        
        NSArray* arr = [KISDictionaryHaveKey(dict, @"img") componentsSeparatedByString:@","];
       // NSLog(@"arr%@-->%@-->%d",arr,imgStr,arr.count);
        
        for (int i =0; i<3; i++) {
            for (int j = 0; j<arr.count/3; j++) {
                cell.thumbImgView = [[EGOImageView alloc]initWithPlaceholderImage:KUIImage( @"placeholder")];
 
                if (arr.count==1)
                {
                    cell.thumbImgView.frame = CGRectMake(60, size.height+27,180, cell.thumbImgView.image.size.height*(180/ cell.thumbImgView.image.size.width));
                }
                else{
                    cell.thumbImgView.frame =CGRectMake(60+80*i, size.height+27+80*j, 75, 75);
                }
                cell.thumbImgView.imageURL = [NSURL URLWithString:[[GameCommon isNewOrOldWithImage:[arr objectAtIndex:i+j*i] ] stringByAppendingString:[arr objectAtIndex:i+j*i]]];

                [cell.contentView addSubview:cell.thumbImgView];

            }
        }
            cell.timeLabel.frame = CGRectMake(60,size.height+27+80*arr.count/3, 120, 30);
    }
    
    NSString *urlLink = KISDictionaryHaveKey(dict, @"urlLink");
       if ([urlLink isEqualToString:@" "]||[urlLink isEqualToString:@""]||urlLink ==nil) {
        cell.shareView.hidden = YES;
        cell.contentLabel.hidden = YES;
        cell.shareImgView.hidden = YES;
           //cell.thumbImgView.hidden = NO;
    }else{
        cell.shareView.hidden = NO;
        cell.contentLabel.hidden = NO;
        cell.shareImgView.hidden = NO;
        cell.timeLabel.frame = CGRectMake(60,size.height+27+cell.shareView.bounds.size.height+10, 120, 30);

       // cell.thumbImgView.hidden = YES;
    }
    cell.openBtn.frame = CGRectMake(250, cell.timeLabel.frame.origin.y, 50, 30);

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [m_dataArray objectAtIndex:indexPath.row];
    
    OnceDynamicViewController *detailVC = [[OnceDynamicViewController alloc]init];
    detailVC.messageid = KISDictionaryHaveKey(dict, @"id");
    //    detailVC.urlLink = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"urlLink")];
    
    NSString* imageName = [GameCommon getHeardImgId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img")];
    
    detailVC.imgStr =[BaseImageUrl stringByAppendingString:imageName];
    detailVC.nickNameStr = [KISDictionaryHaveKey(dict, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]] ? @"我" :KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"nickname");
    
    
    detailVC.timeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")];
    
    [self.navigationController pushViewController:detailVC animated:YES];

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size= [CircleHeadCell getContentHeigthWithStr:KISDictionaryHaveKey([m_dataArray objectAtIndex:indexPath.row], @"comment")];
    NSDictionary *dict =[m_dataArray objectAtIndex:indexPath.row];
    
    NSArray *arr =[KISDictionaryHaveKey(dict, @"img") componentsSeparatedByString:@","];
    NSLog(@"arr/3--%d->%d",arr.count,arr.count/3);

    if (![KISDictionaryHaveKey(dict, @"urlLink")isEqualToString:@""]&&![KISDictionaryHaveKey(dict, @"urlLink")isEqualToString:@" "]) {
        return size.height + 27 + 100;
    }
    
   else if ([KISDictionaryHaveKey(dict, @"img")isEqualToString:@""]||[KISDictionaryHaveKey(dict, @"img") isEqualToString:@" "]) {
        return size.height+27+60;
    }
    else
    {
       if (arr.count==1) {
           return 150;
       }
       else{
           return size.height+27+120+((arr.count/3)*80);
       }

    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)changeTopImage:(UIGestureRecognizer*)sender
{
    UIActionSheet *acs = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相册" otherButtonTitles:@"相机", nil];
    [acs showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController * imagePicker;
    if (buttonIndex==1)
        //这里捕捉“毁灭键”,其实该键的index是0，从上到下从0开始，称之为毁灭是因为是红的
    {
        if (imagePicker==nil) {
            imagePicker=[[UIImagePickerController alloc]init];
            imagePicker.delegate=self;
            imagePicker.allowsEditing = YES;
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:^{
                
            }];
        }
        else {
            UIAlertView *cameraAlert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的设备不支持相机" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
            [cameraAlert show];
        }
    }
    else if (buttonIndex==0) {
        if (imagePicker==nil) {
            imagePicker=[[UIImagePickerController alloc]init];
            imagePicker.delegate=self;
            imagePicker.allowsEditing = YES;
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            //                [self presentModalViewController:imagePicker animated:YES];
            [self presentViewController:imagePicker animated:YES completion:^{
                
            }];
        }
        else {
            UIAlertView *libraryAlert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的设备不支持相册" delegate:self cancelButtonTitle:@"了解" otherButtonTitles:nil];
            [libraryAlert show];
        }
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%@",info);
    UIImage * upImage = (UIImage *)[info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSData *data =UIImageJPEGRepresentation(upImage, 1);
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"topImage_wx"];
    topImgaeView.image = upImage;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
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
