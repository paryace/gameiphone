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
#import "PhotoViewController.h"
#import "CircleHeadCell.h"
#import "MJRefresh.h"
#import "UserManager.h"
@interface CircleHeadViewController ()
{
    UITableView *m_myTableView;
    NSMutableArray *m_dataArray;//数据集合
    NSInteger  m_currPageCount;//分页加载
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;
    UILabel *nickNameLabel;
    UIImageView *topImgaeView;
    EGOImageView *headImageView;
    EGOImageView *imageView;
    UIButton *friendZanBtn;
    UIButton *abobtMeBtn;
    NSIndexPath *indexPaths;
    NSMutableArray * commentArray;
    UIView *toolView;
    UITextView *textView;
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
    NSDictionary* user=[[UserManager singleton] getUser:self.userId];

    nickNameLabel.text = KISDictionaryHaveKey(user, @"nickName");
    headImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(user, @"img")]]];
    
    m_dataArray = [NSMutableArray array];
    commentArray = [NSMutableArray array];
    m_currPageCount = 0;
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, KISHighVersion_7 ? 20 : 0, 320, self.view.bounds.size.height-(KISHighVersion_7 ? 20 : 0)) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
//    m_myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:m_myTableView];
    
    
    
    UIView *topVIew =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 440)];
    topVIew.backgroundColor  =[UIColor whiteColor];
    m_myTableView.tableHeaderView = topVIew;
    topImgaeView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];
    
    
    
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"topImage_wx"]) {
        topImgaeView.image =[UIImage imageWithData:[[NSUserDefaults standardUserDefaults]objectForKey:@"topImage_wx"]];
    }else{
        topImgaeView.image = KUIImage(@"ceshibg.jpg");
    }
    
    
    topImgaeView.userInteractionEnabled =YES;
    [topImgaeView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeTopImage:)]];
    [topVIew addSubview:topImgaeView];
    
    
