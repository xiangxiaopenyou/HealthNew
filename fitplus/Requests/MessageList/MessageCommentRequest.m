//
//  MessageCommentRequest.m
//  fitplus
//
//  Created by 陈 on 15/7/9.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "MessageCommentRequest.h"
#import "CommonsDefines.h"

@implementation MessageCommentRequest

- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler
{
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSMutableDictionary *param = [@{@"page" : @(_page),
                                    @"userId" : userid} mutableCopy];
   
    [[RequestManager sharedInstance] POST:@"Plate/getUserNoteInf" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
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
