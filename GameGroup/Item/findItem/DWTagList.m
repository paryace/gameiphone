//
//  DWTagList.m
//  GameGroup
//
//  Created by Marss on 14-7-15.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "DWTagList.h"
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 3.0f
#define LABEL_MARGIN 5.0f
#define BOTTOM_MARGIN 5.0f
#define FONT_SIZE 13.0f
#define HORIZONTAL_PADDING 7.0f
#define VERTICAL_PADDING 3.0f
#define BACKGROUND_COLOR [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00]
#define TEXT_COLOR [UIColor blackColor]
#define TEXT_SHADOW_COLOR [UIColor whiteColor]
#define TEXT_SHADOW_OFFSET CGSizeMake(0.0f, 1.0f)
#define BORDER_COLOR [UIColor lightGrayColor].CGColor
#define BORDER_WIDTH 0.5f
#define KUIImage(name) ([UIImage imageNamed:name])

@implementation DWTagList


@synthesize view, textArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:view];
    }
    return self;
}

- (void)setTags:(NSArray *)array
{
    [self setTags:array average:NO rowCount:3];
}
- (void)setTags:(NSArray *)array average:(BOOL)average rowCount:(NSInteger)rowcount
{
    textArray = [[NSArray alloc] initWithArray:array];
    self.isAverage = average;
    self.rowNum = rowcount;
    sizeFit = CGSizeZero;
    [self display];
}

- (void)setLabelBackgroundColor:(UIColor *)color
{
    lblBackgroundColor = color;
    [self display];
}

- (void)display
{
    for (UILabel *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    float totalHeight = 0;
    CGRect previousFrame = CGRectZero;
    BOOL gotPreviousFrame = NO;
    for (int i = 0;i<textArray.count;i++) {
        ;
        NSString * text = KISDictionaryHaveKey([textArray objectAtIndex:i], @"value");
        CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:CGSizeMake(self.frame.size.width, 1500) lineBreakMode:NSLineBreakByCharWrapping];
        if (self.isAverage) {
            textSize.width = (self.frame.size.width-(HORIZONTAL_PADDING*self.rowNum-1))/self.rowNum;
        }else {
            textSize.width += (HORIZONTAL_PADDING*2);
        }
        textSize.height += VERTICAL_PADDING*2;
        UIButton *label = nil;
        if (!gotPreviousFrame) {
            label = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,textSize.width, textSize.height)];
            totalHeight = textSize.height;
        } else {
            CGRect newRect = CGRectZero;
            if (previousFrame.origin.x+previousFrame.size.width + textSize.width + LABEL_MARGIN > self.frame.size.width) {
                newRect.origin = CGPointMake(0, previousFrame.origin.y + textSize.height + BOTTOM_MARGIN);
                totalHeight += textSize.height + BOTTOM_MARGIN;
            } else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + LABEL_MARGIN, previousFrame.origin.y);
            }
            newRect.size = textSize;
            label = [[UIButton alloc] initWithFrame:newRect];
        }
        previousFrame = label.frame;
        gotPreviousFrame = YES;
        label.titleLabel.font = [UIFont systemFontOfSize: FONT_SIZE];
        if (!lblBackgroundColor) {
            [label setBackgroundColor:BACKGROUND_COLOR];
        } else {
            [label setBackgroundColor:lblBackgroundColor];
        }
        [label setBackgroundImage:KUIImage(@"card_click") forState:UIControlStateNormal];
        [label setBackgroundImage:KUIImage(@"card_purple") forState:UIControlStateHighlighted];
        label.tag = i;
        [label addTarget:self action:@selector(lableClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [label setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [label setTitle:text forState: UIControlStateNormal];
        label.titleLabel.textAlignment = NSTextAlignmentCenter;
        label.titleLabel.shadowColor = TEXT_SHADOW_COLOR;
        label.titleLabel.shadowOffset = TEXT_SHADOW_OFFSET;
        [label.layer setMasksToBounds:YES];
        [label.layer setCornerRadius:CORNER_RADIUS];
        [label.layer setBorderColor:BORDER_COLOR];
        [label.layer setBorderWidth: BORDER_WIDTH];
        [self addSubview:label];
    }
    sizeFit = CGSizeMake(self.frame.size.width, totalHeight + 1.0f);
}

-(void)lableClick:(UIButton*)sender
{
    if (self.tagDelegate) {
        [self.tagDelegate tagClick:sender];
    }
}

- (CGSize)fittedSize
{
    return sizeFit;
}

@end
