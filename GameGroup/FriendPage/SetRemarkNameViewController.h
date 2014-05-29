//
//  SetRemarkNameViewController.h
//  GameGroup
//  备注
//  Created by Shen Yanping on 13-12-18.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface SetRemarkNameViewController : BaseViewController<UITextFieldDelegate, UIAlertViewDelegate>

@property (copy, nonatomic)NSString* userId;
@property (copy, nonatomic)NSString* userName;
@property (copy, nonatomic)NSString* nickName;
@property (assign, nonatomic)BOOL      isFriend;//好友或关注的人

@end
