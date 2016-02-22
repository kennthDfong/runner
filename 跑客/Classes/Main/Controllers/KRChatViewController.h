//
//  KRChatViewController.h
//  跑客
//
//  Created by guoaj on 15/10/25.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPJID.h"
@interface KRChatViewController : UIViewController

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForBottom;

@property (nonatomic,strong) XMPPJID *friendJid;
@end
