//
//  NetManager.m
//  PetGroup
//
//  Created by Tolecen on 13-8-20.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import "NetManager.h"
#import "JSON.h"

#define CompressionQuality 1  //图片上传时压缩质量

@implementation NetManager
//post请求，需自己设置失败提示
+(void)requestWithURLStr:(NSString *)urlStr Parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, id error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager POST:urlStr parameters:parameters
    success:^(AFHTTPRequestOperation *operation, id dict) {
//        NSString *receiveStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSDictionary * dict = [receiveStr JSONValue];
        NSLog(@"获得数据：%@", dict);
        int status = [[dict objectForKey:@"errorcode"] intValue];
        if (status==0) {
            success(operation,[dict objectForKey:@"entity"]);
        }
        else
        {
            NSDictionary* failDic = [NSDictionary dictionaryWithObjectsAndKeys:KISDictionaryHaveKey(dict, @"entity"), kFailMessageKey, KISDictionaryHaveKey(dict, @"errorcode"), kFailErrorCodeKey, nil];
            if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"errorcode")] isEqualToString:@"100001"])
            {//token无效
                NSLog(@"token invalid");
                [self getTokenStatusMessage];
                [GameCommon loginOut];
            }
            failure(operation, failDic);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation,error);
    }];
}

+ (void)getTokenStatusMessage
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] ? [[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] : @"",@"token", nil];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"141" forKey:@"method"];
    [postDict setObject:dic forKey:@"params"];
    [self requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIAlertView* al = [[UIAlertView alloc] initWithTitle:@"提示" message:responseObject delegate:nil
                           cancelButtonTitle:@"确定"
                           otherButtonTitles: nil];
        [al show];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}

//下载图片
//+(void)downloadImageWithBaseURLStr:(NSString *)url ImageId:(NSString *)imgId completion:(void(^)(NSURLResponse *response, NSURL *filePath, NSError *error))completion
//{
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    NSString * downLoadUrl = [NSString stringWithFormat:@"%@",url];
//    NSURL *URL = [NSURL URLWithString:downLoadUrl];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil
//    destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//         NSString *path = [RootDocPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",imgId]];
//         NSURL *pathUrl = [[NSURL alloc]initFileURLWithPath:path];
//        return pathUrl;
//    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//        completion(response,filePath,error);
//    }];
//    [downloadTask resume];
    
    
    
    
//    NSString * downLoadUrl = [NSString stringWithFormat:@"%@",url];
//    NSURL *URL = [NSURL URLWithString:downLoadUrl];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    NSString *path = [RootDocPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",imgId]];
//    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"sasa%@",responseObject);
//    }
//       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//           
//       }];
//    [operation start];
//}



////下载图片
//+(void)downloadImageWithBaseURLStr:(NSString *)url ImageId:(NSString *)imgId success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
//{
    //    NSString * downLoadUrl = [NSString stringWithFormat:@"%@%@",url,imgId];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downLoadUrl]];
    //    AFImageRequestOperation *operation;
    //    [AFImageRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"multipart/form-data"]];
    //    operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:nil success:success  failure:failure];
    //    [operation start];
//}


