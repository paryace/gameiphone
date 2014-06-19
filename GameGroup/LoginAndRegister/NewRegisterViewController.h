//
//  NewRegisterViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "RealmsSelectViewController.h"
#import "SearchRoleViewController.h"
#import "UpLoadFileService.h"
@protocol NewRegisterViewControllerDelegate <NSObject>
@optional
-(void)NewRegisterViewControllerFinishRegister;

@end

@interface NewRegisterViewController : BaseViewController
<
UITextFieldDelegate,
RealmSelectDelegate,
UIAlertViewDelegate,
SearchRoleDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
QiniuUploadDelegate
>
@property (nonatomic,retain) id <NewRegisterViewControllerDelegate>delegate;
@property(nonatomic,strong)UIImageView *topImageView;
@property(nonatomic,strong)UITextField *gameTextField;
@property(nonatomic,strong)UITextField *realmTextField;
@property(nonatomic,strong)UITextField *groupNameTf;
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UIScrollView *firstScrollView;
@property(nonatomic,strong)UIScrollView *secondScrollView;
@property(nonatomic,strong)UIScrollView *thirdScrollView;
@property(nonatomic,strong)UILabel *cardTF;
@property(nonatomic,strong) NSMutableDictionary *listDict;
@property(nonatomic,copy)   NSString *cardStr;
@property(nonatomic,strong) NSMutableArray *cardArray;
@property(nonatomic,strong)   UICollectionView * titleCollectionView;



@end
