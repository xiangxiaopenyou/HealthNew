//
//  FetchHotCardRequest.h
//  fitplus
//
//  Created by xlp on 15/12/12.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RBRequest.h"

@interface FetchHotCardRequest : RBRequest
@property (nonatomic, copy) NSString *communityId;
@property (nonatomic, assign) NSInteger page;

@end
