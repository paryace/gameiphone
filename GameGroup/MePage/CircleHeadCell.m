//
//  CircleHeadCell.m
//  GameGroup
//
//  Created by 魏星 on 14-4-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CircleHeadCell.h"
#import "FinderView.h"
#import "ImgCollCell.h"
@interface CircleHeadCell(){
    int nickNameLenght;
}
@end
@implementation CircleHeadCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
         self.headImgBtn = [[EGOImageButton alloc]initWithPlaceholderImage:KUIImage(@"placeholder.png")];
        self.headImgBtn.frame = CGRectMake(10, 10, 40, 40);
    
        [self.contentView addSubview:self.headImgBtn];
        
        self.nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 120, 20)];
        self.nickNameLabel.textColor = UIColorFromRGBA(0x455ca8, 1);
        self.nickNameLabel.backgroundColor = [UIColor clearColor];
        self.nickNameLabel.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:self.nickNameLabel];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 27, 170, 30)];
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        self.titleLabel.numberOfLines=0;
        [self addSubview:self.titleLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 60, 130, 30)];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.textColor =[UIColor grayColor];
        [self.contentView addSubview:self.timeLabel];
        
        self.delBtn = [[UIButton alloc]initWithFrame:CGRectMake(180, 60, 50, 30)];
        [self.delBtn setTitle:@"删除" forState:UIControlStateNormal];
        [self.delBtn setTitleColor:UIColorFromRGBA(0x455ca8, 1) forState:UIControlStateNormal];
        self.delBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.delBtn addTarget:self action:@selector(delCell:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.delBtn];
        
        
        self.shareView = [[UIView alloc]initWithFrame:CGRectMake(60, 60, 250, 50)];
        self.shareView.backgroundColor = UIColorFromRGBA(0xf0f1f3, 1);
        [self addSubview:self.shareView];
        self.shareImgView = [[EGOImageView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
        self.shareImgView.placeholderImage = KUIImage(@"placeholder");
        [self.shareView addSubview:self.shareImgView];
        
        self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 190, 40)];
        self.contentLabel.font = [UIFont systemFontOfSize:12];
        self.contentLabel.numberOfLines = 2;
        self.contentLabel.backgroundColor = [UIColor clearColor];
        [self.shareView addSubview:self.contentLabel];
     
       self.oneImageView  = [[EGOImageView alloc]initWithFrame:CGRectMake(60, 100, 100, 100)];
        self.oneImageView.hidden = YES;
        self.oneImageView.delegate = self;
        [self.contentView addSubview:self.oneImageView];
        
        CGSize size = [CircleHeadCell getContentHeigthWithStr:self.commentStr];
        self.titleLabel.frame = CGRectMake(60, 27, 170, size.height);
        
        
        self.layout = [[UICollectionViewFlowLayout alloc]init];
        self.layout.minimumInteritemSpacing = 1;
        self.layout.minimumLineSpacing = 1;
        //self.layout.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1);

        // 3.设置整个collectionView的内边距
       
       // [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(comeBackMenuView:)]];
        self.layout.itemSize = CGSizeMake(80, 80);
        
        self.customPhotoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.layout];
        self.customPhotoCollectionView.scrollEnabled = NO;
        self.customPhotoCollectionView.delegate = self;
        self.customPhotoCollectionView.dataSource = self;
        [self.customPhotoCollectionView registerClass:[ImgCollCell class] forCellWithReuseIdentifier:@"ImageCell"];
        self.customPhotoCollectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.customPhotoCollectionView];
        
        
        
        self.zanView = [[UIImageView alloc]initWithFrame:CGRectMake(60, 100, 250, 30)];
        self.zanView.image = KUIImage(@"zanAndCommentBg");
        [self.contentView addSubview:self.zanView];
        
        self.zanImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 10, 10, 10)];
        self.zanImageView.image = KUIImage(@"zan_circle");
        [self.zanView addSubview:self.zanImageView];
        
        self.zanNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 30)];
        self.zanNameLabel.textColor = UIColorFromRGBA(0x455cab, 1);
        self.zanNameLabel.font = [UIFont boldSystemFontOfSize:12];
        self.zanNameLabel.backgroundColor = [UIColor clearColor];
        [self.zanView addSubview:self.zanNameLabel];
        
        self.zanLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 0, 100, 30)];
        self.zanLabel.textColor = [UIColor grayColor];
        self.zanLabel.font = [UIFont boldSystemFontOfSize:12];
        [self.zanView addSubview:self.zanLabel];
    

        self.commentTabelView = [[UITableView alloc]initWithFrame:CGRectMake(60, 100, 255, 50) style:UITableViewStylePlain];
        self.commentTabelView.delegate = self;
        self.commentTabelView.dataSource = self;
        self.commentTabelView.bounces = NO;
        self.commentTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.commentTabelView.scrollEnabled = NO;
        [self.contentView addSubview:self.commentTabelView];
        
        //展开菜单“。。。”
        self.openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.openBtn.frame = CGRectMake(270, 60, 50, 30);
        [self.openBtn setBackgroundImage:KUIImage(@"add_click") forState:UIControlStateNormal];
        [self.openBtn addTarget:self action:@selector(openBtnList:) forControlEvents:UIControlEventTouchUpInside];
        self.openBtn.tag =self.tag;
        [self.contentView addSubview:self.openBtn];
        
        
        self.menuImageView =[[ UIImageView alloc]initWithFrame:CGRectMake(105, 60, 180, 38)];
        self.menuImageView.image = KUIImage(@"bgImg");
        self.menuImageView.userInteractionEnabled = YES;
        self.menuImageView.hidden = YES;
        [self addSubview:self.menuImageView];

        
        self.zanBtn=[[ UIButton alloc]initWithFrame:CGRectMake(2, 2, 87, 36)];
        [self.zanBtn setBackgroundImage:KUIImage(@"zan_circle_normal") forState:UIControlStateNormal];
        [self.zanBtn setBackgroundImage:KUIImage(@"zan_circle_click") forState:UIControlStateHighlighted];
        [self.zanBtn addTarget:self action:@selector(zan:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuImageView addSubview:self.zanBtn];
        
        self.commentBtn=[[ UIButton alloc]initWithFrame:CGRectMake(91, 2, 87, 36)];
        [self.commentBtn setBackgroundImage:KUIImage(@"pinglun_circle_normal") forState:UIControlStateNormal];
        [self.commentBtn setBackgroundImage:KUIImage(@"pinglun_circle_click") forState:UIControlStateHighlighted];
        [self.commentBtn addTarget:self action:@selector(pinglun:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuImageView addSubview:self.commentBtn];
        
        self.commentMoreBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 0, 250, 20)];
        [self.commentMoreBtn setTitle:@"查看更多评论" forState:UIControlStateNormal];
        [self.commentMoreBtn setTitleColor: UIColorFromRGBA(0x455ca8, 1) forState:UIControlStateNormal];
        self.commentMoreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.commentMoreBtn addTarget:self action:@selector(loadMoreComment:) forControlEvents:UIControlEventTouchUpInside];
        self.commentMoreBtn .backgroundColor = UIColorFromRGBA(0xf0f1f3, 1);
        self.commentMoreBtn.hidden =YES;
        [self.contentView addSubview:self.commentMoreBtn];
    }
    return self;
}

