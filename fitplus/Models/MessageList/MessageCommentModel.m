//
//  MessageCommentModel.m
//  fitplus
//
//  Created by 陈 on 15/7/9.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "MessageCommentModel.h"
#import "MessageCommentRequest.h"
#import "LimitResultModel.h"
#import "MessagePraiseRequest.h"
@implementation MessageCommentModel

+ (void)MessageCommentWithPage:(NSInteger)page handler:(RequestResultHandler)handler{
    [[MessageCommentRequest new] request:^BOOL(MessageCommentRequest *request) {
        request.page = page;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        }else{
            
           // LimitResultModel *limitmodel = [[LimitResultModel alloc]initWithNewResult:object modelKey:@"list" modelClass:[MessageCommentModel new]];
            
             LimitResultModel *limitmodel = [[LimitResultModel alloc] initWithNewResult:object modelKey:@"list" modelClass:[MessageCommentModel new]];
            
            
            !handler ?: handler(limitmodel, nil);
        }
    }];
}
+ (void)MessageNote:(RequestResultHandler)handler
{

    [[MessagePraiseRequest new] request:^BOOL(MessagePraiseRequest *request) {
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        }else{
            
            LimitResultModel *limitmodel = [[LimitResultModel alloc]initWithNewResult:object modelKey:@"list" modelClass:[MessageCommentModel new]];
            
            !handler ?: handler(limitmodel, nil);
        }
    }];


}
@end