//    昵称
    nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(138, 280, 85, 30)];
    nickNameLabel.text =self.nickNmaeStr;
    nickNameLabel.layer.cornerRadius = 5;
    nickNameLabel.layer.masksToBounds=YES;
    nickNameLabel.text = KISDictionaryHaveKey(user, @"nickname");

    nickNameLabel.textColor = [UIColor whiteColor];
    nickNameLabel.backgroundColor =[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.2];
    nickNameLabel.textAlignment = NSTextAlignmentRight;
    [topVIew addSubview:nickNameLabel];
    
    
    //头像
    headImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(236, 280, 80, 80)];
    headImageView.placeholderImage = KUIImage(@"placeholder");
    headImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseImageUrl,self.imageStr]];
    headImageView.layer.cornerRadius = 5;
    headImageView.layer.masksToBounds=YES;
    headImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(user, @"img")]]];
    
    [topVIew addSubview:headImageView];

    //朋友在赞
    friendZanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    friendZanBtn.frame = CGRectMake(10, 280, 85, 25);
    [friendZanBtn setBackgroundImage:KUIImage(@"friendZan") forState:UIControlStateNormal];
    [friendZanBtn addTarget:self action:@selector(friendZan:) forControlEvents:UIControlEventTouchUpInside];
    [topVIew addSubview:friendZanBtn];
    

    //与我相关
    abobtMeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    abobtMeBtn.frame = CGRectMake(68, 370, 184, 37);
    [abobtMeBtn setBackgroundImage:KUIImage(@"新消息_03") forState:UIControlStateNormal];
    [abobtMeBtn setTitle:@"N条新消息" forState:UIControlStateNormal];
    [abobtMeBtn addTarget:self action:@selector(enterAboutMePage:) forControlEvents:UIControlEventTouchUpInside];
    [topVIew addSubview:abobtMeBtn];
    
    [self setTopViewWithTitle:@"朋友圈" withBackButton:YES];

    [self addheadView];
    [self addFootView];
    
    
    textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 5, 250, 40)];
    textView.font = [UIFont systemFontOfSize:<#(CGFloat)#>]
    
    
    
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
#pragma mark --朋友在赞触发方法与网络请求
-(void)friendZan:(id)sender
{
    
}




-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *identifier =@"cell";
    CircleHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[CircleHeadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *dict = [m_dataArray objectAtIndex:indexPath.row];
    int m_currmagY =0;
    cell.tag = indexPath.row+100;
    indexPaths = [NSIndexPath indexPathForRow:cell.tag-100 inSection:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.headImgBtn.imageURL = [NSURL URLWithString:[[GameCommon isNewOrOldWithImage:[GameCommon getHeardImgId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img")]] stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img")]]];
    
    cell.headImgBtn.tag= indexPath.row;
    [cell.headImgBtn addTarget:self action:@selector(enterPersonCirclePage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    cell.nickNameLabel.text =KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"nickname");
    cell.commentStr = KISDictionaryHaveKey(dict, @"msg");
    cell.myCellDelegate = self;

    cell.timeLabel.text = [self getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")]];

    
    NSString *urlLink = KISDictionaryHaveKey(dict, @"urlLink");
    
    //判断是否是后台推送
    if ([urlLink isEqualToString:@" "]||[urlLink isEqualToString:@""]||urlLink ==nil) {
        cell.shareView.hidden = YES;
        cell.contentLabel.hidden = YES;
        cell.shareImgView.hidden = YES;
        CGSize size = [CircleHeadCell getContentHeigthWithStr:KISDictionaryHaveKey(dict, @"msg")];
        cell.titleLabel.frame = CGRectMake(60, 30, 250, size.height);
        cell.titleLabel.text = KISDictionaryHaveKey(dict, @"msg");
        
        m_currmagY  += size.height+30;
        
        if ([KISDictionaryHaveKey(dict, @"img") isEqualToString:@""]||[KISDictionaryHaveKey(dict, @"img") isEqualToString:@" "]) {
            cell.customPhotoCollectionView.hidden =YES;

                cell.timeLabel.frame = CGRectMake(60,m_currmagY+10, 120, 30);
                cell.openBtn.frame = CGRectMake(250,m_currmagY+10, 50, 40);
                m_currmagY+=50;
        }else{
            NSMutableString *imgStr = KISDictionaryHaveKey(dict, @"img");
            
            NSString *str = [imgStr substringFromIndex:imgStr.length];
            NSString *str2;
            if ([str isEqualToString:@","]) {
                str2= [imgStr substringToIndex:imgStr.length-1];
            }
            else {
                str2 = imgStr;
            }

            cell.collArray = [imgStr componentsSeparatedByString:@","];
            if ([[cell.collArray lastObject]isEqualToString:@""]||[[cell.collArray lastObject]isEqualToString:@" "]) {
                [(NSMutableArray*)cell.collArray removeLastObject];
            }
 

            cell.customPhotoCollectionView.hidden =NO;
            int i = (cell.collArray.count-1)/3;
            cell.customPhotoCollectionView.frame = CGRectMake(60, m_currmagY, 240, i*80+80) ;
            CGFloat paddingY = 7;
            CGFloat paddingX = 7;
            cell.layout.sectionInset = UIEdgeInsetsMake(paddingY, paddingX, paddingY, paddingX);
            
            [cell.customPhotoCollectionView reloadData];
            // 4.设置每一行之间的间距
            cell.layout.minimumLineSpacing = paddingY;
            m_currmagY += i*80+80;
            
            cell.timeLabel.frame = CGRectMake(60,m_currmagY, 120, 30);
            cell.openBtn.frame = CGRectMake(250,m_currmagY, 50, 40);
            m_currmagY+=40;
            
        }
       
    }
    else
    {
        cell.shareView.hidden = NO;
        cell.contentLabel.hidden = NO;
        cell.shareImgView.hidden = NO;
        cell.customPhotoCollectionView.hidden =YES;
        CGSize size1 = [CircleHeadCell getContentHeigthWithStr:KISDictionaryHaveKey(dict, @"title")];
        cell.titleLabel.frame = CGRectMake(60, 30, 250, size1.height);
        cell.titleLabel.text = KISDictionaryHaveKey(dict, @"title");
        cell.shareView.frame = CGRectMake(60, size1.height+30, 250, 50);
        cell.contentLabel.text = KISDictionaryHaveKey(dict, @"msg");
        
        
        UITapGestureRecognizer *tapGe = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterInfoPage:)];
        [cell.shareView addGestureRecognizer:tapGe];
        tapGe.view.tag = indexPath.row;
        
        cell.shareImgView.imageURL = [NSURL URLWithString:[GameCommon isNewOrOldWithImage:KISDictionaryHaveKey(dict, @"img") width:80 hieght:80 a:80]];
        m_currmagY  = size1.height+80;
        
        cell.timeLabel.frame = CGRectMake(60,size1.height+80, 120, 30);
        cell.openBtn.frame = CGRectMake(250,size1.height+80, 50, 40);
        m_currmagY+=cell.timeLabel.frame.size.height+10;
    }
    
//    UIView *listView = [[UIView alloc]initWithFrame:CGRectMake(60, m_currmagY+25, 200, 1)];
//    listView.backgroundColor =UIColorFromRGBA(0xe1e1e1, 1);
//    listView.hidden = YES;
//    [cell.contentView addSubview:listView];
//
    
    if ([KISDictionaryHaveKey(dict, @"zanNum")intValue]!=0) {
        cell.zanView.frame = CGRectMake(60, m_currmagY, 200, 25);
        NSArray *array = KISDictionaryHaveKey(dict, @"zanList");
        cell.zanView.hidden = NO;
        cell.zanImageView.center = CGPointMake(5, 5);
        cell.zanNameLabel.text = KISDictionaryHaveKey([array objectAtIndex:0], @"nickname");
        cell.zanLabel.text = [NSString stringWithFormat:@"等%@人都觉得赞",KISDictionaryHaveKey(dict,@"zanNum")];
        m_currmagY +=cell.zanView.frame.size.height;

    }else{
        cell.zanView.hidden = YES;
        [cell.zanView removeFromSuperview];
    }
    commentArray =KISDictionaryHaveKey(dict, @"commentList");
    if ([commentArray isKindOfClass:[NSArray class]]&&commentArray !=nil) {
        cell.commentsView.hidden =NO;
        NSArray *views = [cell.commentsView subviews];
        for(UIView* view in views)
        {
            [view removeFromSuperview];
        }
        cell.commentsView.frame = CGRectMake(60, m_currmagY, 250, commentArray.count *20);
    for (int i = 0; i<commentArray.count; i++) {
        UILabel * commNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20*i, 100, 20)];
        commNameLabel.font = [UIFont systemFontOfSize:12];
        [cell.commentsView addSubview:commNameLabel];
        UILabel * commentsLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 20*i, 140, 20)];
        commentsLabel.font = [UIFont systemFontOfSize:12];
        commentsLabel.textColor = UIColorFromRGBA(0x455ca8, 1);
        [cell.commentsView addSubview:commentsLabel];

        NSDictionary *dic = [commentArray objectAtIndex:i];
        commNameLabel.text =KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"commentUser"), @"nickname");
        commentsLabel.text =KISDictionaryHaveKey(dic,@"comment");
        cell.commentsView.hidden = NO;
        commNameLabel.hidden = NO;
        commentsLabel.hidden = NO;
    }
        m_currmagY +=commentArray.count*20;
    }
    else{
        cell.commentsView.hidden =YES;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float currnetY = 0;

    NSDictionary *dict =[m_dataArray objectAtIndex:indexPath.row];
    if (![KISDictionaryHaveKey(dict, @"urlLink")isEqualToString:@""]&&![KISDictionaryHaveKey(dict, @"urlLink")isEqualToString:@" "]) {
        CGSize size = [CircleHeadCell getContentHeigthWithStr:KISDictionaryHaveKey(dict, @"title")];

        currnetY +=size.height+30+50+40;
    }else{
        
        CGSize size = [CircleHeadCell getContentHeigthWithStr:KISDictionaryHaveKey(dict, @"msg")];

        currnetY +=size.height+30;
        currnetY+=40;
        NSArray *imgArray = [NSArray array];
        NSString *imgStr =KISDictionaryHaveKey(dict, @"img");
        NSString *str;
        if ([imgStr isEqualToString:@""] || [imgStr isEqualToString:@" "]) {
            str = @"";
        }else{
            str = [imgStr substringFromIndex:imgStr.length-1];
            NSString *str2;
            if ([str isEqualToString:@","]) {
                str2= [imgStr substringToIndex:imgStr.length-1];
            }
            else {
                str2 = imgStr;
            }
            
            imgArray = [NSArray array];
            
            imgArray = [str2 componentsSeparatedByString:@","];
        }

    if ([KISDictionaryHaveKey(dict, @"img")isEqualToString:@""]||[KISDictionaryHaveKey(dict, @"img") isEqualToString:@" "]) {
        
        }
        else
        {
            if (imgArray.count==1) {
                currnetY +=180;
            }
            else if(imgArray.count>1&&imgArray.count<4){
                currnetY+=80;
            }
            else if(imgArray.count>4&&imgArray.count<6){
                currnetY  +=160;
            }else{
                currnetY +=240;
            }
        }
    }
    if ([KISDictionaryHaveKey(dict, @"zanNum")intValue]>0) {
        currnetY+=40;
    }else{
        
    }
    NSArray *ar = [NSArray array];
    ar = KISDictionaryHaveKey(dict, @"commentList");
    if (ar.count>0) {
        currnetY+=ar.count*20+10;
    }
    else{
        
    }
    return currnetY;
    currnetY =0;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)enterPersonCirclePage:(UIButton *)sender
{
    NSDictionary *dict = [m_dataArray objectAtIndex:sender.tag];
    MyCircleViewController *VC = [[MyCircleViewController alloc]init];
    VC.userId = [GameCommon getHeardImgId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"userid")];
    VC.nickNmaeStr = KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"nickname");
    VC.imageStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img")];
    [self.navigationController pushViewController:VC animated:YES];
}


