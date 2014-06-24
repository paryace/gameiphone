//
//  InvitationViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "InvitationViewController.h"
#import "AddGroupMemberCell.h"
#import "ImgCollCell.h"
@interface InvitationViewController ()
{
    UITableView *m_myTableView;
    NSMutableDictionary *resultDict;//数据集合
    NSMutableArray * keyArr;//字母集合
    UICollectionView *m_customCollView;
    UICollectionViewFlowLayout *m_layout;
    NSMutableArray *addMemArray;
    AddGroupMemberCell*cell1;
}
@end

@implementation InvitationViewController

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
    
    resultDict = [NSMutableDictionary dictionary];
    keyArr = [NSMutableArray array];
    addMemArray = [NSMutableArray array];
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX-50)];
    m_myTableView.dataSource = self;
    m_myTableView.delegate = self;
    if(KISHighVersion_7){
        m_myTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    m_myTableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    [self.view addSubview:m_myTableView];

    [self getInfo];
    // Do any additional setup after loading the view.
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    
    [self buildAddMembersScroll];
    
    
}

-(void)buildAddMembersScroll
{
    UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeigth-50, 320, 50)];
    customView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    [self.view addSubview:customView];
    
    m_layout = [[UICollectionViewFlowLayout alloc]init];
    m_layout.minimumInteritemSpacing = 4;
    m_layout.minimumLineSpacing = 3;
    m_layout.itemSize = CGSizeMake(34, 34);
    [m_layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    m_customCollView = [[UICollectionView alloc]initWithFrame:CGRectMake(5, 5, 240, 40) collectionViewLayout:m_layout];
    [m_customCollView registerClass:[ImgCollCell class] forCellWithReuseIdentifier:@"ImageCell"];
    m_customCollView.delegate = self;
    m_customCollView.dataSource = self;
    m_customCollView.backgroundColor = [UIColor clearColor];
    [customView addSubview:m_customCollView];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(260, 10, 50, 30)];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor blueColor];
    [button addTarget:self action:@selector(addMembers:) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:button];
    
}



-(void)getInfo
{
    hud.labelText = @"获取中...";
//    [hud showAnimated:YES whileExecutingBlock:^{
        NSMutableDictionary *userinfo=[DataStoreManager  newQuerySections:@"1" ShipType2:@"2"];
        NSMutableDictionary* result = [userinfo objectForKey:@"userList"];
        NSMutableArray* keys = [userinfo objectForKey:@"nameKey"];
        [keyArr removeAllObjects];
        [resultDict removeAllObjects];
        [keyArr addObjectsFromArray:keys];
        resultDict = result;
        [m_myTableView reloadData];
//    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  keyArr.count;
}
//返回每个组里面的数据条数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[resultDict objectForKey:[keyArr objectAtIndex:section]] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *indefine = @"cell";
    AddGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:indefine];
    if (!cell) {
        cell = [[AddGroupMemberCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indefine];
    }
    cell.tag = 100000*indexPath.section+indexPath.row;
    
    NSDictionary * tempDict =[[resultDict objectForKey:[keyArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    NSString * headplaceholderImage= [self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")];

    cell.headImg.placeholderImage = [UIImage imageNamed:headplaceholderImage];
    NSString * imageids=KISDictionaryHaveKey(tempDict, @"img");
    cell.headImg.imageURL=[ImageService getImageStr:imageids Width:80];
    NSString * nickName=[tempDict objectForKey:@"alias"];
    if ([GameCommon isEmtity:nickName]) {
        nickName=[tempDict objectForKey:@"nickname"];
    }
    cell.chooseImg.image = KUIImage(@"unchoose");
    cell.nameLabel.text = nickName;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddGroupMemberCell*cell = (AddGroupMemberCell*)[m_myTableView cellForRowAtIndexPath:indexPath];
        NSDictionary * tempDict =[[resultDict objectForKey:[keyArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    if (cell.chooseImg.image ==KUIImage(@"unchoose")) {
        cell.chooseImg.image = KUIImage(@"choose");
        [addMemArray addObject:tempDict];
        NSDictionary *dic = tempDict;
        [dic setValue:@(indexPath.section) forKey:@"section"];
        [dic setValue:@(indexPath.row) forKey:@"row"];
    }else{
        cell.chooseImg.image =KUIImage(@"unchoose");
        NSDictionary *dic = tempDict;
        [dic setValue:@(indexPath.section) forKey:@"section"];
        [dic setValue:@(indexPath.row) forKey:@"row"];

        [addMemArray removeObject:dic];
    }
    [m_customCollView reloadData];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
    [UIView commitAnimations];

}
#pragma mark 索引
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    NSString * keyName =[keyArr objectAtIndex:section];
    return keyName;
}
// 返回索引列表的集合
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return keyArr;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 30;
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
    
    cell.imageView.placeholderImage = [UIImage imageNamed:headplaceholderImage];
    NSString * imageids=KISDictionaryHaveKey(tempDict, @"img");
    cell.imageView.imageURL=[ImageService getImageStr:imageids Width:80];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * tempDict =[addMemArray objectAtIndex:indexPath.row];
    NSIndexPath *path = [NSIndexPath indexPathForRow:[[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"row")]intValue] inSection:[[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"section")]intValue]];
    cell1 = (AddGroupMemberCell*)[m_myTableView cellForRowAtIndexPath:path];
        cell1.chooseImg.image = KUIImage(@"unchoose");
    
    [addMemArray removeObject:tempDict];
    [m_customCollView reloadData];
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
    if (addMemArray.count>0) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *dic  in addMemArray) {
            [arr addObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"img")]];
        }
        
        [self updataInfoWithId:[self getImageIdsStr:arr]];
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
-(void)updataInfoWithId:(NSString *)str
{
    [hud show:YES];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.groupId forKey:@"groupId"];
    [paramDict setObject:str forKey:@"userids"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"258" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
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
