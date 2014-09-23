//
//  EmojiView.m
//  PetGroup
//
//  Created by Tolecen on 13-11-25.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import "EmojiView.h"

@implementation EmojiView

- (id)initWithFrame:(CGRect)frame WithSendBtn:(BOOL)ifWith
{
    self = [super initWithFrame:frame];
    if (self) {
        emojis = [Emojis allEmoji];
        [self showEmojiScrollView:ifWith];
        
    }
    return self;
}
-(void)showEmojiScrollView:(BOOL)ifWith
{
    //将面板先于工具栏加入视图，避免遮挡
    UIImageView *sixGridBGV=[[UIImageView alloc]initWithFrame:CGRectMake(-320, 0, 1280, 253)];//原来是253
    [sixGridBGV setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]];
    //创建表情视图
    UIScrollView *i_emojiScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,  0, 320, 253)];//原来是227和253
    //设置表情列表scrollview属性
    i_emojiScrollView.backgroundColor=[UIColor yellowColor];
    m_EmojiScrollView = i_emojiScrollView;
    [m_EmojiScrollView addSubview:sixGridBGV];
    m_EmojiScrollView.delegate=self;
    m_EmojiScrollView.bouncesZoom = YES;
    m_EmojiScrollView.pagingEnabled = YES;
    m_EmojiScrollView.showsHorizontalScrollIndicator = NO;
    m_EmojiScrollView.showsVerticalScrollIndicator = NO;
    [m_EmojiScrollView setContentSize:CGSizeMake(640,253)];//原来是253
    m_EmojiScrollView.backgroundColor = [UIColor clearColor];
    m_EmojiScrollView.scrollEnabled = YES;
    [self addSubview:m_EmojiScrollView];
    [self emojiView];
    //启动pagecontrol
    [self loadPageControl];
    emojiBGV = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-45.5-26.5-10, 320, 45.5+26.5+10)];
    emojiBGV.backgroundColor = [UIColor clearColor];
    [self addSubview:emojiBGV];
    UIImageView * ebgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 26.5+10, 320, 45.5)];
    [ebgv setImage:[UIImage imageNamed:@"inputbg.png"]];
    [emojiBGV addSubview:ebgv];
    if(ifWith){
        UIButton * backEmojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backEmojiBtn setFrame:CGRectMake(320-12-49.5, 5, 40.5, 23)];
        [backEmojiBtn setImage:[UIImage imageNamed:@"qqqqq_03.png"] forState:UIControlStateNormal];
        [emojiBGV addSubview:backEmojiBtn];
        [backEmojiBtn addTarget:self action:@selector(backBtnDo) forControlEvents:UIControlEventTouchUpInside];
        UIButton * sendEmojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendEmojiBtn setFrame:CGRectMake(320-12-71.5, 43.5, 71.5, 32)];
        [sendEmojiBtn setImage:[UIImage imageNamed:@"btn_03.png"] forState:UIControlStateNormal];
        [emojiBGV addSubview:sendEmojiBtn];
        [sendEmojiBtn addTarget:self action:@selector(sendButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}
-(void)backBtnDo
{
    [self.delegate deleteEmojiStr];
    
}
-(void)sendButton:(UIButton *)sender
{
    [self.delegate emojiSendBtnDo];
}
-(void)loadPageControl
{
	//创建并初始化uipagecontrol
	m_Emojipc=[[UIPageControl alloc]initWithFrame:CGRectMake(20, self.frame.size.height-70, 280, 20)];
	//设置背景颜色
	m_Emojipc.backgroundColor=[UIColor clearColor];
	//设置pc页数（此时不会同步跟随显示）
	m_Emojipc.numberOfPages=2;
	//设置当前页,为第一张，索引为零
	m_Emojipc.currentPage=0;
	//添加事件处理，btn点击
	[m_Emojipc addTarget:self action:@selector(pagePressed:) forControlEvents:UIControlEventTouchUpInside];
	//将pc添加到视图上
	[self addSubview:m_Emojipc];
    NSLog(@"load page control");
}
-(void)emojiView
{
    
    for (int n = 0; n <=55; n++) {
        UIButton *btn = [[UIButton alloc]init];
        if (n<28) {
            [btn setFrame:CGRectMake(13.75*(n%7+1)+30*(n%7), (n/7+1)*12+30*(n/7), 30, 30)];
        }
        else if(n>=28&&n<56)
            [btn setFrame:CGRectMake(13.75*(n%7+1)+30*(n%7)+320, ((n-28)/7+1)*12+30*((n-28)/7), 30, 30)];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:30.0]];
        [btn setTitle: [emojis objectAtIndex:n] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(emojiButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTag:n];
        
        [m_EmojiScrollView addSubview:btn];
    }
    

}
-(void)emojiButtonPress:(id)sender
{
	//获取对应的button
	UIButton *selectedButton = (UIButton *) sender;
	int  n = selectedButton.tag;
	//根据button的tag获取对应的文字名
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"EmojiList.plist"];
    NSArray *arrayEmoji = [NSArray arrayWithContentsOfFile:finalPath];
    NSDictionary *dic = arrayEmoji[n];
    NSString *thekey = KISDictionaryHaveKey(dic, @"thekey");
    [self.delegate selectedEmoji:[NSString stringWithFormat:@"%@ ",thekey]];
    //提示文字标签隐藏
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	float a=m_EmojiScrollView.contentOffset.x;
	int page=floor((a-320/2)/320)+1;
	m_Emojipc.currentPage=page;
}

@end
