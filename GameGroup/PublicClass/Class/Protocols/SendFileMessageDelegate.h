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

-(void)uploading:(NSInteger)cellIndex Type:(NSString*)type;
-(void)uploadFinish:(NSInteger)cellIndex FileKey:(NSString*)fileKey Type:(NSString*)type;
-(void)uploadFail:(NSInteger)cellIndex Type:(NSString*)type;
-(void)uploadProgressUpdated:(NSInteger)cellIndex percent:(float)percent Type:(NSString*)type;
@end
