//
//  MyWorldCell.h
//  GameGroup
//
//  Created by Marss on 14-9-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "EGOImageButton.h"
@interface MyWorldCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong)EGOImageButton *faceBt;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *timeLabel;
@property (nonatomic,strong)UILabel *areaLabel;
@property (nonatomic,strong)UILabel *describLabel;//需要自适应高度
@property (nonatomic,strong)UIButton *openBtn;
@property (nonatomic,strong)UIImageView *menuImageView;
@property (nonatomic,strong)UIButton *zanBtn;
@property (nonatomic,strong)UIButton *commentBtn;
@property(nonatomic,strong)UICollectionViewFlowLayout *layout;
@property(nonatomic,strong)UICollectionView *customPhotoCollectionView;
@property(nonatomic,strong)NSArray *collArray;//图片数组


+ (CGFloat)getLabelSize:(NSString *)str;
-(void)getImgWithArray:(NSArray *)array;
@end
