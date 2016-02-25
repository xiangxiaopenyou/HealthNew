//
//  FetchDelPraiseRequest.m
//  fitplus
//
//  Created by lalala on 15/12/16.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "FetchDelPraiseRequest.h"

@implementation FetchDelPraiseRequest

- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSMutableDictionary *param = [@{@"userId" : userid, @"articleId" : _articleId} mutableCopy];
    
    [[RequestManager sharedInstance] POST:@"Plate/delfavortie" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
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
