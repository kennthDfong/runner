//
//  KRSportRecordCell.m
//  跑客
//
//  Created by guoaj on 15/10/29.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import "KRSportRecordCell.h"

@implementation KRSportRecordCell

/* 根据枚举值获得 相应的图片名 */
- (NSString*) getImageNameByModel:(enum SportModel) type
{
    NSString *imageName = nil;
    switch(type)
    {
        case SportModelBike:
            imageName = @"cmbike";
            break;
        case SportModelWalk:
            imageName = @"cmwalk";
            break;
        case SportModelFree:
            imageName = @"cmfree";
            break;
        case SportModelSkiing:
            imageName = @"cmskiing";
            break;
            
    }
    return  imageName;
}
/* 给cell 赋值的方法 */
- (void) setSPortData:(KRSportRecord*) sportData;
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[sportData.sportStartTime doubleValue]];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [format stringFromDate:date];
    self.sportRecordDate.text = dateStr;
    self.sportRecordDistance.text = [[sportData.sportDistance substringToIndex:[sportData.sportDistance rangeOfString:@"."].location ]stringByAppendingString:@"米"];
    if ([sportData.sportHeat isEqualToString:@"0.0"]) {
         self.sportRecordHeat.text = @"0K卡";
    }else{
         self.sportRecordHeat.text =  [[sportData.sportHeat substringToIndex:[sportData.sportHeat rangeOfString:@"."].location+4 ] stringByAppendingString:@"K卡"];
    }
   
    //self.sportRecordHeat.text = sportData.sportHeat;
    self.sportRecordType.image = [UIImage imageNamed:[self getImageNameByModel:sportData.sportType]];
    self.sprotRecordTime.text = [[sportData.sportTimeLen substringToIndex:[sportData.sportTimeLen rangeOfString:@"."].location ] stringByAppendingString:@"秒"];
}
@end
