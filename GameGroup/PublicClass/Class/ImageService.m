//
//  ImageService.m
//  GameGroup
//
//  Created by Apple on 14-5-24.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ImageService.h"

@implementation ImageService
////传入单个图片id，返回指定宽高的的完整路径
+(NSURL*)getImageUrl:(NSString*)imageid Width:(NSInteger)width Height:(NSInteger)height
{
    if ([GameCommon isPureInt:imageid]) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%d%@%d",[self getImgUrl:imageid],@"/",width,@"/",height]];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%d%@%d",[self getImgUrl:imageid],@"?imageView2/1/w/",width,@"/h/",height]];
}
//返回带宽高的图片地址String
+(NSString*)getImageUrlString:(NSString*)imageid Width:(NSInteger)width Height:(NSInteger)height
{
    if ([GameCommon isPureInt:imageid]) {
        return [NSString stringWithFormat:@"%@%@%d%@%d",[self getImgUrl:imageid],@"/",width,@"/",height];
    }
    return [NSString stringWithFormat:@"%@%@%d%@%d",[self getImgUrl:imageid],@"?imageView2/1/w/",width,@"/h/",height];
}
//传入单个图片id，返回默认宽高相等的完整图片路径
+(NSURL*)getImageUrl2:(NSString*)imageid
{
    return [self getImageUrl:imageid Width:80 Height:80];
}
//传入单个图片id，返回指定宽高相等的的完整图片路径
+(NSURL*)getImageUrl3:(NSString*)imageid Width:(NSInteger)width
{
    return [self getImageUrl:imageid Width:width Height:width];
}
//传入单个图片id，返回没有宽高的完整图片路径
+(NSURL*)getImageUrl4:(NSString*)imageid
{
    return [NSURL URLWithString:[self getImgUrl:imageid]];
}

//根据图片id集合返回第一张带宽度的完整图片路径
+(NSURL*)getImageStr:(NSString*)imageids Width:(NSInteger)width
{
    NSMutableArray *images=[self getImageIds2:imageids Width:width];
    return images.count==0?nil:[images objectAtIndex:0];
}
//根据图片id集合返回第一张的图片完整路径
+(NSURL*)getImageStr2:(NSString*)imageids
{
    return [self getImageStr:imageids Width:0];
}

//根据图片id集合返回第一张图片的完整地址
+(NSString*)getImageString:(NSString*)imageids
{
    NSMutableArray *images=[self getImageIds:imageids];
    return images.count==0?nil:[self getImgUrl:[images objectAtIndex:0]];
}

//根据图片id集合返回第一张图片的id
+(NSString*)getImageOneId:(NSString*)imageids
{
    NSMutableArray *images=[self getImageIds:imageids];
    return images.count==0?nil:[images objectAtIndex:0];
}

//根据图片id集合返回解析之后的id集合（逗号截取之后放到数组里返回）
+(NSMutableArray*)getImageIds:(NSString*)images
{
    return [self getHeardImgId:images Width:0 AllUrl:NO];
}
//根据图片id集合返回带指定宽高相等的完整地址路径集合
+(NSMutableArray*)getImageIds2:(NSString*)images Width:(NSInteger)width
{
    return [self getHeardImgId:images Width:width AllUrl:YES];
}
//根据图片id集合返回不带宽度的完整地址路径集合
+(NSMutableArray*)getImageIds3:(NSString*)images
{
    return [self getImageIds2:images Width:0];
}

//传入单个图片的id，返回拼接后的图片完整地址
+(NSString*)getImgUrl:(NSString*)imageid
{
    return [NSString stringWithFormat:@"%@%@",[self getBaseImageUrl:imageid],[GameCommon getNewStringWithId:imageid]];
}
+(NSString*)getBaseImageUrl:(NSString*)imageId
{
    if ([GameCommon isPureInt:imageId]) {
        return BaseImageUrl;
    }
    return QiniuBaseImageUrl;
}
//获取图片地址集合
+ (NSMutableArray*)getHeardImgId:(NSString*)imgs Width:(NSInteger)width AllUrl:(BOOL)allUrl
{
    NSMutableArray *imageList=[NSMutableArray array];
    if ([GameCommon isEmtity:imgs]) {
        return imageList;
    }
    if ([imgs rangeOfString:@","].location!=NSNotFound) {
        NSArray* arr = [imgs componentsSeparatedByString:@","];
        for (NSString *str in arr) {
            if (![GameCommon isEmtity:str]) {
                if (allUrl) {//返回完整路径
                    if (width>0) {//指定宽高
                        NSURL *url1=[self getImageUrl3:str Width:width];
                        if (url1) {
                            [imageList addObject:url1];
                        }
                    }else{//没有指定宽高
                        NSURL *url2=[self getImageUrl4:str];
                        if (url2) {
                            [imageList addObject:url2];
                        }
                    }
                }else{//仅返回图片id
                    [imageList addObject:str];
                }
            }
            
        }
    }else{
        if (allUrl) {//返回完整路径
            if (width>0) {//指定宽高
                NSURL *url1=[self getImageUrl3:imgs Width:width];
                if (url1) {
                    [imageList addObject:url1];
                }
                
            }else{//没有指定宽高
                NSURL *url2=[self getImageUrl4:imgs];
                if (url2) {
                    [imageList addObject:url2];
                }
            }
        }else{//仅返回图片id
            [imageList addObject:imgs];
        }
    }
    return imageList;
}
@end
