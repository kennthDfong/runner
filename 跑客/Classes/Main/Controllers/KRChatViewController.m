//
//  KRChatViewController.m
//  跑客
//
//  Created by guoaj on 15/10/25.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import "KRChatViewController.h"
#import "KRXMPPTool.h"
#import "KRUserInfo.h"
#import "KRMeTextCell.h"
#import "KROtherTextCell.h"
#import "XMPPMessage.h"
#import "XMPPvCardTemp.h"
#import "UIImageView+KRRoundImageView.h"
@interface   KRChatViewController()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSFetchedResultsController *fetechCol;
@property (weak, nonatomic) IBOutlet UITextField *msgText;
@property (strong,nonatomic) UIImage *meImage;
@property (strong,nonatomic) UIImage *friendImage;
- (IBAction)sendBtnClick:(id)sender;

@end
@implementation KRChatViewController
- (void) viewDidLoad
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = NO;
    /* 适应自动布局 */
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    [self loadMsg];
    NSData *data = [KRXMPPTool sharedKRXMPPTool].xmppvCard.myvCardTemp.photo;
    if (data == nil) {
        self.meImage = [UIImage imageNamed:@"微信"];
    }else{
        self.meImage = [UIImage imageWithData:data];
    }
    NSData *fdata = [[KRXMPPTool sharedKRXMPPTool].xmppvCardAvtar photoDataForJID:self.friendJid];
    if (fdata == nil) {
        self.friendImage = [UIImage imageNamed:@"微信"];
    }else{
        self.friendImage = [UIImage imageWithData:fdata];
    }
   
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.msgText resignFirstResponder];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.msgText resignFirstResponder];
}
/** 即将显示 */
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyboard:) name:UIKeyboardWillHideNotification object:nil];
//    [[UIBarButtonItem  appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-60, 0) forBarMetrics:UIBarMetricsDefault];
}
/** 加载消息 */
- (void) loadMsg
{
    // 获得上下文
    NSManagedObjectContext *context = [[KRXMPPTool sharedKRXMPPTool].xmppMsgArchStore mainThreadManagedObjectContext];
    // 请求对象关联实体
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    // 请求对象设置过滤条件 和 排序
    NSPredicate *pre = [NSPredicate predicateWithFormat:
        @"bareJidStr=%@ and streamBareJidStr=%@",
        [self.friendJid bare],[KRUserInfo sharedKRUserInfo].jid];
    request.predicate = pre;
    NSSortDescriptor *sortdes = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sortdes];
    // 提取数据
    self.fetechCol = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetechCol.delegate = self;
    NSError *error = nil;
    [self.fetechCol performFetch:&error];
    if (error) {
        MYLog(@"提取数据失败");
    }
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetechCol.fetchedObjects.count;
}
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Message_CoreDataObject *message = self.fetechCol.fetchedObjects[indexPath.row];
    
   if ([message.body hasPrefix:@"text"]) {
        if (message.isOutgoing) {
            KRMeTextCell  *cell = [tableView dequeueReusableCellWithIdentifier:@"meTextCell"];
            cell.headImageView.image = self.meImage;
            [cell.headImageView setRoundLayer];
            NSString *base64Str = [message.body substringFromIndex:4];
            NSData * base64Data = [[NSData alloc]initWithBase64EncodedString:base64Str options:0];
            cell.popImageView.image = nil;
            cell.chatTextLabel.text = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];
            cell.nikeName.text = [KRUserInfo sharedKRUserInfo].userName;
            NSDateFormatter *formater = [[NSDateFormatter alloc]init];
            formater.dateFormat = @"yyyy-MM-dd";
            cell.timeLabel.text = [formater stringFromDate: message.timestamp];
            return cell;
        }else{
            KROtherTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherTextCell"];
            cell.headImageView.image = self.friendImage;
            [cell.headImageView setRoundLayer];
            cell.popImageView.image = nil;
            NSString *base64Str = [message.body substringFromIndex:4];
            NSData * base64Data = [[NSData alloc]initWithBase64EncodedString:base64Str options:0];
            cell.chatTextLabel.text = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];
            cell.nikeNameLabel.text = self.friendJid.user;
            NSDateFormatter *formater = [[NSDateFormatter alloc]init];
            formater.dateFormat = @"yyyy-MM-dd";
            cell.timeLabel.text = [formater stringFromDate: message.timestamp];

            return cell;
        }
   }
    if ([message.body hasPrefix:@"image"]) {
        
        if (message.isOutgoing) {
            KRMeTextCell  *cell = [tableView dequeueReusableCellWithIdentifier:@"meTextCell"];
            cell.headImageView.image = self.meImage;
            [cell.headImageView setRoundLayer];
            NSString *base64Str = [message.body substringFromIndex:5];
            NSData * base64Data = [[NSData alloc]initWithBase64EncodedString:base64Str options:0];
            cell.chatTextLabel.text = nil;
            // 处理图片数据 完成
            cell.popImageView.image = [UIImage imageWithData:base64Data];
            cell.nikeName.text = [KRUserInfo sharedKRUserInfo].userName;
            NSDateFormatter *formater = [[NSDateFormatter alloc]init];
            formater.dateFormat = @"yyyy-MM-dd";
            cell.timeLabel.text = [formater stringFromDate: message.timestamp];
            return cell;
        }else{
            KROtherTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherTextCell"];
            cell.headImageView.image = self.friendImage;
            [cell.headImageView setRoundLayer];
            cell.detailTextLabel.text = @"";
            cell.popImageView.image = nil;
            NSString *base64Str = [message.body substringFromIndex:5];
            NSData * base64Data = [[NSData alloc]initWithBase64EncodedString:base64Str options:0];
            cell.popImageView.image = [UIImage imageWithData:base64Data];
            cell.nikeNameLabel.text = self.friendJid.user;
            NSDateFormatter *formater = [[NSDateFormatter alloc]init];
            formater.dateFormat = @"yyyy-MM-dd";
            cell.timeLabel.text = [formater stringFromDate: message.timestamp];
            return cell;
        }
    }

    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
    return cell;
}
- (IBAction)picSelected:(UIButton *)sender
{
    UIImagePickerController *picVc = [[UIImagePickerController alloc]init];
    picVc.delegate = self;
    picVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picVc animated:YES completion:nil];
}
/* 生成图片缩略图 */
- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize

