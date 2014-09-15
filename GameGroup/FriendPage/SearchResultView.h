//
//  SearchResultView.h
//  GameGroup
//
//  Created by Apple on 14-9-15.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySearchBar.h"
@protocol ItemClickDelegate;
@interface SearchResultView : UIView<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, strong) UITableView *mTableView;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) MySearchBar *m_searchBar;
@property (strong, nonatomic)  NSMutableArray * searchResultView;
@property(assign,nonatomic)id<ItemClickDelegate> delegate;
-(void)setResultList:(NSMutableArray*)resultArray;
-(void)showSelf;
-(void)hideSelf;
@end

@protocol ItemClickDelegate <NSObject>

- (void)itemClick:(SearchResultView*)Sender DateDic:(NSMutableDictionary*)dataDic;
-(void)reloadSearchList:(NSString*)searchText;
-(void)showSearchResultView;
-(void)hideSearchResultView;
@end