//
//  DryCollectRequest.m
//  fitplus
//
//  Created by xlp on 15/11/26.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "DryCollectRequest.h"

@implementation DryCollectRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSMutableDictionary *param = [@{@"userId" : userid,
                                    @"articleId" : _articleId} mutableCopy];
    [[RequestManager sharedNewInstance] POST:@"Article/addArticleFavorite" parameters:[self buildParam:param] success:^(NSURLSessionDataTask *task, id responseObject) {
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
