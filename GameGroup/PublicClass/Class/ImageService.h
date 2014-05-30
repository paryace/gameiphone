//
//  ImageService.h
//  GameGroup
//
//  Created by Apple on 14-5-24.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageService : NSObject
+(NSURL*)getImageUrl:(NSString*)imageid Width:(NSInteger)width Height:(NSInteger)height;

+(NSURL*)getImageUrl2:(NSString*)imageid;

+(NSURL*)getImageUrl3:(NSString*)imageid Width:(NSInteger)width;

+(NSURL*)getImageUrl4:(NSString*)imageid;

+(NSURL*)getImageStr:(NSString*)imageids Width:(NSInteger)width;

+(NSURL*)getImageStr2:(NSString*)imageids;

+(NSMutableArray*)getImageIds:(NSString*)images;

+(NSMutableArray*)getImageIds2:(NSString*)images Width:(NSInteger)width;

+(NSMutableArray*)getImageIds3:(NSString*)images;

+(NSString*)getImgUrl:(NSString*)imageid;

+(NSString*)getImageString:(NSString*)imageids;

+(NSString*)getImageUrlString:(NSString*)imageid Width:(NSInteger)width Height:(NSInteger)height;

+(NSString*)getImageOneId:(NSString*)imageids;

@end
