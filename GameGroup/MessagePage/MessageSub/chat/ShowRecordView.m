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
    
    if (0<lowPassResults<=0.14) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani14"]];
        NSLog(@"111");
    }else if (0.14<lowPassResults<=0.28) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani13"]];
        NSLog(@"222");
    }else if (0.28<lowPassResults<=0.42) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani12"]];
        NSLog(@"333");
    }else if (0.42<lowPassResults<=0.56) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani11"]];
        NSLog(@"444");
    }else if (0.56<lowPassResults<=0.7) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani10"]];
        NSLog(@"555");
    }else if (0.7<lowPassResults<=0.84) {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani9"]];
        NSLog(@"666");
    }else {
        [m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani8"]];
        NSLog(@"777");
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
