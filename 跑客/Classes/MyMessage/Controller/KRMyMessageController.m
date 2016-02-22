//
//  KRMyMessageController.m
//  跑客
//
//  Created by guoaj on 15/11/1.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import "KRMyMessageController.h"
#import "KRXMPPTool.h"
#import "KRUserInfo.h"
#import "KRMessageCell.h"
#import "XMPPMessageArchiving.h"
#import "KRChatViewController.h"
#import "UIImageView+KRRoundImageView.h"
@interface KRMyMessageController()
@property (nonatomic,strong) NSArray  *friends;
@property (nonatomic,strong) NSArray  *friendNames;
@property (nonatomic,strong) NSArray  *mostMsgs;

- (IBAction)backBtn:(id)sender;


@end

@implementation KRMyMessageController

- (void) viewDidLoad
{
    [self loadMostMessage];
    /* 加载哪些人聊过 */
    // [self loadFriends];
}
- (void) loadMostMessage
{
    NSManagedObjectContext * context = [[KRXMPPTool sharedKRXMPPTool].xmppMsgArchStore  mainThreadManagedObjectContext];
    NSFetchRequest  *request = [[NSFetchRequest alloc]initWithEntityName:@"XMPPMessageArchiving_Contact_CoreDataObject"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[KRUserInfo sharedKRUserInfo].jid];
    request.predicate = pre;
    NSSortDescriptor  *desc = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:NO];
    request.sortDescriptors = @[desc];
    NSError *error = nil;
    self.mostMsgs = [context executeFetchRequest:request error:&error];
    if (error) {
        MYLog(@"%@",error);
    }
    
}
- (void) loadFriends
{
    // 获得上下文
    NSManagedObjectContext *context = [[KRXMPPTool sharedKRXMPPTool].xmppMsgArchStore mainThreadManagedObjectContext];
    // 请求对象关联实体
    NSFetchRequest *requst = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    // 过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",
            [KRUserInfo sharedKRUserInfo].jid];
    requst.predicate = pre;
    // order by
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    requst.sortDescriptors = @[sort];
    self.friends = [context executeFetchRequest:requst error:nil];
    NSMutableSet * names = [NSMutableSet set];
    for (int i=0; i<self.friends.count; i++) {
        XMPPMessageArchiving_Message_CoreDataObject *ma = self.friends[i];
        [names addObject:ma.bareJidStr];
    }
    self.friendNames = [names allObjects];
}
/* 查找最后的信息 */
- (XMPPMessageArchiving_Message_CoreDataObject *) findLastMessage:(NSString*) bareJidStr
{
    for (int i=0; i<self.friends.count; i++) {
        XMPPMessageArchiving_Message_CoreDataObject *ma = self.friends[i];
        if ([ma.bareJidStr isEqualToString:bareJidStr]) {
            return ma;
        }
    }
    return nil;
}
- (NSInteger)tableView2:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     return  self.friendNames.count;
    // return self.friends.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.mostMsgs.count;
    // return self.friends.count;
}
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KRMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    XMPPMessageArchiving_Contact_CoreDataObject *ma = self.mostMsgs[indexPath.row];
    cell.nikeNameLabel.text = ma.bareJidStr;
    /* 根据信息显示头像 */
    NSData * imagedata = [[KRXMPPTool sharedKRXMPPTool].xmppvCardAvtar photoDataForJID:[XMPPJID jidWithString:ma.bareJidStr]];
    [cell.friendHeadImage  setRoundLayer];
    if(imagedata !=nil){
        cell.friendHeadImage.image = [UIImage imageWithData:imagedata];
    }else{
        cell.friendHeadImage.image = [UIImage imageNamed:@"微信"];
    }
    if ([ma.mostRecentMessageBody hasPrefix:@"image"]) {
        cell.lastMessageLabel.text = @"图片";
    }else{
        NSString  *base64Str = [ma.mostRecentMessageBody substringFromIndex:4];
        NSData *base64data = [[NSData alloc]initWithBase64EncodedString:base64Str options:0];
        cell.lastMessageLabel.text = [[NSString alloc]initWithData:base64data encoding:NSUTF8StringEncoding];
    }
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"yyyy-MM-dd";
    cell.lastMessageDateLabel.text = [format stringFromDate:ma.mostRecentMessageTimestamp];
    return cell;
}
- (UITableViewCell*) tableView2:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KRMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    XMPPMessageArchiving_Message_CoreDataObject *ma =
    [self findLastMessage:self.friendNames[indexPath.row]];
    cell.nikeNameLabel.text = ma.bareJidStr;
    /* 根据信息显示头像 */
    [cell.friendHeadImage  setRoundLayer];
    NSData * imagedata = [[KRXMPPTool sharedKRXMPPTool].xmppvCardAvtar photoDataForJID:[XMPPJID jidWithString:ma.bareJidStr]];
    if(imagedata !=nil){
        cell.friendHeadImage.image = [UIImage imageWithData:imagedata];
    }else{
        cell.friendHeadImage.image = [UIImage imageNamed:@"微信"];
    }
    if ([ma.message.body hasPrefix:@"image"]) {
        cell.lastMessageLabel.text = @"图片";
    }else{
        NSString  *base64Str = [ma.message.body substringFromIndex:4];
        NSData *base64data = [[NSData alloc]initWithBase64EncodedString:base64Str options:0];
        cell.lastMessageLabel.text = [[NSString alloc]initWithData:base64data encoding:NSUTF8StringEncoding];
    }
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"yyyy-MM-dd";
    cell.lastMessageDateLabel.text = [format stringFromDate:ma.timestamp];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XMPPMessageArchiving_Contact_CoreDataObject *ma = self.mostMsgs[indexPath.row];
    [self performSegueWithIdentifier:@"chatSegue" sender:ma.bareJid];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id vc = segue.destinationViewController;
    if ([vc isKindOfClass:[KRChatViewController class]]) {
        KRChatViewController *chatVc = (KRChatViewController *)vc;
        chatVc.friendJid = sender;
        
    }
}
- (IBAction)backBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
