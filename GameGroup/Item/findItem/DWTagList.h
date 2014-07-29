//
//  DWTagList.h
//  GameGroup
//
//  Created by Marss on 14-7-15.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWTagDelegate;
@interface DWTagList : UIView
{
    UIView *view;
    NSArray *textArray;
    CGSize sizeFit;
    UIColor *lblBackgroundColor;
}
@property(assign,nonatomic)id<DWTagDelegate> tagDelegate;

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) NSArray *textArray;
@property (assign, nonatomic)  NSInteger rowNum;
@property (assign, nonatomic)  BOOL isAverage;

- (void)setLabelBackgroundColor:(UIColor *)color;
- (void)setTags:(NSArray *)array;
- (void)setTags:(NSArray *)array average:(BOOL)average rowCount:(NSInteger)rowcount;
- (void)display;
- (CGSize)fittedSize;

@end

@protocol DWTagDelegate <NSObject>
-(void)tagClick:(UIButton*)sender;
@end
