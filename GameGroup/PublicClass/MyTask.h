//
//  MyTask.h
//  GameGroup
//
//  Created by Apple on 14-7-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyTask : NSInvocationOperation
{
    int operationId;    
}
@property int operationId;
@end
