//
//  JoinInGroupViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "JoinInGroupViewController.h"
#import "SearchGroupViewController.h"
#import "CardCell.h"
#import "CardTitleView.h"
#import "EGOImageView.h"
@interface JoinInGroupViewController ()
{
    UITextField *m_searchTf;
    UICollectionViewFlowLayout *m_layout;
    UICollectionView *groupCollectionView;
    NSMutableArray *cardArray;
    NSMutableDictionary *listDict;
    UILabel *cardTitleLabel;
    UILabel *realmLabel;
    EGOImageView *clazzImg;
    EGOImageView *gameImg;
    UIImageView *authBg;
    UILabel *nameLabel;
    UIPickerView *m_gamePickerView;
    UIScrollView *m_baseScrollView;
    NSMutableArray *gameInfoArray;
    UIView *m_pickView;
    
    NSMutableArray *allkeysArr;
}
@end

@implementation JoinInGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"推荐搜索" withBackButton:YES];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    tapGr.delegate = self;
    [self.view addGestureRecognizer:tapGr];
    
    
    m_baseScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, startX, 320,kScreenHeigth-startX)];
    m_baseScrollView.contentSize = CGSizeMake(0,700);
    [self.view addSubview:m_baseScrollView];
    
    listDict  = [NSMutableDictionary dictionary];
//    allkeysArr = [NSMutableArray array];
    gameInfoArray  = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];

    m_searchTf = [[UITextField alloc]initWithFrame:CGRectMake(10, 20, 300, 40)];
    m_searchTf.backgroundColor = [UIColor clearColor];
    m_searchTf.borderStyle = UITextBorderStyleRoundedRect;
    m_searchTf.placeholder = @"搜索群名称或群号";
    m_searchTf.clearButtonMode = UITextFieldViewModeAlways;
    m_searchTf.autocorrectionType = UITextAutocorrectionTypeNo;
    m_searchTf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    m_searchTf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    m_searchTf.delegate = self;
    m_searchTf.returnKeyType =UIReturnKeyGo;
    [m_baseScrollView addSubview:m_searchTf];
    
    [self buildRoleView];
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[GameCommon getNewStringWithId:KISDictionaryHaveKey(gameInfoArray[0], @"gameid")],@"gameid",[GameCommon getNewStringWithId:KISDictionaryHaveKey(gameInfoArray[0], @"id")],@"characterId", nil];

    [self getCardWithNetWithDic:dic];
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 140, 320, 20)];
    lable.backgroundColor = [UIColor clearColor];
    lable.text = @"根据角色为您推荐以下分类";
    lable.font = [UIFont systemFontOfSize:10];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor  = [UIColor grayColor];
    [m_baseScrollView addSubview:lable];
    
    m_layout = [[UICollectionViewFlowLayout alloc]init];
    m_layout.minimumInteritemSpacing = 10;
    m_layout.minimumLineSpacing =5;
    m_layout.itemSize = CGSizeMake(88, 30);
