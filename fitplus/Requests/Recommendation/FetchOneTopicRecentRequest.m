//
//  FetchOneTopicRecentRequest.m
//  fitplus
//
//  Created by xlp on 15/12/2.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "FetchOneTopicRecentRequest.h"

@implementation FetchOneTopicRecentRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSMutableDictionary *param = [@{@"userId" : userid,
                                    @"HostId" : _topicId,
                                    @"page" : @(_page)} mutableCopy];
    [[RequestManager sharedInstance] POST:@"Trends/getNewHostList" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
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
