//
//  SelectTypeAndNumberPersonView.h
//  GameGroup
//
//  Created by Apple on 14-8-26.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SelectTypeDelegate;

@interface SelectTypeAndNumberPersonView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>
@property (nonatomic, strong) UIPickerView * m_typePickerView;
@property (nonatomic, strong) UIPickerView  *  m_countPickView;
@property(nonatomic,strong)NSMutableArray * m_typeArray;
@property(nonatomic,strong)NSMutableArray  *  m_countArray;
@property(nonatomic,assign)id<SelectTypeDelegate>selectTypeDelegate;

-(void)setTypeArray:(id)responseObject;
-(void)setNumberArray:(id)responseObject;
@end

@protocol SelectTypeDelegate <NSObject>
-(void)selectType:(NSMutableDictionary*)typeDic;
-(void)selectCount:(NSMutableDictionary*)countDic;
@end
