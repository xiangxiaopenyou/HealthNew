//
//  FetchAddCommendRequest.m
//  fitplus
//
//  Created by lalala on 15/12/17.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "FetchAddCommendRequest.h"

@implementation FetchAddCommendRequest

- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSMutableDictionary *param = [@{ @"type" :_type,
                                     @"userId" : _userId,
                                     @"article" : _article,
                                     @"commentId" :_commentId,
                                     @"commentContent" :_commentContent} mutableCopy];
    if (_commendId) {
        [param setObject:_commendId forKey:@"replyId"];
    }
    if (_replyId) {
        [param setObject:_replyId forKey:@"commendId"];
    }
    
    [[RequestManager sharedInstance] POST:@"Plate/addArticleCommend" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
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
