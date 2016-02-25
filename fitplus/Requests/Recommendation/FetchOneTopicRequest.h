//
//  FetchOneTopicRequest.h
//  fitplus
//
//  Created by xlp on 15/11/24.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RBRequest.h"

@interface FetchOneTopicRequest : RBRequest
@property (nonatomic, copy) NSString *hotTopicId;
@property (nonatomic, copy) NSString *recommendationId;

@end
