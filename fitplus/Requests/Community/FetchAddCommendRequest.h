//
//  FetchAddCommendRequest.h
//  fitplus
//
//  Created by lalala on 15/12/17.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RBRequest.h"

@interface FetchAddCommendRequest : RBRequest

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *article;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *commentId;
@property (nonatomic, copy) NSString *commentContent;
@property (nonatomic, copy) NSString *replyId;
@property (nonatomic, copy) NSString *commendId;



@end
