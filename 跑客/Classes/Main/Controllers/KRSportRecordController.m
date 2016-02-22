//
//  KRSportRecordController.m
//  跑客
//
//  Created by guoaj on 15/10/29.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import "KRSportRecordController.h"
#import "KRSportRecordCell.h"
#import "KRSport.h"
#import "AFNetworking.h"
#import "KRUserInfo.h"

@interface  KRSportRecordController()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) UIButton *selectedBtn;
@property (weak, nonatomic) IBOutlet UIButton *preBtn;

- (IBAction)choseSportModel:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray * sportDatas;
- (IBAction)backToMain:(id)sender;

@end

@implementation KRSportRecordController
- (void) viewDidLoad
{
    self.selectedBtn = self.preBtn;
    self.selectedBtn.selected = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.sportDatas = [NSMutableArray array];
    /* 默认加载跑步的 */
    [self  loadFromWebServerWithType:SportModelWalk];
}
/* 从服务器上获取跑步数据 */
- (void)  loadFromWebServerWithType:(enum SportModel) type
{
//    NSString *url =
//    @"http://localhost:8080/allRunServer/queryUserDataByType.jsp";
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServerNew/queryUserDataByType.jsp",KRXMPPHOSTNAME];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    KRUserInfo *userInfo = [KRUserInfo sharedKRUserInfo];
    parameters[@"username"] = userInfo.userName;
    parameters[@"md5password"] = userInfo.userPwd;
    parameters[@"sportType"] = @(type);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"%@",responseObject[@"sportData"]);
        NSArray *array = responseObject[@"sportData"];
        [self.sportDatas removeAllObjects];
        for (int i=0; i< array.count; i++) {
            KRSportRecord *rec = [[KRSportRecord alloc]init];
            [rec setValuesForKeysWithDictionary:array[i]];
            [self.sportDatas  addObject:rec];
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"%@",error);
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.sportDatas.count;
}
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KRSportRecordCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"sportCell" forIndexPath:indexPath];
    KRSportRecord *rec = self.sportDatas[indexPath.row];
    
    [cell  setSPortData:rec];
    return cell;
}
- (IBAction)choseSportModel:(UIButton *)sender {
    if (sender == self.selectedBtn) {
        return;
    }
    self.preBtn = self.selectedBtn;
    self.selectedBtn = sender;
    self.selectedBtn.selected = YES;
    self.preBtn.selected = NO;
    [self loadFromWebServerWithType:sender.tag];
}
- (IBAction)backToMain:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

