//
//  FetchUserCardsRequest.m
//  fitplus
//
//  Created by xlp on 15/12/24.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "FetchUserCardsRequest.h"

@implementation FetchUserCardsRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSDictionary *param = @{@"userId" : _userId, @"page" : @(_page)};
    [[RequestManager sharedInstance] POST:@"Plate/getUerArticleList" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
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
