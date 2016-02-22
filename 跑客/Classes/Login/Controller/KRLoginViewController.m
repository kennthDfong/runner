//
//  KRLoginViewController.m
//  跑客
//
//  Created by guoaj on 15/10/23.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import "KRLoginViewController.h"
#import "KRUserInfo.h"
#import "KRXMPPTool.h"
#import "MBProgressHUD+KR.h"
#import "KRRegisterViewController.h"
@interface KRLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPasswd;
- (IBAction)loginBtnClick:(UIButton *)sender;

@end

@implementation KRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    if ([KRUserInfo sharedKRUserInfo].userName) {
        self.userName.text = [KRUserInfo sharedKRUserInfo].userName;
    }
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


- (IBAction)loginBtnClick:(UIButton *)sender {
    if (self.userName.text.length == 0 || self.userPasswd.text.length == 0) {
        [MBProgressHUD showError:@"用户名密码不能为空"];
        return ;
    }
    [KRUserInfo  sharedKRUserInfo].userName = self.userName.text;
    [KRUserInfo  sharedKRUserInfo].userPwd = self.userPasswd.text;
   
    [KRUserInfo  sharedKRUserInfo].registerType = NO;
    [MBProgressHUD showMessage:@"登录中..."];
     __weak typeof(self) vc = self;
    [[KRXMPPTool  sharedKRXMPPTool] userLogin:^(KRXMPPResultType type) {
        [MBProgressHUD hideHUD];
        [vc handleResultType:type];
    }];
}
- (void) handleResultType:(KRXMPPResultType) type
{
    switch (type) {
        case KRXMPPResultTypeNetError:
            [MBProgressHUD   showError:@"网路错误"];
            break;
        case KRXMPPResultTypeLoginFailed:
            [MBProgressHUD showError:@"登录失败"];
            break;
        case KRXMPPResultTypeLoginSuccess:
        {
            [MBProgressHUD showSuccess:@"登录成功"];
            // 切换到主界面
            UIStoryboard *stroyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = stroyboard.instantiateInitialViewController;
            break;
        }
        default:
            break;
    }
}

- (void)dealloc
{
    MYLog(@"%@",self);
}
@end






