//
//  TempData.m
//  NewXMPPTest
//
//  Created by Tolecen on 13-7-23.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import "TempData.h"

@implementation TempData
static TempData *sharedInstance=nil;

+(TempData *) sharedInstance
{
    @synchronized(self)
    {
        if(!sharedInstance)
        {
            sharedInstance=[[self alloc] init];
            [sharedInstance initThis];
        }
        return sharedInstance;
    }
}
-(void)initThis
{
    self.wxAlreadydidClickniehe = YES;
    latitude = 0;
    longitude = 0;
    self.registerNeedMsg = YES;
    self.passBindingRole = NO;
    self.isSoundOpen =YES;
    self.isVibration = YES;
    self.isShowOpenImg = YES;
    self.isBindingRoles = YES;
    self.isShowOpenImg = YES;
    self.token=[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken];
}

-(void)isBindingRolesWithBool:(BOOL)isYes
{
    self.isBindingRoles = isYes;
}
-(void)ChangeShowOpenImg:(BOOL)isYes
{
    self.isShowOpenImg = isYes;
}

-(void)setLat:(double)lat Lon:(double)lon
{
    latitude = lat;
    longitude = lon;
}
-(double)returnLat
{
    return latitude;
}
-(double)returnLon
{
    return longitude;
}
-(NSString*)getMyUserID
{
    if (!self.myUserID) {
        self.myUserID = [[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID];
    }
    return self.myUserID;
}
- (BOOL)isHaveLogin
{
    //    if ([SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil]) {//登录
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] && [[NSUserDefaults standardUserDefaults] objectForKey:kMyToken]) {
        return YES;
    }
    return NO;
}
@end
