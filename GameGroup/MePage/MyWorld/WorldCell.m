//
//  NewNearByCell.m
//  GameGroup
//
//  Created by 魏星 on 14-5-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "WorldCell.h"
#import "ImgCollCell.h"
@implementation WorldCell
{
    int nickNameLenght;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor =[ UIColor whiteColor];
        self.headImgBtn = [[EGOImageButton alloc]initWithPlaceholderImage:KUIImage(@"placeholder.png")];
        self.headImgBtn.frame = CGRectMake(10, 10, 40, 40);
        [self.headImgBtn addTarget:self action:@selector(enterPersonPage:) forControlEvents:UIControlEventTouchUpInside];
        self.headImgBtn.layer.cornerRadius = 8;
        self.headImgBtn.layer.masksToBounds=YES;
        [self.contentView addSubview:self.headImgBtn];
        
        self.focusButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 60, 40, 20)];
        [self.focusButton setBackgroundImage:KUIImage(@"guanzhu") forState:UIControlStateNormal];
        self.focusButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [self.focusButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.focusButton addTarget:self action:@selector(guanzhuing:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.focusButton];
        
        self.makeFriendBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 60, 40, 20)];
//        [self.makeFriendBtn setTitle:@"加好友" forState:UIControlStateNormal];
        [self.makeFriendBtn setBackgroundImage:KUIImage(@"makeFriendBtn") forState:UIControlStateNormal];
        self.makeFriendBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [self.makeFriendBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.makeFriendBtn addTarget:self action:@selector(guanzhuing:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.makeFriendBtn];

        
        self.nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 120, 20)];
        self.nickNameLabel.textColor = UIColorFromRGBA(0x455ca8, 1);
        self.nickNameLabel.backgroundColor = [UIColor clearColor];
        self.nickNameLabel.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:self.nickNameLabel];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 27, 170, 30)];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.numberOfLines=0;
        [self.contentView addSubview:self.titleLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(242, 10, 70, 30)];
        self.timeLabel.font = [UIFont systemFontOfSize:11];
        self.timeLabel.textColor = UIColorFromRGBA(0x999999, 1);
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.timeLabel];
        
        self.jubaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.jubaoBtn.frame = CGRectMake(0, 0, 60, 30);
        [self.jubaoBtn setTitle:@"举报" forState:UIControlStateNormal];
        [self.jubaoBtn setTitleColor: UIColorFromRGBA(0x455ca8, 1)forState:UIControlStateNormal];
        self.jubaoBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.jubaoBtn addTarget:self action:@selector(jubaoThisInfo:) forControlEvents:UIControlEventTouchUpInside];
//        self.jubaoBtn.hidden = YES;
        [self.contentView addSubview:self.jubaoBtn];
        //坐标button
        self.ETBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.ETBtn.frame = CGRectMake(0, 0, 60, 30);
        self.ETBtn.hidden = YES;
        [self.contentView addSubview:self.ETBtn];

        
        
        
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
        
        UITapGestureRecognizer *tapMIss = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(taptap)];
