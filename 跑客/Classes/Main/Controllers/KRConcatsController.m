//
//  KRConcatsController.m
//  跑客
//
//  Created by guoaj on 15/10/24.
//  Copyright © 2015年 Strom. All rights reserved.
//
#import "KRConcatsController.h"
#import "KRXMPPTool.h"
#import "KRUserInfo.h"
#import "UIImageView+KRRoundImageView.h"
#import "KRFriendCell.h"
#import "KRChatViewController.h"
@interface KRConcatsController()<NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) NSArray *friends;
@property (nonatomic,strong) NSFetchedResultsController *fetchController;

- (IBAction)backClick:(id)sender;

@end
@implementation KRConcatsController
- (void) viewDidLoad
{
    self.tableView.separatorStyle = NO;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadFriend2];
    NSLog(@"%@",self.friends);
}
/** 加载好友列表 */
- (void) loadFriend
{
    // 获得上下文
    NSManagedObjectContext *context = [KRXMPPTool sharedKRXMPPTool].xmppRoserStore.mainThreadManagedObjectContext;
    // NSFetchRequest 关联实体
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:
        @"XMPPUserCoreDataStorageObject"];
    // 设置过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:
        @"streamBareJidStr = %@",[KRUserInfo sharedKRUserInfo].jid];
    request.predicate = pre;
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    // 排序
    request.sortDescriptors = @[nameSort];
    NSError *error = nil;
    self.friends = [context  executeFetchRequest:request error:&error];
    if (error) {
        MYLog(@"%@",error);
    }
}

/** 新的加载好友列表方式  */
- (void) loadFriend2
{
    // 获得上下文
    NSManagedObjectContext *context = [KRXMPPTool sharedKRXMPPTool].xmppRoserStore.mainThreadManagedObjectContext;
    // NSFetchRequest 关联实体
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:
                               @"XMPPUserCoreDataStorageObject"];
    // 设置过滤条件
    NSPredicate *pre = [NSPredicate predicateWithFormat:
        @"streamBareJidStr = %@ and subscription!=%@",[KRUserInfo sharedKRUserInfo].jid,@"none"];
    request.predicate = pre;
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    // 排序
    request.sortDescriptors = @[nameSort];
    NSError *error = nil;
    self.fetchController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchController.delegate = self;
    [self.fetchController  performFetch:&error];
    if (error) {
        MYLog(@"%@",error);
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"数据发生改变");
    // 刷新表格
    [self.tableView reloadData];
    
}
// 删除模式
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[KRXMPPTool sharedKRXMPPTool].xmppRoser  removeUser:friend.jid];
        
    }
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return self.friends.count;
    NSInteger  i = [self.fetchController.fetchedObjects count];
    // return  [self.fetchController.fetchedObjects count];
    return  i;
   
}
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *identifier = @"roseCell";
    KRFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    XMPPUserCoreDataStorageObject *roser = self.fetchController.fetchedObjects[indexPath.row];
    
    NSData * data = [[KRXMPPTool sharedKRXMPPTool].xmppvCardAvtar photoDataForJID:roser.jid];
    
    if (data) {
        cell.headImageView.image = [UIImage imageWithData:data];
    }else{
        cell.headImageView.image = [UIImage imageNamed:@"placehoder"];
    }
    cell.jidStrLabel.text = roser.jidStr;
    [cell.headImageView setRoundLayer];
    cell.selectedBackgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cellselect"]];
    // 0 在线  1 离开 2 离线
    switch (roser.sectionNum.intValue ) {
        case  0:
            [cell.detailBtn setTitle:@"在线" forState:UIControlStateNormal];
            break;
        case  1:
            [cell.detailBtn setTitle:@"离开" forState:UIControlStateNormal];
            break;
        case  2:
            [cell.detailBtn setTitle:@"离线" forState:UIControlStateNormal];
            break;
    }
    return cell;
}
/* 选中谁和谁聊天 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *roser = self.fetchController.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"chatSegue" sender:roser.jid];
}
/* 把好友的jid传入下一个控制器 */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id vc = segue.destinationViewController;
    if ([vc isKindOfClass:[KRChatViewController class]]) {
        KRChatViewController *chatVc = (KRChatViewController *)vc;
        chatVc.friendJid = sender;
        
    }
}

- (IBAction)backClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

