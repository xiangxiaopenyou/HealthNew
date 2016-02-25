//
//  PostCardRequest.m
//  fitplus
//
//  Created by xlp on 15/12/15.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "PostCardRequest.h"

@implementation PostCardRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSMutableDictionary *param = [@{@"userId" : userId,
                                    @"plateId" : _postDictionary[@"plateId"],
                                    @"title" : _postDictionary[@"title"],
                                    @"text" : _postDictionary[@"text"]} mutableCopy];
    if (_postDictionary[@"tag"]) {
        [param setObject:_postDictionary[@"tag"] forKey:@"tag"];
    }
    if (_postDictionary[@"pic"]) {
        [param setObject:_postDictionary[@"pic"] forKey:@"pic"];
    }
    [[RequestManager sharedInstance] POST:@"Plate/addArticleByUser" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
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