//        [self.photoCollectionView addGestureRecognizer:tapMIss];
        
        self.photoCollectionView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.photoCollectionView];
        
        self.zanView = [[UIImageView alloc]initWithFrame:CGRectMake(60, 100, 250, 30)];
        self.zanView.image = KUIImage(@"zanAndCommentBg");
        self.zanView.userInteractionEnabled = YES;
        
        [self.contentView addSubview:self.zanView];
        
        self.zanImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 10, 10, 10)];
        self.zanImageView.image = KUIImage(@"zan_circle");
        [self.zanView addSubview:self.zanImageView];
        
        self.zanNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 30)];
        self.zanNameLabel.textColor = UIColorFromRGBA(0x455cab, 1);
        self.zanNameLabel.font = [UIFont boldSystemFontOfSize:12];
        self.zanNameLabel.backgroundColor = [UIColor clearColor];
        self.zanNameLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapgc =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sssssss:)];
        [self.zanNameLabel addGestureRecognizer:tapgc];
        [self.zanView addSubview:self.zanNameLabel];
        
        self.zanLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 0, 100, 30)];
        self.zanLabel.textColor = [UIColor grayColor];
        self.zanLabel.backgroundColor =[UIColor clearColor];
        self.zanLabel.font = [UIFont boldSystemFontOfSize:12];
        [self.zanView addSubview:self.zanLabel];
        
        
        self.commentTabelView = [[UITableView alloc]initWithFrame:CGRectMake(60, 100, 245, 50) style:UITableViewStylePlain];
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
//        [self.openBtn setBackgroundImage:KUIImage(@"zan_pl_click") forState:UIControlStateHighlighted];
        [self.openBtn addTarget:self action:@selector(openBtnList:) forControlEvents:UIControlEventTouchUpInside];
        self.openBtn.tag =self.tag;
        [self.contentView addSubview:self.openBtn];
        
        
        self.menuImageView =[[ UIImageView alloc]initWithFrame:CGRectMake(105, 60, 180, 38)];
        self.menuImageView.image = KUIImage(@"bgImg");
//        self.menuImageView.backgroundColor = [UIColor clearColor];
        self.menuImageView.userInteractionEnabled = YES;
        self.menuImageView.hidden = YES;
        [self addSubview:self.menuImageView];
        
        
        self.zanBtn=[[ UIButton alloc]initWithFrame:CGRectMake(2, 2, 89, 36)];
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
        
        //区域label
        self.areaLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.areaLabel.font = [UIFont systemFontOfSize:11];
        self.areaLabel.textColor = UIColorFromRGBA(0x999999, 1);
        self.areaLabel.textAlignment = NSTextAlignmentLeft;
        self.areaLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.areaLabel];
        //区域icon
        self.areaIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.areaIcon.image = KUIImage(@"areaIcon1_15");
        self.areaIcon.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.areaIcon];
    }
    return self;
}
- (void)taptap
{
    if (self.myCellDelegate &&[self.myCellDelegate respondsToSelector:@selector(TapMiss)]) {
        [self.myCellDelegate  TapMiss];
    }
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
    cell.imageView.imageURL = [ImageService getImageUrl3:url Width:160];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.myCellDelegate &&[self.myCellDelegate respondsToSelector:@selector(bigImgWithCircle:WithIndexPath:)]) {
        [self.myCellDelegate  bigImgWithCircle:self WithIndexPath:indexPath.row];
    }
}

-(void)guanzhuing:(NSString *)sender
{
    if (self.myCellDelegate &&[self.myCellDelegate respondsToSelector:@selector(changeShiptypeWithCell:)]) {
        [self.myCellDelegate changeShiptypeWithCell:self];
    }
}



