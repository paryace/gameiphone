//
//  FillInInfoViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
@protocol InfoDelegate;

@interface FillInInfoViewController : BaseViewController<UITextViewDelegate>
@property(nonatomic,assign)id<InfoDelegate>mydelegate;

@end
@protocol InfoDelegate <NSObject>

-(void)coreBackWithVC:(FillInInfoViewController*)vc info:(NSString *)info;

@end