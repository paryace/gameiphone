//
//  GameCommon.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-5.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "GameCommon.h"
#import <AdSupport/AdSupport.h>
#import "Reachability.h"
#import "AppDelegate.h"

@implementation GameCommon

static GameCommon *my_gameCommon = NULL;

@synthesize wow_realms;
@synthesize emoji_array;

- (id)init
{
    self = [super init];
    if (self) {

        self.deviceToken = @"";
        
        self.wow_realms = [NSMutableDictionary dictionaryWithCapacity:1];
        self.wow_clazzs = [NSMutableArray arrayWithCapacity:1];
        
        //初始化表情
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:@"EmojiList.plist"];
        self.emoji_array = [NSArray arrayWithContentsOfFile:finalPath];
        self.emoji_dict = [[NSMutableDictionary alloc]init];
        for (int i =0; i<emoji_array.count; i++) {
            NSDictionary *dic = emoji_array[i];
            NSString *emoji = KISDictionaryHaveKey(dic, @"emoji");
            NSString *thekey = KISDictionaryHaveKey(dic, @"thekey");
            [self.emoji_dict setValue:emoji forKey:thekey];
        }
    }
    return self;
}

+ (GameCommon*)shareGameCommon
{
    @synchronized(self)
    {
		if (my_gameCommon == nil)
		{
			my_gameCommon = [[self alloc] init];
		}
	}
	return my_gameCommon;
}
//+(NSString*)getGameIconWithGameId:(NSString*)gameId
//{
//    if ([gameId isEqualToString:@"1"]) {
//        return @"";
//    }else if ([gameId isEqualToString:@"2"]){
//        return @"";
//    }
//    return @"";
//}

+(float)diffHeight:(UIViewController *)controller
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        return 0.0f;
    } else {
        // Load resources for iOS 7 or later
        if (controller) {
            [controller setNeedsStatusBarAppearanceUpdate];
        }
        
        return 20.0f;
    }
}

+ (NSString*)getNewStringWithId:(id)oldString//剔除json里的空格字段
{
    return  [[oldString description] stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - 汉字转为拼音
-(NSString *)convertChineseToPinYin:(NSString *)chineseName
{
    NSMutableString * theName = [NSMutableString stringWithString:chineseName];
    CFRange range = CFRangeMake(0, theName.length);
    CFStringTransform((CFMutableStringRef)theName, &range, kCFStringTransformToLatin, NO);
    range = CFRangeMake(0, theName.length);
    CFStringTransform((CFMutableStringRef)theName, &range, kCFStringTransformStripCombiningMarks, NO);
    NSString * dd = [theName stringByReplacingOccurrencesOfString:@" " withString:@""];
    return dd;
}

#pragma mark - 联网默认字段
-(NSString*) uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);

    NSString *uuid =  [[NSString  alloc]initWithCString:CFStringGetCStringPtr(uuid_string_ref, 0) encoding:NSUTF8StringEncoding];
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-"withString:@""];
    CFRelease(uuid_string_ref);
    
    return uuid;
}

- (NSMutableDictionary*)getNetCommomDic
{
    NSMutableDictionary* commomDic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    [commomDic setObject:version forKey:@"version"];
    
    if ([appType isEqualToString:@"91"]) {
        [commomDic setObject:@"2" forKey:@"channel"];
    }
    else
        [commomDic setObject:@"1" forKey:@"channel"];
    [commomDic setObject:[self uuid] forKey:@"sn"];//流水号
    
    if ([[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]) {
        [commomDic setObject:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] forKey:@"mac"];
    }
    else
        [commomDic setObject:@"" forKey:@"mac"];
    [commomDic setObject:@"iphone" forKey:@"imei"];

    [commomDic setObject:@"0" forKey:@"isEncrypt"];//是否加密
    [commomDic setObject:@"0" forKey:@"isCompression"];//是否压缩

    return commomDic;
}

#pragma mark -计算字符串长度
-(NSUInteger) unicodeLengthOfString: (NSString *) text
{
    NSUInteger asciiLength = 0;
    
    for (NSUInteger i = 0; i < text.length; i++)
    {
        unichar uc = [text characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;
    }
    NSUInteger unicodeLength = asciiLength / 2;
    if(asciiLength % 2)
    {
        unicodeLength++;
    }
    return unicodeLength;
}

-(NSUInteger) asciiLengthOfString: (NSString *) text
{
    NSUInteger asciiLength = 0;
    
    for (NSUInteger i = 0; i < text.length; i++)
    {
        unichar uc = [text characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;
    }
    return asciiLength;
}

#pragma mark -验证邮箱
- (BOOL)isValidateEmail:(NSString *)email {
    NSString *strRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,5}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strRegex];
    
    return [predicate evaluateWithObject:email];
}

