//
//  ShareToOther.h
//  GameGroup
//
//  Created by 魏星 on 14-4-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareToOther : NSObject
{
    enum WXScene _scene;
}

+ (ShareToOther*)singleton;
-(void)shareTosina:(UIImage *)imageV;
- (void) sendImageContentWithImage:(UIImage *)imageV;
-(void) changeScene:(NSInteger)scene;
@end