//    m_layout.sectionInset = UIEdgeInsetsMake(30,0, 0, 0);
    m_layout.headerReferenceSize = CGSizeMake(300, 40);
    
    
    groupCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 150, 300, 500) collectionViewLayout:m_layout];
    groupCollectionView.backgroundColor = UIColorFromRGBA(0xf8f8f8, 1);
    groupCollectionView.scrollEnabled = NO;
    groupCollectionView.delegate = self;
    groupCollectionView.dataSource = self;
    [groupCollectionView registerClass:[CardCell class] forCellWithReuseIdentifier:@"titleCell"];
    [groupCollectionView registerClass:[CardTitleView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headViewww"];

    groupCollectionView.backgroundColor = [UIColor clearColor];
    [m_baseScrollView addSubview:groupCollectionView];
    
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    if([m_searchTf isFirstResponder]){
        [m_searchTf resignFirstResponder];
    }
    if (m_pickView.tag==222) {
        [self hideSelectView];
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    for(UIView *view in gestureRecognizer.view.subviews){
        if ([view isKindOfClass:[UIButton class]]) {
            return NO;
        }
    }
    return YES;
}

-(void)buildRoleView
{
 
    UIButton * myView = [[UIButton alloc]initWithFrame:CGRectMake(0, 70, 320, 60)];
    
    [myView setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [myView setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    UIView *uplineView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 1)];
    uplineView.backgroundColor = [UIColor grayColor];
    [myView addSubview:uplineView];
    
    UIView *downView =[[ UIView alloc]initWithFrame:CGRectMake(0, 65, 320, 1)];
    downView.backgroundColor =[UIColor grayColor];
    [myView addSubview:downView];
    
    
    clazzImg = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 25.0/2, 35, 35)];
    clazzImg.backgroundColor = [UIColor clearColor];
    clazzImg.imageURL = [ImageService getImageStr2:[gameInfoArray[0]objectForKey:@"img"]];
    [myView addSubview:clazzImg];
    
    authBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    authBg.backgroundColor = [UIColor clearColor];
    NSString *auth =[gameInfoArray[0]objectForKey:@"auth"];
//    BOOL isAuth = [auth boolValue];
    if ([auth intValue]==0) {
        authBg.image = KUIImage(@"chara_auth_2");
    }else{
        authBg.image = KUIImage(@"chara_auth_1");
    }
    [myView addSubview:authBg];
//    authBg.hidden = YES;
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 120, 20)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = kColorWithRGB(51, 51, 51, 1.0);
    nameLabel.font = [UIFont boldSystemFontOfSize:15.0];
    
    [myView addSubview:nameLabel];
    
    nameLabel.text = KISDictionaryHaveKey(gameInfoArray[0], @"name");
    
    gameImg = [[EGOImageView alloc] initWithFrame:CGRectMake(55, 31, 18, 18)];
    gameImg.backgroundColor = [UIColor clearColor];
    gameImg.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(gameInfoArray[0], @"gameid")]];
    [myView addSubview:gameImg];
    
    realmLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 30, 130, 20)];
    realmLabel.backgroundColor = [UIColor clearColor];
    realmLabel.textColor = kColorWithRGB(102, 102, 102, 1.0) ;
    realmLabel.font = [UIFont boldSystemFontOfSize:14.0];
    realmLabel.text = KISDictionaryHaveKey(gameInfoArray[0], @"realm");
    [myView addSubview:realmLabel];
    
    
    m_pickView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeigth, 320, 200)];
    m_pickView.tag=111;
//    m_pickView.hidden = YES;
    [self.view addSubview:m_pickView];
    
    m_gamePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 44, 320, 180)];
    m_gamePickerView.dataSource = self;
    m_gamePickerView.delegate = self;
    m_gamePickerView.backgroundColor = [UIColor whiteColor];
    m_gamePickerView.showsSelectionIndicator = YES;
    [m_pickView addSubview:m_gamePickerView];
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.tintColor = [UIColor blackColor];
    UIBarButtonItem*rb_server = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(selectServerNameOK:)];
    rb_server.tintColor = [UIColor blackColor];
    toolbar.items = @[rb_server];
    [m_pickView addSubview:toolbar];

    UILabel *clickLb = [[UILabel alloc]initWithFrame:CGRectMake(260, 0, 50, 60)];
    clickLb.text =@"切换角色";
    clickLb.backgroundColor = [UIColor clearColor];
    clickLb.textColor = [UIColor blueColor];
    clickLb.font = [UIFont systemFontOfSize:12];
    [myView addSubview:clickLb];
     
    [myView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickChangeRole:)]];
    
     [m_baseScrollView addSubview:myView];
}
//<<<<<<< HEAD
//-(void)didClickChangeRole:(id)sender
//{
//    m_pickView.hidden = NO;
//=======

-(void)showSelectView
{
     m_pickView.tag=222;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    m_pickView.frame = CGRectMake(0, kScreenHeigth-224, 320, 200);
    [UIView commitAnimations];
}
-(void)hideSelectView
{
    m_pickView.tag=111;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    m_pickView.frame = CGRectMake(0, kScreenHeigth, 320, 0);
    [UIView commitAnimations];
}

-(void)didClickChangeRole:(id)sender
{
    if([m_searchTf isFirstResponder]){
        [m_searchTf resignFirstResponder];
    }
    if (m_pickView.tag==111) {
        [self showSelectView];
    }else
    {
        [self hideSelectView];
    }

}

#pragma mark ---获取网络请求数据
-(void)getCardWithNetWithDic:(NSMutableDictionary *)paramDict
{
    NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];

    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"236" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            listDict  = responseObject;
           
            
            NSArray *array = [NSArray arrayWithObjects:@{@"tagName":[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"realm")],@"tagId":@"realm"},@{@"tagName": @"附近组织",@"tagId":@"nearby"},@{@"tagName":@"最热组织",@"tagId":@"hot"}, nil];
            allkeysArr = [NSMutableArray arrayWithArray:KISDictionaryHaveKey(responseObject, @"sortList")];
            [allkeysArr insertObject:@"aaaa" atIndex:0];

            [listDict setObject:array forKey:@"aaaa"];
            [listDict removeObjectForKey:@"sortList"];

            
            
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
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
//{
//    NSArray *arr = [listDict allKeys];
//    NSArray *arry =[listDict objectForKey:arr[indexPath.section]];
//    NSDictionary *dic = [arry objectAtIndex:indexPath.row];
//    CGSize size = [KISDictionaryHaveKey(dic, @"tagName") sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
//    return CGSizeMake(size.width+25, 30);
//    
//}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return [listDict allKeys].count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *arry =[listDict objectForKey:allkeysArr[section]];
    return arry.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CardCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"titleCell" forIndexPath:indexPath];
    cell.bgImgView.image = KUIImage(@"card_show");
    NSArray *arry =[listDict objectForKey:allkeysArr[indexPath.section]];
    
    NSDictionary* dic = [arry objectAtIndex:indexPath.row];
    