#pragma mark -首页显示时间格式
+(NSString *)getCurrentTime{
    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    nowTime = nowTime*1000;
    return [NSString stringWithFormat:@"%lld",(long long)nowTime];
    
}
#pragma mark -周
+(NSString *)getWeakDay:(NSDate *)datetime{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSWeekCalendarUnit|NSWeekdayCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:datetime];
    switch ([comps weekday]) {
        case 1:
            return @"周日";break;
        case 2:
            return @"周一";break;
        case 3:
            return @"周二";break;
        case 4:
            return @"周三";break;
        case 5:
            return @"周四";break;
        case 6:
            return @"周五";break;
        case 7:
            return @"周六";break;
        default:
            return @"未知";break;
    }
}
#pragma mark -时间
+(NSString *)CurrentTime:(NSString *)currentTime AndMessageTime:(NSString *)messageTime
{
    NSString * finalTime;
    int theCurrentT = [currentTime intValue];
    int theMessageT = [messageTime intValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *messageDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    NSString *currentStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theCurrentT]];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"HH:mm"];
    NSString * msgT = [dateFormatter2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    NSString * nowT = [dateFormatter2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:theCurrentT]];
//    int msgHour = [[msgT substringToIndex:2] intValue];
    int hours = [[nowT substringToIndex:2] intValue];
    int minutes = [[nowT substringFromIndex:3] intValue];
    // NSLog(@"hours:%d,minutes:%d",hours,minutes);
    int currentDayBegin = theCurrentT-hours*3600-minutes*60;
    int yesterdayBegin = currentDayBegin-3600*24;
//    int qiantianBegin = yesterdayBegin-3600*24;
    int oneWeekBegin = yesterdayBegin - 6 * 24 *3600;
    //今天
    if ([currentStr isEqualToString:messageDateStr]) {
//        if (msgHour>0&&msgHour<11) {
//            finalTime = [NSString stringWithFormat:@"早上 %@",msgT];
//        }
//        else if (msgHour>=11&&msgHour<13){
//            finalTime = [NSString stringWithFormat:@"中午 %@",msgT];
//        }
//        else if(msgHour>=13&&msgHour<18) {
//            finalTime = [NSString stringWithFormat:@"下午 %@",msgT];
//        }
//        else{
//            finalTime = [NSString stringWithFormat:@"晚上 %@",msgT];
//        }
        finalTime = [NSString stringWithFormat:@"%@",msgT];
    }
    //昨天
    else if(theMessageT>=yesterdayBegin&&theMessageT<currentDayBegin){
//        if (msgHour>0&&msgHour<11) {
//            finalTime = @"昨天早上";
//        }
//        else if (msgHour>=11&&msgHour<13){
//            finalTime = @"昨天中午";
//        }
//        else if(msgHour>=13&&msgHour<18) {
//            finalTime = @"昨天下午";
//        }
//        else{
//            finalTime = @"昨天晚上";
//        }
        finalTime = @"昨天";
    }
    //一周以内
    else if (theMessageT-oneWeekBegin < 7 * 24 * 3600)
    {
        NSDate * msgDate = [NSDate dateWithTimeIntervalSince1970:theMessageT];
        NSString * weekday = [GameCommon getWeakDay:msgDate];
      
        finalTime = [NSString stringWithFormat:@"%@",weekday];
    }
//    //今年
//    else if([[messageDateStr substringToIndex:4] isEqualToString:[currentStr substringToIndex:4]]){
//        finalTime = [NSString stringWithFormat:@"%@月%@日",[[messageDateStr substringFromIndex:5] substringToIndex:2],[messageDateStr substringFromIndex:8]];
//    }
//    else
//    {
//        finalTime = messageDateStr;
//    }
    else
        finalTime = [NSString stringWithFormat:@"%@-%@-%@",[[messageDateStr substringFromIndex:2] substringToIndex:2] ,[[messageDateStr substringFromIndex:5] substringToIndex:2],[messageDateStr substringFromIndex:8]];

    // NSLog(@"finalTime:%@",finalTime);
    return finalTime;
}

