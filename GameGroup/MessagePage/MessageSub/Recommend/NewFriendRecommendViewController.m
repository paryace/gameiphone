//
//  NewFriendRecommendViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewFriendRecommendViewController.h"
#import "AddGroupMemberCell.h"
#import "ImgCollCell.h"
#import "TestViewController.h"
@interface NewFriendRecommendViewController ()
{
    UITableView *m_myTableView;
    UICollectionView *m_customCollView;
    UICollectionViewFlowLayout *m_layout;
    NSMutableArray *addMemArray;
    NSMutableArray *m_dataArray;
    AddGroupMemberCell*cell1;
    UIButton *m_button;
    BOOL isChoose;
}
@end

@implementation NewFriendRecommendViewController

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
    
    [self setTopViewWithTitle:@"添加成员" withBackButton:YES];
    
    isChoose = YES;
    UIButton *chooseAllBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    chooseAllBtn.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    //    [chooseAllBtn setBackgroundImage:KUIImage(@"delete_normal") forState:UIControlStateNormal];
    //    [chooseAllBtn setBackgroundImage:KUIImage(@"delete_click") forState:UIControlStateHighlighted];
//    [chooseAllBtn setTitle:@"全不选" forState:UIControlStateNormal];
    [chooseAllBtn setImage:KUIImage(@"choose_no") forState:UIControlStateNormal];
    [self.view addSubview:chooseAllBtn];
    [chooseAllBtn addTarget:self action:@selector(didClickChooseAll:) forControlEvents:UIControlEventTouchUpInside];
    
    
    m_dataArray = [NSMutableArray array];
    addMemArray = [NSMutableArray array];
    [addMemArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"find_billboard",@"img", nil]];
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX-50)];
    m_myTableView.dataSource = self;
    m_myTableView.delegate = self;
    if(KISHighVersion_7){
        m_myTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    m_myTableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    [self.view addSubview:m_myTableView];
    
    // Do any additional setup after loading the view.
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    
    [self buildAddMembersScroll];
    
    [self getInfo];

}

-(void)didClickChooseAll:(UIButton *)sender
{
    if (isChoose) {
        isChoose =NO;
//        [sender setTitle:@"全选" forState:UIControlStateNormal];
        [sender setImage:KUIImage(@"choose_all") forState:UIControlStateNormal];
        
        
        for (NSMutableDictionary *dic in m_dataArray) {
            [dic setObject:@"1" forKey:@"state"];
        }
        [addMemArray removeAllObjects];
        [addMemArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"find_billboard",@"img", nil]];

        [m_myTableView reloadData];
//        m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
        [m_customCollView reloadData];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
        [UIView commitAnimations];

    }else{
        isChoose =YES;
        [sender setImage:KUIImage(@"choose_no") forState:UIControlStateNormal];
        for (NSMutableDictionary *dic in m_dataArray) {
            [dic setObject:@"0" forKey:@"state"];
        }
        [addMemArray removeAllObjects];
        [addMemArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"find_billboard",@"img", nil]];

        for (NSDictionary *dict in m_dataArray) {
            [addMemArray insertObject:dict atIndex:addMemArray.count-1];
        }
        [m_myTableView reloadData];
        [m_customCollView reloadData];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
        [UIView commitAnimations];


//        m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);

    }
    NSString *title;
    if (addMemArray.count==1) {
        title = [NSString stringWithFormat:@"关注"];
    }else{
        title = [NSString stringWithFormat:@"关注(%d)",addMemArray.count-1];
    }
    [m_button setTitle:title forState:UIControlStateNormal];


}


-(void)buildAddMembersScroll
{
    UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeigth-50-(KISHighVersion_7?0:20), 320, 50)];
    customView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:customView];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    line1.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    [customView addSubview:line1];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0.5, 320, 0.5)];
    line2.backgroundColor = [UIColor grayColor];
    [customView addSubview:line2];
    
    
    m_layout = [[UICollectionViewFlowLayout alloc]init];
    m_layout.minimumInteritemSpacing = 15;
    m_layout.minimumLineSpacing = 5;
    m_layout.itemSize = CGSizeMake(34, 34);
    [m_layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    m_customCollView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 5, 240, 40) collectionViewLayout:m_layout];
    [m_customCollView registerClass:[ImgCollCell class] forCellWithReuseIdentifier:@"ImageCell"];
    m_customCollView.delegate = self;
    m_customCollView.dataSource = self;
    m_customCollView.backgroundColor = [UIColor clearColor];
    [customView addSubview:m_customCollView];
    
    m_button = [[UIButton alloc]initWithFrame:CGRectMake(260, 10, 55, 25)];
    [m_button setBackgroundImage:KUIImage(@"addmembers_ok") forState:UIControlStateNormal];
    [m_button setTitle:@"关注" forState:UIControlStateNormal];
    m_button.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    [m_button addTarget:self action:@selector(addMembers:) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:m_button];
}

