//
//  TakePhotoModel.m
//  fitplus
//
//  Created by xlp on 15/8/21.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "TakePhotoModel.h"

@implementation TakePhotoModel
+ (NSDictionary *)buildRecordWithRecord:(NSArray *)goods calories:(CGFloat)calories tags:(NSArray *)tags content:(NSString *)content topicId:(NSString *)topicId {
    NSMutableDictionary *record = [[super buildRecordWithRecord:goods calories:calories tags:tags content:content topicId:topicId] mutableCopy];
    [record setObject:@(3) forKey:@"trendsportstype"];
    return record;
}

@end
