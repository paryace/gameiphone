//
//  IntroduceViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-5.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "IntroduceViewController.h"
#import "LoginViewController.h"


@interface IntroduceViewController ()
{
    UIScrollView*   m_myScrollView;
    NSTimer*        m_timer;
    NSInteger       m_currentPage;//当前页码
    UIButton* loginButton;
    UIButton* registerButton;
    
    float           diffH;
}
@end

@implementation IntroduceViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleBlackOpaque;
}
/*
- (void)viewWillDisappear:(BOOL)animated
{
    if(m_timer != nil)
	{
		[m_timer invalidate];
		m_timer = nil;
	}

    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(m_timer != nil)
	{
		[m_timer invalidate];
		m_timer = nil;
	}
	else
	{
		m_timer = [NSTimer scheduledTimerWithTimeInterval:(3.0) target:self selector:@selector(refreshLeftTime)
												 userInfo:nil repeats:YES];
	}
}
*/
- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.hidden = YES;

   // diffH = [GameCommon diffHeight:self];

    m_myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
    m_myScrollView.backgroundColor =[UIColor greenColor];
    NSLog(@"%@", NSStringFromCGRect(m_myScrollView.frame));
    m_myScrollView.pagingEnabled = YES;
    m_myScrollView.scrollEnabled = YES;
    m_myScrollView.contentSize = CGSizeMake(320 * (kMAXPAGE+2), 0);    //5张图但是需要6ge
//    m_myScrollView.contentOffset = CGPointMake(0, 0); //从第二张开始
    m_myScrollView.showsHorizontalScrollIndicator = NO;
    m_myScrollView.showsVerticalScrollIndicator = NO;
    m_myScrollView.delegate = self;
    m_myScrollView.contentOffset = CGPointMake(320, 0);//开始展示第2页
    m_myScrollView.bounces = NO;
    [self.view addSubview:m_myScrollView];

   // m_myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
//    m_myScrollView.backgroundColor = [UIColor clearColor];
    
   
    for (int i = 0; i < kMAXPAGE+2; i++) {   //5张图循环6次
        UIImageView* bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(320 * i,0, 320, self.view.bounds.size.height)];
        NSLog(@"%@",bgImage);
        bgImage.backgroundColor =[ UIColor redColor];
        //第一张图是最后一张
        int page;
        if (i==0)
            page= kMAXPAGE; //第一页放最后一张
        else if (i>kMAXPAGE)
            page =1;    //最后一张放第一张
        else
            page = i;
        if (iPhone5) {
            NSString* imageName = [NSString stringWithFormat:@"second_%d.jpg", page];
            bgImage.image = KUIImage(imageName);
        }else{
            NSString* imageName = [NSString stringWithFormat:@"first_%d.jpg", page];

            bgImage.image = KUIImage(imageName);
        }
            [m_myScrollView addSubview:bgImage];
    }
    
//    m_currentPage = 0;
    
    loginButton = [[UIButton alloc] initWithFrame:CGRectMake(25, m_myScrollView.frame.size.height - 45 -(KISHighVersion_7?10:0), 120, 35)];
    [loginButton addTarget:self action:@selector(loginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
   
    
    registerButton = [[UIButton alloc] initWithFrame:CGRectMake(175, m_myScrollView.frame.size.height - 45-(KISHighVersion_7?10:0), 120, 35)];
    
    if (iPhone5) {
        [loginButton setBackgroundImage:KUIImage(@"second_login_normal") forState:UIControlStateNormal];
        [loginButton setBackgroundImage:KUIImage(@"second_login_normal") forState:UIControlStateHighlighted];
        [registerButton setBackgroundImage:KUIImage(@"second_regist_normal") forState:UIControlStateNormal];
        [registerButton setBackgroundImage:KUIImage(@"second_regist_normal") forState:UIControlStateHighlighted];

    }
    else{
        [loginButton setBackgroundImage:KUIImage(@"first_login_normal") forState:UIControlStateNormal];
        [loginButton setBackgroundImage:KUIImage(@"first_login_normal") forState:UIControlStateHighlighted];
        [registerButton setBackgroundImage:KUIImage(@"first_regist_normal") forState:UIControlStateNormal];
        [registerButton setBackgroundImage:KUIImage(@"first_regist_normal") forState:UIControlStateHighlighted];

    }

    [registerButton addTarget:self action:@selector(registerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:loginButton];
    [self.view addSubview:registerButton];
    loginButton.hidden = YES;
    registerButton.hidden = YES;
}

#pragma mark button click
- (void)loginButtonClick:(id)sender
{
    LoginViewController* vc = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)registerButtonClick:(id)sender
{
    RegisterViewController* vc = [[RegisterViewController alloc] init];
    vc.delegate = self.delegate;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark scrollView 手动划
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  
	CGPoint offsetofScrollView = scrollView.contentOffset;
    
    //[m_pageController setCurrentPage:offsetofScrollView.x / self.scroll.frame.size.width];
    
	NSInteger page = offsetofScrollView.x / m_myScrollView.frame.size.width;

    if(page==0||page==1||page==kMAXPAGE+1){
        loginButton.hidden = YES;
        registerButton.hidden = YES;
    }else{
        loginButton.hidden = NO;
        registerButton.hidden = NO;
    }
    if( page ==0)
    {
        m_myScrollView.contentOffset = CGPointMake(320 * kMAXPAGE,0);
    }
    else if (page==(kMAXPAGE+1))
    {
        m_myScrollView.contentOffset = CGPointMake(320,0);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
