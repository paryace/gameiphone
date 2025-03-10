//
//  EncoXHViewController.m
//  GameGroup 
//
//  Created by admin on 14-2-27.
//  Copyright (c) 2014年 vstar. All rights reserved.
//



#import "EncoXHViewController.h"
#import "HostInfo.h"
#import "EnteroCell.h"
#import "EGOImageView.h"
#import "UIView+i7Rotate360.h"
#import "TestViewController.h"
#import "CharacterDetailsViewController.h"
#import "CharacterEditViewController.h"
#import "AppDelegate.h"
#import "KKChatController.h"
#import "H5CharacterDetailsViewController.h"
@interface EncoXHViewController ()

@end

@implementation EncoXHViewController
{
    UIButton *sayHelloBtn;//打招呼
    UIButton *inABtn;//换一个
    EGOImageView *headImageView;//头像
    EGOImageView *clazzImageView;//职业图标
    UILabel *NickNameLabel;//昵称
    UILabel *customLabel;//年龄+性别+星座
    UITextView *promptLabel;//提示语
    NSDictionary *getDic;//获取邂逅字典
    UILabel *clazzLabel;//职业名称
    NSMutableArray *m_characterArray;//获取职业列表
    HostInfo     *m_hostInfo;//信息
    UITableView *m_tableView;//职业列表
    UITextField *tf;//请选择一个角色
    UIImageView *backgroundImageView;//背景图片
    UILabel *sexLabel;//性别
    UIAlertView *alertView;
    UIView *promptView;
    
    NSString *charaterId;
    
    NSInteger m_leftTime;
    NSTimer *m_verCodeTimer;
    BOOL     isWXCeiling;//打招呼达到上限
    BOOL     isSuccessToshuaishen;
    BOOL     isXiaoshuaishen;
    BOOL     isXuyuanchi;//刚开始的时候
    BOOL     isCardOrAttion;//点卡或者激活码
    NSInteger   heightAox;
    NSInteger   EncoCount;
    NSInteger   encoLastCount;
    NSInteger   nowCount;
    NSMutableDictionary *mainDic;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (iPhone5) {
        heightAox = 0;
    }
    else{
        heightAox = 10;
    }
    isXuyuanchi =YES;
    isXiaoshuaishen =NO;
    [self setTopViewWithTitle:@"许愿池" withBackButton:YES];
    
    backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height -startX)];
    
    backgroundImageView.image =KUIImage(@"meet_bg_img.jpg");
    backgroundImageView.userInteractionEnabled = YES;
    [self.view addSubview:backgroundImageView];
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    
    [self buildTableView];
    [self buildEncounterView];
    m_tableView.hidden = YES;
    tf.hidden = YES;
    headImageView.hidden = YES;
    clazzImageView.hidden = YES;
    clazzLabel.hidden =YES;
    NickNameLabel.hidden = YES;
    customLabel.hidden = YES;
    inABtn.hidden = YES;
    sexLabel.hidden = YES;
    sayHelloBtn.hidden =YES;
    promptLabel .hidden = YES;
    promptView.hidden =YES;

    mainDic = [NSMutableDictionary dictionary];
    

    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    [paramDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] forKey:@"userid"];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (app.reach.currentReachabilityStatus ==NotReachable) {
        [self showAlertViewWithTitle:@"提示" message:@"请求数据失败，请检查网络" buttonTitle:@"确定"];
        return;
    }
    else{

    [self getSayHelloForNetWithDictionary:paramDict method:@"202" prompt:@"获取中..." type:3];
    }
    
    
    
     getDic = [[NSDictionary alloc]init];
     m_characterArray = [[NSMutableArray alloc]init];
    

}
-(void)buildTableView
{
    tf = [[UITextField alloc]init];
    tf.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.4];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.text = @"请选择一个角色";
    tf.textAlignment =NSTextAlignmentCenter;
    tf.textColor = [UIColor whiteColor];
    [self.view addSubview:tf];
    
    m_tableView = [[UITableView alloc]initWithFrame:CGRectMake(45, 80+startX, 230, 250) style:UITableViewStylePlain];
    m_tableView.layer.masksToBounds = YES;
    m_tableView.layer.cornerRadius = 6.0;
    m_tableView.layer.borderWidth = 0;
    m_tableView.layer.borderColor = [[UIColor whiteColor] CGColor];
    m_tableView.rowHeight = 70;
    m_tableView.backgroundColor =[UIColor clearColor];
    m_tableView.delegate = self;
    m_tableView.dataSource = self;
    m_tableView.showsVerticalScrollIndicator = NO;
    m_tableView.showsHorizontalScrollIndicator = NO;
    m_tableView.hidden = YES;
    [self.view addSubview:m_tableView];
}
#pragma mark ---创建邂逅界面
-(void)buildEncounterView
{
    clazzImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(260,6, 40, 40)];
    clazzImageView.placeholderImage = KUIImage(@"clazz_icon.png");
    clazzImageView.layer.masksToBounds = YES;
    clazzImageView.layer.cornerRadius = 20;
    clazzImageView.layer.borderWidth = 2.0;
    clazzImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [backgroundImageView addSubview:clazzImageView];
    clazzImageView.userInteractionEnabled = YES;
    [clazzImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showChararcter:)]];

    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showChararcter:)];
    
    [clazzImageView addGestureRecognizer:tapG];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showGameList:)];
    longPress.minimumPressDuration =1;
    [clazzImageView addGestureRecognizer:longPress];
    
    clazzLabel = [[UILabel alloc]initWithFrame:CGRectMake(260-clazzLabel.text.length/2, 53, 50+clazzLabel.text.length *12, 20)];
    clazzLabel.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.6];
    clazzLabel.layer.masksToBounds = YES;
    clazzLabel.layer.cornerRadius = 5;
    clazzLabel.textAlignment = NSTextAlignmentCenter;
    clazzLabel.font = [UIFont systemFontOfSize:12];
    clazzLabel.textColor = [UIColor whiteColor];
    [backgroundImageView addSubview:clazzLabel];
    
    headImageView = [[EGOImageView alloc]init];
    
    headImageView.layer.masksToBounds = YES;
    headImageView.layer.cornerRadius = 165/2.0;
    headImageView.frame = CGRectMake(80, 76-40-heightAox, 165, 165);
    headImageView.userInteractionEnabled = YES;
   // headImageView.backgroundColor =[UIColor whiteColor];
    headImageView.image = KUIImage(@"许愿池头像");
    headImageView.placeholderImage = KUIImage(@"moren_people");
    headImageView.backgroundColor = [UIColor whiteColor];
    headImageView.layer.borderWidth = 2.0;
    headImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterToPernsonPage:)]];

    [backgroundImageView addSubview:headImageView];
    
    
    
    NickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,251-40-heightAox, 320, 20)];
    NickNameLabel.backgroundColor = [UIColor clearColor];
    NickNameLabel.font = [UIFont boldSystemFontOfSize:17];
    NickNameLabel.textAlignment = NSTextAlignmentCenter;
    NickNameLabel.textColor = [UIColor whiteColor];
    NickNameLabel.text  = @"许愿池";
    [backgroundImageView addSubview:NickNameLabel];
    
    

    
    customLabel = [[UILabel alloc]initWithFrame:CGRectMake(125, 276-40-heightAox, 120, 15)];
    customLabel.backgroundColor = [UIColor clearColor];
    customLabel.font = [UIFont boldSystemFontOfSize:13];
    customLabel.textColor = [UIColor whiteColor];
    customLabel.text = [NSString stringWithFormat:@" ?? |神迹"];

    [backgroundImageView addSubview:customLabel];
    
    sexLabel = [[UILabel alloc]initWithFrame:CGRectMake(customLabel.frame.origin.x-40, 276-40-heightAox, 40, 15)];
    sexLabel.font = [UIFont fontWithName:@"menlo" size:20];
    sexLabel.backgroundColor =[UIColor clearColor];
    sexLabel.textAlignment = NSTextAlignmentRight;
    [backgroundImageView addSubview:sexLabel];
    
    if (iPhone5) {
        promptView = [[UIView alloc]initWithFrame:CGRectMake(0,318-50-heightAox, 320, 50)];
    }else{
        promptView = [[UIView alloc]initWithFrame:CGRectMake(0,318-50-heightAox, 320, 60)];
    }
    promptView.backgroundColor =[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];;
    [backgroundImageView addSubview:promptView];
    
    if (iPhone5) {
        promptLabel = [[UITextView alloc]initWithFrame:CGRectMake(20,0, 280, 50)];
    }else{
        promptLabel = [[UITextView alloc]initWithFrame:CGRectMake(20,0, 280, 60)];
    }
    promptLabel.textColor = UIColorFromRGBA(0xc3c3c3, 1);
    promptLabel.textAlignment =NSTextAlignmentLeft;
    promptLabel.userInteractionEnabled = NO;
    promptLabel.font = [UIFont boldSystemFontOfSize:14];
    promptLabel.text = @"在许愿池你会遇见冥冥之中与你有缘的神奇事物或是有趣之人,点击“换一个”试试手气吧";
    promptLabel.backgroundColor = [UIColor clearColor];

    [promptView addSubview:promptLabel];
    
    
    inABtn =[[UIButton alloc]init];
    inABtn.frame = CGRectMake(20, kScreenHeigth-70, 120, 44);
    [inABtn setBackgroundImage:KUIImage(@"white") forState:UIControlStateNormal];
    [inABtn setBackgroundImage:KUIImage(@"white_onclick") forState:UIControlStateHighlighted];
    [inABtn setTitle:@"换一个" forState:UIControlStateNormal];
    [inABtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [inABtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [inABtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [inABtn addTarget:self action:@selector(changeOtherOne) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inABtn];
    
    
    sayHelloBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    sayHelloBtn.frame = CGRectMake(180, kScreenHeigth-70, 120, 44);
    [sayHelloBtn setBackgroundImage:KUIImage(@"green") forState:UIControlStateNormal];
    [sayHelloBtn setBackgroundImage:KUIImage(@"green_onclick") forState:UIControlStateHighlighted];
    [sayHelloBtn addTarget:self action:@selector(sayHiToYou:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sayHelloBtn];

    
}
//换一个的说
- (void)changeOtherOne
{
    inABtn.selected = YES;
    inABtn.enabled = NO;
    sayHelloBtn.enabled = NO;
    headImageView.userInteractionEnabled = NO;
    clazzImageView.userInteractionEnabled = NO;
    [sayHelloBtn setBackgroundImage:KUIImage(@"green") forState:UIControlStateNormal];

    NSMutableDictionary *paramDict =[[NSMutableDictionary alloc]init];

    [paramDict setObject:KISDictionaryHaveKey(mainDic, @"gameid") forKey:@"gameid"];
    [paramDict setObject:self.characterId forKey:@"characterid"];
 //   [paramDict setObject:@"6" forKey:@"testIndex"];
    [self getSayHelloForNetWithDictionary:paramDict method:@"164" prompt:nil type:1];

    promptLabel.text =@"你将一枚金币抛入了许愿池中，然后耐心的等待池水平静下来…";
   int i= promptLabel.text.length/20;
    promptView.frame = CGRectMake(0, 318-50-heightAox, 320, 35+15*i);
    promptLabel.frame = CGRectMake(20, 0, 280, 30+15*i);

}


-(void)sayHiToYou:(UIButton *)sender
{
    
    if (isXuyuanchi ==YES) {
        promptLabel.text  =@"你和许愿池打了个招呼, 但是许愿池完全没有鸟你， 点击”换一个”来遇到有缘人吧。" ;
        [sender setBackgroundImage:KUIImage(@"gray") forState:UIControlStateNormal];
        return;
    }
    
    if (isCardOrAttion) {
        return;
    }
    
    if (isSuccessToshuaishen) {
       promptLabel.text  =@"很遗憾，无法和小衰神打招呼，点击“换一个”远离小衰神" ;
        sayHelloBtn.enabled = NO;
    }else{
        NSMutableDictionary *paramDict =[[NSMutableDictionary alloc]init];
        [paramDict setObject:KISDictionaryHaveKey(mainDic, @"gameid") forKey:@"gameid"];
        [paramDict setObject:self.characterId forKey:@"characterid"];
        [paramDict setObject:KISDictionaryHaveKey(getDic, @"userid") forKey:@"touserid"];
        [paramDict setObject:KISDictionaryHaveKey(getDic,@"sayHelloType") forKey:@"sayHelloType"];
        [paramDict setObject:KISDictionaryHaveKey(getDic, @"index") forKey:@"index"];
        [self getSayHelloForNetWithDictionary:paramDict method:@"165" prompt:@"打招呼ING" type:2];
        
//        KKChatController * kkchat = [[KKChatController alloc] init];
//        kkchat.chatWithUser =KISDictionaryHaveKey(getDic, @"userid");
//        kkchat.type = @"normal";
//        [self.navigationController pushViewController:kkchat animated:YES];

        
        
    }
}
#pragma mark ---网络请求
- (void)getSayHelloForNetWithDictionary:(NSDictionary *)dic method:(NSString *)method prompt:(NSString *)prompt type:(NSInteger)COME_TYPE
{

    hud.labelText = prompt;
   // [hud show:YES];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    
    [postDict setObject:dic forKey:@"params"];
    [postDict setObject:method forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];
    
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseObject%@",responseObject);
        inABtn.enabled = YES;

        [hud hide:YES];

        if (COME_TYPE ==1) {
            isXuyuanchi=NO;
            isSuccessToshuaishen =NO;
            sayHelloBtn.enabled = YES;
            inABtn.enabled = YES;
            sayHelloBtn.enabled = YES;
            headImageView.userInteractionEnabled = YES;
            clazzImageView.userInteractionEnabled = YES;
            
            
            isWXCeiling =YES;
            getDic = nil;
            getDic = [NSDictionary dictionaryWithDictionary:responseObject];
            NSLog(@"getDic%@",getDic);
            
            
            //打招呼次数
            EncoCount = [KISDictionaryHaveKey(getDic, @"playedTime")intValue];
            encoLastCount = [KISDictionaryHaveKey(getDic, @"restrictionTime")intValue];
            nowCount =encoLastCount-EncoCount;
            if (encoLastCount==-1) {
                
            }else{
                [inABtn setTitle:[NSString stringWithFormat:@"换一个(%d)",encoLastCount-EncoCount] forState:UIControlStateNormal];
            }
            inABtn.titleLabel.textColor = [UIColor blackColor];
            
            
            
            
            if ([KISDictionaryHaveKey(getDic, @"encounterType")intValue] ==0) {
                isCardOrAttion =NO;
                //男♀♂
                if ([KISDictionaryHaveKey(getDic, @"gender")isEqualToString:@"1"]) {
                    sexLabel.text = @"♀";
                    sexLabel.textColor = kColorWithRGB(238, 100, 196, 1.0);
                }else{
                    sexLabel.text = @"♂";
                    sexLabel.textColor = kColorWithRGB(33, 193, 250, 1.0);
                    
                }
                NickNameLabel.text = KISDictionaryHaveKey(getDic, @"nickname");
                customLabel.text = [NSString stringWithFormat:@" %@ |%@",KISDictionaryHaveKey(getDic, @"age"),KISDictionaryHaveKey(getDic, @"constellation")];
                
                
                promptLabel.text =KISDictionaryHaveKey(getDic, @"prompt");
                NSInteger i;
                
                
                NSLog(@"%@",headImageView.image);
                NSString *imageStr =nil;
                UIImage *  image;
                if ([KISDictionaryHaveKey(getDic, @"img")isEqualToString:@""]||[KISDictionaryHaveKey(getDic, @"ing")isEqualToString:@" "]) {
                    headImageView.imageURL = nil;
                }else{
                    
                    if([KISDictionaryHaveKey(getDic, @"img") rangeOfString:@","].location !=NSNotFound) {
                        NSString * fruits = KISDictionaryHaveKey(getDic, @"img");
                        NSArray  * array= [fruits componentsSeparatedByString:@","];
                        
                        imageStr =[array objectAtIndex:0];
                    }else{
                        imageStr =KISDictionaryHaveKey(getDic, @"img");
                    }
                    NSLog(@"imageUrl--->%@",headImageView.imageURL);
                    NSLog(@"imageUrl---->%@",headImageView.image);
                    
                    NSURL * imageUrl = [ImageService getImageUrl3:imageStr Width:330];
                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
                    
//                    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[BaseImageUrl stringByAppendingString:[NSString stringWithFormat:@"%@/330",imageStr]]]]];
                }
                [headImageView rotate360WithDuration:1.0 repeatCount:1 timingMode:i7Rotate360TimingModeEaseInEaseOut];
                headImageView.animationDuration = 2.0;
                headImageView.animationImages = [NSArray arrayWithObjects:image,nil];
                headImageView.animationRepeatCount = 1;
                [headImageView startAnimating];
                
                if ([KISDictionaryHaveKey(getDic, @"img")isEqualToString:@""]||[KISDictionaryHaveKey(getDic, @"ing")isEqualToString:@" "]) {
                    headImageView.imageURL = nil;
                }else{
//                    headImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[NSString stringWithFormat:@"%@/330",imageStr]]];
                    
                    headImageView.imageURL = [ImageService getImageUrl3:imageStr Width:330];
                    
                    headImageView.animationImages=nil;
                }
                i= promptLabel.text.length/20;
                promptView.frame = CGRectMake(0, 318-50-heightAox, 320, 35+15*i);
                promptLabel.frame = CGRectMake(20, 0, 280, 30+15*i);
            }
            else if ([KISDictionaryHaveKey(getDic, @"encounterType") intValue] ==1)
            {
                isCardOrAttion =YES;
                sexLabel.text = @"♀";
                sexLabel.textColor = kColorWithRGB(238, 100, 196, 1.0);
                NickNameLabel.text = @"陌游激活码";
                customLabel.text = [NSString stringWithFormat:@"    0 | 陌游"];
                
                promptLabel.text =[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(getDic, @"prompt")];
                promptLabel.textAlignment = NSTextAlignmentCenter;
                NSInteger i;
                
                headImageView.imageURL = Nil;
                headImageView.image =KUIImage(@"Activation");
                
                [headImageView rotate360WithDuration:1.0 repeatCount:1 timingMode:i7Rotate360TimingModeEaseInEaseOut];
                headImageView.animationDuration = 2.0;
                headImageView.animationImages =
                [NSArray arrayWithObjects:
                 headImageView.image,
                 nil];
                headImageView.animationRepeatCount = 1;
                [headImageView startAnimating];
                
                i= promptLabel.text.length/20;
                promptView.frame = CGRectMake(0, 318-50-heightAox, 320, 35+15*i);
                promptLabel.frame = CGRectMake(20, 0, 280, 30+15*i);
            }
            else{
                isCardOrAttion =YES;
                
                sexLabel.text = @"♀";
                sexLabel.textColor = kColorWithRGB(238, 100, 196, 1.0);
                NickNameLabel.text = @"魔兽世界点卡";
                customLabel.text = [NSString stringWithFormat:@"    0 | 魔兽"];
                
                promptLabel.text =[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(getDic, @"prompt")];
                
                promptLabel.textAlignment = NSTextAlignmentCenter;
                NSInteger i;
                
                headImageView.imageURL = Nil;
                headImageView.image =KUIImage(@"card");
                
                [headImageView rotate360WithDuration:1.0 repeatCount:1 timingMode:i7Rotate360TimingModeEaseInEaseOut];
                headImageView.animationDuration = 2.0;
                headImageView.animationImages =
                [NSArray arrayWithObjects:
                 headImageView.image,
                 nil];
                headImageView.animationRepeatCount = 1;
                [headImageView startAnimating];
                
                i= promptLabel.text.length/20;
                promptView.frame = CGRectMake(0, 318-50-heightAox, 320, 35+15*i);
                promptLabel.frame = CGRectMake(20, 0, 280, 30+15*i);
            }
        }
        
        else if (COME_TYPE ==2)
        {
            NSLog(@"打招呼");
            [self showMessageWindowWithContent:@"打招呼成功" imageType:0];
            sayHelloBtn.enabled = NO;
        }
        
       else if (COME_TYPE ==3) {
           NSArray *array = responseObject;
            if ([array isKindOfClass:[NSArray class]]&&array.count>0) {
                for (NSDictionary *dic  in array) {
                    NSString *gameidStr = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"gameid")];
                    if ([gameidStr intValue] ==[self.gameId intValue]) {
                        [m_characterArray addObject:dic];
                    }
                    NSLog(@"-------->%@---->%@",gameidStr,self.gameId);
                }
                
                if (m_characterArray.count ==1) {
                    m_tableView.hidden = YES;
                    tf.hidden = YES;
                    headImageView.hidden = NO;
                    clazzImageView.hidden = NO;
                    clazzLabel.hidden =NO;
                    NickNameLabel.hidden = NO;
                    customLabel.hidden = NO;
                    inABtn.hidden = NO;
                    sexLabel.hidden = NO;
                    sayHelloBtn.hidden =NO;
                    promptLabel .hidden = NO;
                    promptView.hidden =NO;
                    
                    charaterId =KISDictionaryHaveKey([m_characterArray objectAtIndex:0], @"id");
                    [self getEncoXhinfoWithNet:[m_characterArray objectAtIndex:0]];
                }
                else if (m_characterArray.count==0)
                {
                    alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定角色" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去绑定", nil];
                    alertView.tag = 10001;
                    [alertView show];

                }
                else
                {
                    tf.hidden = NO;
                    m_tableView.hidden =NO;
                    if (m_characterArray.count>1&&m_characterArray.count<4) {
                        m_tableView.frame = CGRectMake(45, 80+startX, 230, m_characterArray.count*70-3);
                    }else{
                        m_tableView.frame = CGRectMake(45, 80+startX, 230, 250);
                    }
                    [m_tableView reloadData];
                    tf.frame =CGRectMake(0, startX+40, 200, 30);
                    tf.center  = CGPointMake(160, startX+50);
                    
                }

        

        }
            else{
                alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定角色" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去绑定", nil];
                alertView.tag = 10001;
                [alertView show];

            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        
        inABtn.enabled = YES;
        sayHelloBtn.enabled = YES;
        [hud hide:YES];
        inABtn.titleLabel.textColor = [UIColor blackColor];
        if ([error isKindOfClass:[NSDictionary class]]) {
            
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                
                if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100041"]) {
                    isWXCeiling =NO;
                    sayHelloBtn.enabled = NO;
                }
                
                
                if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100042"]) {
 
                    int i = --nowCount;
                    if (nowCount >0) {
                        [inABtn setTitle:[NSString stringWithFormat:@"换一个(%d)",i] forState:UIControlStateNormal];

                    }


                isSuccessToshuaishen =YES;
                isWXCeiling =YES;
                inABtn.enabled = YES;
                sayHelloBtn.enabled = YES;
                    headImageView.userInteractionEnabled = YES;
                    clazzImageView.userInteractionEnabled = YES;
                //男♀♂
                    sexLabel.text = @"♂";
                    sexLabel.textColor = kColorWithRGB(33, 193, 250, 1.0);
               // promptLabel.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];
                
                NickNameLabel.text =@"小衰神";
                customLabel.text = @" ？？|神 明";
                
                promptLabel.text =@"小衰神附体,你ROLL出了1点,什么也没遇到...";
                headImageView.image = KUIImage(@"roll_0");

                UIImage *image = headImageView.image;
                    
                [headImageView rotate360WithDuration:1.0 repeatCount:1 timingMode:i7Rotate360TimingModeLinear];
                headImageView.animationDuration = 2.0;
                headImageView.animationImages =
                [NSArray arrayWithObjects:
                 headImageView.image,
                 headImageView.image,
                 headImageView.image,
                 image,
                 nil];
                headImageView.animationRepeatCount = 1;
                [headImageView startAnimating];
                    return ;
                }
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];

            }
        }

    }];
}

