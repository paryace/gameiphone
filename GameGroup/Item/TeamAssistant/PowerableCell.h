//
//  PowerableCell.h
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SwitchDelegate;
@interface PowerableCell : UITableViewCell
@property(nonatomic,strong)UILabel *tlb;
@property(nonatomic,strong)UISwitch *soundSwitch;
@property (assign, nonatomic)id<SwitchDelegate> switchelegate;
@end
@protocol SwitchDelegate <NSObject>
-(void)infomationAccording:(UISwitch*)sender;
@end
