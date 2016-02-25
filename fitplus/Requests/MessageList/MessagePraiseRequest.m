//
//  MessagePraiseRequest.m
//  fitplus
//
//  Created by 陈 on 15/7/9.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "MessagePraiseRequest.h"
#import "CommonsDefines.h"
@implementation MessagePraiseRequest

-(void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler{
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] valueForKey:UserIdKey];
    if (userid) {
        NSMutableDictionary *param = [@{@"userId" : userid}mutableCopy];
    
        [[RequestManager sharedInstance] POST:@"Plate/getUserMessageNoteInf" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject[@"state"] intValue] == 1000) {
                !resultHandler ?: resultHandler(responseObject[@"data"], nil);
            }else {
                !resultHandler ?: resultHandler(nil, responseObject[@"message"]);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            !resultHandler ?: resultHandler(nil, [self handlerError:error]);
        }];
    } else {
        !resultHandler ?: resultHandler(nil, @"请求数据失败");
    }
}

@end
