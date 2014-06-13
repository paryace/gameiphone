//
//  AddGroupView.h
//  GameGroup
//
//  Created by 魏星 on 14-6-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol groupViewDelegate;

@interface AddGroupView : UIView<UITextFieldDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextViewDelegate>
@property(nonatomic,strong)UIImageView *topImageView;
@property(nonatomic,strong)UITextField *gameTextField;
@property(nonatomic,strong)UITextField *realmTextField;
@property(nonatomic,strong)UITextField *groupNameTf;
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,assign)id<groupViewDelegate>myDelegate;
@property(nonatomic,strong)UIScrollView *firstScrollView;
@property(nonatomic,strong)UIScrollView *secondScrollView;
@property(nonatomic,strong)UIScrollView *thirdScrollView;
@property(nonatomic,strong)UILabel *cardTF;
@property(nonatomic,strong) NSMutableDictionary *listDict;
@property(nonatomic,copy)   NSString *cardStr;
@property(nonatomic,strong) NSMutableArray *cardArray;
@property(nonatomic,strong)   UICollectionView * titleCollectionView;

@end
@protocol groupViewDelegate <NSObject>

-(void)didClickGameListWithDel:(AddGroupView *)gro dic:(NSDictionary *)dic;
-(void)didClickRealmListWithDel:(AddGroupView *)gro;
-(void)didClickCardWithDel:(AddGroupView *)gro dic:(NSMutableDictionary *)dic;
-(void)didClickCardImgWithDel:(AddGroupView *)gro;
-(void)didClickContentWithDel:(AddGroupView *)gro content:(NSString *)content;
-(void)didClickPageOneWithDel:(AddGroupView *)gro WithDic:(NSDictionary *)dic;
@end