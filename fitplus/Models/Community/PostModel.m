//
//  PostModel.m
//  fitplus
//
//  Created by lalala on 15/12/12.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "PostModel.h"
#import "FetchPostRequest.h"
#import "CardModel.h"
@implementation PostModel

+ (void)postWith:(NSString *)articleId handler:(RequestResultHandler)handler {
    
    [[FetchPostRequest new] request:^BOOL(FetchPostRequest *request) {
        request.articleid = articleId;
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            !handler ?: handler(nil, msg);
        } else {
            CardModel *result = [[CardModel alloc] initWithDictionary:object error:nil];
            !handler ?: handler(result, nil);
            
        }
    }];
}


@end
