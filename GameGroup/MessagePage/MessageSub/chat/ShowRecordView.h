//
//  ShowRecordView.h
//  GameGroup
//
//  Created by 魏星 on 14-8-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowRecordView : UIView
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong) UIImageView *m_bodongImg;

-(void)changeBDimgWithimg:(double)img;
//手指按下开始录音
- (void)holdDownButtonTouchDown;
//取消本次录音
- (void)holdDownButtonTouchUpOutside;
//正常录音完成
- (void)holdDownButtonTouchUpInside;
//手指移动到取消录制范围
- (void)holdDownDragOutside;
//手指移动回来重新录制
- (void)holdDownDragInside;;
@end
