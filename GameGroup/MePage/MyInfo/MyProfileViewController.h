//
//  MyProfileViewController.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-11.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "HGPhotoWall.h"
#import "HostInfo.h"
#import "DSuser.h"
#import "TextLabelTableCell.h"
#import "QiniuUploadDelegate.h"
#import "EditMessageViewController.h"

typedef  enum
{
    ActionSheetTypeChoosePic = 1,
    ActionSheetTypeOperationPic
}ActionSheetType;




@interface MyProfileViewController : BaseViewController
<
UITableViewDataSource,
UITableViewDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
HGPhotoWallDelegate,
UIAlertViewDelegate,
BirthDayDelegate,
QiniuUploadDelegate,
editMessageDelegate
>

@property(nonatomic,strong)NSString*  nickName;
@property(nonatomic,strong)NSString*  userName;
@property(nonatomic,strong)DSuser*  hostInfo;
@property(nonatomic,strong)NSArray*    headImgArray;

@end
