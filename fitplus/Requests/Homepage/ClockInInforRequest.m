//
//  HomepageRequest.m
//  fitplus
//
//  Created by 陈 on 15/7/3.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "ClockInInforRequest.h"
#import "CommonsDefines.h"

@implementation ClockInInforRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler{
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] valueForKey:UserIdKey];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if (_frendid) {
        [param setObject:_frendid forKey:@"FriendId"];
    } else {
        [param setObject:userid forKey:@"FriendId"];
    }
    [param setObject:@(_page) forKey:@"page"];
    [[RequestManager sharedInstance] POST:@"Trends/getMyFriendNewsList" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"state"] integerValue] == 1000) {
            !resultHandler ?: resultHandler(responseObject[@"data"], nil);
        }else {
            !resultHandler ?: resultHandler(nil, responseObject[@"message"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !resultHandler ?: resultHandler(nil, [self handlerError:error]);
    }];

}
@end
