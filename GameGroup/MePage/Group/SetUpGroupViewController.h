//
//  SetUpGroupViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    SETUP_JOIN = 0,
    SETUP_NAME,
    SETUP_INFO,
    SETUP_IMG,//陌生人
    SETUP_EDIT,
}setUpType;
@protocol SetupDelegate;
@interface SetUpGroupViewController : BaseViewController<UITextViewDelegate>
@property(nonatomic,assign)setUpType  mySetupType;
@property(nonatomic,copy)NSString *groupid;
@property(nonatomic,assign)id<SetupDelegate>delegate;

@end
@protocol SetupDelegate <NSObject>

-(void)comeBackInfoWithController:(SetUpGroupViewController *)controller type:(setUpType)mysetupType info:(NSString *)info;

@end