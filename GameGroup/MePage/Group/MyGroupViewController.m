//
//  MyGroupViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MyGroupViewController.h"
#import "JoinInGroupViewController.h"
#import "GroupOfMineCell.h"
#import "GroupInformationViewController.h"
@interface MyGroupViewController ()
{
    UICollectionViewFlowLayout *m_layout;
    UICollectionView *groupCollectionView;
    NSMutableArray *myGroupArray;
}
@end

@implementation MyGroupViewController

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
    
    [self setTopViewWithTitle:@"我的群组" withBackButton:YES];
    
    myGroupArray = [NSMutableArray array];
    
//    UIButton*button  = [UIButton buttonWithType: UIButtonTypeCustom];
//    button.frame = CGRectMake(20, startX+20, 60, 60);
//    [button setImage:KUIImage(@"addphoto") forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(enterSearchGroupPage:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
    
    m_layout = [[UICollectionViewFlowLayout alloc]init];
    m_layout.minimumInteritemSpacing = 1;
    m_layout.minimumLineSpacing =5;
    m_layout.itemSize = CGSizeMake(60, 60);
    
    groupCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, startX+60, 300, 70) collectionViewLayout:m_layout];
    groupCollectionView.backgroundColor = UIColorFromRGBA(0xf8f8f8, 1);
    groupCollectionView.scrollEnabled = NO;
    groupCollectionView.delegate = self;
    groupCollectionView.dataSource = self;
    [groupCollectionView registerClass:[GroupOfMineCell class] forCellWithReuseIdentifier:@"titleCell"];
    groupCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:groupCollectionView];

    [self getGroupListFromNet];
    // Do any additional setup after loading the view.
}

-(void)getGroupListFromNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"230" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSMutableArray class]]) {
            [myGroupArray removeAllObjects];
            [myGroupArray addObjectsFromArray:responseObject];
            [groupCollectionView reloadData];
            
            for (NSMutableDictionary * groupInfo in responseObject) {
                [DataStoreManager saveDSGroupList:groupInfo];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return myGroupArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GroupOfMineCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"titleCell" forIndexPath:indexPath];
    NSMutableDictionary * cellDic = [myGroupArray objectAtIndex:indexPath.row];
    cell.headImgView.placeholderImage = KUIImage(@"people_man.png");
    cell.headImgView.imageURL = [ImageService getImageUrl4:KISDictionaryHaveKey(cellDic, @"backgroundImg")];

    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [myGroupArray objectAtIndex:indexPath.row];
    GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
    gr.groupId =KISDictionaryHaveKey(dic, @"groupId");
    [self.navigationController pushViewController:gr animated:YES];
}


-(void)enterSearchGroupPage:(id)sender
{
    JoinInGroupViewController *joinIn = [[JoinInGroupViewController alloc]init];
    [self.navigationController pushViewController:joinIn animated:YES];
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
