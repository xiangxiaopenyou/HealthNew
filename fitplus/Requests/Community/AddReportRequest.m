//
//  AddReportRequest.m
//  fitplus
//
//  Created by lalala on 15/12/20.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "AddReportRequest.h"

@implementation AddReportRequest

- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSMutableDictionary *param = [@{@"userId" : userid, @"reportid" : _reportid,@"type" : _type} mutableCopy];
    
    [[RequestManager sharedInstance] POST:@"Plate/addReport" parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
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
