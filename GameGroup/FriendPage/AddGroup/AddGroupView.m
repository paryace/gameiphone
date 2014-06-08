//
//  AddGroupView.m
//  GameGroup
//
//  Created by 魏星 on 14-6-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "AddGroupView.h"

@implementation AddGroupView
{
    UICollectionViewFlowLayout *layout;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.scrollView.scrollEnabled = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.contentSize = CGSizeMake(kScreenWidth *3, 0);
        [self addSubview:self.scrollView];
        
        [self buildFirstView];
        [self buildSecondView];
        [self buildThirdView];
    }
    return self;
}

-(void)buildFirstView
{
    self.firstScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.firstScrollView.showsHorizontalScrollIndicator = NO;
    self.firstScrollView.showsVerticalScrollIndicator = NO;
    self.firstScrollView.contentSize = CGSizeMake(0,150+kScreenHeigth);
    [self.scrollView addSubview:self.firstScrollView];

    self.topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 220)];
    self.topImageView .backgroundColor = [UIColor grayColor];
    [self.firstScrollView addSubview:self.topImageView];
    
    
    UILabel *lb1 =[[UILabel alloc]initWithFrame:CGRectMake(20, 230, 200, 10)];
    lb1.text = @"选择游戏";
    lb1.backgroundColor = [UIColor clearColor];
    lb1.textColor = [UIColor grayColor];
    lb1.font = [UIFont systemFontOfSize:10];
    [self.firstScrollView addSubview:lb1];
    
    self.gameTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 250, 320, 30)];
    self.gameTextField.textColor = [UIColor blackColor];
    self.gameTextField.delegate = self;
    self.gameTextField.font = [UIFont systemFontOfSize:13];
    self.gameTextField.backgroundColor = [UIColor whiteColor];
    [self.firstScrollView addSubview:self.gameTextField];
    
    UILabel *lb2 =[[UILabel alloc]initWithFrame:CGRectMake(20, 290, 200, 10)];
    lb2.text = @"选择服务器";
    lb2.backgroundColor = [UIColor clearColor];
    lb2.textColor = [UIColor grayColor];
    lb2.font = [UIFont systemFontOfSize:10];
    [self.firstScrollView addSubview:lb2];
    
    self.realmTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 310, 320, 30)];
    self.realmTextField.textColor = [UIColor blackColor];
    self.realmTextField.font = [UIFont systemFontOfSize:13];
    self.realmTextField.backgroundColor = [UIColor whiteColor];
    [self.firstScrollView addSubview: self.realmTextField];
    
    self.groupNameTf = [[UITextField alloc]initWithFrame:CGRectMake(0, 370, 320, 30)];
    self.groupNameTf.textColor = [UIColor blackColor];
    self.groupNameTf.font = [UIFont systemFontOfSize:13];
    self.groupNameTf.backgroundColor = [UIColor whiteColor];
    [self.firstScrollView addSubview: self.groupNameTf];
    
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 420, 320, 30)];
    [button setTitle:@"下一步" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor grayColor];
    [button addTarget:self action:@selector(playNextGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.firstScrollView addSubview:button];

}
-(void)buildSecondView
{
    self.secondScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(320, 0, self.bounds.size.width, self.bounds.size.height)];
    self.secondScrollView.showsHorizontalScrollIndicator = NO;
    self.secondScrollView.showsVerticalScrollIndicator = NO;
    self.secondScrollView.contentSize = CGSizeMake(0,150+kScreenHeigth);
    [self.scrollView addSubview:self.secondScrollView];
   
    
    
    
    self.cardTF =[[UITextField alloc]initWithFrame:CGRectMake(0, 10, 320, 40)];
    self.cardTF.userInteractionEnabled = NO;
    self.cardTF.textColor = [UIColor grayColor];
    self.cardTF.backgroundColor = [UIColor clearColor];
    self.cardTF.font = [UIFont systemFontOfSize:12];
    [self.secondScrollView addSubview:self.cardTF];
    
    layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing =1;
    layout.sectionInset = UIEdgeInsetsMake(1,1, 1, 1);
    layout.itemSize = CGSizeMake(80, 20);

    // 3.设置整个collectionView的内边距
    
    // [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(comeBackMenuView:)]];
    
    UICollectionView * customPhotoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 50, 320, 400) collectionViewLayout:layout];
     customPhotoCollectionView.scrollEnabled = NO;
    customPhotoCollectionView.delegate = self;
    customPhotoCollectionView.dataSource = self;
    [customPhotoCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ImageCell"];
    customPhotoCollectionView.backgroundColor = [UIColor clearColor];
    [self.secondScrollView addSubview:customPhotoCollectionView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 460, 320, 40);
    [button setTitle:@"next" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(enterThirdPage:) forControlEvents:UIControlEventTouchUpInside];
    [self.secondScrollView addSubview:button];
    
}

-(void)buildThirdView
{
    self.thirdScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(640, 0, self.bounds.size.width, self.bounds.size.height)];
    self.thirdScrollView.showsHorizontalScrollIndicator = NO;
    self.thirdScrollView.showsVerticalScrollIndicator = NO;
    self.thirdScrollView.contentSize = CGSizeMake(0,150+kScreenHeigth);
    [self.scrollView addSubview:self.thirdScrollView];

}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    UILabel *label  = [[UILabel alloc]initWithFrame:cell.frame];
    label.text = [NSString stringWithFormat:@"%d",indexPath.row];
    label .textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:13];
    [cell addSubview:label];
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)playNextGame:(id)sender
{
    self.scrollView.contentOffset = CGPointMake(320, 0);
}
-(void)enterThirdPage:(id)sender
{
    self.scrollView.contentOffset = CGPointMake(640, 0);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
