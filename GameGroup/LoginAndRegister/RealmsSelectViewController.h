//
//  RealmsSelectViewController.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-23.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@protocol RealmSelectDelegate <NSObject>

- (void)selectOneRealmWithName:(NSString*)name num:(NSString *)num;

@end

@interface RealmsSelectViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
@property(nonatomic, assign)id<RealmSelectDelegate> realmSelectDelegate;
@property(nonatomic,copy)NSString *gameNum;
@property(nonatomic,copy)NSString *indexCount;
@property(nonatomic,copy)NSString *prama;
@end
