//
//  CharacterAndTitleService.h
//  GameGroup
//
//  Created by Marss on 14-7-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CharacterAndTitleService : NSObject
+ (CharacterAndTitleService*)singleton;
//请求角色信息
-(void)getCharacterInfo:(NSString*)userid;
// 保存角色信息
-(void)saveCharachers:(NSArray*)charachers Userid:(NSString*)userid;
//请求头衔信息－－type显示头衔，0是显示， 1是隐藏， 如果不传两种都返回
-(void)getTitleInfo:(NSString*)userid Type:(NSString*)type;
//保存头衔信息
-(void)saveTitleInfo:(NSString*)userId Titles:(NSArray*)titles Type:(NSString*)type;

-(void)deleteCharacher:(NSString*)characherId;

-(void)deleteTitle:(NSString*)characherId;
@end
