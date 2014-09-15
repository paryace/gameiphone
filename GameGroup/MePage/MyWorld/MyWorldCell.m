//
//  MyWorldCell.m
//  GameGroup
//
//  Created by Marss on 14-9-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MyWorldCell.h"
#import "EGOImageView.h"
#import "ImgCollCell.h"
@implementation MyWorldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setSubView];
    }
    return self;
}
- (void)setSubView
{
    // 头像
    self.faceBt = [[EGOImageButton alloc]initWithPlaceholderImage:KUIImage(@"placeholder")];
    self.faceBt.frame = CGRectMake(10, 10, 40, 40);
    self.faceBt.layer.cornerRadius = 5;
    self.faceBt.layer.masksToBounds = YES;
    [self.contentView addSubview:self.faceBt];
    //名字
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 10, 80, 20)];
    self.nameLabel.textColor = UIColorFromRGBA(0x455ca8, 1);
//    self.nameLabel.backgroundColor = [UIColor blueColor];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:13];
    [self.contentView addSubview:self.nameLabel];
    //时间label
    self.timeLabel = [[UILabel alloc]init];
    self.timeLabel.frame = CGRectMake(250, 10, 57, 13);
    self.timeLabel.font = [UIFont systemFontOfSize:11];
    self.timeLabel.textColor = [UIColor grayColor];
//    self.timeLabel.backgroundColor = [UIColor orangeColor];
    [self.contentView addSubview:self.timeLabel];
    //区域label,需要计算高度
    self.areaLabel = [[UILabel alloc]init];
    self.areaLabel.frame = CGRectMake(55, 55, 100, 20);
    self.areaLabel.font = [UIFont systemFontOfSize:10];
//    self.areaLabel.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:self.areaLabel];
    
    //描述label
    self.describLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 33, 250, 100)];
    self.describLabel.numberOfLines = 0;
    self.describLabel.font = [UIFont systemFontOfSize:12];
//    self.describLabel.backgroundColor = [UIColor redColor];
    self.describLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:self.describLabel];
   // 分享与评论的button

    self.openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.openBtn.frame = CGRectMake(270, 60, 50, 30);
//    [self.openBtn addTarget:self action:@selector(openBtnList:) forControlEvents:UIControlEventTouchUpInside];
//    self.openBtn.tag =self.tag;
    [self.contentView addSubview:self.openBtn];
    
    //创建 评论与攒的底层 视图
    self.menuImageView =[[ UIImageView alloc]initWithFrame:CGRectMake(105, 60, 180, 38)];
    self.menuImageView.image = KUIImage(@"bgImg");
    self.menuImageView.userInteractionEnabled = YES;
    self.menuImageView.hidden = YES;
    [self.contentView addSubview:self.menuImageView];
    //创建赞的button
    self.zanBtn=[[ UIButton alloc]initWithFrame:CGRectMake(2, 2, 87, 36)];
    [self.zanBtn setBackgroundImage:KUIImage(@"zan_circle_normal") forState:UIControlStateNormal];
    [self.zanBtn setBackgroundImage:KUIImage(@"zan_circle_click") forState:UIControlStateHighlighted];
    [self.zanBtn addTarget:self action:@selector(zan:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuImageView addSubview:self.zanBtn];
    //创建评论的button
    self.commentBtn=[[ UIButton alloc]initWithFrame:CGRectMake(91, 2, 87, 36)];
    [self.commentBtn setBackgroundImage:KUIImage(@"pinglun_circle_normal") forState:UIControlStateNormal];
    [self.commentBtn setBackgroundImage:KUIImage(@"pinglun_circle_click") forState:UIControlStateHighlighted];
    [self.commentBtn addTarget:self action:@selector(pinglun:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuImageView addSubview:self.commentBtn];
    //collectionView
    self.layout = [[UICollectionViewFlowLayout alloc]init];
    self.layout.minimumInteritemSpacing = 1;
    self.layout.minimumLineSpacing = 1;
    
    self.layout.itemSize = CGSizeMake(80, 80);
    
    self.customPhotoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.customPhotoCollectionView.scrollEnabled = NO;
    self.customPhotoCollectionView.delegate = self;
    self.customPhotoCollectionView.dataSource = self;
    [self.customPhotoCollectionView registerClass:[ImgCollCell class] forCellWithReuseIdentifier:@"ImageCell"];
    self.customPhotoCollectionView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.customPhotoCollectionView];

    
}
+ (CGFloat)getLabelSize:(NSString *)str
{
    NSDictionary * textDic = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0]};
    // 计算introduce文本显示的范围
    CGRect textRect = [str boundingRectWithSize:CGSizeMake(250, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:textDic context:nil];
    //    计算时需要设置一些参数：文本显示的范围（200 , 任意大），文本再计算时字体的大小。
    CGFloat textHight = textRect.size.height;
    return (textHight+70);
}

-(void)openBtnList:(UIButton *)sender
{
//    self.menuImageView.frame = CGRectMake(100, sender.frame.origin.y-18, 180, 38);
//    if (self.myCellDelegate&&[self.myCellDelegate respondsToSelector:@selector(openMenuCell:)]) {
//        [self.myCellDelegate openMenuCell:self];
//    }
    self.menuImageView.hidden = NO;
}
-(void)getImgWithArray:(NSArray *)array
{
    self.collArray = array;
    [self.customPhotoCollectionView reloadData];
}
#pragma mark ---collectionviewdelegate datasourse
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImgCollCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    NSString *url = [self.collArray objectAtIndex:indexPath.row];
    cell.imageView.imageURL =[ImageService getImageUrl3:url Width:160];
    return cell;
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
