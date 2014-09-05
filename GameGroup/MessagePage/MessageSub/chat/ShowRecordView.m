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
   
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = kColorWithRGB(0, 0, 0, .7);
        self.imageView = [[ UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 150)];
        self.imageView.center = CGPointMake(self.center.x, self.center.y-100);
        self.imageView.image = KUIImage(@"third_xiemessage_record_icon");
        [self addSubview:self.imageView];
        
        self.m_bodongImg = [[UIImageView alloc]initWithFrame:CGRectMake(85, 30, 35, 70)];
        self.m_bodongImg.image = KUIImage(@"");
        [self.imageView addSubview:self.m_bodongImg];
        
    }
    return self;
}
-(void)changeBDimgWithimg:(double)lowPassResults
{
    
    if (0<lowPassResults<=0.14) {
        [self.m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani1"]];
        NSLog(@"111");
    }else if (0.14<lowPassResults<=0.28) {
        [self.m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani2"]];
        NSLog(@"222");
    }else if (0.28<lowPassResults<=0.42) {
        [self.m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani3"]];
        NSLog(@"333");
    }else if (0.42<lowPassResults<=0.56) {
        [self.m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani4"]];
        NSLog(@"444");
    }else if (0.56<lowPassResults<=0.7) {
        [self.m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani5"]];
        NSLog(@"555");
    }else if (0.7<lowPassResults<=0.84) {
        [self.m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani6"]];
        NSLog(@"666");
    }else {
        [self.m_bodongImg setImage:[UIImage imageNamed:@"third_xiemessage_record_ani7"]];
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
