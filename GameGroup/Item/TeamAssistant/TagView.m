//
//  TagView.m
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TagView.h"

@implementation TagView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _layout = [[UICollectionViewFlowLayout alloc]init];
        _layout.minimumInteritemSpacing = 10;
        _layout.minimumLineSpacing =10;
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _layout.itemSize = CGSizeMake(88, 30);
        _customPhotoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10.0f, 10, 300, frame.size.height-20) collectionViewLayout:_layout];
        _customPhotoCollectionView.delegate = self;
        _customPhotoCollectionView.scrollEnabled = YES;
        _customPhotoCollectionView.showsHorizontalScrollIndicator = NO;
        _customPhotoCollectionView.showsVerticalScrollIndicator = NO;
        _customPhotoCollectionView.dataSource = self;
        _customPhotoCollectionView.hidden = YES;
        _customPhotoCollectionView.backgroundColor = [UIColor redColor];
        [_customPhotoCollectionView registerClass:[TagCell class] forCellWithReuseIdentifier:@"ImageCell"];
        _customPhotoCollectionView.backgroundColor = [UIColor clearColor];;
        [self addSubview:_customPhotoCollectionView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenSelf)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];

    }
    return self;
}

-(void)setDate:(NSMutableArray*)typeArray{
    _tagArray=typeArray;
    [self resetTableFrame];
}

-(void)resetTableFrame{
    _customPhotoCollectionView.hidden =NO;
    [_customPhotoCollectionView reloadData];
}

-(void)hiddenSelf
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0f;
        self.alpha = 0.2f;
        
    }completion:^(BOOL finished) {
        self.hidden=  YES;
    }];
    
}
-(void)showSelf
{
    self.hidden=  NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.2f;
        self.alpha = 1.0f;
    }completion:^(BOOL finished) {
    }];
    
}

#pragma mark - text view delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _tagArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TagCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.delegate = self;
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    cell.titleLabel.text =  KISDictionaryHaveKey([_tagArray objectAtIndex:indexPath.row], @"value");
    cell.titleLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mark - 点击标签
-(void)tagOnClick:(TagCell*)sender{
     [self hiddenSelf];
    NSMutableDictionary * tagDic = [_tagArray objectAtIndex:sender.tag];
    if (self.tagDelegate) {
        [self.tagDelegate tagType:tagDic];
    }
}
@end