#pragma mark --tableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_characterArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCharacter";
    EnteroCell *cell = (EnteroCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[EnteroCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.4];
    
    NSDictionary* tempDic = [m_characterArray objectAtIndex:indexPath.row];
    
    NSString * imageId=KISDictionaryHaveKey(tempDic, @"img");
    NSString * fialMsg=KISDictionaryHaveKey(tempDic, @"failedmsg");
    NSString* realm = KISDictionaryHaveKey(tempDic, @"value1");
     NSString * gameid=KISDictionaryHaveKey(tempDic, @"gameid");
    cell.headerImageView.placeholderImage = [UIImage imageNamed:[NSString stringWithFormat:@"clazz_icon.png"]];
    if ([fialMsg isEqualToString:@"404"])//角色不存在
    {
        cell.headerImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"clazz_icon.png"]];
        cell.serverLabel.text=@"角色不存在";
    }else{
        if ([GameCommon isEmtity:imageId]) {
            cell.headerImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"clazz_icon.png"]];
        }else{
            cell.headerImageView.imageURL = [ImageService getImageUrl4:imageId];
        }
        cell.serverLabel.text = [NSString stringWithFormat:@"%@ %@",KISDictionaryHaveKey(tempDic, @"simpleRealm"),realm];//realm
    }
    cell.titleLabel.text = KISDictionaryHaveKey(tempDic, @"name");
    NSString * gameImageId =[GameCommon putoutgameIconWithGameId:[GameCommon getNewStringWithId:gameid]];
   cell.gameTitleImage.imageURL = [ImageService getImageUrl4:gameImageId];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tempDic =[m_characterArray objectAtIndex:indexPath.row];
    
