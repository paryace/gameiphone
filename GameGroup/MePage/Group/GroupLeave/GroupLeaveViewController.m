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
    
}
@end

@implementation GroupLeaveViewController

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
    
    [self setTopViewWithTitle:@"群组经验" withBackButton:YES];
    
    
    UIScrollView *scrollView =[[ UIScrollView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    headImg = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 15, 80, 80)];
    headImg.placeholderImage = KUIImage(@"groupinfo_top");
    [scrollView addSubview:headImg];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 10, 200, 30)];
    titleLabel.text = @"群名";
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    [scrollView addSubview:titleLabel];
    
    numLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 40, 200, 30)];
    numLabel.text = @"群号";
    numLabel.textColor = [UIColor grayColor];
    numLabel.font = [UIFont systemFontOfSize:14];
    [scrollView addSubview:numLabel];
    
    lvLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 70, 200, 30)];
    lvLabel.text = @"群等级";
    lvLabel.textColor = [UIColor grayColor];
    lvLabel.font = [UIFont systemFontOfSize:14];
    [scrollView addSubview:lvLabel];

    UILabel *experTitleLb = [[UILabel alloc]initWithFrame:CGRectMake(20,100, 40, 20)];
    experTitleLb.text = @"群经验";
    experTitleLb.textColor = [UIColor grayColor];
    experTitleLb.font = [UIFont systemFontOfSize:12];
    [scrollView addSubview:experTitleLb];

    maxExperImg = [[UIImageView alloc]initWithFrame:CGRectMake(70,105, 180, 10)];
    maxExperImg.image = KUIImage(@"maxExper");
    [scrollView addSubview:maxExperImg];
    
    nowExperImg =[[UIImageView alloc]initWithFrame:CGRectMake(70,105, 150, 10)];
    nowExperImg.image = KUIImage(@"nowExper");
    [scrollView addSubview:nowExperImg];

    experlb = [[UILabel alloc]initWithFrame:CGRectMake(260,100, 40, 20)];
    experlb.text = @"0/100";
    experlb.textColor = [UIColor grayColor];
    experlb.font = [UIFont systemFontOfSize:12];
    [scrollView addSubview:experlb];
    
    UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,130, 290, 50)];
    infoLabel.backgroundColor =[UIColor clearColor];
    infoLabel.font = [UIFont systemFontOfSize:12];
    infoLabel.numberOfLines =2;
    infoLabel.textColor = [UIColor grayColor ];
    infoLabel.text = @"群内每个成员在当天登陆陌游都会为群贡献1点经验值,本群升级经验还需要XX经验值";
    [scrollView addSubview:infoLabel];
    
    listImageView =[[UIImageView alloc]initWithFrame:CGRectMake(20,190, 280, 288)];
    listImageView.image = KUIImage(@"groupExpList");
    [scrollView addSubview:listImageView];
    
    UILabel *tsLb1 = [[UILabel alloc]initWithFrame:CGRectMake(20,485, 300, 20)];
    tsLb1.text = @"*群组每提升一级都会获得5个成员的上限";
    tsLb1.textColor = [UIColor grayColor];
    tsLb1.font = [UIFont systemFontOfSize:12];
    [scrollView addSubview:tsLb1];

    UILabel *tsLb2 = [[UILabel alloc]initWithFrame:CGRectMake(20,505, 300, 20)];
    tsLb2.text = @"*群等级越高的群组将会在群所在的分类中排名越靠前";
    tsLb2.textColor = [UIColor grayColor];
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
        float width  = [KISDictionaryHaveKey(responseObject, @"experience")floatValue]/[KISDictionaryHaveKey(responseObject, @"levelUpExperience") floatValue];
        
        nowExperImg.frame = CGRectMake(70,105, 180*width, 10);
        
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
