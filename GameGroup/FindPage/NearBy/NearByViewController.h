//
//  NearByViewController.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-11.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface NearByViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,UIAlertViewDelegate>
@property (strong,nonatomic) AppDelegate * appDel;
@property(nonatomic,copy)NSString *cityCode;
@property(nonatomic,copy)NSString *titleStr;
@end
