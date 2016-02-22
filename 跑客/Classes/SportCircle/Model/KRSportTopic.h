//
//  KRSportTopic.h
//  跑客
//
//  Created by guoaj on 15/10/30.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRSportTopic : NSObject
/*   address = "\U5317\U4eac\U6f58\U5bb6\U56ed";
 content = "\U8fd9\U4e2a\U8fd0\U52a8\U6d88\U8017\U4e86\U4e0d\U5c11\U80fd\U91cf \U6709\U52a9\U4e8e\U51cf\U80a5";
 "createTime " = 0;
 id = 2;
 imageUrl = "/allRunServer/topicImage/test.png";
 latitude = "37.33007046735588";
 longitude = "-122.0211791992187";
 username = c; */
@property (nonatomic,copy) NSString *address;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *createTime;
@property (nonatomic,copy) NSString *topicid;
@property (nonatomic,copy) NSString *imageUrl;
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *latitude;
@property (nonatomic,copy) NSString *longitude;
@end




