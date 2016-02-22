//
//  KRMyProfileViewController.m
//  跑客
//
//  Created by guoaj on 15/10/24.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import "KRMyProfileViewController.h"
#import "KRXMPPTool.h"
#import "XMPPvCardTemp.h"
#import "KRUserInfo.h"
#import "KREditMyProfileController.h"
#import "UIImageView+KRRoundImageView.h"
@interface KRMyProfileViewController()
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nikeName;

@property (strong,nonatomic) XMPPvCardTemp *vCardTemp;
- (IBAction)hideProfileBtnClick:(id)sender;

@end
@implementation KRMyProfileViewController
- (void)viewDidLoad
{
    
}
- (void) viewWillAppear:(BOOL)animated{
    XMPPvCardTemp *vCardTemp = [KRXMPPTool sharedKRXMPPTool].xmppvCard.myvCardTemp;
    self.nikeName.text = [KRUserInfo sharedKRUserInfo].userName;
    if (vCardTemp.photo) {
        self.headImage.image = [UIImage imageWithData:vCardTemp.photo];
    }else{
        self.headImage.image = [UIImage imageNamed:@"placehoder"];
        vCardTemp.photo = UIImagePNGRepresentation(self.headImage.image);
    }
    [self.headImage setRoundLayer];
    self.vCardTemp = vCardTemp;

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navDes = segue.destinationViewController;
    if ([[navDes topViewController] isKindOfClass:[KREditMyProfileController class]]) {
        KREditMyProfileController* editProfileVc =
        (KREditMyProfileController*)[navDes topViewController];
        editProfileVc.vCardTemp = self.vCardTemp;
    }
}
/** 退出登录 */
- (IBAction)logout:(UIButton *)sender {
    [[KRUserInfo sharedKRUserInfo] saveKRUserInfoToSandBox];
    [[KRXMPPTool sharedKRXMPPTool] sendOffLine];
    [KRUserInfo sharedKRUserInfo].jid = nil;
    if ([KRUserInfo sharedKRUserInfo].sinaLogin) {
        [KRUserInfo sharedKRUserInfo].sinaLogin = NO;
        [KRUserInfo sharedKRUserInfo].userName = nil;
    }
   
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *vc = storyboard.instantiateInitialViewController;
    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
}
/* 隐藏当前控制器 */
- (IBAction)hideProfileBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end



