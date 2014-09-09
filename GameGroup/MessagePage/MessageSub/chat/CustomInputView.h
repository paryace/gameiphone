//
//  CustomInputView.h
//  GameGroup
//
//  Created by 魏星 on 14-9-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomInputDelegate;
@interface CustomInputView : UIView
@property (nonatomic,assign)id<CustomInputDelegate>mydelegate;
-(void)rechangReadyState;
@end

@protocol CustomInputDelegate <NSObject>

-(void)beginRecordWithView:(UIView *)view;//点击开始
-(void)touchMovedWithView:(UIView *)view;//移动向上超过20
-(void)touchMoveBackWithView:(UIView *)view;//移动向上小雨20
-(void)RecordSuccessWithView:(UIView *)view;//点击完成 录制成功
-(void)cancleRecordWithView:(UIView *)view;//点击完成 录制失败
-(void)didClickEmjoWithView:(UIView *)view; //点击表情buton
-(void)didClickkkchatAddBtnWithView:(UIView *)view;//点击加号
-(void)didClickAudioWithView:(UIView *)view;//点击声音

@end