+(NSString *)getTimeWithChatStyle:(NSString *)currentTime AndMessageTime:(NSString *)messageTime
{
    NSString * finalTime;
    int theCurrentT = [currentTime intValue];
    int theMessageT = [messageTime intValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *messageDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    NSString *currentStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theCurrentT]];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"HH:mm"];
    
    NSString * msgT = [dateFormatter2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    NSString * nowT = [dateFormatter2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:theCurrentT]];
    int hours = [[nowT substringToIndex:2] intValue];
    int minutes = [[nowT substringFromIndex:3] intValue];
    int currentDayBegin = theCurrentT-hours*3600-minutes*60;
    int yesterdayBegin = currentDayBegin-3600*24;
    int yearDay =[[[messageDateStr substringFromIndex:0] substringToIndex:4]intValue];
    int yearBegin =[[[currentStr substringFromIndex:0] substringToIndex:4]intValue];
    
    //今天
    if ([currentStr isEqualToString:messageDateStr]) {
    
        finalTime = [NSString stringWithFormat:@"%@",msgT];
    }
    //昨天
    else if(theMessageT>=yesterdayBegin&&theMessageT<currentDayBegin){
      
        finalTime = [NSString stringWithFormat:@"昨天 %@",msgT];
    }
  
    else if(yearDay !=yearBegin){
        finalTime = [NSString stringWithFormat:@"%@年%@月%@日 %@",
                     [[messageDateStr substringFromIndex:0] substringToIndex:4],
                     [[messageDateStr substringFromIndex:5] substringToIndex:2],
                     [messageDateStr substringFromIndex:8],
                     msgT];

    }else
        finalTime = [NSString stringWithFormat:@"%@-%@", [[messageDateStr substringFromIndex:5] substringToIndex:2],[messageDateStr substringFromIndex:8]];
    return finalTime;
}


+ (NSString*)getTimeWithMessageTime:(NSString*)messageTime
{
    NSString* currentString = [GameCommon getCurrentTime];
    if ([NSString stringWithFormat:@"%.f", [messageTime doubleValue]].length < 10 || [NSString stringWithFormat:@"%.f", [currentString doubleValue]].length < 10) {
        return @"未知";
    }
    NSString * finalTime;
    NSString* curStr = [currentString substringToIndex:messageTime.length-3];
    NSString* mesStr = [messageTime substringToIndex:messageTime.length-3];
    
    double theCurrentT = [curStr doubleValue];
    double theMessageT = [mesStr doubleValue];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *messageDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    
    NSString *currentStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theCurrentT]];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"HH:mm"];
    
    NSString * msgT = [dateFormatter2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    
    NSString * nowT = [dateFormatter2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:theCurrentT]];
    int msgHour = [[msgT substringToIndex:2] intValue];
    int msgmin = [[msgT substringFromIndex:3] intValue];
//    int msgDay = [[messageDateStr substringFromIndex:8] intValue];

    int hours = [[nowT substringToIndex:2] intValue];
    int minutes = [[nowT substringFromIndex:3] intValue];
//    int day = [[currentStr substringFromIndex:8] intValue];

//    int currentDayBegin = theCurrentT-hours*3600-minutes*60;
//    int yesterdayBegin = currentDayBegin-3600*24;

    //今天
    if ([currentStr isEqualToString:messageDateStr] && msgHour == hours) {
        if (minutes-msgmin<=0) {
            finalTime = @"1分钟前";
        }
        else{
            finalTime = [NSString stringWithFormat:@"%d分钟前",(minutes-msgmin)];
        }
    }
    else if ([currentStr isEqualToString:messageDateStr]) {
           finalTime = [NSString stringWithFormat:@"%d小时前",(hours-msgHour)];
    }
    //昨天
//    else if(theMessageT>=yesterdayBegin&&theMessageT<currentDayBegin){
//        finalTime = @"昨天";
//    }
    else
    {
        if ((theCurrentT-theMessageT)/86400 <= 0) {
            finalTime = @"1天前";
        }
        else
            finalTime = [NSString stringWithFormat:@"%.f天前",(theCurrentT-theMessageT)/86400];
        if ([finalTime isEqualToString:@"0天前"]) {
            finalTime = @"1天前";
        }
    }
    return finalTime;

}

