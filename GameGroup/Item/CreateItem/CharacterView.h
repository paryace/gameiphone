//
//  CharacterView.h
//  GameGroup
//
//  Created by Apple on 14-8-26.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharacterCell.h"
@protocol CharacterDelegate;
@interface CharacterView : UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property(nonatomic,strong)NSMutableArray * characterArray;
@property(nonatomic,strong)UITableView *roleTableView;
@property(nonatomic,assign)id<CharacterDelegate>characterDelegate;
-(void)setDate:(NSMutableArray*)characterArray;
-(void)hiddenSelf;
-(void)showSelf;
@end
@protocol CharacterDelegate <NSObject>
-(void)selectCharacter:(NSMutableDictionary *)characterDic;
@end
