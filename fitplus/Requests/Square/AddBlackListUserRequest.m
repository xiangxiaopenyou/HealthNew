//
//  AddBlackListUserRequest.m
//  fitplus
//
//  Created by xlp on 15/12/8.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "AddBlackListUserRequest.h"

@implementation AddBlackListUserRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSMutableDictionary *param = [@{@"userId" : userid,
                                    @"blackId" : _blackId} mutableCopy];
    [[RequestManager sharedInstance] POST:@"Black/addBlackList" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"state"] integerValue] == 1000) {
            !resultHandler ?: resultHandler(responseObject, nil);
        } else {
            !resultHandler ?: resultHandler(nil, responseObject[@"message"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !resultHandler ?: resultHandler(nil, error.description);
        
    }];
}

@end
