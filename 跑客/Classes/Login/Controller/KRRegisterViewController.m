//
//  KRRegisterViewController.m
//  跑客
//
//  Created by guoaj on 15/10/23.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import "KRRegisterViewController.h"
#import "KRXMPPTool.h"
#import "MBProgressHUD+KR.h"
#import "KRUserInfo.h"
#import "AFNetworking.h"
@interface KRRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPasswd;

- (IBAction)registerBtnClick:(id)sender;

- (IBAction)cancel:(id)sender;

@end

@implementation KRRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *imageN = [UIImage imageNamed:@"icon"];
    UIImageView *leftVN = [[UIImageView alloc]initWithImage:imageN];
    leftVN.contentMode = UIViewContentModeCenter;
    leftVN.frame = CGRectMake(0, 0, 55, 20);
    self.userName.leftViewMode = UITextFieldViewModeAlways;
    self.userName.leftView = leftVN;
    UIImage *imageP = [UIImage imageNamed:@"lock"];
    UIImageView *leftVP = [[UIImageView alloc]initWithImage:imageP];
    leftVP.contentMode = UIViewContentModeCenter;
    leftVP.frame = CGRectMake(0, 0, 55, 20);
    self.userPasswd.leftViewMode = UITextFieldViewModeAlways;
    self.userPasswd.leftView = leftVP;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.userName resignFirstResponder];
    [self.userPasswd resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerBtnClick:(id)sender {
    if (self.userName.text.length == 0 || self.userPasswd.text.length == 0) {
        [MBProgressHUD showError:@"用户名密码不能为空"];
        return ;
    }
    [KRUserInfo sharedKRUserInfo].registerName = self.userName.text;
    [KRUserInfo sharedKRUserInfo].registerPasswd = self.userPasswd.text;
    [KRUserInfo sharedKRUserInfo].registerType = YES;
    __weak typeof (self) myVC = self;
    [[KRXMPPTool sharedKRXMPPTool] userRegister:^(KRXMPPResultType type) {
        [myVC handleXMPPResultType:type];
    }];
}
#pragma mark  新增加web服务器帐号访问
/**  发送注册信息到web服务器 */
- (void) registerUserForWebServer
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
   // NSString *url = @"http://localhost:8080/allRunServer/register.jsp";
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServerNew/register.jsp",KRXMPPHOSTNAME];
    NSMutableDictionary *parameters = [ NSMutableDictionary dictionary];
    KRUserInfo *userInfo = [KRUserInfo sharedKRUserInfo];
    /* username=username&md5password=password
      &nickname=nickname&gender=gender&mobile=mobile
    &latitude=latitude&longitude=longitude&intro=intro */
    parameters[@"username"] = userInfo.registerName;
    parameters[@"md5password"] = userInfo.registerPasswd;
    parameters[@"nickname"] = userInfo.registerName;
    parameters[@"gender"] = @"1";
    parameters[@"mobile"] = @"15811001234";
    //parameters[@"latitude"] = @"39.1";
    //parameters[@"longitude"] = @"116.8";
    // parameters[@"intro"] = @"139.1@16.8";
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        UIImage *image = [UIImage imageNamed:@"placehoder"];
        NSData *data = UIImagePNGRepresentation(image);
        [formData appendPartWithFileData:data name:@"pic" fileName:@"headerImage.png" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
        MYLog(@"web register success!%@",responseObject);
        MYLog(@"msg = %@",responseObject[@"msg"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"web register failed!%@",error);
    }];
}
- (void) handleXMPPResultType:(KRXMPPResultType) type
{
    switch (type) {
        case KRXMPPResultTypeNetError:
            [MBProgressHUD   showError:@"网路错误"];
            break;
        case KRXMPPResultTypeRegisterSuccess:
            [MBProgressHUD showMessage:@"注册成功"];
            [self registerUserForWebServer];
            [KRUserInfo sharedKRUserInfo].userName = [KRUserInfo sharedKRUserInfo].registerName;
             [KRUserInfo sharedKRUserInfo].userPwd = [KRUserInfo sharedKRUserInfo].registerPasswd;
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case KRXMPPResultTypeRegisterFailure:
            [MBProgressHUD showError:@"注册失败"];
            break;
        default:
            break;
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc
{
    MYLog(@"self = %@",self);
}
@end
