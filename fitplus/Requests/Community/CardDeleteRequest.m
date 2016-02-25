//
//  CardDeleteRequest.m
//  fitplus
//
//  Created by xlp on 15/12/21.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "CardDeleteRequest.h"

@implementation CardDeleteRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSMutableDictionary *param = [@{@"userId" : userId,
                                    @"articleId" : _articleId} mutableCopy];
    [[RequestManager sharedInstance] POST:@"Plate/delArticleByUser" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
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
