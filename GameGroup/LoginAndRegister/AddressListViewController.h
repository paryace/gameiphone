//
//  AddressListViewController.h
//  GameGroup
//
//  Created by wangxr on 14-3-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "InDoduAddressTableViewCell.h"
@interface AddressListViewController : BaseViewController<DetailDelegate>
@property (nonatomic,retain)NSArray * inDudeArray;
@property (nonatomic,retain)NSArray * outDudeArray;
@end
