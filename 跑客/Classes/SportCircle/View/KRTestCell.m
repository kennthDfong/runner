//
//  KRTestCell.m
//  跑客
//
//  Created by guoaj on 15/10/30.
//  Copyright © 2015年 Strom. All rights reserved.
//

#import "KRTestCell.h"
#import "KRXMPPTool.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
@implementation KRTestCell
- (void) setDataWithTopic:(KRSportTopic*) topic
{
   
    self.topicLabel.text = topic.content;
    if (topic.imageUrl) {
        
//         NSString *imageurl = [NSString stringWithFormat:@"http://localhost:8080%@",topic.imageUrl];
         NSString *imageurl = [NSString stringWithFormat:@"http://%@:8080/%@",KRXMPPHOSTNAME,topic.imageUrl];
         MYLog(@"%@",imageurl);
         [self.myTopicView setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[UIImage imageNamed:@"mapplaceholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
         }];
    }
    self.topicLabel.text = topic.content;
    self.nikeNameLabel.text = topic.username;
    // self.addConcatBtn.tag = ind;
    [self.addConcatBtn addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
}
- (void) addFriend
{
    NSLog(@"add firend");
    if ([self.delegate respondsToSelector:@selector(addConcatp:)]) {
        [self.delegate addConcatp:self.nikeNameLabel.text];
    }
}
@end