-(void)enterInfoPage:(UITapGestureRecognizer *)sender
{
    NSDictionary *dict = [m_dataArray objectAtIndex:sender.view.tag];
    
    OnceDynamicViewController *detailVC = [[OnceDynamicViewController alloc]init];
    detailVC.messageid = KISDictionaryHaveKey(dict, @"id");
    
    NSString* imageName = [GameCommon getHeardImgId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img")];
    
    detailVC.imgStr =[BaseImageUrl stringByAppendingString:imageName];
    detailVC.nickNameStr = [KISDictionaryHaveKey(dict, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]] ? @"我" :KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"nickname");
    
    
    detailVC.timeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")];
    
    [self.navigationController pushViewController:detailVC animated:YES];

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


//获取时间
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


#pragma mark ---cell delegate
-(void)pinglunWithCircle:(CircleHeadCell *)myCell
{
    NSLog(@"评论");
    
    
    
}

-(void)zanWithCircle:(CircleHeadCell *)myCell
{
    NSLog(@"赞");
}

- (void)bigImgWithCircle:(CircleHeadCell*)myCell WithIndexPath:(NSInteger)row
{
    NSLog(@"点击查看大图");
    NSDictionary *dict = [m_dataArray objectAtIndex:myCell.tag-100];
    NSArray *array = [NSArray  array];

    NSString *imgStr =KISDictionaryHaveKey(dict, @"img");
    NSString *str;
    if ([imgStr isEqualToString:@""] || [imgStr isEqualToString:@" "]) {
        str = @"";
    }else{
        str = [imgStr substringFromIndex:imgStr.length-1];
        NSString *str2;
        if ([str isEqualToString:@","]) {
            str2= [imgStr substringToIndex:imgStr.length-1];
        }
        else {
            str2 = imgStr;
        }
        array = [NSArray array];
        
        array = [str2 componentsSeparatedByString:@","];
    }

    PhotoViewController * pV = [[PhotoViewController alloc] initWithSmallImages:nil images:array indext:row];
    [self presentViewController:pV animated:NO completion:^{
        
    }];

}

-(void)addheadView
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = m_myTableView;
    
    header.scrollView = m_myTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        m_currPageCount = 0;
        [self getInfoFromNet];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
    [header beginRefreshing];
    m_header = header;
}
-(void)addFootView
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    CGRect headerRect = footer.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    footer.arrowImage.frame = headerRect;
    footer.activityView.center = footer.arrowImage.center;
    footer.scrollView = m_myTableView;
    
    footer.scrollView = m_myTableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self getInfoFromNet];
        
    };
    m_footer = footer;
    
}




