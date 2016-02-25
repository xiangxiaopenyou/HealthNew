//
//  CardModel.m
//  fitplus
//
//  Created by xlp on 15/12/12.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "CardModel.h"
#import "FetchHotCardRequest.h"
#import "LimitResultModel.h"
#import "FetchRecentCardRequest.h"
#import "PostCardRequest.h"
#import "QNImageUploadRequest.h"
#import "FetchPraiseRequest.h"
#import "FetchDelPraiseRequest.h"
#import "AddReportRequest.h"
#import "CardDeleteRequest.h"
#import "CommentDeleteRequest.h"
#import "FetchUserCardsRequest.h"
@implementation CardModel
+ (void)fetchCardList:(NSString *)communityId page:(NSInteger)page handler:(RequestResultHandler)handler {
    [[FetchHotCardRequest new] request:^BOOL(FetchHotCardRequest *request) {
        request.communityId = communityId;
        request.page = page;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            LimitResultModel *tempModel = [[LimitResultModel alloc] initWithNewResult:object modelKey:@"list" modelClass:[CardModel new]];
            !handler ?: handler(tempModel, nil);
        }
    }];
}
+ (void)fetchRecentCardList:(NSString *)communityId page:(NSInteger)page handler:(RequestResultHandler)handler {
    [[FetchRecentCardRequest new] request:^BOOL(FetchRecentCardRequest *request) {
        request.communityId = communityId;
        request.page = page;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            LimitResultModel *tempModel = [[LimitResultModel alloc] initWithNewResult:object modelKey:@"list" modelClass:[CardModel new]];
            !handler ?: handler(tempModel, nil);
        }
    }];
}
+ (void)postCard:(NSDictionary *)dictionary handler:(RequestResultHandler)handler {
    [[PostCardRequest new] request:^BOOL(PostCardRequest *request) {
        request.postDictionary = dictionary;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            !handler ?: handler(object, nil);
        }
    }];
}
+ (void)submitCard:(NSDictionary *)dictionary pictureArray:(NSArray *)array handler:(RequestResultHandler)handler {
    NSMutableDictionary *cardDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    if (array) {
        [[QNImageUploadRequest new] request:^BOOL(QNImageUploadRequest *request) {
            request.images = array;
            return YES;
        } result:^(id object, NSString *msg) {
            if (msg) {
                !handler ?: handler(nil, msg);
            } else {
                NSArray *keyArray = [object copy];
                NSString *keyString = @"";
                for (NSInteger i = 0; i < keyArray.count; i ++) {
                    if (i >= keyArray.count - 1) {
                        keyString = [NSString stringWithFormat:@"%@%@", keyString, keyArray[i]];
                        [cardDictionary setObject:keyString forKey:@"pic"];
                        [[self class] postCard:cardDictionary handler:handler];
                    } else {
                        keyString = [NSString stringWithFormat:@"%@%@,", keyString, keyArray[i]];
                    }
                }
            }
        }];
    } else {
        [[self class] postCard:dictionary handler:handler];
    }
}
//点赞
+ (void)addFavoriteWith:(NSString *)articleId handler:(RequestResultHandler)handler {
    
    [[FetchPraiseRequest new] request:^BOOL(FetchPraiseRequest *request) {
        request.articleId = articleId;
        
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            !handler ?: handler(object, nil);
            
        }
    }];
    
}
//取消点赞
+ (void)delFavortieWith:(NSString *)articleId handler:(RequestResultHandler)handler
{
    [[FetchDelPraiseRequest new] request:^BOOL(FetchDelPraiseRequest *request) {
        request.articleId = articleId;
        
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            !handler ?: handler(object, nil);
            
        }
    }];
    
}
//举报
+ (void)addReportWith:(NSString *)reportId type:(NSString*)type handler:(RequestResultHandler)handler

{
    [[AddReportRequest new] request:^BOOL(AddReportRequest *request) {
        request.reportid = reportId;
        request.type=type;
        
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            !handler ?: handler(object, nil);
            
        }
    }];

}
+ (void)cardDeleteWith:(NSString *)articleId handler:(RequestResultHandler)handler {
    [[CardDeleteRequest new] request:^BOOL(CardDeleteRequest *request) {
        request.articleId = articleId;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            !handler ?: handler(object, nil);
            
        }
    }];
}
+ (void)commentDeleteWith:(NSString *)commentId handler:(RequestResultHandler)handler {
    [[CommentDeleteRequest new] request:^BOOL(CommentDeleteRequest *request) {
        request.commentId = commentId;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            !handler ?: handler(object, nil);
            
        }
    }];
}
+ (void)fetchUserCardsWith:(NSString *)userId page:(NSInteger)page handler:(RequestResultHandler)handler {
    [[FetchUserCardsRequest new] request:^BOOL(FetchUserCardsRequest *request) {
        request.userId = userId;
        request.page = page;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            LimitResultModel *tempModel = [[LimitResultModel alloc] initWithNewResult:object modelKey:@"list" modelClass:[CardModel new]];
            !handler ?: handler(tempModel, nil);
        }
    }];
}

@end