//NSString * gen_uuid()
//{
//    
//    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
//    
//    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
//    
//    
//    CFRelease(uuid_ref);
//    
//    NSString *uuid =  [[NSString  alloc]initWithCString:CFStringGetCStringPtr(uuid_string_ref, 0) encoding:NSUTF8StringEncoding];
//    
//    uuid = [uuid stringByReplacingOccurrencesOfString:@"-"withString:@""];
//    
//    CFRelease(uuid_string_ref);
//    
//    return uuid;
//}
//#pragma mark 上传注册时头像
//+(void)uploadImageWithRegister:(UIImage *)uploadImage WithURLStr:(NSString *)urlStr ImageName:(NSString *)imageName TheController:(UIViewController *)controller Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    AFHTTPClient *httpClient =  [NetManager getClient:urlStr];
//    NSData *imageData = [NetManager getImageDataCompressNor:uploadImage];
//    NSDictionary * dict =[NetManager getDict:@"register" imageType:@"album" compressImage:@"N" addTopImage:@"N"];
//    NSMutableURLRequest *request =[NetManager getRequest:httpClient Dict:dict ImageData:imageData ImageName:imageName];
//  [NetManager startUpload:httpClient Request:request TheController:controller Progress:block Success:success failure:failure];
//}
//
//
//#pragma mark 上传单张图片,压缩
//+(void)uploadImageWithCompres:(UIImage *)uploadImage
//                   WithURLStr:(NSString *)urlStr
//                    ImageName:(NSString *)imageName
//                TheController:(UIViewController *)controller
//                     Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    AFHTTPClient *httpClient =  [NetManager getClient:urlStr];
//    NSData *imageData = [NetManager getImageDataCompress:uploadImage W:100 H:100];
//    NSDictionary * dict =[NetManager getDict:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] imageType:@"album" compressImage:@"N" addTopImage:@"N"];
//    
//    NSMutableURLRequest *request =[NetManager getRequest:httpClient Dict:dict ImageData:imageData ImageName:imageName];
//    [NetManager startUpload:httpClient Request:request TheController:controller Progress:block Success:success failure:failure];
//}
//
//#pragma mark 上传单张图片,不压缩
///**
// *	@brief	上传单张图片
// *
// *	@param 	uploadImage 	需要上传的图片
// *	@param 	urlStr 	图片服务器地址
// *	@param 	imageName 	图片名称
// *	@param 	controller
// */
//+(void)uploadImage:(UIImage *)uploadImage
//        WithURLStr:(NSString *)urlStr
//         ImageName:(NSString *)imageName
//     TheController:(UIViewController *)controller
//          Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block
//           Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//
//{
//    
//    AFHTTPClient *httpClient=[NetManager getClient:urlStr];
//    NSData *imageData = [NetManager getImageDataCompressNor:uploadImage];
//    
//    NSDictionary * dict =[NetManager getDict:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] imageType:@"album" compressImage:@"N" addTopImage:@"N"];
//    NSLog(@"上传单张图片，参数表：%@",dict);
//    NSMutableURLRequest *request =[NetManager getRequest:httpClient Dict:dict ImageData:imageData ImageName:imageName];
//    
//   [NetManager startUpload:httpClient Request:request TheController:controller Progress:block Success:success failure:failure];
//}
//
//#pragma mark 上传单张图片,不压缩
///**
// *	@brief	上传单张图片
// *
// *	@param 	uploadImage 	需要上传的图片
// *	@param 	urlStr 	图片服务器地址
// *	@param 	imageName 	图片名称
// *	@param 	controller
// */
//-(void)uploadImage:(UIImage *)uploadImage
//        WithURLStr:(NSString *)urlStr
//         ImageName:(NSString *)imageName
//     TheController:(UIViewController *)controller
//          Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block
//           Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//
//{
//    NSURL *url = [NSURL URLWithString:urlStr];
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
//    
//    UIImage * a = [NetManager compressImage:uploadImage targetSizeX:640 targetSizeY:1136];
//    NSData *imageData = UIImageJPEGRepresentation(a, CompressionQuality);
//    
//   NSDictionary * dict =[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID],@"userid",@"album",@"type",@"N",@"compressImage",@"N",@"addTopImage", gen_uuid(), @"sn",nil];
//    NSLog(@"上传单张图片，参数表：%@",dict);
//    
//    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"" parameters:dict constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
//        [formData appendPartWithFileData:imageData name:@"file" fileName:imageName mimeType:@"image/jpeg"];
//    }];
//    [self startUpload:httpClient Request:request TheController:controller Progress:block Success:success failure:failure];
//}
//
//
//////开始执行上传图片
//-(void)startUpload:(AFHTTPClient *)httpClient Request:(NSMutableURLRequest *)request TheController:(UIViewController *)controller
//          Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block
//           Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setUploadProgressBlock:block];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        if (controller) {
//            NSString *receiveStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
//            NSDictionary * dict = [receiveStr JSONValue];
//            int status = [[dict objectForKey:@"errorcode"] intValue];
//            if (status==0) {
//                success(operation,[dict objectForKey:@"entity"]);
//            }
//            else
//            {
//                NSLog(@"上传图片失败Errorcode:%@",[dict objectForKey:@"errorcode"]);
//                failure(operation,nil);
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"上传图片Failure");
//        if (controller) {
//            failure(operation,error);
//        }
//    }];
//    [httpClient enqueueHTTPRequestOperation:operation];
//}
//
//
//#pragma mark 上传单张妹子图片
//+(void)uploadGrilImage:(UIImage *)uploadImage WithURLStr:(NSString *)urlStr ImageName:(NSString *)imageName TheController:(UIViewController *)controller Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    AFHTTPClient *httpClient=[NetManager getClient:urlStr];
//    NSData *imageData = [NetManager getImageDataCompressNor:uploadImage];
//    NSDictionary * dict =[NetManager getDict:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] imageType:@"girl" compressImage:@"N" addTopImage:@"N"];
//    NSLog(@"上传单张图片，参数表：%@",dict);
//    NSMutableURLRequest *request =[NetManager getRequest:httpClient Dict:dict ImageData:imageData ImageName:imageName];
//   [NetManager startUpload:httpClient Request:request TheController:controller Progress:block Success:success failure:failure];
//}
//#pragma mark 上传多张图片，压缩
//+(void)uploadImagesWithCompres:(NSArray *)imageArray WithURLStr:(NSString *)urlStr ImageName:(NSArray *)imageNameArray TheController:(UIViewController *)controller Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation,  NSDictionary *responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    NSMutableDictionary * reponseStrArray = [NSMutableDictionary dictionary];
//    for (int i = 0; i<imageArray.count; i++) {
//        [NetManager uploadImageWithCompres:[imageArray objectAtIndex:i] WithURLStr:urlStr ImageName:[imageNameArray objectAtIndex:i] TheController:controller Progress:block Success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSString *response = [GameCommon getNewStringWithId:responseObject];
//            [reponseStrArray setObject:response forKey:[imageNameArray objectAtIndex:i]];//图片id
//            if (reponseStrArray.count==imageArray.count) {
//                if (controller) {
//                    success(operation,reponseStrArray);
//                }
//                
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            if (controller) {
//                failure(operation,error);
//            }
//        }];
//    }
//}
//#pragma mark 上传多张图片，不压缩
//+(void)uploadImages:(NSArray *)imageArray WithURLStr:(NSString *)urlStr ImageName:(NSArray *)imageNameArray TheController:(UIViewController *)controller Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation,  NSDictionary *responseObject))success
//            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    NSMutableDictionary * reponseStrArray = [NSMutableDictionary dictionary];
//    for (int i = 0; i<imageArray.count; i++) {
//        [NetManager uploadImage:[imageArray objectAtIndex:i] WithURLStr:urlStr ImageName:[imageNameArray objectAtIndex:i] TheController:controller Progress:block Success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSString *response = [GameCommon getNewStringWithId:responseObject];//图片id
//            [reponseStrArray setObject:response forKey:[imageNameArray objectAtIndex:i]];
//            if (reponseStrArray.count==imageArray.count) {
//                if (controller) {
//                    success(operation,reponseStrArray);
//                }
//                
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            if (controller) {
//                failure(operation,error);
//            }
//        }];
//    }
//}
//
//
////没有压缩的图片
//+(NSData *) getImageDataCompressNor:(UIImage *)uploadImage
//{
//    UIImage * a = [NetManager compressImage:uploadImage targetSizeX:640 targetSizeY:1136];
//    NSData *imageData = UIImageJPEGRepresentation(a, CompressionQuality);
//    return imageData;
//}
//
////根据宽高压缩图片
//+(NSData *) getImageDataCompress:(UIImage *)uploadImage W:(CGFloat)width H:(CGFloat)height
//{
//    UIImage* a = [NetManager compressImageDownToPhoneScreenSize:uploadImage targetSizeX:width targetSizeY:height];
//    UIImage* upImage = [NetManager image:a centerInSize:CGSizeMake(width, height)];
//    NSData *imageData = UIImageJPEGRepresentation(upImage, 1);
//    return imageData;
//}
////AFHTTPClient
//+(AFHTTPClient *) getClient:(NSString *)urlStr
//{
//    NSURL *url = [NSURL URLWithString:urlStr];
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
//    return httpClient;
//}
//
////NSMutableURLRequest
//+(NSMutableURLRequest *)getRequest:(AFHTTPClient *)httpClient Dict:(NSDictionary *)dict ImageData:(NSData *)imageData ImageName:(NSString *)imageName
//{
//    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"" parameters:dict constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
//        [formData appendPartWithFileData:imageData name:@"file" fileName:imageName mimeType:@"image/jpeg"];
//    }];
//    return request;
//}
////上传配置
//+(NSDictionary *) getDict:(NSString *)userid imageType:(NSString *)imageType compressImage:(NSString *)compressImage addTopImage:(NSString *)addTopImage
//{
//    return [NSDictionary dictionaryWithObjectsAndKeys:userid,@"userid",imageType,@"type",compressImage,@"compressImage",addTopImage,@"addTopImage", gen_uuid(), @"sn",nil];
//}
//
//////开始执行上传图片
//+(void)startUpload:(AFHTTPClient *)httpClient Request:(NSMutableURLRequest *)request TheController:(UIViewController *)controller
//          Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block
//           Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setUploadProgressBlock:block];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//        if (controller) {
//            NSString *receiveStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
//            NSDictionary * dict = [receiveStr JSONValue];
//            int status = [[dict objectForKey:@"errorcode"] intValue];
//            if (status==0) {
//                success(operation,[dict objectForKey:@"entity"]);
//            }
//            else
//            {
//                NSLog(@"上传图片失败Errorcode:%@",[dict objectForKey:@"errorcode"]);
//                failure(operation,nil);
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"上传图片Failure");
//        if (controller) {
//            failure(operation,error);
//        }
//    }];
//    [httpClient enqueueHTTPRequestOperation:operation];
//}
//
//
//+(void)uploadWaterMarkImages:(NSArray *)imageArray WithURLStr:(NSString *)urlStr ImageName:(NSArray *)imageNameArray TheController:(UIViewController *)controller Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation,  NSDictionary *responseObject))success
//                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    NSMutableDictionary * reponseStrArray = [NSMutableDictionary dictionary];
//    for (int i = 0; i<imageArray.count; i++) {
//        [NetManager uploadWaterMarkImage:[imageArray objectAtIndex:i] WithURLStr:urlStr ImageName:[imageNameArray objectAtIndex:i] TheController:controller Progress:block Success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSString *response = responseObject;
//            [reponseStrArray setObject:response forKey:[imageNameArray objectAtIndex:i]];
//            if (reponseStrArray.count==imageArray.count) {
//                if (controller) {
//                    success(operation,reponseStrArray);
//                }
//                
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            if (controller) {
//                failure(operation,error);
//            }
//        }];
//    }
//}
//+(void)uploadWaterMarkImage:(UIImage *)uploadImage WithURLStr:(NSString *)urlStr ImageName:(NSString *)imageName TheController:(UIViewController *)controller Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    NSURL *url = [NSURL URLWithString:urlStr];
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
//    UIImage * a = [NetManager compressImage:uploadImage targetSizeX:640 targetSizeY:1136];
//    NSData *imageData = UIImageJPEGRepresentation(a, CompressionQuality);
//    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:@"OK",@"compressImage",@"OK",@"addTopImage", nil];
//    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"" parameters:dict constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
//        [formData appendPartWithFileData:imageData name:@"file" fileName:imageName mimeType:@"image/jpeg"];
//    }];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setUploadProgressBlock:block];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if (controller) {
//            NSString *receiveStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
//            NSDictionary * dict = [receiveStr JSONValue];
//            int status = [[dict objectForKey:@"errorcode"] intValue];
//            if (status==0) {
//                success(operation,[dict objectForKey:@"entity"]);
//            }
//            else
//            {
//                failure(operation,nil);
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if (controller) {
//            failure(operation,error);
//        }
//    }];
//    [httpClient enqueueHTTPRequestOperation:operation];
//}
//
//
//+(void)uploadAudioFileData:(NSData *)audioData WithURLStr:(NSString *)urlStr AudioName:(NSString *)audioName TheController:(UIViewController *)controller Success:(void (^)(AFHTTPRequestOperation *operation,  id responseObject))success
//                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    NSURL *url = [NSURL URLWithString:urlStr];
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
//    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"" parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
//        [formData appendPartWithFileData:audioData name:@"file" fileName:audioName mimeType:@"audio/amr"];
//    }];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if (controller) {
//            success(operation,responseObject);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if (controller) {
//            failure(operation,error);
//        }
//    }];
//    [httpClient enqueueHTTPRequestOperation:operation];
//}
//
//+(void)downloadAudioFileWithURL:(NSString *)downloadURL FileName:(NSString *)audioName TheController:(UIViewController *)controller Success:(void (^)(AFHTTPRequestOperation *operation,  id responseObject))success
//                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[downloadURL stringByAppendingString:audioName]]];
//    AFHTTPRequestOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        success(operation,responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//    [operation start];;
//}



//图片压缩 两个方法组合
+(UIImage*)compressImageDownToPhoneScreenSize:(UIImage*)theImage targetSizeX:(CGFloat) sizeX targetSizeY:(CGFloat) sizeY
{
	
	UIImage * bigImage = theImage;
	
	float actualHeight = bigImage.size.height;
	float actualWidth = bigImage.size.width;
	
	float imgRatio = actualWidth / actualHeight;
	if(actualWidth > sizeX || actualHeight > sizeY)
	{
		float maxRatio = sizeX / sizeY;
		
		if(imgRatio < maxRatio){
            imgRatio = sizeX / actualWidth;
			actualHeight = imgRatio * actualHeight;
			actualWidth = sizeX;
		} else {
            imgRatio = sizeY / actualHeight;
			actualWidth = imgRatio * actualWidth;
			actualHeight = sizeY;
            
		}
        
	}
	CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
	UIGraphicsBeginImageContext(rect.size);
	[bigImage drawInRect:rect];  // scales image to rect
	theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}

//将原图显示为指定大小。先按比例缩放，再居中裁剪
+ (UIImage *) image: (UIImage *) image centerInSize: (CGSize) viewsize
{
	CGSize size = image.size;
	
    float dwidth = 0.0f;
    float dheight = 0.0f;
    float rate = 0.0f;
    
    if (size.width> size.height) //宽为长边
    {
        if (size.width < viewsize.width)
        {
            return image;
        }
        rate = viewsize.height / size.height;
        float w = rate * size.width;
        
        dwidth = (viewsize.width - w) / 2.0f;
        dheight = 0;
    }
    else    //长为长边
    {
        if (size.height< viewsize.height)
        {
            return image;
        }
        rate = viewsize.width / size.width;
        float h = rate * size.height;
        dwidth = 0;
        dheight = (viewsize.height - h) /2.0f;
        
    }
    CGRect rect = CGRectMake(dwidth, dheight, size.width*rate, size.height*rate);
	UIGraphicsBeginImageContext(viewsize);
	[image drawInRect:rect];  // scales image to rect
	UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
    return newimg;
}
//将原图显示为指定大小。先按比例缩放，再居中裁剪
+ (UIImage *) image2: (UIImage *) image centerInSize: (CGSize) viewsize
{
	CGSize size = image.size;
    float dwidth = 0.0f;
    float dheight = 0.0f;
    float rate = 0.0f;
    
    float rate1 = viewsize.height / size.height;
    float rate2  = viewsize.width / size.width;
    if(rate1>rate2){
        rate=rate1;
        float w = rate * size.width;
        dwidth = (viewsize.width - w) / 2.0f;
        dheight = 0;
    }else{
        rate=rate2;
        float w = rate * size.height;
        dheight = (viewsize.height - w) / 2.0f;
        dwidth = 0;
    }
    CGRect rect = CGRectMake(dwidth, dheight, size.width*rate, size.height*rate);
	UIGraphicsBeginImageContext(viewsize);
	[image drawInRect:rect];  // scales image to rect
	UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return newimg;
}





//图片压缩 设置最宽，按比例压缩
+(UIImage*)compressImage:(UIImage*)theImage targetSizeX:(CGFloat) sizeX targetSizeY:(CGFloat) sizeY
{
	
	UIImage * bigImage = theImage;
	
	float actualHeight = bigImage.size.height;
	float actualWidth = bigImage.size.width;
	
	float imgRatio = actualWidth / actualHeight;
    
    if (actualWidth > sizeX) {
        imgRatio = sizeX / actualWidth;
        actualHeight = imgRatio * actualHeight;
        actualWidth = sizeX;
    }
    
	CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
	UIGraphicsBeginImageContext(rect.size);
	[bigImage drawInRect:rect];  // scales image to rect
	theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    NSLog(@"%f==%f",theImage.size.width,theImage.size.height);
	return theImage;
}
@end