- (NSString*)getDataWithTimeInterval:(NSString*)timeInterval
{
    if ([NSString stringWithFormat:@"%.f", [timeInterval doubleValue]].length < 10) {
        return timeInterval;
    }
    NSString* timeStr = [timeInterval substringToIndex:timeInterval.length-3];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];//location设置为中国
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    double time = [timeStr doubleValue];
    NSLog(@"%@", [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]]);
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

+ (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}



+ (NSString*)getTimeAndDistWithTime:(NSString*)time Dis:(NSString*)distrance
{
    double dis = [distrance doubleValue];
    double gongLi = dis/1000;

    NSString* allStr = @"";
    if (gongLi < 0 || gongLi == 9999) {//距离-1时 存的9999000
        allStr = [allStr stringByAppendingFormat:@"未知 | %@" , [GameCommon getTimeWithMessageTime:time]];
    }
    else
       allStr = [allStr stringByAppendingFormat:@"%.2fkm | %@", gongLi , [GameCommon getTimeWithMessageTime:time]];
    
    return allStr;
}

#pragma mark 动态时间格式
+(NSString *)dynamicListCurrentTime:(NSString *)currentTime AndMessageTime:(NSString *)messageTime
{
    NSDateFormatter * dateF= [[NSDateFormatter alloc]init];
    dateF.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [dateF dateFromString:messageTime];
    NSTimeInterval theMessageT = [date timeIntervalSince1970];
    int theCurrentT = [currentTime intValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *messageDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    NSString *currentStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theCurrentT]];
    if ([messageDateStr isEqualToString:currentStr]) {
        return @"今天";
    }
    if ([[messageDateStr substringToIndex:8] isEqualToString:[currentStr substringToIndex:8]]&&[[currentStr substringFromIndex:8]intValue] -[[messageDateStr substringFromIndex:8] intValue] == 1) {
        return @"昨天";
    }
    return [messageDateStr substringFromIndex:5];
}
+(NSString *)DynamicCurrentTime:(NSString *)currentTime AndMessageTime:(NSString *)messageTime
{
    NSDateFormatter * dateF= [[NSDateFormatter alloc]init];
    dateF.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [dateF dateFromString:messageTime];
    NSTimeInterval theMessageT = [date timeIntervalSince1970];
    
    NSString * finalTime;
    int theCurrentT = [currentTime intValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *messageDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    NSString *currentStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theCurrentT]];
    NSString *chaStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theCurrentT - theMessageT]];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"HH:mm"];
    NSString * msgT = [dateFormatter2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    NSString * nowT = [dateFormatter2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:theCurrentT]];
    if ([messageDateStr isEqualToString:currentStr]) {
        int hours = [[nowT substringToIndex:2] intValue];
        int msgHour = [[msgT substringToIndex:2] intValue];
        if (msgHour == hours) {
            int minutes = [[nowT substringFromIndex:3] intValue];
            int msgMin = [[msgT substringFromIndex:3] intValue];
            if (msgMin == minutes) {
                finalTime = @"1分钟内";
            }else{
                finalTime = [NSString stringWithFormat:@"%d分钟前",minutes - msgMin];
            }
        }else{
            finalTime = [NSString stringWithFormat:@"%d小时前",hours - msgHour];
        }
    }else if([[messageDateStr substringToIndex:7] isEqualToString:[currentStr substringToIndex:7]]){
        int msgDay = [[messageDateStr substringFromIndex:8] integerValue];
        int day = [[currentStr substringFromIndex:8] integerValue];
        finalTime = [NSString stringWithFormat:@"%d天前",day - msgDay];
    }else if([[chaStr substringToIndex:7] isEqualToString:@"1970-01"]){
        int day = [[chaStr substringFromIndex:8] integerValue];
        finalTime = [NSString stringWithFormat:@"%d天前",day];
    }else if([[messageDateStr substringToIndex:4] isEqualToString:[currentStr substringToIndex:4]]){
        int msgMonth = [[[messageDateStr substringToIndex:7] substringFromIndex:5]integerValue];
        int month = [[[currentStr substringToIndex:7] substringFromIndex:5]integerValue];
        finalTime = [NSString stringWithFormat:@"%d月前",month - msgMonth];
    }else{
        finalTime = messageDateStr;
    }
    return finalTime;
}

