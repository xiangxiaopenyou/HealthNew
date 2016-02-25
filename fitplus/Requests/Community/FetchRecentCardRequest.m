//
//  FetchRecentCardRequest.m
//  fitplus
//
//  Created by xlp on 15/12/14.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "FetchRecentCardRequest.h"

@implementation FetchRecentCardRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSMutableDictionary *param = [@{@"page" : @(_page),
                                    @"plateId" : _communityId,
                                    @"userId" : userid} mutableCopy];
    [[RequestManager sharedInstance] POST:@"Plate/getPlateNewArticleByPlateId" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"state"] integerValue] == 1000) {
            !resultHandler ?: resultHandler(responseObject[@"data"], nil);
        } else {
            !resultHandler ?: resultHandler(nil, responseObject[@"message"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !resultHandler ?: resultHandler(nil, error.description);
    }];
}

@end
