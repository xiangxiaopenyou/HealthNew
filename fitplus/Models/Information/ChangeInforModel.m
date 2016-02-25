//
//  ChangeInforModel.m
//  fitplus
//
//  Created by 陈 on 15/7/15.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "ChangeInforModel.h"
#import "GetOwnInfomationRequest.h"
#import "FetchUserInformationRequest.h"
@implementation ChangeInforModel

+ (void)fetchMyInfomation:(RequestResultHandler)handler {
    [[GetOwnInfomationRequest new] request:^BOOL(GetOwnInfomationRequest *request) {
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            ChangeInforModel *changeinforModel = [[ChangeInforModel alloc] initWithDictionary:object error:nil];
            
            !handler ?: handler(changeinforModel, nil);
        }
    }];
}
+ (void)fetchUserInformation:(NSString *)friendId handler:(RequestResultHandler)handler {
    [[FetchUserInformationRequest new] request:^BOOL(FetchUserInformationRequest *request) {
        request.friendId = friendId;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            ChangeInforModel *informationModel = [[ChangeInforModel alloc] initWithDictionary:object error:nil];
            !handler ?: handler(informationModel, nil);
        }
    }];
}
@end
