//
//  FetchUserCardsRequest.h
//  fitplus
//
//  Created by xlp on 15/12/24.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RBRequest.h"

@interface FetchUserCardsRequest : RBRequest
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) NSInteger page;

@end
