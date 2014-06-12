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
#import "ReusableView.h"
#import "SearchGroupViewController.h"

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
NSString *const RAMCollectionViewFlemishBondHeaderKind = @"RAMCollectionViewFlemishBondHeaderKind";
static NSString * const HeaderIdentifier = @"HeaderIdentifier";

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
    m_layout.headerReferenceSize = CGSizeMake(320, 60);
    m_layout.sectionInset = UIEdgeInsetsMake(10,10,0,10);
    
    groupCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, KISHighVersion_7?64:44, 320, 150) collectionViewLayout:m_layout];
    groupCollectionView.backgroundColor = UIColorFromRGBA(0xf8f8f8, 1);
    groupCollectionView.scrollEnabled = NO;
    groupCollectionView.delegate = self;
    groupCollectionView.dataSource = self;
    [groupCollectionView registerClass:[GroupOfMineCell class] forCellWithReuseIdentifier:@"titleCell"];
    [groupCollectionView registerClass:[ReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderIdentifier];

    groupCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:groupCollectionView];

    
//    [groupCollectionView registerClass:[ReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView"];
    NSArray *arr1 = @[@"XXX开始,找个群一起聊",@"附近的组织",@"同服的组织"];
    NSArray *arr2 = @[@"根据你支持的队伍选择群组",@"加入附近的组织,和他们一起玩",@"看看同服有哪些组织"];
    NSArray *arr3 =@[@"mess_news",@"mess_news",@"mess_news"];
    for (int i =0; i<3; i++) {
        UIView *view = [self bulidCellWithFrame:CGRectMake(0, 280+60*i, 320, 59) title1:arr1[i] title2:arr2[i] img:arr3[i]];
        view.tag = 100+i;
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickNormal:)]];
        [self.view addSubview:view];
    }
    
    
    
    [self getGroupListFromNet];
    // Do any additional setup after loading the view.
}

-(UIView *)bulidCellWithFrame:(CGRect)frame title1:(NSString*)title1 title2:(NSString *)title2 img:(NSString *)img
{
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10,10, 40, 40)];
    imageView.image = KUIImage(img);
    [view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60,10, 200, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:17];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = title1;
    [view addSubview:label];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(60, 35, 200, 20)];
    label1.backgroundColor = [UIColor clearColor];
    label1.textColor = [UIColor grayColor];
    label1.font = [UIFont systemFontOfSize:14];
    label1.textAlignment = NSTextAlignmentLeft;
    label1.text = title2;
    [view addSubview:label1];

    UIImageView *rightImg = [[UIImageView alloc]initWithFrame:CGRectMake(300, 25, 10, 10)];
    rightImg.image = KUIImage(@"right");
    [view addSubview:rightImg];
    
    UIView *lineView =[[ UIView alloc]initWithFrame:CGRectMake(0, frame.origin.y+59, 320, 1)];
    lineView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineView];
    return view;
    
}

-(void)didClickNormal:(UIGestureRecognizer *)sender
{
    SearchGroupViewController *groupView = [[SearchGroupViewController alloc]init];

    switch (sender.view.tag) {
        case 100:
            [self showAlertViewWithTitle:@"嘟嘟嘟嘟" message:@"我都不知道这个标签是干什么的！没事不要乱点!" buttonTitle:@"跪求原谅"];
            break;
        case 101:
            groupView.ComeType = SETUP_NEARBY;
            [self.navigationController pushViewController:groupView animated:YES];
            break;
     
        default:
            [self showAlertViewWithTitle:@"嘟嘟嘟嘟" message:@"难道你不知道同服现在不能点呢嘛！！没事不要乱点!" buttonTitle:@"跪求原谅"];
 
//            groupView.ComeType = SETUP_SAMEREALM;
//            [self.navigationController pushViewController:groupView animated:YES];
            break;
    }
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
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"addphoto",@"backgroundImg", nil];
            [myGroupArray addObject:dic];
            if (myGroupArray.count>3) {
                groupCollectionView.frame = CGRectMake(0, startX, 320, 230);
            }
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
    if (indexPath.row ==myGroupArray.count-1) {
        cell.headImgView.placeholderImage =nil;
        cell.headImgView.imageURL = nil;
        NSString *imgStr = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(cellDic, @"backgroundImg")];
        cell.headImgView.image = KUIImage(imgStr);
    }else{
    cell.headImgView.placeholderImage = KUIImage(@"mess_news");
    cell.headImgView.imageURL = [ImageService getImageUrl4:KISDictionaryHaveKey(cellDic, @"backgroundImg")];
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath

{
    NSDictionary *dic = [myGroupArray objectAtIndex:indexPath.row];
    if (indexPath.row ==myGroupArray.count-1) {
        JoinInGroupViewController *joinIn = [[JoinInGroupViewController alloc]init];
        [self.navigationController pushViewController:joinIn animated:YES];
  
    }else{
    GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
    gr.groupId =KISDictionaryHaveKey(dic, @"groupId");
    [self.navigationController pushViewController:gr animated:YES];
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *titleView;
    
    if (kind == UICollectionElementKindSectionHeader) {
        titleView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HeaderIdentifier forIndexPath:indexPath];
        ((ReusableView *)titleView).label.text = @"晨星是个坑晨星是个坑晨星是个坑晨星是个坑晨星是个坑晨星是个坑晨星是个坑晨星是个坑晨星是个坑晨星是个坑晨星是个坑";
        ((ReusableView *)titleView).contentLabel.text = @"大家一起坑晨星";
        ((ReusableView *)titleView).timeLabel.text = @"06-11";
        ((ReusableView *)titleView).headImageView.imageURL = nil;

    }
    return titleView;
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