//隐藏评论赞button
-(void)comeBackMenuView:(UIGestureRecognizer *)sender
{
    self.menuImageView.hidden =YES;
}

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
    cell.myCommentCellDelegate = self;
    //cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.tag = indexPath.row;
    NSMutableDictionary *dict = [self.commentArray objectAtIndex:indexPath.row];
    NSString * str = KISDictionaryHaveKey(dict, @"commentStr");
    NSMutableDictionary * commentD = KISDictionaryHaveKey(dict, @"commentUser");
    NSString * nickName=KISDictionaryHaveKey(commentD, @"alias");
    if ([GameCommon isEmtity:nickName]) {
        nickName=KISDictionaryHaveKey(commentD, @"nickname");
    }
    cell.comNickNameStr =nickName;
    nickNameLenght=[cell.comNickNameStr length];
    
    cell.commentContLabel.text = str;
    
    //创建昵称的隐形按钮
    [cell showNickNameButton:cell.comNickNameStr withSize:cell.commentContLabel.frame.size];
    
    float cellHeight = [KISDictionaryHaveKey(dict, @"commentCellHieght") floatValue];
    CGSize matchSize = [cell.comNickNameStr sizeWithFont:cell.commentContLabel.font];
    cell.nickNameLabel.frame = CGRectMake(5, 3, matchSize.width+5.0, matchSize.height);
    cell.nickNameLabel.font = cell.commentContLabel.font;
    cell.nickNameLabel.text = cell.comNickNameStr;
    cell.commentContLabel.frame = CGRectMake(5, 0, 245, cellHeight);
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.commentTabelView deselectRowAtIndexPath:indexPath animated:YES];
    
    tableView =self.commentTabelView;
    if (self.myCellDelegate &&[self.myCellDelegate respondsToSelector:@selector(editCommentOfYouWithCircle:withIndexPath:)]) {
        [self.myCellDelegate editCommentOfYouWithCircle:self withIndexPath:indexPath.row];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0.0f;
    NSMutableDictionary *dict = [self.commentArray objectAtIndex:indexPath.row];
    
    if(![[dict allKeys]containsObject:@"commentCellHieght"]){    //如果没算高度， 算出高度，存起来
        NSString *str ;
        if ([[dict allKeys]containsObject:@"commentStr"]) {
            str =KISDictionaryHaveKey(dict, @"commentStr");
        }
        else{
            NSString *nickName =KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"alias");
            if ([GameCommon isEmtity:nickName]) {
                nickName =KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"nickname");
            }
            if ([[dict allKeys]containsObject:@"destUser"]) {
                NSString *nickName2 =KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"destUser"), @"alias");
                if ([GameCommon isEmtity:nickName2]) {
                    nickName2 =KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"destUser"), @"nickname");
                }
                str =[NSString stringWithFormat:@"%@ 回复 %@: %@", nickName,nickName2,KISDictionaryHaveKey(dict, @"comment")];
            }else{
                str =[NSString stringWithFormat:@"%@: %@",nickName,KISDictionaryHaveKey(dict, @"comment")];
            }
            str = [UILabel getStr:str];
            [dict setObject:str forKey:@"commentStr"];
        }
        
        CGSize size = [str sizeWithFont:[UIFont boldSystemFontOfSize:12.0] constrainedToSize:CGSizeMake(245, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        height= size.height;
        [dict setObject:@(height) forKey:@"commentCellHieght"];
    }
    else
    {
        height = [KISDictionaryHaveKey(dict,@"commentCellHieght") floatValue];
    }
    return height;
    
}


-(void)enterPersonPage:(id)sender
{
    if (self.myCellDelegate &&[self.myCellDelegate respondsToSelector:@selector(enterPersonPageWithCell:)]) {
        [self.myCellDelegate enterPersonPageWithCell:self];
    }
    
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
    CGSize cSize = [contStr sizeWithFont:[UIFont boldSystemFontOfSize:12.0] constrainedToSize:CGSizeMake(245, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    return cSize;
}

+ (CGSize)getTitleHeigthWithStr:(NSString*)contStr
{
    CGSize cSize = [contStr sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(245, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    return cSize;
}

-(void)delCell:(UIButton *)sender
{
    if (self.myCellDelegate && [self.myCellDelegate respondsToSelector:@selector(delCellWithCell:)]) {
        [self.myCellDelegate delCellWithCell:self];
    }
}

- (void)handleNickNameButton:(CommentCell*)cell
{
    if (self.myCellDelegate &&[self.myCellDelegate respondsToSelector:@selector(handleNickNameButton_HeadCell:withIndexPathRow:)]) {
        [self.myCellDelegate handleNickNameButton_HeadCell:self withIndexPathRow:cell.tag];
    }
}
-(void)sssssss:(id)sender
{
    if (self.myCellDelegate &&[self.myCellDelegate respondsToSelector:@selector(tapZanNickNameWithCell:)]) {
        [self.myCellDelegate tapZanNickNameWithCell:self];
    }
    
}
-(void)jubaoThisInfo:(id)sender
{
    if (self.myCellDelegate &&[self.myCellDelegate respondsToSelector:@selector(jubaoThisInfoWithCell:)]) {
        [self.myCellDelegate jubaoThisInfoWithCell:self];
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