//    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"failedmsg")] isEqualToString:@"404"]
//        ||[[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"failedmsg")] isEqualToString:@"notSupport"]) {
//        [self showMessageWithContent:@"无法获取角色详情数据,由于角色不存在或暂不支持" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
//        return;
//    }
    tableView.hidden = YES;
    tf.hidden = YES;
    headImageView.hidden = NO;
    clazzImageView.hidden = NO;
    clazzLabel.hidden =NO;
    NickNameLabel.hidden = NO;
    customLabel.hidden = NO;
    inABtn.hidden = NO;
    sexLabel.hidden = NO;
    sayHelloBtn.hidden =NO;
    promptLabel .hidden = NO;
    promptView.hidden =NO;
    charaterId = KISDictionaryHaveKey(tempDic, @"id");
    [self getEncoXhinfoWithNet:[m_characterArray objectAtIndex:indexPath.row]];
}
-(void)getEncoXhinfoWithNet:(NSDictionary *)dic
{
    [mainDic removeAllObjects];
    [mainDic setValuesForKeysWithDictionary:dic];
    NSMutableDictionary *paramDict =[[NSMutableDictionary alloc]init];
    self.characterId =KISDictionaryHaveKey(dic, @"id");
    [paramDict setObject:KISDictionaryHaveKey(dic, @"gameid") forKey:@"gameid"];
    NSString * imageId=KISDictionaryHaveKey(dic, @"img");
    clazzImageView.imageURL = [ImageService getImageUrl4:imageId];
    NSString * charaName = KISDictionaryHaveKey(dic, @"name");
    if (charaName.length>5) {
        charaName = [NSString stringWithFormat:@"%@...",[charaName substringToIndex:5]];
    }
    clazzLabel.text =charaName;
//    NSInteger i = [[GameCommon shareGameCommon] unicodeLengthOfString:clazzLabel.text];
//    if (i>10) {
//        clazzLabel.text = [NSString stringWithFormat:@"%@...",[clazzLabel.text substringWithRange:NSMakeRange(0,8)]];
//    }
    clazzLabel.frame = CGRectMake(260-clazzLabel.text.length*3, 53, 10+clazzLabel.text.length *12, 20);
    clazzLabel.center = CGPointMake(280, 63);
}

