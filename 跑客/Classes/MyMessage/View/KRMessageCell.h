//
//  KRMessageCell.h
//  跑客
//
//  Created by guoaj on 15/11/1.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KRMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *friendHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *nikeNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageDateLabel;


@end
