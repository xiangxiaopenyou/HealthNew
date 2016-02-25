//
//  FetchPostRequest.m
//  fitplus
//
//  Created by lalala on 15/12/12.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "FetchPostRequest.h"

@implementation FetchPostRequest

- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSMutableDictionary *param = [@{@"articleId" : _articleid,
                                    @"userId" : userid} mutableCopy];
    [[RequestManager sharedInstance] POST:@"Plate/getArticleByArticleId" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"state"] integerValue] == 1000) {
            NSLog(@"%@",responseObject);
            !resultHandler ?: resultHandler(responseObject[@"data"], nil);
        } else {
            !resultHandler ?: resultHandler(nil, responseObject[@"message"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !resultHandler ?: resultHandler(nil, error.description);
    }];
    
}

@end
