//
//  PBEmojiLabel.h
//  PBEmojiLabelParser
//
//  Marss添加， 用来支持iphone表情。 用的是iphone自带表情库
//  Created by Piet Brauer on 02.01.13.
//  Copyright (c) 2013 nerdishbynature. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (PBEmojiLabel)

-(void)setEmojiText:(NSString *)emojiString;

@end
