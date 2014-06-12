//
//  JoinInGroupViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "JoinInGroupViewController.h"
#import "GroupListViewController.h"
#import "SearchGroupViewController.h"
#import "CardCell.h"
#import "CardTitleView.h"
@interface JoinInGroupViewController ()
{
    UITextField *m_searchTf;
    UICollectionViewFlowLayout *m_layout;
    UICollectionView *groupCollectionView;
    NSMutableArray *cardArray;
    NSMutableDictionary *listDict;
    UILabel *cardTitleLabel;
}
@end

@implementation JoinInGroupViewController

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
    
    
    [self setTopViewWithTitle:@"推荐搜索" withBackButton:YES];
    
    listDict  = [NSMutableDictionary dictionary];
    
    m_searchTf = [[UITextField alloc]initWithFrame:CGRectMake(10, startX+20, 300, 40)];
    m_searchTf.backgroundColor = [UIColor clearColor];
    m_searchTf.borderStyle = UITextBorderStyleRoundedRect;
    m_searchTf.placeholder = @"搜索群名称或群号";
    m_searchTf.clearButtonMode = UITextFieldViewModeAlways;
    m_searchTf.autocorrectionType = UITextAutocorrectionTypeNo;
    m_searchTf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_searchTf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    m_searchTf.delegate = self;
    [self.view addSubview:m_searchTf];
    
//    UIButton *okbutton = [[UIButton alloc]initWithFrame:CGRectMake(10, startX+80, 300, 40)];
//    [okbutton setTitle:@"搜索" forState:UIControlStateNormal];
//    [okbutton addTarget:self action:@selector(searchStrToNextPage:) forControlEvents:UIControlEventTouchUpInside];
//    okbutton.backgroundColor =[UIColor grayColor];
//    [self.view addSubview:okbutton];
    
    
    m_layout = [[UICollectionViewFlowLayout alloc]init];
    m_layout.minimumInteritemSpacing = 10;
    m_layout.minimumLineSpacing =5;
//    m_layout.sectionInset = UIEdgeInsetsMake(30,0, 0, 0);
    m_layout.headerReferenceSize = CGSizeMake(300, 40);
    
    
    groupCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 150, 300, 400) collectionViewLayout:m_layout];
    groupCollectionView.backgroundColor = UIColorFromRGBA(0xf8f8f8, 1);
    groupCollectionView.scrollEnabled = NO;
    groupCollectionView.delegate = self;
    groupCollectionView.dataSource = self;
    [groupCollectionView registerClass:[CardCell class] forCellWithReuseIdentifier:@"titleCell"];
    [groupCollectionView registerClass:[CardTitleView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headViewww"];

    groupCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:groupCollectionView];
    
    [ self getCardWithNet];
    
    // Do any additional setup after loading the view.
}
-(void)getCardWithNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"236" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            listDict  = responseObject;
            
            [groupCollectionView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
    
}

-(void)searchStrToNextPage:(id)sender
{    
    SearchGroupViewController *groupView = [[SearchGroupViewController alloc]init];
    groupView.conditiona = m_searchTf.text;
    groupView.ComeType = SETUP_Search;
    [self.navigationController pushViewController:groupView animated:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self searchStrToNextPage:nil];
    
    return YES;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSArray *arr = [listDict allKeys];
    NSArray *arry =[listDict objectForKey:arr[indexPath.section]];
    NSDictionary *dic = [arry objectAtIndex:indexPath.row];
    CGSize size = [KISDictionaryHaveKey(dic, @"tagName") sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
    return CGSizeMake(size.width+25, 30);
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return [listDict allKeys].count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *arr = [listDict allKeys];
    NSArray *arry =[listDict objectForKey:arr[section]];
    return arry.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CardCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"titleCell" forIndexPath:indexPath];
    cell.bgImgView.image = KUIImage(@"selectednormal-big");
    NSArray *arr = [listDict allKeys];
    NSArray *arry =[listDict objectForKey:arr[indexPath.section]];
    
    NSDictionary* dic = [arry objectAtIndex:indexPath.row];
    
    CGSize size = [KISDictionaryHaveKey(dic, @"tagName") sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
    cell.titleLabel.frame = CGRectMake(0, 0, size.width+20, 30);
    
    cell.titleLabel.text = KISDictionaryHaveKey(dic, @"tagName");
    
    return cell;
    
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *titleView;
    
    if (kind == UICollectionElementKindSectionHeader) {
        titleView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headViewww" forIndexPath:indexPath];
        ((CardTitleView *)titleView).cardTitleLabel.text =[[listDict allKeys]objectAtIndex:indexPath.section];
    }
    return titleView;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = [listDict allKeys];
    NSArray *arry =[listDict objectForKey:arr[indexPath.section]];
    
    NSDictionary* dic = [arry objectAtIndex:indexPath.row];

    SearchGroupViewController *groupView = [[SearchGroupViewController alloc]init];
    groupView.ComeType = SETUP_Tags;
    groupView.tagsId =KISDictionaryHaveKey(dic, @"tagId");
    [self.navigationController pushViewController:groupView animated:YES];

    
    
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