-(void)getInfo
{
    hud.labelText = @"获取中...";
    [m_dataArray removeAllObjects];
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * dRecommend = [DSRecommendList MR_findAllInContext:localContext];
        for (DSRecommendList* Recommend in dRecommend) {
            NSMutableDictionary* tempDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:Recommend.headImgID, @"headImgID", Recommend.nickName, @"nickname", Recommend.userName, @"username", Recommend.state, @"state", Recommend.fromID, @"type", Recommend.fromStr,@"dis",Recommend.userid,@"userid",Recommend.recommendReason,@"recommendReason",nil];
            [m_dataArray insertObject:tempDic atIndex:0];
        }
    }];
    
    for (NSDictionary *dic  in m_dataArray) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"state")]isEqualToString:@"0"]) {
            [addMemArray insertObject:dic atIndex:addMemArray.count-1];
        }
    }
    
    [m_myTableView reloadData];
    [m_customCollView reloadData];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
    [UIView commitAnimations];
    NSString *title;
    if (addMemArray.count==1) {
        title = [NSString stringWithFormat:@"关注"];
    }else{
        title = [NSString stringWithFormat:@"关注(%d)",addMemArray.count-1];
    }
    [m_button setTitle:title forState:UIControlStateNormal];

    //    }];
}
//返回每个组里面的数据条数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indefine = @"cell";
    NewRecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:indefine];
    if (!cell) {
        cell = [[NewRecommendCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indefine];
    }
    cell.tag = 100+indexPath.row;
    cell.myDelegate = self;
    NSDictionary * tempDict =[m_dataArray objectAtIndex:indexPath.row];
    NSString * headplaceholderImage= [self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    
    cell.headImg.placeholderImage = [UIImage imageNamed:headplaceholderImage];
    NSString * imageids=KISDictionaryHaveKey(tempDict, @"img");
    cell.headImg.imageURL=[ImageService getImageStr:imageids Width:80];
    NSString * nickName=[tempDict objectForKey:@"alias"];
    if ([GameCommon isEmtity:nickName]) {
        nickName=[tempDict objectForKey:@"nickname"];
    }
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"state")]intValue]==0) {
        [cell.chooseImg setImage: KUIImage(@"choose") forState:UIControlStateNormal];
    }else{
        [cell.chooseImg setImage: KUIImage(@"unchoose") forState:UIControlStateNormal];
    }
    cell.nameLabel.text = nickName;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    TestViewController *tes = [[TestViewController alloc]init];
    tes.userId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")];
    tes.nickName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"nickname")];
    
    [self.navigationController pushViewController:tes animated:YES];
    
    
    
//    if (cell.chooseImg.image ==KUIImage(@"unchoose")) {
//        cell.chooseImg.image = KUIImage(@"choose");
//        NSDictionary *dic = tempDict;
//        [tempDict setObject:@"0" forKey:@"state"];
//        [dic setValue:@(indexPath.row) forKey:@"row"];
//        [addMemArray insertObject:dic atIndex:addMemArray.count-1];
//        
//    }else{
//        cell.chooseImg.image =KUIImage(@"unchoose");
//        NSDictionary *dic = tempDict;
//        [tempDict setObject:@"1" forKey:@"choose"];
//        
//        [dic setValue:@(indexPath.row) forKey:@"row"];
//        
//        [addMemArray removeObject:dic];
//    }
//    [m_customCollView reloadData];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.3];
//    m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
//    [UIView commitAnimations];
//    int count = addMemArray.count;
//    NSString *title = [NSString stringWithFormat:@"确定(%d)",count-1];
//    [m_button setTitle:title forState:UIControlStateNormal];
//    
}
-(void)chooseWithCell:(NewRecommendCell *)cell
{
    NSMutableDictionary * tempDict =(NSMutableDictionary*)[m_dataArray objectAtIndex:cell.tag-100];

    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"state")]isEqualToString:@"0"]) {
        [addMemArray removeObject:tempDict];
        [tempDict setObject:@"1" forKey:@"state"];
        [m_myTableView reloadData];
        [m_customCollView reloadData];
    }else{
        [tempDict setObject:@"0" forKey:@"state"];
        [addMemArray insertObject:tempDict atIndex:addMemArray.count-1];
        [m_myTableView reloadData];
        [m_customCollView reloadData];
    }
    NSString *title;
    if (addMemArray.count==0) {
        title = [NSString stringWithFormat:@"关注"];
    }else{
        title = [NSString stringWithFormat:@"关注(%d)",addMemArray.count-1];
    }
    [m_button setTitle:title forState:UIControlStateNormal];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
    [UIView commitAnimations];

    
}

