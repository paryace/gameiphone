//
//  SeniorViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SeniorViewController.h"
#import "MemberView.h"
@interface SeniorViewController ()
{
    NSDictionary * m_userDict;
    NSDictionary * m_charaDic;
    
    UILabel *m_zdlLb;
    DWTagList * tagList;
    NSMutableDictionary *seniorDict;
    NSMutableArray * m_tagsArray;
    
}
@end

@implementation SeniorViewController

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
    [self setTopViewWithTitle:@"高级" withBackButton:YES];
    
    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"okButton") forState:UIControlStateNormal];
    [createBtn setBackgroundImage:KUIImage(@"okButton2") forState:UIControlStateHighlighted];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(createItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];

    m_tagsArray = [NSMutableArray array];
    
    m_userDict = [NSMutableDictionary dictionaryWithDictionary:[[UserManager singleton ]getUser:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]];
    seniorDict = [NSMutableDictionary dictionary];
    m_charaDic = [NSMutableDictionary dictionaryWithDictionary:[DataStoreManager queryCharacter:self.charaterId]];
    UIView * firstLineView =[self buildViewWithFrame:CGRectMake(0, startX+60, 320, 25) leftText:@"最低战斗力" rigthText:@"20000"];
    [self.view addSubview:firstLineView];
    
    [self buildPersonInfoView];
    UIView *secondLineView = [self buildViewWithFrame:CGRectMake(0, startX+170, 320, 25) leftText:@"队友最低段位(单选)" rigthText:nil];
    [self.view addSubview:secondLineView];
    
    [self buildSliderView];
    [self buildCardView];

    [self getcardWithNet];
    // Do any additional setup after loading the view.
}

-(void)getcardWithNet
{
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_charaDic, @"gameid")] forKey:@"gameid"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"285" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [m_tagsArray removeAllObjects];
            [m_tagsArray addObjectsFromArray:responseObject];
            [tagList setTags:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
        [hud hide:YES];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag = 789;
                [alert show];
            }
        }
    }];

}


-(UIView *)buildViewWithFrame:(CGRect)frame leftText:(NSString *)leftText rigthText:(NSString *)rightText
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.backgroundColor = UIColorFromRGBA(0xc1c1c1, 1);
    
    UILabel *leftlb = [GameCommon buildLabelinitWithFrame:CGRectMake(10,0, 150, 25) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
    UILabel *rightLb = [GameCommon buildLabelinitWithFrame:CGRectMake(200, 0, 100, 25) font:[UIFont boldSystemFontOfSize:12] textColor:[UIColor blueColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentRight];
    leftlb.text = leftText;
    rightLb.text = rightText;
    [view addSubview:leftlb];
    [view addSubview:rightLb];
    return view;
}
-(void)buildPersonInfoView
{    
    MemberView *cell  =[[MemberView alloc]initWithFrame:CGRectMake(0, startX, 320, 60)];
    cell.headImageView.imageURL =[ImageService getImageStr:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_userDict, @"img")] Width:90];
    cell.nickLabel.text =[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_userDict, @"nickname")];
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_userDict, @"gender")] isEqualToString:@"0"]) {//男♀♂
        
        cell.genderImgView.image = KUIImage(@"gender_boy");
        cell.headImageView.placeholderImage = [UIImage imageNamed:@"people_man.png"];
    }
    else
    {
        cell.genderImgView.image = KUIImage(@"gender_girl");
        cell.headImageView.placeholderImage = [UIImage imageNamed:@"people_woman.png"];
    }
    NSString * gameImageId = [GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(m_charaDic, @"gameid")];
    cell.gameIconImgView.imageURL = [ImageService getImageUrl4:gameImageId];
    cell.value1Lb.text = [NSString stringWithFormat:@"%@-%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_charaDic, @"name")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_charaDic, @"simpleRealm")]];
    cell.value2Lb.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(m_charaDic, @"value3")];
    
    [self.view addSubview:cell];
}

-(void)buildSliderView
{
    m_zdlLb = [GameCommon buildLabelinitWithFrame:CGRectMake(135,startX+ 90, 50, 20) font:[UIFont systemFontOfSize:13] textColor:[UIColor grayColor] backgroundColor:[UIColor whiteColor] textAlignment:NSTextAlignmentCenter];
    m_zdlLb.layer.cornerRadius = 5;
    m_zdlLb.layer. borderWidth = 1;
    m_zdlLb.text = @"0";
    m_zdlLb.layer.borderColor = [[UIColor grayColor]CGColor];
    [self.view addSubview:m_zdlLb];
    
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, startX+120, 300, 10)];
    slider.minimumValue = 0;
	slider.maximumValue = 20000;
    slider.value = 50;
	[slider addTarget:self action:@selector(getZDL:) forControlEvents:UIControlEventValueChanged];
 	[self.view addSubview:slider];
}
-(void)getZDL:(UISlider *)slider
{
    int i = slider.value;
    m_zdlLb.text = [NSString stringWithFormat:@"%d",i];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.1];
//    [UIView setAnimationDelegate:self];
    
//    float r = slider.value;
//    float x = 300*(r/20000);
//    
//    m_zdlLb.center = CGPointMake(x+25, startX+100);
//    [UIView commitAnimations];

    
    
}
-(void)buildCardView
{
    tagList = [[DWTagList alloc] initWithFrame:CGRectMake(10.0f, startX+220.0f,300.0f, 300.0f)];
    tagList.tagDelegate=self;
    [self.view addSubview:tagList];

}

-(void)tagClick:(UIButton*)sender
{
    [sender setBackgroundColor:[UIColor grayColor]];
    NSLog(@"%@",[m_tagsArray objectAtIndex:sender.tag]);
    
    [seniorDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_tagsArray[sender.tag], @"constId")] forKey:@"levelId"];
}

#pragma mark --创建
-(void)createItem:(id)sender
{
    [hud show:YES];
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.mainDict, @"characterId")] forKey:@"characterId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.mainDict, @"gameid")] forKey:@"gameid"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.mainDict, @"description")] forKey:@"description"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.mainDict, @"typeId")] forKey:@"typeId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.mainDict, @"maxVol")] forKey:@"maxVol"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[GameCommon getNewStringWithId:KISDictionaryHaveKey(seniorDict, @"levelId")],@"levelId",m_zdlLb.text,@"power", nil];
    
    [paramDict setObject:dic forKey:@"options"];
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"265" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        //发送通知 刷新我的组队页面
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTeamList_wx" object:nil];
        [self showMessageWindowWithContent:@"创建成功" imageType:0];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self showErrorAlert:error];
        [hud hide:YES];
    }];
}

-(void)showErrorAlert:(id)error
{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
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
