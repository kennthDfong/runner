//
//  AppDelegate.m
//  跑客
//
//  Created by guoaj on 15/10/23.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD+KR.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

//- (UIStatusBarStyle)preferredStatusBarStyle
//
//{
//    
//    return UIStatusBarStyleLightContent;
//    
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setThme];
    self.manager = [[BMKMapManager alloc]init];
    [self.manager start:@"siUhWmFxG86396FlAXxFzoH6" generalDelegate:self];
    return YES;
}
/**  设置状态栏和导航栏的统一样式 */
- (void) setThme
{
    // 1.设置导航栏背景
    UINavigationBar *bar = [UINavigationBar appearance];
     [bar setBackgroundImage:[UIImage imageNamed:@"矩形.png"] forBarMetrics:UIBarMetricsDefault];
    // 状态栏
    bar.barStyle =  UIBarStyleBlack;
    //
    bar.tintColor = [UIColor whiteColor];
}
/** 百度地图联网状态 */
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        MYLog(@"联网成功");
    }
    else{
        // NSLog(@"onGetNetworkState %d",iError);
        // [MBProgressHUD showError:@"网络错误"];
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        MYLog(@"授权成功");
    }
    else {
        // NSLog(@"onGetPermissionState %d",iError);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