#pragma mark - 获得头衔字色
+(UIColor*)getAchievementColorWithLevel:(NSUInteger)level
{
    UIColor* color;
    switch (level) {
        case 1:
            color = kColorWithRGB(227, 53, 0, 1.0);//红色
            break;
        case 2:
            color = kColorWithRGB(225, 73, 21, 1.0);//橙色
            break;
        case 3:
            color = kColorWithRGB(103, 4, 146, 1.0);//紫色
            break;
        case 4:
            color = kColorWithRGB(0, 153, 255, 1.0);//蓝色
            break;
        case 5:
            color = kColorWithRGB(14, 132, 0, 1.0);//绿色
            break;
        case 6:
            color = kColorWithRGB(102, 102, 102, 1.0);//灰色
            break;
        default:
            break;
    }
    return color;
}

#pragma mark 获得头像
+ (NSString*)getHeardImgId:(NSString*)img
{
    if ([img isEqualToString:@""] || [img isEqualToString:@" "]) {
        return @"";
    }
    NSArray* arr = [img componentsSeparatedByString:@","];
    if ([arr count] != 0) {
        return [arr objectAtIndex:0];
    }
    return @"";
}
+(NSArray*)getGameids:(NSString*)gameids
{
    if ([self isEmtity:gameids]) {
        return nil;
    }
   return [gameids componentsSeparatedByString:@","];
}

//+(NSString *)isNewOrOldWithImage:(NSString *)imgStr
//{
//    unichar c;
//    for (int i=0; i<imgStr.length; i++) {
//        c=[imgStr characterAtIndex:i];
//        if (!isdigit(c)) {
//            return NewBaseImageUrl;
//        }
//    }
//    return BaseImageUrl;
//}

//+(NSString *)isNewOrOldWithImage:(NSString *)imgStr width:(int)width hieght:(int)hieght a:(NSString*)a
//{
//    unichar c;
//    for (int i=0; i<imgStr.length; i++) {
//        c=[imgStr characterAtIndex:i];
//        if (!isdigit(c)) {
//            return [NSString stringWithFormat:@"%@%@?w=%d&h=%d",NewBaseImageUrl,imgStr,width,hieght];
//        }
//    }
//    return [NSString stringWithFormat:@"%@%@/%@",BaseImageUrl,imgStr,a];
//}



#pragma mark MyNews - tabBar小红点
-(void)displayTabbarNotification
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:haveMyNews])
    {
        int value = [[[NSUserDefaults standardUserDefaults] objectForKey:haveMyNews] intValue];
        if (value!=0) {
            [[Custom_tabbar showTabBar] notificationWithNumber:NO AndTheNumber:0 OrDot:YES WithButtonIndex:2];
        }
        else
        {
            [[Custom_tabbar showTabBar] removeNotificatonOfIndex:2];
        }
    }
    else
    {
        [[Custom_tabbar showTabBar] removeNotificatonOfIndex:2];
    }
}
#pragma mark 粉丝数变化
- (void)fansCountChanged:(BOOL)addOne
{
    NSString* fansCout = @"";
    if ([[NSUserDefaults standardUserDefaults] objectForKey:FansCount]) {
        fansCout = [[NSUserDefaults standardUserDefaults] objectForKey:FansCount];
    }
    NSInteger fansInt = addOne ? [fansCout integerValue] + 1 : [fansCout integerValue] - 1;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d", fansInt] forKey:FansCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark 注销
+ (void)loginOut
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:isFirstOpen];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:isFirstIntoMePage];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FansCount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:NearByKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isGetNearByDataByNet"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"topImageData_wx"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"wx_buttonTitleOfPage"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sayHello_wx_info_id"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"wx_buttonTitleOfPage"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"find_initial_game"];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:haveMyNews];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:haveFriendNews];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:PhoneNumKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"active_wx"];
//    [SFHFKeychainUtils deleteItemForUsername:ACCOUNT andServiceName:LOCALACCOUNT error:nil];
   // [SFHFKeychainUtils deleteItemForUsername:PASSWORD andServiceName:LOCALACCOUNT error:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMyToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMYUSERID];
    AppDelegate* app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TempData * tempData = [TempData sharedInstance];
    tempData.myUserID = nil;
    
    [app.xmppHelper disconnect];
}

