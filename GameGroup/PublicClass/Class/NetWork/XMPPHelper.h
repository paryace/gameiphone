//
//  XMPPHelper.h
//  NewXMPPTest
//
//  Created by Tolecen on 13-6-26.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ReconnectionManager.h"

@class XMPPStream;
@class Message;
@class XMPPPresence;
@class XMPPReconnect;
@class XMPPAutoPing;
@interface XMPPHelper : NSObject

typedef void (^CallBackBlock) (void);
typedef void (^CallBackBlockErr) (NSError *result);

@property (nonatomic,strong) XMPPStream *xmppStream;

@property (nonatomic,strong) NSString *account;
@property (nonatomic,strong) NSString *password;

@property (nonatomic, assign)id addReqDelegate;
@property (nonatomic, assign)id commentDelegate;
@property (nonatomic, assign)id chatDelegate;
@property (nonatomic, assign)id xmpprosterDelegate;
@property (nonatomic,assign) id notConnect;
@property (nonatomic,assign) id deletePersonDelegate;
@property (nonatomic,assign) id otherMsgReceiveDelegate;
@property (nonatomic,assign) id recommendReceiveDelegate;

@property (strong,nonatomic) CallBackBlock success;
@property (strong,nonatomic) CallBackBlockErr fail;
@property (strong,nonatomic) CallBackBlock regsuccess;
@property (strong,nonatomic) CallBackBlockErr regfail;
@property (strong,nonatomic) XMPPReconnect* xmppReconnect;
@property (strong,nonatomic) NSMutableArray * rosters;

//-(BOOL)isDisconnected;
//-(BOOL)isConnecting;
//-(BOOL)isConnected;

- (void) setupStream;
- (void) goOnline;
- (void) goOffline;
-(BOOL)isConnecting;
-(BOOL)isDisconnected;
-(BOOL)isConnected;
-(BOOL)connect:(NSString *)account password:(NSString *)password host:(NSString *)host success:(CallBackBlock)Success fail:(CallBackBlockErr)Fail;

-(void)disconnect;
-(BOOL)sendMessage:(NSXMLElement *)message;
- (void)comeBackDelivered:(NSString*)sender msgId:(NSString*)msgId;
@end
