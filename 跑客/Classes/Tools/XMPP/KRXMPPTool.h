//
//  KRXMPPTool.h
//  跑客
//
//  Created by guoaj on 15/10/23.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "XMPPvCardTempModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "Singleton.h"
#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
typedef enum {
    KRXMPPResultTypeLoginSuccess,
    KRXMPPResultTypeLoginFailed,
    KRXMPPResultTypeNetError,
    KRXMPPResultTypeRegisterSuccess,
    KRXMPPResultTypeRegisterFailure
}KRXMPPResultType;
/* 定义BLOCK  */
typedef  void (^KRXMPPResultBlock)(KRXMPPResultType type);
@interface KRXMPPTool : NSObject
singleton_interface(KRXMPPTool)
@property (nonatomic,strong) XMPPStream *xmppStream;
/* 增加个人电子名片模块 和 头像模块 */
@property (nonatomic,strong) XMPPvCardTempModule *xmppvCard;
@property (nonatomic,strong) XMPPvCardAvatarModule *xmppvCardAvtar;
@property (nonatomic,strong) XMPPvCardCoreDataStorage *xmppvCardStore;
/* 增加花名册模块 */
@property (nonatomic,strong,readonly) XMPPRoster *xmppRoser;
@property (nonatomic,strong,readonly) XMPPRosterCoreDataStorage *xmppRoserStore;
/* 增加消息模块 */
@property (nonatomic,strong,readonly) XMPPMessageArchiving *xmppMegArch;
@property (nonatomic,strong,readonly) XMPPMessageArchivingCoreDataStorage *xmppMsgArchStore;
// 自动重连模块
@property (nonatomic,strong,readonly)  XMPPReconnect *xmppReconn;
/** 初始化XMPP流 */
- (void) setXmpp;
/** 连接服务器 */
- (void) connectHost;
/** 发送密码 */
- (void) sendPasswdToHost;
/** 发送在线消息 */
- (void) sendOnline;
/** 发送离线消息 */
- (void) sendOffLine;
#pragma mark 用户登录
/** 用户登录 */
- (void) userLogin:(KRXMPPResultBlock) block;
/** 用户注册 */
- (void) userRegister:(KRXMPPResultBlock)block;
/** 清理资源 */
- (void) cleanResource;

@end


