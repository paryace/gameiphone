//
//  SelectCharacterCell.h
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface SelectCharacterCell : UITableViewCell
@property(nonatomic,strong)UILabel *tlb;
@property(nonatomic,strong)EGOImageView * headImageView;
@property(nonatomic,strong)UILabel *characterLable;
-(void)reloadCell;
@end