#pragma mark ---查看角色详情
-(void)enterToPernsonPage:(UIGestureRecognizer *)sender
{
    if (isXuyuanchi ==YES) {
        promptLabel.text = @"不要触碰神迹! 这有可能会影响你接下来的运气…";
        return;
    }
    
    if (isCardOrAttion) {
        return;
    }
     if (isSuccessToshuaishen ==NO) {
        TestViewController *pv = [[TestViewController alloc]init];
        pv.userId =KISDictionaryHaveKey(getDic, @"userid");
        pv.nickName = KISDictionaryHaveKey(getDic, @"nickname");
        [self.navigationController pushViewController:pv animated:YES];
    }
    else{
        promptLabel.text = @"发现了一只神明，但神明的世界是你无法窥伺的";
           }
}
#pragma mark--- 查看角色列表

-(void)showChararcter:(UIGestureRecognizer *)sender
{
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(mainDic, @"failedmsg")] isEqualToString:@"404"]
        ||[[GameCommon getNewStringWithId:KISDictionaryHaveKey(mainDic, @"failedmsg")] isEqualToString:@"notSupport"]) {
        [self showMessageWithContent:@"无法获取角色详情数据,由于角色不存在或暂不支持" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
        return;
    }
    H5CharacterDetailsViewController* VC = [[H5CharacterDetailsViewController alloc] init];
    VC.characterId = charaterId;
    VC.myViewType = CHARA_INFO_MYSELF;
    VC.gameId = KISDictionaryHaveKey(mainDic, @"gameid");
    VC.characterName = KISDictionaryHaveKey(mainDic, @"name");
    [self.navigationController pushViewController:VC animated:YES];
}


-(void)showGameList:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        return;
        
    } else if (sender.state == UIGestureRecognizerStateBegan) {
        
        if (m_characterArray.count >1) {
            m_tableView.hidden = NO;
            tf.hidden = NO;
            headImageView.hidden = YES;
            clazzImageView.hidden = YES;
            clazzLabel.hidden =YES;
            NickNameLabel.hidden = YES;
            customLabel.hidden = YES;
            inABtn.hidden = YES;
            sexLabel.hidden = YES;
            sayHelloBtn.hidden =YES;
            promptLabel .hidden = YES;
            promptView.hidden = YES;
        }
        else{
            [self showAlertViewWithTitle:@"提示" message:@"你只有一个角色" buttonTitle:@"确定"];
        }

    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        if (buttonIndex ==1) {
            CharacterEditViewController *CVC = [[CharacterEditViewController alloc]init];
            CVC.isFromMeet = YES;
            [self.navigationController pushViewController:CVC animated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
}
-(void)dealloc
{
    alertView.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
