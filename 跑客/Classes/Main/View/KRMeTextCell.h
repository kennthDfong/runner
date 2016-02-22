//
//  KRMeTextCell.h
//  跑客
//
//  Created by guoaj on 15/10/25.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KRMeTextCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nikeName;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *chatTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *popImageView;
@end