+(NSString *)putoutgameIconWithGameId:(NSString *)gameid
{
    NSString *str = [NSString stringWithFormat:@"id%@",gameid];
    NSString *filePath  =[RootDocPath stringByAppendingString:@"/gameicon_wx"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return [self getNewStringWithId: KISDictionaryHaveKey(dic, str)];
}
+(NSString*) getMsgSettingStateByGroupId:(NSString*)groupId
{
    if ([GameCommon isEmtity:[[NSUserDefaults standardUserDefaults] objectForKey:[self getNewStringWithId:groupId]]]) {
        return @"0";
    }
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self getNewStringWithId:groupId]];
}

#pragma mark 是否由1.0版本升级
+ (void)cleanLastData
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kLastVersion] && [[[NSUserDefaults standardUserDefaults] objectForKey:kLastVersion] floatValue] > 1.0) {
        NSLog(@"当前版本大于1.0");
    }
    else
    {
        [DataStoreManager deleteAllCommonMsg];
        [DataStoreManager deleteAllHello];
    }
    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    [[NSUserDefaults standardUserDefaults] setValue:version forKey:kLastVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isEmtity:(NSString*)str
{
    if (!str||[str isEqualToString:@""]||[str isEqualToString:@" "]) {
        return YES;
    }return NO;
}

#pragma mark 开机联网
-(void)firtOpen
{
    NSMutableDictionary * paramsDic = [NSMutableDictionary dictionary];
    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
    BOOL isTrue = [fileManager fileExistsAtPath:path];
    NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:path error:NULL];
    if (isTrue && [[fileAttr objectForKey:NSFileSize] unsignedLongLongValue] != 0) {
        
        NSMutableDictionary*   openData= [NSMutableDictionary dictionaryWithContentsOfFile:path];
        [paramsDic setObject:KISDictionaryHaveKey(openData, @"gamelist_millis") forKey:@"gamelist_millis"];
    }else{
        [paramsDic setObject:@"" forKey:@"gamelist_millis"];
    }
   [paramsDic setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken]?[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken]:@"" forKey:@"token"];
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramsDic forKey:@"params"];
    [postDict setObject:@"203" forKey:@"method"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (!responseObject) {
            return;
        }
        if (![KISDictionaryHaveKey(responseObject, @"tokenValid")boolValue]) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kMyToken])//本地没有token的情况下不需要请求登陆失败的原因
            {
                [NetManager  getTokenStatusMessage];
            }
            [GameCommon loginOut];
        }
        else
        {
        NSArray *arr = KISDictionaryHaveKey(responseObject, @"characters");
        if (!arr||![arr isKindOfClass:[NSArray class]]) {
            [[TempData sharedInstance]isBindingRolesWithBool:NO];
        }else{
            if (arr.count>0) {
                [[TempData sharedInstance]isBindingRolesWithBool:YES];
            }else{
                [[TempData sharedInstance]isBindingRolesWithBool:NO];  
            }
        }
        }        
//        NSArray *charachers = [responseObject objectForKey:@"characters"];
//        
//        for (NSMutableDictionary *characher in charachers) {
//            [DataStoreManager saveDSCharacters:characher UserId:KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"user"), @"id")];
        
            [[UserManager singleton]saveUserInfo:responseObject];
        
            
