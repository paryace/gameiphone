//
//  EditGroupMessageViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "QiniuUploadDelegate.h"

@protocol GroupEditMessageDelegate;

@interface EditGroupMessageViewController : BaseViewController<UITextViewDelegate,UIAlertViewDelegate,QiniuUploadDelegate>
@property(nonatomic,strong)NSArray*    headImgArray;
@property(nonatomic,strong)NSString* placeHold;
@property(nonatomic,assign)id<GroupEditMessageDelegate>delegate;

@end
@protocol GroupEditMessageDelegate <NSObject>

-(void)comeBackInfoWithController:(NSString *)info InfoImg:(NSString*)infoImg;

@end