//
//  CardViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CardViewController.h"
#import "CardCell.h"
#import "CardTitleView.h"
@interface CardViewController ()
{
    UICollectionViewFlowLayout *layout;
    UICollectionView *customPhotoCollectionView;
    NSMutableArray *cardArray;
    NSMutableArray *numArray;
    CardCell *msxCell;
    NSMutableArray *allkeysArr;
}
@end

@implementation CardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"群分类" withBackButton:YES];
    
    UIButton *okbutton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [okbutton setBackgroundImage:KUIImage(@"ok_normal") forState:UIControlStateNormal];
    [okbutton setBackgroundImage:KUIImage(@"ok_click") forState:UIControlStateHighlighted];
    okbutton.backgroundColor = [UIColor clearColor];
    [okbutton addTarget:self action:@selector(successClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okbutton];
    

    cardArray = [NSMutableArray  array];
    numArray =[NSMutableArray array];
    layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing =10;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.headerReferenceSize = CGSizeMake(300, 40);
    layout.itemSize = CGSizeMake(88, 30);
    customPhotoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, startX, 300, kScreenHeigth-startX) collectionViewLayout:layout];
    customPhotoCollectionView.backgroundColor = [UIColor blackColor];
    customPhotoCollectionView.delegate = self;
    customPhotoCollectionView.showsHorizontalScrollIndicator = NO;
    customPhotoCollectionView.showsVerticalScrollIndicator = NO;
    customPhotoCollectionView.dataSource = self;
    [customPhotoCollectionView registerClass:[CardCell class] forCellWithReuseIdentifier:@"ImageCell"];
    [customPhotoCollectionView registerClass:[CardTitleView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headViewww"];
    customPhotoCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:customPhotoCollectionView];
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"正在加载数据...";
    [self getCardWithNetWithDic:self.infoDict];
}

-(void)getCardWithNetWithDic:(NSMutableDictionary*)dict
{
    [hud show:YES];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"236" forKey:@"method"];
    [postDict setObject:dict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            self.listDict  = responseObject;
            [self.listDict removeObjectForKey:@"sortList"];
            
            
            [customPhotoCollectionView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}



//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
//{
//        NSArray *array = [self.listDict allKeys];
//        NSDictionary *dic = [[self.listDict objectForKey:[array objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row];
//        CGSize size = [KISDictionaryHaveKey(dic, @"tagName") sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
//        return CGSizeMake(size.width+10, 30);
//    
//}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *titleView;
    
    if (kind == UICollectionElementKindSectionHeader) {
        titleView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headViewww" forIndexPath:indexPath];
        ((CardTitleView *)titleView).cardTitleLabel.text =[allkeysArr objectAtIndex:indexPath.section];
    }
    return titleView;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.listDict allKeys].count;
        
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
        NSArray *keyArray = [self.listDict allKeys];
        NSArray *array = [self.listDict objectForKey:[keyArray objectAtIndex:section]];
        return array.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CardCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.bgImgView.image = KUIImage(@"card_show");
    cell.tag = indexPath.section*1000+indexPath.row;
    NSArray *keysArray = [self.listDict allKeys];
    NSDictionary* dic = [[self.listDict objectForKey:[keysArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
//    CGSize size = [KISDictionaryHaveKey(dic, @"tagName") sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
//    cell.titleLabel.frame = CGRectMake(0, 0, size.width+5, 30);
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    cell.titleLabel.text = KISDictionaryHaveKey(dic, @"tagName");
    return cell;
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CardCell*cell = (CardCell*)[customPhotoCollectionView cellForItemAtIndexPath:indexPath];

    NSArray *array = [self.listDict allKeys];
    NSDictionary *dic = [[self.listDict objectForKey:array[indexPath.section] ]objectAtIndex:indexPath.row];
    
    if ([numArray containsObject:@(indexPath.section *10000+indexPath.row)]) {
        NSString *dicStr = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"tagId")];
        for (int i =0;i<cardArray.count;i++ ) {
            NSDictionary *dict = cardArray[i];
//            if ([KISDictionaryHaveKey(dic, @"tagId")intValue]==[KISDictionaryHaveKey(dict, @"tagId") intValue ]) {
            NSString *dictStr = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dict, @"tagId")];
            if ([dicStr isEqualToString:dictStr]) {
                [cardArray removeObject:dict];
            }
        }
        [numArray removeObject:@(indexPath.section *10000+indexPath.row)];
        cell.titleLabel.textColor  = [UIColor blackColor];

        cell.bgImgView.image = KUIImage(@"card_show");
    }else{
        if (cardArray.count==3) {
            [self showAlertViewWithTitle:@"提示" message:@"您最多只能选择3个标签" buttonTitle:@"确定"];
            return;
        }

        [numArray addObject:@(indexPath.section*10000+indexPath.row)];
        [cardArray addObject:dic];
        cell.titleLabel.textColor  = [UIColor whiteColor];
        cell.bgImgView.image = KUIImage(@"card_click");
    }
    
    
//    if (cardArray.count>0) {
//        for (int i =0;i<cardArray.count;i++) {
//            NSDictionary *dict = cardArray[i];
//           [dic setValue:@(10000*indexPath.section+indexPath.row) forKey:@"indexx"];
//            if ([KISDictionaryHaveKey(dict, @"tagId")intValue]==[KISDictionaryHaveKey(dic, @"tagId")intValue]) {
//                cell.backgroundColor = [UIColor grayColor];
//                [cardArray removeObject:dict];
//                NSLog(@"11111111");
//
//            }else{
//                [cardArray addObject:dic];
//                cell.backgroundColor = [UIColor greenColor];
//                NSLog(@"222222222");
//
//            }
//        }
//    }else{
//        [cardArray addObject:dic];
//        cell.titleLabel.backgroundColor = [UIColor greenColor];
//        NSLog(@"333333333");
//
//    }
    
 
}
-(void)successClick:(id)sender
{
    [self.myDelegate senderCkickInfoWithDel:self array:cardArray];
    [self.navigationController popViewControllerAnimated:YES];
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
