//
//  CharacterDetailsView.m
//  GameGroup
//
//  Created by admin on 14-2-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CharacterDetailsView.h"
#import "EGOImageView.h"
@implementation CharacterDetailsView
{
    NSInteger m_pageNum;
    NSInteger m_typeNum;


}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
        self.topImageView.backgroundColor  = [UIColor whiteColor];
       [self addSubview:self.topImageView];
        self.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    
        [self buildRoleView];

        self.listScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 236, 320, 300)];
        self.listScrollView.pagingEnabled = YES;
        self.listScrollView.contentOffset = CGPointMake(m_pageNum*self.listScrollView.bounds.size.width, 0);
        self.listScrollView.delegate = self;
        self.listScrollView.backgroundColor = [UIColor whiteColor];
        self.listScrollView.showsHorizontalScrollIndicator =NO;

        [self addSubview:self.listScrollView];

        self.unlessLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 306, 320, 55)];
        self.unlessLabel.text = @"正在向英雄榜获取数据中...";
        self.unlessLabel.textAlignment = NSTextAlignmentCenter;
        self.unlessLabel.backgroundColor = [UIColor whiteColor];
        self.unlessLabel.hidden =NO;
        [self addSubview:self.unlessLabel];

        self.helpLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 536, 320, 45)];
        self.helpLabel.text = @"如何获得PVP/PVE战斗力";
        self.helpLabel.backgroundColor = [UIColor whiteColor];
        self.helpLabel.userInteractionEnabled = YES;
        self.helpLabel.font = [UIFont systemFontOfSize:12];
        self.helpLabel.textColor = kColorWithRGB(41, 164, 246, 1.0);
        self.helpLabel.textAlignment=  NSTextAlignmentCenter;
        [self addSubview:self.helpLabel];
        
        
        self.reloadingBtn = [[UIButton alloc]init];
        self.reloadingBtn.frame = CGRectMake(0, self.helpLabel.frame.origin.y+self.helpLabel.frame.size.height, 320, 50);
        self.reloadingBtn.backgroundColor = [UIColor whiteColor];
        [self.reloadingBtn setBackgroundImage:KUIImage(@"btn_updata_normol") forState:UIControlStateNormal];
        [self.reloadingBtn setBackgroundImage:KUIImage(@"btn_updata_click") forState:UIControlStateSelected];
        
        NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:@"WX_reloadBtnTitle_wx"];
        if (str ==nil) {
            [self.reloadingBtn setTitle:@"刷新排行榜数据" forState:UIControlStateNormal];
        }
        else{
            [self.reloadingBtn setTitle:[NSString stringWithFormat:@"上次更新时间:%@",[self getTimeWithMessageTime:[GameCommon getNewStringWithId:str]]]forState:UIControlStateNormal];
        }
        
        [self.reloadingBtn setTitleColor:UIColorFromRGBA(0xffffff, 1) forState:UIControlStateNormal];
        self.reloadingBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [self.reloadingBtn addTarget:self action:@selector(reLoadingCont:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.reloadingBtn];
    }
    return self;
}
//右上view “石爪峰 部落  战士”

-(void)buildRoleView//职业资料条
{
    self.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 142, 320, 58)];
    self.titleView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.6];
    [self addSubview:self.titleView];
    //头像
    self.headerImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(12, 7, 44, 44)];
    self.headerImageView.placeholderImage = [UIImage imageNamed:@"moren_people.png"];

    self.headerImageView.layer.masksToBounds = YES;
    self.headerImageView.layer.cornerRadius = 6.0;
    self.headerImageView.layer.borderWidth = 0.1;
    self.headerImageView.layer.borderColor = [[UIColor whiteColor] CGColor];

    [self.titleView addSubview:self.headerImageView];
    
    
  //认证图片
    self. certificationImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 43, 28, 12)];
    self.backgroundColor = UIColorFromRGBA(0x262930, 1);
    [self.titleView addSubview:self.certificationImage];

    
    //角色名
    self.NickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 35)];
    self.NickNameLabel.backgroundColor = [UIColor clearColor];
    self.NickNameLabel.textColor = [UIColor whiteColor];
    self.NickNameLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.titleView addSubview:self.NickNameLabel];
    
    //公会
    self.guildLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 30, 160, 25)];
    self.guildLabel.backgroundColor = [UIColor clearColor];
    self.guildLabel.textColor = UIColorFromRGBA(0xe3e3e3, 1);
    self.guildLabel.font = [UIFont boldSystemFontOfSize:13];
    [self.titleView addSubview:self.guildLabel];
    

    
    //等级
    self.levelLabel = [[UILabel alloc]initWithFrame:CGRectMake(235, 8, 73, 25)];
    self.levelLabel.backgroundColor = [UIColor clearColor];
    self.levelLabel.textColor = UIColorFromRGBA(0xe3e3e3, 1);
    self.levelLabel.textAlignment = NSTextAlignmentRight;

    self.levelLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.titleView addSubview:self.levelLabel];

    self.gameIdView = [[EGOImageView alloc]initWithFrame:CGRectMake(230, 32, 12, 12)];
    [self.titleView addSubview:self.gameIdView];
    
    self.realmView = [[UILabel alloc]initWithFrame:CGRectMake(250, 26, 85, 20)];
    self.realmView.backgroundColor =[UIColor clearColor];
    self.realmView.textAlignment = NSTextAlignmentRight;
    self.realmView.textColor = UIColorFromRGBA(0xe3e3e3, 1);
    self.realmView.font = [UIFont boldSystemFontOfSize:13];
    [self.titleView addSubview:self.realmView];
}

