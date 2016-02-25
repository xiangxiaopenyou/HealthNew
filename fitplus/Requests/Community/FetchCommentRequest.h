//
//  FetchCommentRequest.h
//  fitplus
//
//  Created by lalala on 15/12/16.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RBRequest.h"

@interface FetchCommentRequest : RBRequest

@property (nonatomic, copy) NSString *articleId;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;

@end
