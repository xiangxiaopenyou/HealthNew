//
//  FetchDryListRequest.h
//  fitplus
//
//  Created by xlp on 15/11/26.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RBRequest.h"

@interface FetchDryListRequest : RBRequest
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, copy) NSString *kindsId;
@end