//    CGSize size = [KISDictionaryHaveKey(dic, @"tagName") sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
//    cell.titleLabel.frame = CGRectMake(0, 0, size.width+20, 30);
    
    cell.titleLabel.text = KISDictionaryHaveKey(dic, @"tagName");
    
    return cell;
    
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *titleView;
    
    if (kind == UICollectionElementKindSectionHeader) {
        titleView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headViewww" forIndexPath:indexPath];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[listDict allKeys]];
        [arr sortUsingSelector:@selector(compare:)];
        NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];

        allkeysArr[0] = [NSString stringWithFormat:@"%@的组织推荐",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"name")]];
        ((CardTitleView *)titleView).cardTitleLabel.text =[allkeysArr objectAtIndex:indexPath.section];
    }
    return titleView;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];
    NSArray *arry =[listDict objectForKey:allkeysArr[indexPath.section]];
    NSDictionary* dic = [arry objectAtIndex:indexPath.row];
    SearchGroupViewController *groupView = [[SearchGroupViewController alloc]init];

    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"tagId")]isEqualToString:@"realm"]) {
        groupView.ComeType =SETUP_SAMEREALM;
        groupView.gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"gameid")];
        groupView.realmStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"realm")] ;
    }
    else if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"tagId")]isEqualToString:@"nearby"]) {
        ;
        groupView.ComeType  = SETUP_NEARBY;
        groupView.gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"gameid")];
    }
    else if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"tagId")]isEqualToString:@"hot"]) {
        ;
        groupView.ComeType = SETUP_HOT;
        groupView.gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"gameid")];

    }else{

    groupView.ComeType = SETUP_Tags;
    groupView.tagsId =KISDictionaryHaveKey(dic, @"tagId");
    }
    [self.navigationController pushViewController:groupView animated:YES];

    
    
}
-(void)selectServerNameOK:(id)sender
{
    if([m_searchTf isFirstResponder]){
        [m_searchTf resignFirstResponder];
    }
    if (m_pickView.tag==222) {
        [self hideSelectView];
    }

    if ([gameInfoArray count] != 0) {
        NSDictionary *dict =[gameInfoArray objectAtIndex:[m_gamePickerView selectedRowInComponent:0]];
        clazzImg.imageURL = [ImageService getImageStr2:KISDictionaryHaveKey(dict, @"img")];
        realmLabel.text = KISDictionaryHaveKey(dict, @"realm");
        gameImg.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dict, @"gameid")]];
        nameLabel.text = KISDictionaryHaveKey(dict, @"name");
        NSString *auth =[dict objectForKey:@"auth"];
        //    BOOL isAuth = [auth boolValue];
        if ([auth intValue]==0) {
            authBg.image = KUIImage(@"chara_auth_2");
        }else{
            authBg.image = KUIImage(@"chara_auth_1");
        }
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"gameid")],@"gameid",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"id")],@"characterId", nil];
        
        [self getCardWithNetWithDic:dic];
    }
}

#pragma mark 选择器
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return gameInfoArray.count;
}

//- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger) row forComponent:(NSInteger) component
//{
//    NSString *title = KISDictionaryHaveKey([gameInfoArray objectAtIndex:row], @"name");
//    return title;
//}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
{
    NSDictionary *dic = [gameInfoArray objectAtIndex:row];
    UIView *customView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    EGOImageView *imageView = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 5, 20, 20)];
    imageView.imageURL = [ImageService getImageStr2:[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(dic, @"gameid")]];
    [customView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 30)];
    label.text = [NSString stringWithFormat:@"%@-%@-%@",KISDictionaryHaveKey(dic, @"realm"),KISDictionaryHaveKey(dic, @"value1"),KISDictionaryHaveKey(dic, @"name")];
    label.backgroundColor = [UIColor clearColor];
    [customView addSubview:label];
    return customView;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