{
    
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }else{
        UIGraphicsBeginImageContext(asize);
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}
/* UIImagePickerController 代理方法 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    UIImage *newImage = [self thumbnailWithImage:image size:CGSizeMake(100, 100)];
    NSData  *data = UIImageJPEGRepresentation(image, 0.05);
    
    MYLog(@"---------%ld",data.length);
    NSData  *data2 = UIImageJPEGRepresentation(newImage,0.05);
    MYLog(@"---------%ld",data2.length);

    [self sendMessageWithData:data2 bodyName:@"image"];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/* 发送文本消息的函数 */
- (IBAction)sendBtnClick:(id)sender {
    NSString *msg = self.msgText.text;
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [self sendMessageWithData:data bodyName:@"text"];
    [self.tableView reloadData];
}
/** 发送(文本 图片或者声音) */
- (void)sendMessageWithData:(NSData *)data bodyName:(NSString *)name
{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJid ];
    // 转换成base64的编码
    NSString *base64str = [data base64EncodedStringWithOptions:0];
    [message addBody:[name stringByAppendingString:base64str]];
    // 发送消息
    [[KRXMPPTool sharedKRXMPPTool].xmppStream sendElement:message];
}

-  (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    [self scrollTabel];
}
- (void) scrollTabel
{
    NSInteger  index = self.fetechCol.fetchedObjects.count -1;
    if (index < 0) {
        return;
    }
    NSIndexPath  *indexpath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self scrollTabel];
}
/** 键盘打开 */
- (void) openKeyboard:(NSNotification *)notification{
    
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    self.heightForBottom.constant = keyboardFrame.size.height;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
                         [self.view layoutIfNeeded];
                         [self scrollTabel];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}
/** 键盘关闭 */
- (void) closeKeyboard:(NSNotification *)notification{
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    self.heightForBottom.constant = 0;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

@end
