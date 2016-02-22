//
//  KRSportCircleController.m
//  跑客
//
//  Created by guoaj on 15/10/30.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import "KRSportCircleController.h"
#import "KRTestCell.h"
#import "UIImageView+KRRoundImageView.h"
#import "AFNetworking.h"
#import "KRUserInfo.h"
#import "KRSportTopic.h"
#import "UIImageView+WebCache.h"
#import "XMPPJID.h"
#import "KRXMPPTool.h"
#import "MBProgressHUD+KR.h"

@interface  KRSportCircleController()<KRTestCellProtocol>
- (IBAction)backBtnClick:(id)sender;

- (IBAction)addTopicView:(id)sender;

@property (nonatomic,strong) NSMutableArray *topicArray;
@end

@implementation KRSportCircleController
- (void)viewDidLoad
{
    /* 适应自动布局 */
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 125.0;
    self.topicArray = [NSMutableArray array];
    [MBProgressHUD showMessage:@"加载数据中 请稍后..."];
    [self loadData];
}
/* 加载数据的方法 */
- (void) loadData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServerNew/queryTopic.jsp",KRXMPPHOSTNAME];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"username"] = [KRUserInfo sharedKRUserInfo].userName;
    dict[@"md5password"] = [KRUserInfo sharedKRUserInfo].userPwd;
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUD];
        MYLog(@"----- %@",responseObject[@"data"]);
        NSArray *dataArray = responseObject[@"data"];
        for (int i = 0; i< dataArray.count; i++) {
            KRSportTopic *topic = [[KRSportTopic  alloc]init];
            [topic setValuesForKeysWithDictionary:dataArray[i]];
            [self.topicArray addObject:topic];
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"error ---- %@",error);
    }];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topicArray.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    KRTestCell  *cell = [tableView dequeueReusableCellWithIdentifier:@"mytopiccell"];
    cell.delegate = self;
    cell.headImageView.image = [UIImage imageNamed:@"placehoder"];
    [cell.headImageView setRoundLayer];
    [cell setDataWithTopic:self.topicArray[indexPath.row]];
    cell.addConcatBtn.tag = indexPath.row;
    return cell;
}

- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addTopicView:(id)sender {
    UIView  *topicView = [[UIView alloc]init];
    topicView.frame = self.view.frame;
    topicView.backgroundColor = [UIColor redColor];
    topicView.alpha = 0.4;
    [self.view addSubview:topicView];
}
/* 增加好友的逻辑 */
- (void)addConcatp:(NSString *)jidName
{
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",jidName,KRXMPPDOMAIN];
    XMPPJID  *jid = [XMPPJID jidWithString:jidStr];
    MYLog(@"%@",jid);
    if ([[KRXMPPTool sharedKRXMPPTool].xmppRoserStore userExistsWithJID:jid xmppStream:[KRXMPPTool sharedKRXMPPTool].xmppStream ]) {
        [MBProgressHUD showError:@"对方已经是你的好友"];
        return;
    }
    if([jidStr isEqualToString:[KRUserInfo sharedKRUserInfo].jid]){
        [MBProgressHUD showError:@"不能添加自己"];
        return;
    }
    [[KRXMPPTool sharedKRXMPPTool].xmppRoser subscribePresenceToUser:jid];

}

@end
