//
//  ItemBaseViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-1.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ItemBaseViewController.h"

@interface ItemBaseViewController ()
{
    UITableView *m_myTabelView;
    NSMutableArray *m_dataArray;
}
@end

@implementation ItemBaseViewController

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
    
    [self setTopViewWithTitle:@"组队" withBackButton:NO];
    
    UIButton* collectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, KISHighVersion_7 ? 20 : 0, 65, 44)];
//    [collectionBtn setBackgroundImage:KUIImage(@"btn_back") forState:UIControlStateNormal];
//    [collectionBtn setBackgroundImage:KUIImage(@"btn_back_onclick") forState:UIControlStateHighlighted];
    
    [collectionBtn setTitle:@"收藏" forState:UIControlStateNormal];
    collectionBtn.backgroundColor = [UIColor clearColor];
    [collectionBtn addTarget:self action:@selector(collectionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:collectionBtn];

    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"createGroup_normal") forState:UIControlStateNormal];
    [createBtn setBackgroundImage:KUIImage(@"createGroup_click") forState:UIControlStateHighlighted];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(didClickCreateItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];

    //初始化数据源
    m_dataArray = [NSMutableArray array];
    for (int i =0; i<10; i++) {
        [m_dataArray addObject:@(i)];
    }
    
    
    
    m_myTabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth-startX-50) style:UITableViewStylePlain];
    m_myTabelView.delegate = self;
    m_myTabelView.dataSource  = self;
    [self.view addSubview:m_myTabelView];
    
    UIButton *screenBtn = [[UIButton alloc]initWithFrame:CGRectMake(260, kScreenHeigth-50-(KISHighVersion_7?0:20), 40, 40)];
    screenBtn.backgroundColor = [UIColor clearColor];
    [screenBtn setTitle:@"筛选" forState:UIControlStateNormal];
    [screenBtn addTarget:self action:@selector(didClickScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view.window addSubview:screenBtn];
    // Do any additional setup after loading the view.
}


-(void)collectionBtn:(id)sender
{
    [self showMessageWindowWithContent:@"没有收藏" imageType:1];
}
-(void)didClickCreateItem:(id)sender
{
    [self showMessageWindowWithContent:@"创建不了" imageType:1];
}
-(void)didClickScreen:(id)sender
{
    [self showMessageWindowWithContent:@"筛选不了" imageType:1];
}

#pragma mark ----tableview delegate  datasourse

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
