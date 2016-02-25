//
//  FetchHotCardRequest.m
//  fitplus
//
//  Created by xlp on 15/12/12.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "FetchHotCardRequest.h"

@implementation FetchHotCardRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSMutableDictionary *param = [@{@"page" : @(_page),
                                    @"userId" : userid} mutableCopy];
    if (_communityId && ![_communityId isEqualToString:@""]) {
        [param setObject:_communityId forKey:@"plateId"];
    }
    [[RequestManager sharedInstance] POST:@"Plate/getPlateHotArticleList" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
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
