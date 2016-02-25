//
//  FetchRecentCardRequest.h
//  fitplus
//
//  Created by xlp on 15/12/14.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RBRequest.h"

@interface FetchRecentCardRequest : RBRequest
@property (nonatomic, copy) NSString *communityId;
@property (nonatomic, assign) NSInteger page;

@end
