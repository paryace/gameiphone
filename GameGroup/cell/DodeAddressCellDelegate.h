//
//  DodeAddressCellDelegate.h
//  GameGroup
//
//  Created by wangxr on 14-3-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DodeAddressCellDelegate <NSObject>
@optional
-(void)OutDodeAddressCellTouchButtonWithIndexPath:(NSIndexPath *)indexPath IsSearch:(BOOL)isSearch;
@end
