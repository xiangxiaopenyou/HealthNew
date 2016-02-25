//
//  CommunityModel.m
//  fitplus
//
//  Created by xlp on 15/12/11.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "CommunityModel.h"
#import "FetchHotCommunityRequest.h"
#import "LimitResultModel.h"

@implementation CommunityModel
+ (void)fetchHotCommunity:(RequestResultHandler)handler {
    [[FetchHotCommunityRequest new] request:^BOOL(FetchHotCommunityRequest *request) {
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            NSArray *result = [[CommunityModel class] setupWithArray:object];
            !handler ?: handler(result, nil);
        }
    }];
}
@end
