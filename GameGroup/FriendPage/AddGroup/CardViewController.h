//
//  CardViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@protocol CardListDelegate ;


@interface CardViewController : BaseViewController<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,strong)NSMutableDictionary *listDict;
@property(nonatomic,assign)id<CardListDelegate>myDelegate;

@end
@protocol CardListDelegate <NSObject>

-(void)senderCkickInfoWithDel:(CardViewController *)del array:(NSArray *)array;

@end