-(void)comeFromMy
{
    self.listScrollView.contentSize = CGSizeMake(320*3, 244);
    self.myFriendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.myFriendBtn.frame = CGRectMake(0, 200, 106.6,36);

    [self.myFriendBtn setBackgroundImage:KUIImage(@"tab_bg") forState:UIControlStateNormal];
//    [self.myFriendBtn setTitle:@"好友" forState:UIControlStateNormal];
    [self.myFriendBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.myFriendBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self addSubview:self.myFriendBtn];
    
    self.countryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.countryBtn.frame = CGRectMake(213.4, 200,106.6,36);

    [self.countryBtn setBackgroundImage:KUIImage(@"tab_bg") forState:UIControlStateNormal];
//    [self.countryBtn setTitle:@"全国" forState:UIControlStateNormal];
    [self.countryBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.countryBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self addSubview:self.countryBtn];
    
    
    self.realmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.realmBtn.frame = CGRectMake(106.6, 200, 106.8, 36);

    [ self.realmBtn setBackgroundImage:KUIImage(@"tab_bg") forState:UIControlStateNormal];
//    [ self.realmBtn setTitle:@"服务器" forState:UIControlStateNormal];
    [ self.realmBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [ self.realmBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self addSubview: self.realmBtn];

    
    //全国
    [self.countryBtn addTarget:self action:@selector(changePageNational:) forControlEvents:UIControlEventTouchUpInside];
    //好友
    [self.myFriendBtn addTarget:self action:@selector(changePageWithFriend:) forControlEvents:UIControlEventTouchUpInside];
    //全服务器
    [self.realmBtn addTarget:self action:@selector(changePageRealm:) forControlEvents:UIControlEventTouchUpInside];
    self.underListImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 234,106,4)];
    self.underListImageView.image =KUIImage(@"tab_line");
    [self addSubview:self.underListImageView];

    self.realmBtn.selected = YES;
    self.countryBtn.selected = YES;

}

-(void)comeFromPerson
{
    self.listScrollView.contentSize = CGSizeMake(320*2, 244);
    self.countryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.countryBtn.frame = CGRectMake(160, 200,160,36);

    [self.countryBtn setBackgroundImage:KUIImage(@"tab_bg") forState:UIControlStateNormal];
//    [self.countryBtn setTitle:@"全国" forState:UIControlStateNormal];
    [self.countryBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.countryBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self addSubview:self.countryBtn];
    
    self.realmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.realmBtn.frame = CGRectMake(0, 200, 160, 36);;

    [ self.realmBtn setBackgroundImage:KUIImage(@"tab_bg") forState:UIControlStateNormal];
//    [ self.realmBtn setTitle:@"服务器" forState:UIControlStateNormal];
    [ self.realmBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [ self.realmBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self addSubview: self.realmBtn];
    self.countryBtn.selected = YES;
   // self.myFriendBtn.frame = CGRectMake(106, 200, 0,44);
    //全国
    [self.countryBtn addTarget:self action:@selector(TypeTwoOfCountry:) forControlEvents:UIControlEventTouchUpInside];
    //全服务器
    [self.realmBtn addTarget:self action:@selector(TypeTwoOfSeaml:) forControlEvents:UIControlEventTouchUpInside];
    self.underListImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 234,160,4)];
    self.underListImageView.image =KUIImage(@"tab_line");
    [self addSubview:self.underListImageView];
    
}