//            NSMutableArray *array = [NSMutableArray array];
//            if (![array containsObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(characher, @"gameid")]]) {
//                [array addObject:[characher objectForKey:@"gameid"]];
//            }
//
//            [[NSUserDefaults standardUserDefaults]setObject:array forKey:[NSString stringWithFormat:@"findpageGameList_%@",[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]];
      //  }

        [self openSuccessWithInfo:responseObject From:@"firstOpen"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
#pragma mark ---登陆成功重新获取open接口数据
-(void)LoginOpen
{
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"225" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken]?[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken]:@"" forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self openSuccessWithInfo:responseObject From:@"firstOpen"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)openSuccessWithInfo:(NSDictionary *)dict From:(NSString *)where
{
    //    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    [[TempData sharedInstance] setRegisterNeedMsg:[KISDictionaryHaveKey(dict, @"registerNeedMsg") doubleValue]];
    
    
    
    if ([KISDictionaryHaveKey(dict, @"clientUpdate") doubleValue]) {
        [[NSUserDefaults standardUserDefaults] setObject:KISDictionaryHaveKey(dict, @"clientUpdateUrl") forKey:@"IOSURL"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到新版本，您要升级吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立刻升级", nil];
        alert.tag = 21;
        [alert show];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IOSURL"];
    }
    
    
    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
    NSMutableDictionary* openData = [NSMutableDictionary dictionaryWithContentsOfFile:path] ? [NSMutableDictionary dictionaryWithContentsOfFile:path] : [NSMutableDictionary dictionaryWithCapacity:1];
    
    if ([KISDictionaryHaveKey(dict, @"gamelist_update") boolValue]) {
        
        /* 这里略乱 临时添加尚未修改 */
        
        //本地开机数据和网络获取开机数据相互遍历 判断是否需要更新
        if ([[openData allKeys]containsObject:@"gamelist"]) {
            NSDictionary *oldDic = KISDictionaryHaveKey(openData, @"gamelist");
            NSMutableArray *array = [NSMutableArray array];
            NSArray *alk =[oldDic allKeys];
            for (int i =0; i<alk.count; i++) {
                NSArray *arr = [oldDic objectForKey:alk[i] ];
                [array addObjectsFromArray:arr];
            }
            
            NSDictionary *newDic = KISDictionaryHaveKey(dict, @"gamelist");
            NSMutableArray *newArray = [NSMutableArray array];
            NSArray *allk =[newDic allKeys];
            for (int i =0; i<allk.count; i++) {
                NSArray *array = [newDic objectForKey:allk[i] ];
                [newArray addObjectsFromArray:array];
            }
            
            for (int i =  0; i<array.count; i++) {
                for (int j = 0; j<newArray.count; j++) {
                    NSDictionary *dic = array[i];
                    NSDictionary *temDic = newArray[j];
                    NSString *oldId =[GameCommon getNewStringWithId: KISDictionaryHaveKey(dic,@"id")];
                    NSString *newid =[GameCommon getNewStringWithId: KISDictionaryHaveKey(temDic, @"id")];
                    NSString *gameInfoMills =[GameCommon getNewStringWithId: KISDictionaryHaveKey(dic, @"gameInfoMills")];
                    NSString *newGameInfoMills =[GameCommon getNewStringWithId: KISDictionaryHaveKey(temDic, @"gameInfoMills")];
                    
                    if ([oldId isEqualToString: newid]&&![gameInfoMills isEqualToString: newGameInfoMills]) {
                        
                        NSLog(@"%@--%@-=-%@--%@",oldId,gameInfoMills,newid,newGameInfoMills);
                        
                        NSArray * commonPArray = KISDictionaryHaveKey(KISDictionaryHaveKey(temDic, @"gameParams"), @"commonParams");
                        for (int m =0; m<commonPArray.count; m++) {
                            NSDictionary *commonDic = commonPArray[m];
                            [self getGameInfoWithGameID:KISDictionaryHaveKey(temDic, @"id") withParams:KISDictionaryHaveKey(commonDic, @"param")];
                        }
                        
                    }
                    else if (![[dic allKeys]containsObject:KISDictionaryHaveKey(temDic, @"id")]&&array.count<newArray.count){
                        
                        NSLog(@"%@",temDic);
                        
                        NSArray * commonPArray = KISDictionaryHaveKey(KISDictionaryHaveKey(temDic, @"gameParams"), @"commonParams");
                        for (int m =0; m<commonPArray.count; m++) {
                            NSDictionary *commonDic = commonPArray[m];
                            [self getGameInfoWithGameID:KISDictionaryHaveKey(temDic, @"id") withParams:KISDictionaryHaveKey(commonDic, @"param")];
                        }
                    }
                }
            }
            
        }else{
            
            //第一次登陆 无本地数据
            NSDictionary *newDic = KISDictionaryHaveKey(dict, @"gamelist");
            NSMutableArray *newArray = [NSMutableArray array];
            NSArray *allk =[newDic allKeys];
            for (int i =0; i<allk.count; i++) {
                NSArray *array = [newDic objectForKey:allk[i] ];
                [newArray addObjectsFromArray:array];
            }
            for (int i =0; i<newArray.count; i++) {
                NSDictionary *dic = newArray[i];
                NSArray * commonPArray = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"gameParams"), @"commonParams");
                
                for (int j =0; j<commonPArray.count; j++) {
                    NSDictionary *commonDic = commonPArray[j];
                    [self getGameInfoWithGameID:KISDictionaryHaveKey(dic, @"id") withParams:KISDictionaryHaveKey(commonDic, @"param")];
                }
            }
        }
        //把开机数据写入文件
        [dict writeToFile:path atomically:YES];
        [self saveGameIconInfo:dict];
    }else
    {
        [self saveGameIconInfo:openData];
    }
}

