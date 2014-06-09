//
//  ChatDelegate.h
//  WeShare
//
//  Created by Elliott on 13-5-7.
//  Copyright (c) 2013年 Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChatDelegate <NSObject>

-(void)newMessageReceived:(NSDictionary *)messageContent;
-(void)dailynewsReceived:(NSDictionary * )messageContent;
-(void)newdynamicAboutMe:(NSDictionary *)messageContent;
-(void)newGroupMessageReceived:(NSDictionary *)messageContent;
@end
