//
//  SelectOtherCell.h
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectOtherCell : UITableViewCell
@property(nonatomic,strong)UILabel *tlb;
@property(nonatomic,strong)UILabel *characterLable;
-(void)reloadCell;
@end