#pragma mark ----把所有游戏的图标以key为游戏id写入文件
-(void)saveGameIconInfo:(NSDictionary*)openData
{
    if (![openData isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSMutableDictionary *gameiconDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *gameListDic=KISDictionaryHaveKey(openData, @"gamelist");
    NSArray *keysArr =[gameListDic allKeys];
    for (int i = 0; i <keysArr.count; i++) {
        NSArray *arr = KISDictionaryHaveKey(gameListDic, keysArr[i]);
        for (NSDictionary *dic in arr) {
            [gameiconDic setObject:KISDictionaryHaveKey(dic, @"img") forKey:[NSString stringWithFormat:@"id%@",KISDictionaryHaveKey(dic, @"id")]];
        }
    }
    NSString *filePath  =[RootDocPath stringByAppendingString:@"/gameicon_wx"];
    [gameiconDic writeToFile:filePath atomically:YES];
    NSLog(@"%@",gameiconDic);
}
#pragma mark ----更新游戏数据、、wow服务器等
-(void)getGameInfoWithGameID:(NSString *)gameId withParams:(NSString *)params
{
    NSMutableDictionary * paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:gameId forKey:@"gameid"];
    [paramsDic setObject:params forKey:@"param"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramsDic forKey:@"params"];
    [postDict setObject:@"216" forKey:@"method"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"res -----> %@",responseObject);
        
        /*
         params 是需要输入的内容
         info是需要选择的内容
         
         
         gameName,//游戏名称
         searchParams,//查找这个游戏角色所需要的参数
         gameid,//
         bindParams,//绑定游戏角色需要上传的参数
         bindInfo,//绑定角色是需要的特殊参数----》>需要选择的参数
         commonParams,
         version,//开机返回信息的格式版本号
         commonInfo,//数据
         searchInfo//查找角色的时候需要的参数
         searchParams//
         */
        //  [self openSuccessWithInfo:responseObject From:@"firstOpen"];
        
        //把获取的数据根据游戏id保存本地
        
        
        NSString *filePath = [RootDocPath stringByAppendingString:@"/openInfo"];
        [responseObject writeToFile:[filePath stringByAppendingString:[NSString stringWithFormat:@"gameid_%@_%@",gameId,params]] atomically:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}
//未读消息的数量
+(NSInteger)getNoreadMsgCount:(NSMutableArray*)msgs
{
    int allUnread = 0;
    for (int i = 0; i<msgs.count; i++) {
        NSMutableDictionary * message = [msgs objectAtIndex:i];
        if ([KISDictionaryHaveKey(message, @"msgType") isEqualToString:@"groupchat"]) {//假如是关闭状态，则过滤该群的消息数
            if ([[self getMsgSettingStateByGroupId:KISDictionaryHaveKey(message, @"groupId")] isEqualToString:@"0"]
                ||[[self getMsgSettingStateByGroupId:KISDictionaryHaveKey(message, @"groupId")] isEqualToString:@"2"]) {
                
                allUnread = allUnread+[KISDictionaryHaveKey(message, @"unRead") intValue];
            }
        }else{
            allUnread = allUnread+[KISDictionaryHaveKey(message, @"unRead") intValue];
        }
    }
    return allUnread;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (21 == alertView.tag) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"IOSURL"]) {
                NSURL *url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"IOSURL"]];
                if([[UIApplication sharedApplication] canOpenURL:url])
                {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }
    }
}


+ (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

+(UILabel *)buildLabelinitWithFrame:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor *)backgroundColor textAlignment:(NSTextAlignment)Alignment
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.textColor = textColor;
    label.backgroundColor  = backgroundColor;
    label.font = font;
    label.textAlignment = Alignment;
    return label;
}


+(NSString*)getGroupDomain:(NSString*)domain
{
    return [domain stringByReplacingOccurrencesOfString:@"@" withString:@"@group."];
}

@end
