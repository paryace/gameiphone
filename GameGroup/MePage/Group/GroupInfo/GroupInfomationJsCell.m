//
//  GroupInfomationJsCell.m
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupInfomationJsCell.h"
#import "ImgCollCell.h"
@implementation GroupInfomationJsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 20)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.titleLabel];
        
        self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 50, 20)];
        self.contentLabel.font = [UIFont boldSystemFontOfSize:13];
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.textAlignment = NSTextAlignmentLeft;
        self.contentLabel.numberOfLines = 0;
        [self.contentView addSubview:self.contentLabel];
        
        self.layout = [[UICollectionViewFlowLayout alloc]init];
        
        self.layout.minimumInteritemSpacing = 1;
        self.layout.minimumLineSpacing = 2;
        self.layout.itemSize = CGSizeMake(68, 68);
        self.photoView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.layout];
        self.photoView.scrollEnabled = NO;
        self.photoView.delegate = self;
        self.photoView.dataSource = self;
        [self.photoView registerClass:[ImgCollCell class] forCellWithReuseIdentifier:@"ImageCell"];
        self.photoView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.photoView];
        [self.photoView reloadData];

        
    }
    return self;
}
#pragma mark ---collectionviewdelegate datasourse
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImgCollCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    NSString *url = [self.photoArray objectAtIndex:indexPath.row];
    cell.imageView.imageURL =[ImageService getImageUrl3:url Width:136];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.myCellDelegate &&[self.myCellDelegate respondsToSelector:@selector(bigImgWithCircle:WithIndexPath:)]) {
        [self.myCellDelegate  bigImgWithCircle:self WithIndexPath:indexPath.row];
    }
}

@end
