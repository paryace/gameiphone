//
//  EmojiView.h
//  PetGroup
//
//  Created by Tolecen on 13-11-25.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Emojis.h"
@protocol EmojiViewDelegate<NSObject>
-(NSString *)selectedEmoji:(NSString *)ssss;
-(void)deleteEmojiStr;
-(void)emojiSendBtnDo;
@end
@interface EmojiView : UIView<UIScrollViewDelegate>
{
    UIScrollView *m_EmojiScrollView;
    UIPageControl *m_Emojipc;
    UIView * emojiBGV;
    NSArray *emojis;
}
- (id)initWithFrame:(CGRect)frame WithSendBtn:(BOOL)ifWith;
@property (nonatomic,assign)id<EmojiViewDelegate>delegate;
@end
