//
//  KRXMPPTool.m
//  跑客
//
//  Created by guoaj on 15/10/23.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import "KRXMPPTool.h"
#import "KRUserInfo.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
@interface  KRXMPPTool()<XMPPStreamDelegate,XMPPRosterDelegate,UIActionSheetDelegate>
{
    KRXMPPResultBlock _resultBlock;
}
@property (strong,nonatomic) XMPPJID *fJid;
@end
@implementation KRXMPPTool
singleton_implementation(KRXMPPTool)

/** 初始化XMPP流 */
- (void) setXmpp
{
    
    self.xmppStream= [[XMPPStream alloc]init];
    /* 设置代理 */
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // 初始化电子名片模块 和 头像模块
    self.xmppvCardStore = [XMPPvCardCoreDataStorage sharedInstance];
    self.xmppvCard = [[XMPPvCardTempModule alloc]initWithvCardStorage:self.xmppvCardStore];
    self.xmppvCardAvtar = [[XMPPvCardAvatarModule alloc]initWithvCardTempModule:self.xmppvCard];
    // 日志开启
    //[DDLog addLogger:[DDTTYLogger sharedInstance]];
    // 初始化花名册模块
    _xmppRoserStore = [XMPPRosterCoreDataStorage sharedInstance];
    _xmppRoser = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRoserStore];
    [self.xmppRoser addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // 初始化消息模块
    _xmppMsgArchStore = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    _xmppMegArch = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:self.xmppMsgArchStore];
    // 初始化自动重连
    _xmppReconn = [[XMPPReconnect alloc]init];
    [self.xmppReconn activate:_xmppStream];
    // 激活花名册模块
    [self.xmppRoser activate:self.xmppStream];
    // 激活电子名片模块和头像模块
    [self.xmppvCard activate:self.xmppStream];
    [self.xmppvCardAvtar activate:self.xmppStream];
    // 激活消息模块
    [self.xmppMegArch activate:self.xmppStream];
    
}
/** 连接服务器 */
- (void) connectHost
{
    // 设置流相关
    if (!self.xmppStream) {
        [self setXmpp];
    }
    self.xmppStream.hostName = KRXMPPHOSTNAME;
    self.xmppStream.hostPort = KRXMPPPORT;
    NSString *userName = [KRUserInfo  sharedKRUserInfo].userName;
    if ([KRUserInfo  sharedKRUserInfo].registerType) {
        userName = [KRUserInfo  sharedKRUserInfo].registerName;
    }
    XMPPJID *myJid = [XMPPJID jidWithUser:userName domain:KRXMPPDOMAIN resource:@"iphone"];
    self.xmppStream.myJID = myJid;
    NSError  *error = nil;
    [self.xmppStream  connectWithTimeout:XMPPStreamTimeoutNone
         error:&error];
    if (error) {
        MYLog(@"%@",error);
    }
}
/** 发送密码 */
- (void) sendPasswdToHost
{
    NSString *pwd = nil;
    NSError  *error = nil;
    if ([KRUserInfo  sharedKRUserInfo].registerType) {
        pwd =[KRUserInfo  sharedKRUserInfo].registerPasswd;
        [self.xmppStream registerWithPassword:pwd error:&error];
    }else{
        pwd =[KRUserInfo  sharedKRUserInfo].userPwd;
        [self.xmppStream authenticateWithPassword:pwd error:&error];
    }
    if (error) {
        MYLog(@"%@",error);
    }
}
/** 发送在线消息 */
- (void) sendOnline
{
    XMPPPresence  *persence = [XMPPPresence presence];
    [self.xmppStream sendElement:persence];
}
/** 退出时发送离线消息 */
- (void) sendOffLine
{
   XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
   [self.xmppStream sendElement:presence];
}
/** 连接成功 */
- (void) xmppStreamDidConnect:(XMPPStream *)sender
{
    MYLog(@"连接成功");
    // 服务器连接成功 发送密码
    [self sendPasswdToHost];
}
/** 断开连接  */
- (void) xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    MYLog(@"断开连接");
    if (error &&  _resultBlock) {
        _resultBlock(KRXMPPResultTypeNetError);
    }
}
/** 注册成功 */
- (void) xmppStreamDidRegister:(XMPPStream *)sender
{
   MYLog(@"注册成功");
    if (_resultBlock) {
          _resultBlock(KRXMPPResultTypeRegisterSuccess);
    }
  
}
/** 注册失败 */
- (void) xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
   MYLog(@"注册失败");
    _resultBlock(KRXMPPResultTypeRegisterFailure);
}
/** 授权成功 */
- (void) xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    MYLog(@"授权成功");
    _resultBlock(KRXMPPResultTypeLoginSuccess);
    [self sendOnline];
}
/** 授权失败 */
- (void) xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    MYLog(@"授权失败");
   _resultBlock(KRXMPPResultTypeLoginFailed);
}
/** 用户登录 */
- (void) userLogin:(KRXMPPResultBlock) block
{   
    _resultBlock = block;
    /* 断开之前的连接 */
    
    [self.xmppStream disconnect];
    [self connectHost];
}
/** 用户注册 */
- (void) userRegister:(KRXMPPResultBlock)block
{
    _resultBlock = block;
    /* 断开之前的连接 */
    
    [self.xmppStream disconnect];
    [self connectHost];
}

// 释放资源
- (void) dealloc
{
    [self cleanResource];

}
- (void) cleanResource
{
    // 移除代理
    [_xmppStream removeDelegate:self];
    // 停止激活
    [_xmppMegArch deactivate];
    
    [_xmppRoser   deactivate];
    [_xmppvCardAvtar deactivate];
    // 断开连接
    [_xmppStream disconnect];
    _xmppStream = nil;
    _xmppMegArch = nil;
    _xmppMsgArchStore = nil;
    _xmppRoser = nil;
    _xmppRoserStore = nil;
    _xmppvCardStore = nil;
    _xmppvCardAvtar = nil;
    
}
//处理加好友
#pragma mark 处理加好友回调,加好友

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //取得好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]]; 
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    NSLog(@"-----presenceType:%@",presenceType);
    
    NSLog(@"-----presence2:%@  sender2:%@",presence,sender);
    NSLog(@"-----fromUser:%@",presenceFromUser);
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",presenceFromUser,KRXMPPDOMAIN];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    self.fJid = jid;
    UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:[NSString stringWithFormat:@"%@想申请加好友",jidStr] delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"同意" otherButtonTitles:@"同意并添加对方为好友", nil];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
   
    
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error
{
    //取得好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]];
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    NSLog(@"-----presenceType:%@",presenceType);
    
    NSLog(@"-----presence2:%@  sender2:%@",presence,sender);
    NSLog(@"-----fromUser:%@",presenceFromUser);
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",presenceFromUser,KRXMPPDOMAIN];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    self.fJid = jid;
    UIActionSheet *actionSheet =[[UIActionSheet alloc]initWithTitle:[NSString stringWithFormat:@"%@想申请加好友",jidStr] delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"同意" otherButtonTitles:@"同意并添加对方为好友", nil];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"index====%ld",buttonIndex);
    if (0 == buttonIndex) {
         [self.xmppRoser acceptPresenceSubscriptionRequestFrom:self.fJid andAddToRoster:NO];
    }else if(1== buttonIndex){
         [self.xmppRoser acceptPresenceSubscriptionRequestFrom:self.fJid andAddToRoster:YES];
    }else{
         [self.xmppRoser  rejectPresenceSubscriptionRequestFrom:self.fJid];
    }
}

@end

