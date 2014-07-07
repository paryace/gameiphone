//
//  TempData.h
//  NewXMPPTest
//
//  Created by Tolecen on 13-7-23.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempData : NSObject
{

    double latitude;
    double longitude;
    
}
@property (retain,nonatomic)NSString* myUserID;
@property (nonatomic,assign)BOOL registerNeedMsg;//是否需要验证码
@property (nonatomic,assign)BOOL passBindingRole;//注册时是否跳过绑定角色
@property (nonatomic,assign)BOOL wxAlreadydidClickniehe;//捏合返回首页手势提示
@property (nonatomic,retain)NSString * characterID;//注册时的角色ID
@property (nonatomic,retain)NSString * gamerealm;//注册时的服务器名
@property (nonatomic,retain)NSString * token;
@property(nonatomic,assign)BOOL isSoundOpen;//是否打开声音
@property(nonatomic,assign)BOOL isVibration;//是否打开震动
@property(nonatomic,assign)BOOL isBindingRoles;//是否绑定角色
@property (nonatomic,assign)BOOL isShowOpenImg;
+ (id)sharedInstance;
-(void)setLat:(double)lat Lon:(double)lon;
-(void)isBindingRolesWithBool:(BOOL)isYes;
-(void)ChangeShowOpenImg:(BOOL)isYes;
-(double)returnLat;//经度
-(double)returnLon;//纬度
-(NSString*)getMyUserID;
- (BOOL)isHaveLogin;
@end
