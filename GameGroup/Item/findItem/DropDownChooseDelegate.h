//
//  DropDownChooseDelegate.h
//  GameGroup
//
//  Created by Marss on 14-7-15.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DropDownChooseDelegate <NSObject>

@optional

-(void) chooseAtSection:(NSInteger)section index:(NSInteger)index;

-(BOOL) clickAtSection:(NSInteger)section;
@end

@protocol DropDownChooseDataSource <NSObject>
-(NSInteger)numberOfSections;
-(NSInteger)numberOfRowsInSection:(NSInteger)section;
-(NSString *)titleInSection:(NSInteger)section index:(NSInteger) index;
-(NSInteger)defaultShowSection:(NSInteger)section;
-(NSDictionary *)contentInsection:(NSInteger)section index:(NSInteger) index;
- (void)headImgClick:(NSString*)userId;
- (void)itemOnClick:(NSMutableDictionary*)dic;
- (void)buttonOnClick;

-(void)showDialog;
-(void)hideDialog;
@end
