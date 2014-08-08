//
//  SortingView.h
//  GameGroup
//
//  Created by 魏星 on 14-8-5.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol sortingDelegate;

@interface SortingView : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
-(void)showSortingViewInViewForRect:(CGRect)rect arr:(NSArray *)arr;

-(void)showSortingView;
-(void)hideSortingView;
-(BOOL)isShow;

@property (nonatomic,assign)id<sortingDelegate>mydelegate;
@end

@protocol sortingDelegate <NSObject>

-(void)comeBackInfoWithTag:(NSInteger)row;

@end
