//
//  KRTestCell.h
//  跑客
//
//  Created by guoaj on 15/10/30.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KRSportTopic.h"
@protocol  KRTestCellProtocol<NSObject>
- (void) addConcatp:(NSString*) jidStr;
@end
@interface KRTestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nikeNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *guanZhuLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;

@property (weak, nonatomic) IBOutlet UIImageView *myTopicView;

@property (weak, nonatomic) IBOutlet UIButton *addConcatBtn;
@property (strong,nonatomic) id<KRTestCellProtocol> delegate;

- (void) setDataWithTopic:(KRSportTopic*) topic;
@end
