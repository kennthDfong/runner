//
//  KRSportRecordCell.h
//  跑客
//
//  Created by guoaj on 15/10/29.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KRSportRecord.h"
@interface KRSportRecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sportRecordDate;
@property (weak, nonatomic) IBOutlet UIImageView *sportRecordType;
@property (weak, nonatomic) IBOutlet UILabel *sprotRecordTime;
@property (weak, nonatomic) IBOutlet UILabel *sportRecordDistance;
@property (weak, nonatomic) IBOutlet UILabel *sportRecordHeat;

- (void) setSPortData:(KRSportRecord*) sportData;
@end
