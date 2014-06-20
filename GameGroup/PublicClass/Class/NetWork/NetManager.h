//
//  NetManager.h
//  PetGroup
//
//  Created by Tolecen on 13-8-20.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFURLSessionManager.h"

#define kFailMessageKey @"failMessage"
#define kFailErrorCodeKey @"failErrorCode"
#define kErrorMessage @"NSLocalizedDescription"
//联网

@interface NetManager : NSObject



+(void)requestWithURLStr:(NSString *)urlStr Parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
    failure:(void (^)(AFHTTPRequestOperation *operation, id error))failure;

+(UIImage*)compressImageDownToPhoneScreenSize:(UIImage*)theImage targetSizeX:(CGFloat) sizeX targetSizeY:(CGFloat) sizeY;

+(UIImage*)compressImage:(UIImage*)theImage targetSizeX:(CGFloat) sizeX targetSizeY:(CGFloat) sizeY; //图片压缩 设置最宽，按比例压缩

+ (UIImage *) image: (UIImage *) image centerInSize: (CGSize) viewsize; //剪裁中央区域
+ (UIImage *) image2: (UIImage *) image centerInSize: (CGSize) viewsize; //剪裁中央区域


+ (void)getTokenStatusMessage;

+(void)downloadImageWithBaseURLStr:(NSString *)url ImageId:(NSString *)imgId completion:(void(^)(NSURLResponse *response, NSURL *filePath, NSError *error))completion;//下载文件

//+(void)downloadAudioFileWithURL:(NSString *)downloadURL FileName:(NSString *)audioName TheController:(UIViewController *)controller Success:(void (^)(AFHTTPRequestOperation *operation,  id responseObject))success
//                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
//#pragma mark 上传单张妹子图片
//+(void)uploadGrilImage:(UIImage *)uploadImage WithURLStr:(NSString *)urlStr ImageName:(NSString *)imageName TheController:(UIViewController *)controller Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
////上传注册时头像
//+(void)uploadImageWithRegister:(UIImage *)uploadImage WithURLStr:(NSString *)urlStr ImageName:(NSString *)imageName TheController:(UIViewController *)controller Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
//+(void)uploadImage:(UIImage *)uploadImage WithURLStr:(NSString *)urlStr ImageName:(NSString *)imageName TheController:(UIViewController *)controller Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
//+(void)uploadImageWithCompres:(UIImage *)uploadImage WithURLStr:(NSString *)urlStr ImageName:(NSString *)imageName TheController:(UIViewController *)controller  Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
//+(void)uploadImages:(NSArray *)imageArray WithURLStr:(NSString *)urlStr ImageName:(NSArray *)imageNameArray TheController:(UIViewController *)controller Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation, NSDictionary * responseObject))success
//            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
//+(void)uploadImagesWithCompres:(NSArray *)imageArray WithURLStr:(NSString *)urlStr ImageName:(NSArray *)imageNameArray TheController:(UIViewController *)controller Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation,  NSDictionary *responseObject))success
//                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
//
//+(void)uploadAudioFileData:(NSData *)audioData WithURLStr:(NSString *)urlStr AudioName:(NSString *)audioName TheController:(UIViewController *)controller Success:(void (^)(AFHTTPRequestOperation *operation,  id responseObject))success
//                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//-(void)uploadImage:(UIImage *)uploadImage
//        WithURLStr:(NSString *)urlStr
//         ImageName:(NSString *)imageName
//     TheController:(UIViewController *)controller
//          Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block
//           Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
////开始执行上传图片
//-(void)startUpload:(AFHTTPClient *)httpClient Request:(NSMutableURLRequest *)request TheController:(UIViewController *)controller
//          Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block
//           Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//+(void)uploadWaterMarkImages:(NSArray *)imageArray WithURLStr:(NSString *)urlStr ImageName:(NSArray *)imageNameArray TheController:(UIViewController *)controller Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation,  NSDictionary *responseObject))success
//                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
