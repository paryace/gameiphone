//
//  Emoji.m
//  GameGroup
//  表情类
//  Created by Marss on 14-5-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "Emojis.h"

@implementation Emojis

//根据code取出表情
+ (NSString *)emojiWithCode:(int)code {
    int sym = EMOJI_CODE_TO_SYMBOL(code);
    return [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
}


//从EmojiList里取出来所有表情显示出来
+ (NSArray *)allEmoji {
    NSMutableArray *array = [NSMutableArray new];
    

    NSArray *arrayEmoji = [GameCommon shareGameCommon].emoji_array;

    for (int i =0; i<arrayEmoji.count; i++) {
        NSDictionary *dic = arrayEmoji[i];
        NSString *emoji = KISDictionaryHaveKey(dic, @"emoji");
        [array addObject:emoji];
    }
    return array;
}
@end
