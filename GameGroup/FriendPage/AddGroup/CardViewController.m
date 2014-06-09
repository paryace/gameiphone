//
//  CardViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CardViewController.h"
#import "CardCell.h"
@interface CardViewController ()
{
    UICollectionViewFlowLayout *layout;
    UICollectionView *customPhotoCollectionView;
    NSMutableArray *cardArray;
    NSMutableArray *numArray;
    CardCell *msxCell;
}
@end

@implementation CardViewController

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
    
    [self setTopViewWithTitle:@"标签" withBackButton:YES];
    
    UIButton *okbutton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [okbutton setBackgroundImage:KUIImage(@"share_normal.png") forState:UIControlStateNormal];
    [okbutton setBackgroundImage:KUIImage(@"share_click.png") forState:UIControlStateHighlighted];
    okbutton.backgroundColor = [UIColor clearColor];
    [okbutton addTarget:self action:@selector(successClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okbutton];
    

    cardArray = [NSMutableArray  array];
    numArray =[NSMutableArray array];
    layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing =10;
    layout.sectionInset = UIEdgeInsetsMake(70,0, 0, 0);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //    layout.itemSize = CGSizeMake(60, 15);
    
    // 3.设置整个collectionView的内边距
    
    // [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(comeBackMenuView:)]];
    
    customPhotoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, startX +30, 300, 500) collectionViewLayout:layout];
    customPhotoCollectionView.backgroundColor = [UIColor blackColor];
    customPhotoCollectionView.scrollEnabled = NO;
    customPhotoCollectionView.delegate = self;
    customPhotoCollectionView.dataSource = self;
    [customPhotoCollectionView registerClass:[CardCell class] forCellWithReuseIdentifier:@"ImageCell"];
    customPhotoCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:customPhotoCollectionView];
    
    
    

    // Do any additional setup after loading the view.
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
        NSArray *array = [self.listDict allKeys];
        NSDictionary *dic = [[self.listDict objectForKey:[array objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row];
        CGSize size = [KISDictionaryHaveKey(dic, @"tagName") sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
        return CGSizeMake(size.width+10, 30);
    
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
        NSArray *array = [self.listDict allKeys];
        UICollectionReusableView *header = [[UICollectionReusableView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
        header.backgroundColor = [UIColor greenColor];
        if([kind isEqual:UICollectionElementKindSectionHeader]){
            header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 300, 20)];
            label.text = array[indexPath.section];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor grayColor];
            [header addSubview:label];
        }
        return header;
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
    cell.bgImgView.image = KUIImage(@"card_click_no");
    cell.tag = indexPath.section*1000+indexPath.row;
    cell.backgroundColor = [UIColor redColor];
    NSArray *keysArray = [self.listDict allKeys];
    NSDictionary* dic = [[self.listDict objectForKey:[keysArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    CGSize size = [KISDictionaryHaveKey(dic, @"tagName") sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
    cell.titleLabel.frame = CGRectMake(0, 0, size.width+5, 30);
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
        cell.bgImgView.image = KUIImage(@"card_click_no");
    }else{
        if (cardArray.count==3) {
            [self showAlertViewWithTitle:@"提示" message:@"您最多只能选择3个标签" buttonTitle:@"确定"];
            return;
        }

        [numArray addObject:@(indexPath.section*10000+indexPath.row)];
        [cardArray addObject:dic];
        cell.bgImgView.image = KUIImage(@"card_click_yes");
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
