//
//  ShowRecordView.m
//  GameGroup
//
//  Created by 魏星 on 14-8-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ShowRecordView.h"

@implementation ShowRecordView
{
    UIImageView * m_bodongImg;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *imageView = [[ UIImageView alloc]initWithFrame:frame];
        imageView.image = KUIImage(@"third_xiemessage_record_icon");
        [self addSubview:imageView];
        
        m_bodongImg = [[UIImageView alloc]initWithFrame:CGRectMake(85, 35, 35, 80)];
        m_bodongImg.image = KUIImage(@"");
        [self addSubview:m_bodongImg];
        
    }
    return self;
}
-(void)changeBDimgWithimg:(double)lowPassResults
{
    
    if (0<lowPassResults<=0.06) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani1"]];
    }else if (0.06<lowPassResults<=0.13) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani2"]];
    }else if (0.13<lowPassResults<=0.20) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani3"]];
    }else if (0.20<lowPassResults<=0.27) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani4"]];
    }else if (0.27<lowPassResults<=0.34) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani5"]];
    }else if (0.34<lowPassResults<=0.41) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani6"]];
    }else if (0.41<lowPassResults<=0.48) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani7"]];
    }else if (0.48<lowPassResults<=0.55) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani8"]];
    }else if (0.55<lowPassResults<=0.62) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani9"]];
    }else if (0.62<lowPassResults<=0.69) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani10"]];
    }else if (0.69<lowPassResults<=0.76) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani11"]];
    }else if (0.76<lowPassResults<=0.83) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani12"]];
    }else if (0.83<lowPassResults<=0.9) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani13"]];
    }else {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani14"]];
    }

}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
