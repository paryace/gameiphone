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
bool str_endwith(const char* str, const char c)
{
    return *(str + strlen(str) - 1) == c;
}
@implementation CircleHeadCell
{
}
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
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.titleLabel.numberOfLines=0;
        [self addSubview:self.titleLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 60, 130, 30)];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.textColor =kColorWithRGB(41, 164, 246, 1.0);
        [self.contentView addSubview:self.timeLabel];
        
        self.shareView = [[UIView alloc]initWithFrame:CGRectMake(60, 60, 250, 50)];
        self.shareView.backgroundColor = UIColorFromRGBA(0xf0f1f3, 1);
        [self addSubview:self.shareView];
        self.shareImgView = [[EGOImageView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
        self.shareImgView.placeholderImage = KUIImage(@"placeholder");
        [self.shareView addSubview:self.shareImgView];
        
        self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 190, 40)];
        self.contentLabel.font = [UIFont systemFontOfSize:10];
        self.contentLabel.numberOfLines = 2;
        self.contentLabel.backgroundColor = [UIColor clearColor];
        [self.shareView addSubview:self.contentLabel];
     
        
        self.openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.openBtn.frame = CGRectMake(270, 60, 50, 30);
        [self.openBtn setBackgroundImage:KUIImage(@"add_click") forState:UIControlStateNormal];
        [self.openBtn addTarget:self action:@selector(openBtnList:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.openBtn];
        
        self.menuImageView =[[ UIImageView alloc]initWithFrame:CGRectMake(85, 60, 190, 42)];
        self.menuImageView.image = KUIImage(@"bgImg");
        self.menuImageView.userInteractionEnabled = YES;
        self.menuImageView.hidden = YES;
        [self.contentView addSubview:self.menuImageView];
        
        CGSize size = [CircleHeadCell getContentHeigthWithStr:self.commentStr];
        self.titleLabel.frame = CGRectMake(60, 27, 170, size.height);
        

        
        self.layout = [[UICollectionViewFlowLayout alloc]init];
        self.layout.minimumInteritemSpacing = 1;
        self.layout.minimumLineSpacing = 1;
        //self.layout.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1);
        if (self.collArray.count==1) {
            self.layout.itemSize = CGSizeMake(250, 180);
        }
        else if(self.collArray.count==2)
        {
            self.layout.itemSize = CGSizeMake(110, 100);
        }
        else
        {
            self.layout.itemSize = CGSizeMake(70, 70);
        }

        // 3.设置整个collectionView的内边距
       
       // [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(comeBackMenuView:)]];
        
        
        self.customPhotoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.layout];
        self.customPhotoCollectionView.scrollEnabled = NO;
        self.customPhotoCollectionView.delegate = self;
        self.customPhotoCollectionView.dataSource = self;
        [self.customPhotoCollectionView registerClass:[ImgCollCell class] forCellWithReuseIdentifier:@"ImageCell"];
        self.customPhotoCollectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.customPhotoCollectionView];
        
        
        NSArray *array = [NSArray arrayWithObjects:@"zan_circle_normal",@"pinglun_circle_normal", nil];
        NSArray *array1 = [NSArray arrayWithObjects:@"zan_circle_click",@"pinglun_circle_click", nil];
        for (int i =0; i<2; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(5+92*i, 5, 87, 32);
            [button setBackgroundImage:KUIImage([array objectAtIndex:i]) forState:UIControlStateNormal];
            [button setBackgroundImage:KUIImage([array1 objectAtIndex:i]) forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(pinglunAndZan:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = 100+i;
            [self.menuImageView addSubview:button];
        }
        
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
        [self.contentView addSubview:self.commentTabelView];
        
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
    NSString *address =[GameCommon isNewOrOldWithImage:url width:140 hieght:140 a:140];
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
    cell.tag = indexPath.row;
    NSDictionary *dict = [self.commentArray objectAtIndex:indexPath.row];
    cell.nicknameLabel.text =[KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"nickname") stringByAppendingString:@":"];
    cell.commentContLabel.text = KISDictionaryHaveKey(dict, @"comment");
    cell.comNickNameStr =KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"nickname");
    cell.commentStr = KISDictionaryHaveKey(dict, @"comment");
    [cell  refreshCell];
    cell.backgroundColor = UIColorFromRGBA(0xf0f1f3, 1);
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView =self.commentTabelView;
    if (self.myCellDelegate &&[self.myCellDelegate respondsToSelector:@selector(editCommentOfYouWithCircle:withIndexPath:)]) {
        [self.myCellDelegate editCommentOfYouWithCircle:self withIndexPath:indexPath.row];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.commentArray objectAtIndex:indexPath.row];
    CGSize  size = [CommentCell getcommentHeigthWithNIckNameStr:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"commentUser"), @"nickname") Commentstr:KISDictionaryHaveKey(dic, @"comment")];
    return size.height+5;
}



-(void)openBtnList:(UIButton *)sender
{
    if (self.menuImageView.hidden==YES) {
        self.menuImageView.hidden =NO;
        [self.contentView bringSubviewToFront:self.menuImageView];
        self.menuImageView.frame = CGRectMake(80, sender.frame.origin.y, 190, 42);
        [self becomeFirstResponder];
    }else
    self.menuImageView.hidden =YES;
}

-(void)pinglunAndZan:(UIButton *)sender
{
    if (sender.tag ==100) {
        if (self.myCellDelegate&&[self.myCellDelegate respondsToSelector:@selector(zanWithCircle:)]) {
            [self.myCellDelegate zanWithCircle:self];
        }
    }else{
        if (self.myCellDelegate&&[self.myCellDelegate respondsToSelector:@selector(pinglunWithCircle:)]) {
            [self.myCellDelegate pinglunWithCircle:self];
        }
    }
}

+ (CGSize)getContentHeigthWithStr:(NSString*)contStr
{
    CGSize cSize = [contStr sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(250, 300) lineBreakMode:NSLineBreakByWordWrapping];
    return cSize;
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
