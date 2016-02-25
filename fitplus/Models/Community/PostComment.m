//
//  PostComment.m
//  fitplus
//
//  Created by lalala on 15/12/12.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "PostComment.h"
#import "FetchCommentRequest.h"
#import "FetchPraiseRequest.h"
#import "FetchDelPraiseRequest.h"
#import "FetchAddCommendRequest.h"
#import "FetchDeleteCommentRequest.h"
#import "LimitResultModel.h"
@implementation PostComment

+ (void)postCommentWith:(NSString *)articleId page:(NSInteger)page handler:(RequestResultHandler)handler {
    [[FetchCommentRequest new] request:^BOOL(FetchCommentRequest *request) {
        request.articleId = articleId;
        request.page = page;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            //NSLog(@"comment=%@",object);
            LimitResultModel *tempModel = [[LimitResultModel alloc] initWithNewResult:object modelKey:@"list" modelClass:[PostComment new]];
            !handler ?: handler(tempModel, nil);
            
        }
    }];

    
}
+ (void)postLikeWith:(NSString *)articleId handler:(RequestResultHandler)handler {
    
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
+ (void)postDelCommentWith:(NSString *)articleId handler:(RequestResultHandler)handler
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
+ (void)postAddArticleCommentWith:(NSString *)articleId userId:(NSString *)userId type:(NSString*)type commentId:(NSString*)commentId commentContent:(NSString*)commentContent replyId:(NSString*)replyId commendId:(NSString*)commendId handler:(RequestResultHandler)handler {
    [[FetchAddCommendRequest new] request:^BOOL(FetchAddCommendRequest *request) {
        request.userId = userId;
        request.article = articleId;
        request.type=type;
        request.commentId=commentId;
        request.commentContent=commentContent;
        request.replyId=replyId;
        request.commendId=commendId;
        
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            !handler ?: handler(object, nil);
            
        }
    }];

}
+ (void)postDeleteCommentWith:(NSString *)commendId handler:(RequestResultHandler)handler
{
    [[FetchDeleteCommentRequest new] request:^BOOL(FetchDeleteCommentRequest *request) {
        
        request.commendId=commendId ;
        
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            !handler ?: handler(object, nil);
            
        }
    }];

}

@end
