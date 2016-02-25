//
//  FetchBodyResultRequest.m
//  fitplus
//
//  Created by xlp on 15/12/3.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "FetchBodyResultRequest.h"

@implementation FetchBodyResultRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSMutableDictionary *param = [@{@"userId" : userid,
                                    @"sex" : _dictionary[@"sex"],
                                    @"height" : _dictionary[@"height"],
                                    @"weight" : _dictionary[@"weight"],
                                    @"age" : _dictionary[@"age"],
                                    @"tag" : _dictionary[@"tag"],
                                    @"body" : _dictionary[@"body"],
                                    @"SportTime" : _dictionary[@"sporttime"]} mutableCopy];
    [[RequestManager sharedInstance] POST:@"Course/getguideUrl" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
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
