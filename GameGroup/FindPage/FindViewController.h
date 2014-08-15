//
//  FindViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-5-15.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "TvView.h"

@interface FindViewController : BaseViewController<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,TvViewDelegate>
@property (nonatomic, retain) NSTimer* cellTimer;
@end
