//
//  SendFileMessageDelegate.h
//  GameGroup
//
//  Created by Apple on 14-8-25.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SendFileMessageDelegate <NSObject>

@optional

-(void)uploading:(NSInteger)cellIndex;
-(void)uploadFinish:(NSInteger)cellIndex;
-(void)uploadFail:(NSInteger)cellIndex;
@end