#pragma mark ---collectionview delegate  datasourse

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return addMemArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImgCollCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    NSDictionary * tempDict =[addMemArray objectAtIndex:indexPath.row];
    
    NSString * headplaceholderImage= [self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    
    NSString * imageids=KISDictionaryHaveKey(tempDict, @"img");
    if (indexPath.row ==addMemArray.count-1) {
        cell.imageView.placeholderImage = KUIImage(imageids);
        cell.imageView.imageURL = nil;
    }else{
        cell.imageView.placeholderImage = [UIImage imageNamed:headplaceholderImage];
        cell.imageView.imageURL=[ImageService getImageStr:imageids Width:80];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==addMemArray.count-1) {
        return;
    }
    NSDictionary * tempDict =[addMemArray objectAtIndex:indexPath.row];
    
    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"userid")];
    
    NSLog(@"userid---%@",userid);
    for (NSMutableDictionary *dict in m_dataArray) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"userid")]isEqualToString:userid]) {
            [dict setObject:@"1" forKey:@"state"];
        }
    }
    [m_myTableView reloadData];
    
    [addMemArray removeObject:tempDict];
    m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
    [m_customCollView reloadData];
    int count = addMemArray.count;
    NSString *title;
    if (count==0) {
        title = [NSString stringWithFormat:@"关注"];
    }else{
        title = [NSString stringWithFormat:@"关注(%d)",addMemArray.count-1];
    }
    [m_button setTitle:title forState:UIControlStateNormal];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
    [UIView commitAnimations];
    
    
}

//头像默认图片
-(NSString*)headPlaceholderImage:(NSString*)gender
{
    if ([[GameCommon getNewStringWithId:gender] isEqualToString:@"0"]) {//男♀♂
        return @"people_man.png";
    }
    else
    {
        return @"people_woman.png";
    }
}
//性别图标
-(NSString*)genderImage:(NSString*)gender
{
    if ([gender intValue]==0)
    {
        return @"gender_boy";
    }else
    {
        return @"gender_girl";
    }
}


#pragma mark ---开始邀请成员
-(void)addMembers:(id)sender
{
    if (addMemArray.count>1) {
        
        NSMutableArray *customArr = [NSMutableArray arrayWithArray:addMemArray];
        [customArr removeLastObject];
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *dic  in customArr) {
            
            NSString *typeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"type")];
            NSString *recommendReason =[ GameCommon getNewStringWithId: KISDictionaryHaveKey(dic, @"recommendReason")];
            NSString *userid =[ GameCommon getNewStringWithId: KISDictionaryHaveKey(dic, @"userid")];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:typeStr,@"type",recommendReason,@"recommendReason",userid,@"userid", nil];
            [arr addObject:dict];
        }
        [self updataInfoWithId:arr];
    }
}
-(NSString*)getImageIdsStr:(NSArray*)imageIdArray
{
    NSString* headImgStr = @"";
    for (int i = 0;i<imageIdArray.count;i++) {
        NSString * temp1 = [imageIdArray objectAtIndex:i];
        headImgStr = [headImgStr stringByAppendingFormat:@"%@,",temp1];
    }
    return headImgStr;
}
-(void)updataInfoWithId:(NSArray *)arr
{
    [hud show:YES];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * paramsDict = [NSMutableDictionary dictionary];
    [paramsDict setObject:arr forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"292" forKey:@"method"];
    [postDict setObject:paramsDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        [m_myTableView setEditing:NO animated:YES];
        
        NSMutableArray *sarr = [NSMutableArray arrayWithArray:m_dataArray];
        for (NSDictionary *dic in addMemArray) {
            [DataStoreManager deleteMemberFromListWithUserid:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]];
            [sarr removeObject:dic];
        }
        for (NSDictionary *dict in sarr) {
            [DataStoreManager updateRecommendStatus:@"1" ForPerson:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"userid")]];
        }
        
        [addMemArray removeAllObjects];
        [addMemArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"find_billboard",@"img", nil]];
        
        [self getInfo];
        m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
        
        [self showMessageWindowWithContent:@"发送成功" imageType:0];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView * alertView_1 = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView_1 show];
            }
        }
        [hud hide:YES];
    }];
    
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
