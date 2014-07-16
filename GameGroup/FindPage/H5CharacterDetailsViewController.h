//
//  H5CharacterDetailsViewController.h
//  GameGroup
//
//  Created by Marss on 14-7-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface H5CharacterDetailsViewController : BaseViewController<UIAlertViewDelegate,UIWebViewDelegate,UIActionSheetDelegate>
@property(nonatomic,strong)NSString* gameId;
@property(nonatomic,strong)NSString* characterId;
@end
