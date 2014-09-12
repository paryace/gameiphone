//
//  AudioManager.h
//  GameGroup
//
//  Created by 魏星 on 14-8-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioManager : NSObject
+ (AudioManager*)singleton;


#pragma mark ---替换字符串中的"/"为"-"
-(NSString *)changeStringWithString:(NSString *)str;


#pragma mark----重写地址

-(void)RewriteTheAddressWithAddress:(NSString *)name1 name2:(NSString *)name2;
-(void)isHaveThisFolderWithFilePath:(NSString *)filePath;
@end
