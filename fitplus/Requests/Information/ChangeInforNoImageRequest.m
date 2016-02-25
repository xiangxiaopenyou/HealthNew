//
//  ChangeInforNoImageRequest.m
//  fitplus
//
//  Created by 陈 on 15/7/16.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "ChangeInforNoImageRequest.h"

@implementation ChangeInforNoImageRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler{
    if (!paramsBlock(self)) {
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] valueForKey:UserIdKey];
    NSString *usertoken = [[NSUserDefaults standardUserDefaults] valueForKey:UserTokenKey];
//    if ([_weight integerValue] == 0) {
//        _weight = @"60";
//    }
//    if ([_height integerValue] == 0) {
//        _height = @"170";
//    }
    NSMutableDictionary *param = [@{@"userid" : userid,
                                    @"usertoken" : usertoken,
                                    @"nickname" : _nickname,
                                    @"weightT" : @"70",
                                    @"weight" :_weight,
                                    @"sex" :_sex,
                                    @"duration" : @"1",
                                    @"portrait" : _portrait,
                                    @"introduce" : _introduce,
                                    @"height" : _height,
                                    @"age" : _age
                                    } mutableCopy];
    [[RequestManager sharedInstance] POST:@"Own/updateTerminal" parameters:[self buildParam:param] success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"state"] integerValue] == 1000) {
            !resultHandler ?: resultHandler(responseObject[@"data"], nil);
        } else {
            !resultHandler ?: resultHandler(nil, responseObject[@"message"]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !resultHandler ?: resultHandler(nil, [self handlerError:error]);
    }];

}

@end
