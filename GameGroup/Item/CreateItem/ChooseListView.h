//
//  ChooseListView.h
//  GameGroup
//
//  Created by Marss on 14-7-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseDelegate.h"

#define SECTION_BTN_TAG_BEGIN   1000
#define SECTION_IV_TAG_BEGIN    3000
@interface ChooseListView : UIView<UITableViewDelegate,UITableViewDataSource>{
    NSInteger currentExtendSection;//当前展开的section ，默认－1时，表示都没有展开
}
@property (nonatomic, assign) id<ChooseDelegate> dropDownDelegate;
@property (nonatomic, assign) id<ChooseDataSource> dropDownDataSource;

@property (nonatomic, strong) UIView *mSuperView;
@property (nonatomic, strong) UIView *mTableBaseView;
@property (nonatomic, strong) UITableView *mTableView;

- (id)initWithFrame:(CGRect)frame dataSource:(id)datasource delegate:(id) delegate;
- (void)setTitle:(NSString *)title;

- (void)hideExtendedChooseView;

@end