//隐藏评论赞button
-(void)comeBackMenuView:(UIGestureRecognizer *)sender
{
    self.menuImageView.hidden =YES;
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
    NSString *address =[GameCommon isNewOrOldWithImage:url width:140 hieght:140 a:@"140/140"];
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

#pragma mark-- tableviewdelegate  datasourse

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return self.commentArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *identifier  = @"cell1";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CommentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.backgroundColor = UIColorFromRGBA(0xf0f1f3, 1);
    cell.accessoryType = UITableViewCellAccessoryNone;

        //cell.selectionStyle =UITableViewCellSelectionStyleNone;
        cell.tag = indexPath.row;
        NSDictionary *dict = [self.commentArray objectAtIndex:indexPath.row];
        
            cell.comNickNameStr =[KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"nickname")stringByAppendingString:@":"];
            nickNameLenght=[cell.comNickNameStr length];
            
        cell.commentStr =[cell.comNickNameStr stringByAppendingString: KISDictionaryHaveKey(dict, @"comment")];
        
        NSMutableAttributedString *stratt = [[NSMutableAttributedString alloc] initWithString:cell.commentStr];
        [stratt addAttribute:NSForegroundColorAttributeName value: UIColorFromRGBA(0x455ca8, 1) range:NSMakeRange(0,nickNameLenght)];
        cell.commentContLabel.attributedText = stratt;
        
        //    cell.commentContLabel.text =cell.commentStr;
        
        [cell  refreshsCell];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        tableView =self.commentTabelView;
        if (self.myCellDelegate &&[self.myCellDelegate respondsToSelector:@selector(editCommentOfYouWithCircle:withIndexPath:)]) {
            [self.myCellDelegate editCommentOfYouWithCircle:self withIndexPath:indexPath.row];
            NSLog(@"----%d",indexPath.row);
        }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *dic = [self.commentArray objectAtIndex:indexPath.row];
    NSString *str;
    str =[KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"commentUser"), @"nickname") stringByAppendingString:@":"];
    CGSize  size = [CommentCell getCellHeigthWithStr:[str stringByAppendingString: KISDictionaryHaveKey(dic, @"comment")]];
    return size.height+5;
    
}

-(void)loadMoreComment:(UIButton *)sender
{
    if (self.myCellDelegate &&[self.myCellDelegate respondsToSelector:@selector(enterCommentPageWithCell:)]) {
        [self.myCellDelegate enterCommentPageWithCell:self];
    }
}

-(void)openBtnList:(UIButton *)sender
{
    self.menuImageView.frame = CGRectMake(100, sender.frame.origin.y-18, 180, 38);
    if (self.myCellDelegate&&[self.myCellDelegate respondsToSelector:@selector(openMenuCell:)]) {
        [self.myCellDelegate openMenuCell:self];
    }
}

-(void)hidenMenuView:(UIGestureRecognizer *)sender
{
    self.menuImageView.hidden = YES;
}
//赞点击事件
-(void)zan:(UIButton *)sender
{
    if (self.myCellDelegate&&[self.myCellDelegate respondsToSelector:@selector(zanWithCircle:)]) {
            [self.myCellDelegate zanWithCircle:self];
    }
}
//评论点击事件
-(void)pinglun:(UIButton *)sender
{
    if (self.myCellDelegate&&[self.myCellDelegate respondsToSelector:@selector(pinglunWithCircle:)]) {
            [self.myCellDelegate pinglunWithCircle:self];
    }
}

+ (CGSize)getContentHeigthWithStr:(NSString*)contStr
{
    CGSize cSize = [contStr sizeWithFont:[UIFont boldSystemFontOfSize:12.0] constrainedToSize:CGSizeMake(245, 300) lineBreakMode:NSLineBreakByWordWrapping];
    return cSize;
}

-(void)delCell:(UIButton *)sender
{
    if (self.myCellDelegate && [self.myCellDelegate respondsToSelector:@selector(delCellWithCell:)]) {
        [self.myCellDelegate delCellWithCell:self];
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