//            NSLog(@"第%d行--%d个--%@",indexPath.row,arr.count,arr);
//            if (arr.count==1)
//            {
//                cell.thumbImgView = [[EGOImageView alloc]initWithPlaceholderImage:KUIImage( @"placeholder")];
//
//                cell.thumbImgView.imageURL = [NSURL URLWithString:[[GameCommon isNewOrOldWithImage:[GameCommon getHeardImgId:KISDictionaryHaveKey(dict, @"img")] ] stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(dict, @"img")]]];
//
//                cell.thumbImgView.frame = CGRectMake(60, size.height+30,180, cell.thumbImgView.image.size.height*(180/ cell.thumbImgView.image.size.width));
//
//                cell.timeLabel.frame = CGRectMake(60,size.height+30+cell.thumbImgView.image.size.height*(180/cell.thumbImgView.image.size.height), 120, 30);
//                cell.openBtn.frame = CGRectMake(250,size.height+30+cell.thumbImgView.image.size.height*(180/cell.thumbImgView.image.size.height), 50, 40);
//                m_currmagY+=cell.openBtn.frame.size.height;
//
//                m_currmagY +=cell.thumbImgView.image.size.height*(180/ cell.thumbImgView.image.size.width);
//            }
//            else if(arr.count ==2)
//            {
//                for (int i = 0; i<2; i++) {
//
//                cell.thumbImgView = [[EGOImageView alloc]initWithPlaceholderImage:KUIImage( @"placeholder")];
//
//                cell.thumbImgView.frame = CGRectMake(60+i*(250/2), size.height+30,250/2,80);
//
//                cell.thumbImgView.imageURL = [NSURL URLWithString:[[GameCommon isNewOrOldWithImage:[GameCommon getHeardImgId:[arr objectAtIndex:i]] ] stringByAppendingString:[arr objectAtIndex:i]]];
//
//                cell.openBtn.frame = CGRectMake(250,size.height+30+cell.thumbImgView.image.size.height*(180/cell.thumbImgView.image.size.height), 50, 40);
//                m_currmagY+=cell.openBtn.frame.size.height;
//
//                m_currmagY +=cell.thumbImgView.image.size.height*(180/ cell.thumbImgView.image.size.width);
//                }
//            }
//            else
//            {
//                cell.timeLabel.frame = CGRectMake(60,size.height+30+80+(arr.count/3)*80, 120, 30);
//                cell.openBtn.frame = CGRectMake(250,size.height+30+80+ (arr.count/3)*80, 50, 40);
//                m_currmagY+=80+arr.count/3*80;
//
//
//                for (int i =0; i<arr.count/3; i++) {
//                    for (int j = 0; j<3; j++) {
//                        cell.thumbImgView = [[EGOImageView alloc]initWithPlaceholderImage:KUIImage( @"placeholder")];
//                        cell.thumbImgView.frame =CGRectMake(60+80*j, size.height+35+80*i, 75, 75);
//
//                        cell.thumbImgView.imageURL = [NSURL URLWithString:[[GameCommon isNewOrOldWithImage:[arr objectAtIndex:i*3+j] ] stringByAppendingString:[arr objectAtIndex:i*3+j]]];
//
//                        [cell.contentView addSubview:cell.thumbImgView];
//                    }
//                }
//            }

@end
