//
//  AudioManager.m
//  GameGroup
//
//  Created by 魏星 on 14-8-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "AudioManager.h"
static AudioManager *m_audioManager = NULL;

@implementation AudioManager

+ (AudioManager*)singleton
{
    @synchronized(self)
    {
		if (m_audioManager == nil)
		{
			m_audioManager = [[self alloc] init];
		}
	}
	return m_audioManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark ---替换字符串中的"/"为"-"
-(NSString *)changeStringWithString:(NSString *)str
{
    NSString *string = [str stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    return string;
}
#pragma mark----重写地址
-(void)RewriteTheAddressWithAddress:(NSString *)name1 name2:(NSString *)name2
{
    [[NSFileManager defaultManager] moveItemAtPath:[NSString stringWithFormat:@"%@/vocie/%@",RootDocPath,name1] toPath:[NSString stringWithFormat:@"%@/%@",RootDocPath,[self changeStringWithString:name2]] error:nil];
}



@end
