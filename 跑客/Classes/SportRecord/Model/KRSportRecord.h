//
//  KRSportRecord.h
//  跑客
//
//  Created by guoaj on 15/10/29.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KRSport.h"
@interface KRSportRecord : NSObject
@property (nonatomic,assign) enum SportModel sportType;
@property (nonatomic,copy)  NSString * sportTimeLen;
@property (copy, nonatomic) NSString *sportDistance;
@property (copy, nonatomic) NSString *sportHeat;
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *sportStartTime;

@end


