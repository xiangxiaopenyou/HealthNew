//
//  DeleteBlackListUserRequest.h
//  fitplus
//
//  Created by xlp on 15/12/8.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RBRequest.h"

@interface DeleteBlackListUserRequest : RBRequest
@property (nonatomic, copy) NSString *blackId;

@end
