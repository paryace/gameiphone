//
//  KKChatCell.m
//  GameGroup
//
//  Created by admin on 14-4-27.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "KKChatCell.h"

@implementation KKChatCell

@synthesize message;
@synthesize headImgV;
@synthesize senderAndTimeLabel;
@synthesize bgImageView;

-(KKChatCell* )loadMessage:(NSMutableDictionary *)theMessage{
    
    if (self) {//执行一些资源、变量的初始化工作
        self.accessoryType = UITableViewCellAccessoryNone;  //cell的为无样式
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //读取message数据
        self.message = theMessage;;
        
        //计算这个cell的size
        
        //设置senderAndTimeLabel
       
        
    }

    return self;
}

@end