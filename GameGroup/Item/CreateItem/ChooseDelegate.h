//
//  ChooseDelegate.h
//  GameGroup
//
//  Created by Marss on 14-7-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChooseDelegate <NSObject>

@optional

-(void) chooseAtSection:(NSInteger)index;
@end

@protocol ChooseDataSource <NSObject>
-(NSInteger)numberOfRowsInSection;
-(NSString *)titleInSection:(NSInteger) index;
-(NSInteger)defaultShowSection:(NSInteger)section;

@end
