//
//  NewNearByCell.m
//  GameGroup
//
//  Created by 魏星 on 14-5-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewNearByCell.h"
#import "ImgCollCell.h"
@implementation NewNearByCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.headImgBtn = [[EGOImageButton alloc]initWithPlaceholderImage:KUIImage(@"placeholder.png")];
        self.headImgBtn.frame = CGRectMake(10, 10, 40, 40);
        [self.contentView addSubview:self.headImgBtn];
        
        self.focusButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 60, 40, 20)];
        [self.focusButton setTitle:@"关注" forState:UIControlStateNormal];
        self.focusButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [self.focusButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.contentView addSubview:self.focusButton];
        
        self.nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 120, 20)];
        self.nickNameLabel.textColor = UIColorFromRGBA(0x455ca8, 1);
        self.nickNameLabel.backgroundColor = [UIColor clearColor];
        self.nickNameLabel.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:self.nickNameLabel];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 27, 170, 30)];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.titleLabel.numberOfLines=0;
        [self.contentView addSubview:self.titleLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 60, 130, 30)];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.textColor =[UIColor grayColor];
        [self.contentView addSubview:self.timeLabel];
        
        self.shareView = [[UIButton alloc]initWithFrame:CGRectMake(60, 60, 250, 50)];
        self.shareView.backgroundColor = UIColorFromRGBA(0xf0f1f3, 1);
        [self addSubview:self.shareView];
        
        self.shareImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
        self.shareImageView.placeholderImage = KUIImage(@"placeholder");
        [self.shareView addSubview:self.shareImageView];

        self.shareInfoLabel= [[UILabel alloc]initWithFrame:CGRectMake(50, 5, 190, 40)];
        self.shareInfoLabel.font = [UIFont systemFontOfSize:12];
        self.shareInfoLabel.backgroundColor =[UIColor clearColor];
        self.shareInfoLabel.numberOfLines =2;
        [self.shareView addSubview:self.shareInfoLabel];
        self.shareView.hidden = YES;
        
        self.layout = [[UICollectionViewFlowLayout alloc]init];
        self.layout.minimumInteritemSpacing = 1;
        self.layout.minimumLineSpacing = 1;
        CGFloat paddingY = 2;
        CGFloat paddingX = 2;
        self.layout.sectionInset = UIEdgeInsetsMake(paddingY, paddingX, paddingY, paddingX);
        self.layout.minimumLineSpacing = paddingY;

        self.layout.itemSize = CGSizeMake(80, 80);
        
        self.photoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.layout];
        self.photoCollectionView.scrollEnabled = NO;
        self.photoCollectionView.delegate = self;
        self.photoCollectionView.dataSource = self;
        [self.photoCollectionView registerClass:[ImgCollCell class] forCellWithReuseIdentifier:@"ImageCell"];
        self.photoCollectionView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoCollectionView];
    }
    return self;
}

+ (CGSize)getContentHeigthWithStr:(NSString*)contStr
{
    CGSize cSize = [contStr sizeWithFont:[UIFont boldSystemFontOfSize:12.0] constrainedToSize:CGSizeMake(245, 300) lineBreakMode:NSLineBreakByWordWrapping];
    return cSize;
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
    NSString *address =[NSString stringWithFormat:@"%@%@%@",BaseImageUrl, url,@"/160/160"];
    NSURL *urls;
    urls = [NSURL URLWithString:address];
    cell.imageView.imageURL =urls;
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.myCellDelegate &&[self.myCellDelegate respondsToSelector:@selector(bigImgWithCircle:WithIndexPath:)]) {
        [self.myCellDelegate  bigImgWithCircle:self WithIndexPath:indexPath.row];
    }
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
