//
//  HomepageModel.m
//  fitplus
//
//  Created by 陈 on 15/7/3.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "ClockInInforModel.h"
#import "ClockInInforRequest.h"
#import "LimitResultModel.h"
#import "ClockInDetailModel.h"
@implementation ClockInInforModel

+(void)getclockMessgeWithFrendid:(NSString *)frendid WithLimit:(NSInteger)page handler:(RequestResultHandler)handler{
    [[ClockInInforRequest new] request:^BOOL(ClockInInforRequest *request) {
        request.frendid = frendid;
        request.page = page;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            LimitResultModel *limitModel = [[LimitResultModel alloc] initWithNewResult:object modelKey:@"list" modelClass:[ClockInDetailModel new]];
            !handler ?: handler(limitModel, nil);
        }
    }];
}
@end
