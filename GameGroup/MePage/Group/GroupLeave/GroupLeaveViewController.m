//
//  GroupLeaveViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupLeaveViewController.h"
#import "EGOImageView.h"
@interface GroupLeaveViewController ()
{
    EGOImageView *headImg;
    UILabel *titleLabel;
    UILabel *numLabel;
    UILabel *lvLabel;
    UILabel *experlb;
    
    UIImageView *maxExperImg;
    UIImageView *nowExperImg;
    UIImageView *listImageView;
    UILabel *m_infoLabel;
}
@end

@implementation GroupLeaveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"群组等级" withBackButton:YES];
    
    
    UIScrollView *scrollView =[[ UIScrollView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    headImg = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 15, 80, 80)];
    headImg.placeholderImage = KUIImage(@"groupinfo_top");
    [scrollView addSubview:headImg];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 10, 200, 30)];
    titleLabel.text = @"群名";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    [scrollView addSubview:titleLabel];
    
    numLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 40, 120, 30)];
    numLabel.backgroundColor = [UIColor clearColor];
    numLabel.text = @"群号";
    numLabel.textColor = [UIColor grayColor];
    numLabel.font = [UIFont systemFontOfSize:14];
    [scrollView addSubview:numLabel];
    
    
    
    lvLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 70, 200, 30)];
    lvLabel.text = @"群等级";
    lvLabel.backgroundColor = [UIColor clearColor];
    lvLabel.textColor = [UIColor grayColor];
    lvLabel.font = [UIFont systemFontOfSize:14];
    [scrollView addSubview:lvLabel];

    UILabel *experTitleLb = [[UILabel alloc]initWithFrame:CGRectMake(20,108, 40, 20)];
    experTitleLb.text = @"群经验";
    experTitleLb.backgroundColor = [UIColor clearColor];
    experTitleLb.textColor = [UIColor grayColor];
    experTitleLb.font = [UIFont systemFontOfSize:12];
    [scrollView addSubview:experTitleLb];

    maxExperImg = [[UIImageView alloc]initWithFrame:CGRectMake(70,113, 180, 10)];
    maxExperImg.image = KUIImage(@"maxExper");
    maxExperImg.clipsToBounds = YES;

    [scrollView addSubview:maxExperImg];
   

    nowExperImg =[[UIImageView alloc]initWithFrame:CGRectMake(0,0, 150, 10)];
    nowExperImg.image = [UIImage imageNamed:@"nowExper"];
    nowExperImg.layer.cornerRadius = 5;
    nowExperImg.layer.masksToBounds=YES;

    [maxExperImg addSubview:nowExperImg];

    experlb = [[UILabel alloc]initWithFrame:CGRectMake(260,108, 100, 20)];
    experlb.text = @"0/100";
    experlb.backgroundColor = [UIColor clearColor];
    experlb.textColor = [UIColor grayColor];
    experlb.font = [UIFont systemFontOfSize:12];
    [scrollView addSubview:experlb];
    
    m_infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,130, 290, 50)];
    m_infoLabel.backgroundColor =[UIColor clearColor];
    m_infoLabel.font = [UIFont systemFontOfSize:12];
    m_infoLabel.numberOfLines =2;
    m_infoLabel.textColor = [UIColor grayColor ];
    m_infoLabel.text = @"群内每个成员在当天登陆陌游都会为群贡献1点经验值,本群升级经验还需要XX经验值";
    [scrollView addSubview:m_infoLabel];
    
    listImageView =[[UIImageView alloc]initWithFrame:CGRectMake(20,190, 280, 288)];
    listImageView.image = KUIImage(@"groupExpList");
    [scrollView addSubview:listImageView];
    
    UILabel *tsLb1 = [[UILabel alloc]initWithFrame:CGRectMake(20,485, 300, 20)];
    tsLb1.text = @"*群组每提升一级都会获得5个成员的上限";
    tsLb1.textColor = [UIColor grayColor];
    tsLb1.backgroundColor = [UIColor clearColor];
    tsLb1.font = [UIFont systemFontOfSize:12];
    [scrollView addSubview:tsLb1];

    UILabel *tsLb2 = [[UILabel alloc]initWithFrame:CGRectMake(20,505, 300, 20)];
    tsLb2.text = @"*群等级越高的群组将会在群所在的分类中排名越靠前";
    tsLb2.textColor = [UIColor grayColor];
    tsLb2.backgroundColor = [UIColor clearColor];
    tsLb2.font = [UIFont systemFontOfSize:12];
    [scrollView addSubview:tsLb2];

    scrollView.contentSize = CGSizeMake(0, 550);
    [self getInfoWithNet];
    // Do any additional setup after loading the view.
}
-(void)getInfoWithNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * paramsDict = [NSMutableDictionary dictionary];
    [paramsDict setObject:self.groupId forKey:@"groupId"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"250" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [postDict setObject:paramsDict forKey:@"params"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        titleLabel.text = [NSString stringWithFormat:@"群名：%@",KISDictionaryHaveKey(responseObject,@"groupName")];
        numLabel.text = [NSString stringWithFormat:@"群号：%@",KISDictionaryHaveKey(responseObject,@"groupId")];
        lvLabel.text = [NSString stringWithFormat:@"等级：%@",KISDictionaryHaveKey(responseObject,@"level")];
        headImg.imageURL = [ImageService getImageStr:KISDictionaryHaveKey(responseObject, @"backgroundImg") Width:170];
        m_infoLabel.text = [NSString stringWithFormat:@"群内每个成员在当天登陆陌游都会为群贡献1点经验值,本群升级经验还需要%d经验值",[KISDictionaryHaveKey(responseObject, @"levelUpExperience")intValue]-[KISDictionaryHaveKey(responseObject, @"experience")intValue]];
        float width  = [KISDictionaryHaveKey(responseObject, @"experience")floatValue]/[KISDictionaryHaveKey(responseObject, @"levelUpExperience") floatValue];
//        nowExperImg.image =[self dealDefaultImage:[UIImage imageNamed:@"nowExper"] org:215-215*width];

        nowExperImg.frame = CGRectMake(0,0, 180*width, 10);
        experlb.text = [NSString stringWithFormat:@"%@/%@",KISDictionaryHaveKey(responseObject, @"experience"),KISDictionaryHaveKey(responseObject, @"levelUpExperience")];
        
        
        
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

- (UIImage *) dealDefaultImage: (UIImage *) image org:(float)orgX
{
	CGSize size = image.size;
    float dwidth = orgX;
    CGRect rect = CGRectMake(dwidth, 2, size.width-dwidth, size.height);
	UIGraphicsBeginImageContext(CGSizeMake(size.width-dwidth, size.height));
	[image drawInRect:rect];
	UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    NSLog(@"%f--%f---%f",rect.origin.x,newimg.size.width,newimg.size.height);
    return newimg;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