-(void)changePageWithFriend:(id)sender
{
    
    self.myFriendBtn.selected = NO;
    self.countryBtn.selected = YES;
    self.realmBtn.selected = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    m_pageNum =0;
    self.listScrollView.contentOffset = CGPointMake(m_pageNum*self.listScrollView.bounds.size.width, 0);
    
    self.underListImageView.frame =CGRectMake(self.myFriendBtn.frame.origin.x, 234, self.myFriendBtn.frame.size.width, 4);;
    [UIView commitAnimations];
    
    m_pageNum =0;
    //self.TopScrollView.contentOffset = CGPointMake(m_pageNum*self.TopScrollView.bounds.size.width, 0);
    


}
-(void)changePageNational:(id)sender
{
    self.myFriendBtn.selected = YES;
    self.countryBtn.selected = NO;
    self.realmBtn.selected = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    m_pageNum =2;
    
    self.listScrollView.contentOffset = CGPointMake(m_pageNum*self.listScrollView.bounds.size.width, 0);
    
    self.underListImageView.frame = CGRectMake(self.countryBtn.frame.origin.x, 234, self.countryBtn.frame.size.width, 4);
    [UIView commitAnimations];
    
   // self.TopScrollView.contentOffset = CGPointMake(m_pageNum*self.TopScrollView.bounds.size.width, 0);
    
}
-(void)changePageRealm:(id)sender
{
    self.myFriendBtn.selected = YES;
    self.countryBtn.selected = YES;
    self.realmBtn.selected = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    m_pageNum =1;
    
    
    self.listScrollView.contentOffset = CGPointMake(m_pageNum*self.listScrollView.bounds.size.width, 0);

    
    self.underListImageView.frame = CGRectMake(self.realmBtn.frame.origin.x, 234, self.realmBtn.frame.size.width, 4);;
    [UIView commitAnimations];
    

}
//接受通知 是谁推过来的  是自己 还是朋友


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //判断滚动视图的对象是否是newsTableScroll,如果是newsTableScroll则做请求
    if (scrollView !=self.listScrollView) {
        return;
    }
        m_pageNum = (NSInteger)self.listScrollView.contentOffset.x/self.listScrollView.bounds.size.width;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    NSLog(@"m_pageNum%d",m_pageNum);
    
    self.underListImageView.frame = CGRectMake(m_pageNum *self.underListImageView.bounds.size.width, 234, self.underListImageView.bounds.size.width, 4);


    [UIView commitAnimations];

    if (_isComeTo ==YES) {
        
   
        if (m_pageNum ==0) {
            self.myFriendBtn.selected = NO;
            self.countryBtn.selected = YES;
            self.realmBtn.selected = YES;
    }
         if (m_pageNum ==2) {
            self.myFriendBtn.selected = YES;
            self.countryBtn.selected = NO;
            self.realmBtn.selected = YES;
         }
         if (m_pageNum ==1) {
            self.myFriendBtn.selected = YES;
            self.countryBtn.selected = YES;
            self.realmBtn.selected = NO;
    }
         }
    else{
        if (m_pageNum ==0) {
        self.countryBtn.selected = YES;
        self.realmBtn.selected = NO;
    }
        if (m_pageNum ==1) {
            self.countryBtn.selected = NO;
            self.realmBtn.selected = YES;
        }

        
    }
    }

#pragma MARK --
-(void)TypeTwoOfCountry:(UIButton *)sender
{

    self.countryBtn.selected = NO;
    self.realmBtn.selected = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    m_pageNum =1;
    
    self.listScrollView.contentOffset = CGPointMake(m_pageNum*self.listScrollView.bounds.size.width, 0);
    
    self.underListImageView.frame = CGRectMake(160, 234, 160, 4);
    [UIView commitAnimations];
    

    
}
-(void)TypeTwoOfSeaml:(UIButton *)sender
{
    self.countryBtn.selected = YES;
    self.realmBtn.selected = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    m_pageNum =0;
    
    self.listScrollView.contentOffset = CGPointMake(m_pageNum*self.listScrollView.bounds.size.width, 0);
    
    self.underListImageView.frame = CGRectMake(0, 234, 160, 4);
    [UIView commitAnimations];
    

}

-(void)reLoadingCont:(id)sender
{
    if (self.myCharaterDelegate && [self.myCharaterDelegate respondsToSelector:@selector(reLoadingList:)] ) {
        [self.myCharaterDelegate reLoadingList:self];
    }

}
- (NSString*)getTimeWithMessageTime:(NSString*)messageTime
{
    NSString* currentString = [GameCommon getCurrentTime];
    if (messageTime.length < 10 || currentString.length < 10) {
        return @"未知";
    }
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



@end
