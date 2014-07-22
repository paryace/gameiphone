//
//  SeniorViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "DWTagList.h"
@protocol SeniorDelegate;
@interface SeniorViewController : BaseViewController<DWTagDelegate>
@property(nonatomic,assign)id<SeniorDelegate>mydelegate;
@property(nonatomic,copy)NSString *charaterId;
@property(nonatomic,strong)NSMutableDictionary *mainDict;
@end

@protocol SeniorDelegate <NSObject>



@end