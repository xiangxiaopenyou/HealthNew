//
//  CommentDeleteRequest.m
//  fitplus
//
//  Created by xlp on 15/12/21.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "CommentDeleteRequest.h"

@implementation CommentDeleteRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSMutableDictionary *param = [@{@"userId" : userId,
                                    @"commendId" : _commentId} mutableCopy];
    [[RequestManager sharedInstance] POST:@"Plate/delArticleCommend" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
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
