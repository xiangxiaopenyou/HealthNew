//
//  FetchOneTopicRecentRequest.h
//  fitplus
//
//  Created by xlp on 15/12/2.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RBRequest.h"

@interface FetchOneTopicRecentRequest : RBRequest
@property (nonatomic, copy) NSString *topicId;
@property (nonatomic, assign) NSInteger page;

@end
