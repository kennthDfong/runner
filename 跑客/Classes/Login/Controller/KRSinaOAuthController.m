//
//  KRSinaOAuthController.m
//  跑客
//
//  Created by guoaj on 15/10/24.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import "KRSinaOAuthController.h"
#import "AFNetworking.h"
#import "KRUserInfo.h"
#import "KRXMPPTool.h"
#import "MBProgressHUD+KR.h"
#define  APPKEY       @"2075708624"
#define  REDIRECT_URI @"http://www.tedu.cn"
#define  APPSECRET    @"36a3d3dec55af644cd94a316fdd8bfd8"

@interface  KRSinaOAuthController() <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)backClick:(id)sender;

@end
@implementation KRSinaOAuthController
- (void) viewDidLoad
{
    
    self.webView.delegate = self;
    NSString  *urlStr = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&redirect_uri=%@"
                         ,APPKEY,REDIRECT_URI];
    NSURL  *url = [NSURL URLWithString:urlStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString  *urlPath =request.URL.absoluteString;
    MYLog(@"urlPath=%@",urlPath);
    NSRange range = [urlPath rangeOfString:
            [NSString stringWithFormat:@"%@%@",REDIRECT_URI,@"/?code="]];
    NSString *code = nil;
    if (range.length > 0) {
        code = [urlPath substringFromIndex:range.length];
        MYLog(@"%@",code);
        [self accesTokenWithCode:code];
        return NO;
    }
    return YES;
}
- (void) accesTokenWithCode:(NSString*) code
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager  manager];
    NSString *urlStr = @"https://api.weibo.com/oauth2/access_token";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    /*
     必选	类型及范围	说明
     client_id	true	string	申请应用时分配的AppKey。
     client_secret	true	string	申请应用时分配的AppSecret。
     grant_type	true	string	请求的类型，填写authorization_code
     
     grant_type为authorization_code时
     必选	类型及范围	说明
     code	true	string	调用authorize获得的code值。
     redirect_uri	true	string	回调地址，需需与注册应用里的回调地址一致。
     */
    parameters[@"client_id"] = APPKEY;
    parameters[@"client_secret"] = APPSECRET;
    parameters[@"grant_type"] = @"authorization_code";
    parameters[@"code"] = code;
    parameters[@"redirect_uri"] = REDIRECT_URI;
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"获取token成功");
        /* 根据返回数据的uid生成系统内部帐号 之前生成过就使用帐号登录*/
        MYLog(@"%@",responseObject);
        NSString *innerName = [NSString stringWithFormat:@"sina%@",responseObject[@"uid"]];
        [KRUserInfo sharedKRUserInfo].registerName = innerName;
        [KRUserInfo sharedKRUserInfo].registerPasswd = responseObject[@"access_token"];
        [KRUserInfo sharedKRUserInfo].userName = innerName;
        [KRUserInfo sharedKRUserInfo].userPwd = responseObject[@"access_token"];
        [KRUserInfo sharedKRUserInfo].registerType = YES;
        [KRUserInfo sharedKRUserInfo].sinaLogin = YES;
        /* 成功之后赋值 token */
        [KRUserInfo sharedKRUserInfo].sinaToken = responseObject[@"access_token"];
        // [];
        __weak typeof(self) sinaVc = self;
        [[KRXMPPTool sharedKRXMPPTool] userRegister:^(KRXMPPResultType type) {
            [sinaVc handleRegisterResult:type];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"获取token失败");
        [self dismissViewControllerAnimated:self completion:nil];
    }];
}
/* 处理注册结果 */
-(void)  handleRegisterResult:(KRXMPPResultType) type
{
     /* 无论内部注册成功还是失败 都直接登录 */
     [KRUserInfo sharedKRUserInfo].registerType = NO;
     // [self registerUserForWebServer];
    __weak typeof(self) selfVC = self;
     [[KRXMPPTool  sharedKRXMPPTool] userLogin:^(KRXMPPResultType type) {
        [selfVC handleLoginResult:type];
     }];
}
- (void)  handleLoginResult:(KRXMPPResultType) type
{
     __weak typeof(self) sinaVc = self;
    switch (type) {
        case KRXMPPResultTypeNetError:
            [MBProgressHUD   showError:@"网路错误"];
            break;
        case KRXMPPResultTypeLoginFailed:
            [MBProgressHUD showError:@"登录失败"];
            break;
        case KRXMPPResultTypeLoginSuccess:
        {
            // [MBProgressHUD showError:@"登录成功"];
            [KRUserInfo sharedKRUserInfo].sinaLogin = YES;
            [sinaVc dismissViewControllerAnimated:YES completion:nil];
            // 切换到主界面
            UIStoryboard *stroyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = stroyboard.instantiateInitialViewController;
            break;
        }
        default:
            break;
    }

}
- (IBAction)backClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) dealloc
{
    NSLog(@"%@",self);
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


+(void)dealloc
{
    NSLog(@"%@",self);
}
@end
