//
//  TeamTagCell.h
//  GameGroup
//
//  Created by Apple on 14-9-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagCell.h"
#import "DWTagList.h"
@protocol TagDelegate;
@interface TeamTagCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate,TagOnCLicklDelegate,DWTagDelegate>
@property(nonatomic,strong)NSMutableArray * tagArray;
@property(nonatomic,strong)DWTagList *tagList;
-(void)setTagDate:(NSMutableArray*)typeArray ifCreate:(BOOL)ifCreate;
-(void)hideSelf;
-(void)showSelf;
@property(nonatomic,assign)id<TagDelegate>tagDelegate;
@end
@protocol TagDelegate <NSObject>
-(void)tagType:(NSMutableDictionary *)tagDic isRemove:(BOOL)isRemove;

@end
