//
//  AddGroupView.h
//  GameGroup
//
//  Created by 魏星 on 14-6-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddGroupView : UIView<UITextFieldDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,strong)UIImageView *topImageView;
@property(nonatomic,strong)UITextField *gameTextField;
@property(nonatomic,strong)UITextField *realmTextField;
@property(nonatomic,strong)UITextField *groupNameTf;
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UIScrollView *firstScrollView;
@property(nonatomic,strong)UIScrollView *secondScrollView;
@property(nonatomic,strong)UIScrollView *thirdScrollView;
@property(nonatomic,strong)UITextField *cardTF;
@end
