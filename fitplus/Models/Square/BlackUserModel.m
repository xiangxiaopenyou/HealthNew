//
//  BlackUserModel.m
//  fitplus
//
//  Created by xlp on 15/12/8.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "BlackUserModel.h"
#import "DeleteBlackListUserRequest.h"
#import "AddBlackListUserRequest.h"
#import "FetchBlackListRequest.h"
#import "LimitResultModel.h"

@implementation BlackUserModel
+ (void)addBlack:(NSString *)blackId handler:(RequestResultHandler)handler {
    [[AddBlackListUserRequest new] request:^BOOL(AddBlackListUserRequest *request) {
        request.blackId = blackId;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            !handler ?: handler(object, nil);
        }
    }];
}
+ (void)deleteBlack:(NSString *)blackId handler:(RequestResultHandler)handler {
    [[DeleteBlackListUserRequest new] request:^BOOL(DeleteBlackListUserRequest *request) {
        request.blackId = blackId;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            !handler ?: handler(object, nil);
        }
    }];
}
+ (void)fetchBlackList:(RequestResultHandler)handler {
    [[FetchBlackListRequest new] request:^BOOL(id request) {
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            LimitResultModel *tempModel = [[LimitResultModel alloc] initWithNewResult:object modelKey:@"list" modelClass:[BlackUserModel new]];
            !handler ?: handler(tempModel, nil);
        }
    }];
}


@end
