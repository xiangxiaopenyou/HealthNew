//
//  TopicModel.m
//  fitplus
//
//  Created by xlp on 15/11/27.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "TopicModel.h"
#import "FetchHotTopicListRequest.h"
#import "LimitResultModel.h"
#import "FetchOneTopicRequest.h"

@implementation TopicModel
+ (void)fetchRecommendedTopicList:(RequestResultHandler)handler {
    [[FetchHotTopicListRequest new] request:^BOOL(FetchHotTopicListRequest *request) {
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            LimitResultModel *tempModel = [[LimitResultModel alloc] initWithNewResult:object modelKey:@"list" modelClass:[TopicModel new]];
            !handler ?: handler(tempModel, nil);
        }
    }];
}
+ (void)fetchOneTopicDetail:(NSString *)hotTopicId recommendationId:(NSString *)recommendationId handler:(RequestResultHandler)handler {
    [[FetchOneTopicRequest new] request:^BOOL(FetchOneTopicRequest *request) {
        request.hotTopicId = hotTopicId;
        request.recommendationId = recommendationId;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler (nil, msg);
        } else {
            !handler ?: handler(object, nil);
        }
    }];
}
@end
