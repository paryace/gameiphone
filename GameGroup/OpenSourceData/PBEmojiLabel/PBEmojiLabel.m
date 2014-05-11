//
//  PBEmojiLabel.m
//  PBEmojiLabelParser
//
//  Created by Piet Brauer on 02.01.13.
//  Copyright (c) 2013 nerdishbynature. All rights reserved.
//

#import "PBEmojiLabel.h"

@implementation UILabel (PBEmojiLabel)

-(void)setEmojiText:(NSString *)emojiString{
    
    self.text = [UILabel getStr:emojiString];

//    NSMutableDictionary *dict = [GameCommon shareGameCommon].emoji_dict;
//
//    for (NSString *key in dict.allKeys)
//        emojiString = [emojiString stringByReplacingOccurrencesOfString:key
//															 withString:[dict objectForKey:key]];
//
//    self.text = emojiString;
}

+(NSString *)getStr:(NSString *)emojiString;
{
    NSMutableDictionary *dict = [GameCommon shareGameCommon].emoji_dict;
    
    for (NSString *key in dict.allKeys)
        emojiString = [emojiString stringByReplacingOccurrencesOfString:key
															 withString:[dict objectForKey:key]];
    return emojiString;
}

@end
