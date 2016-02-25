//
//  FetchUserInformationRequest.h
//  fitplus
//
//  Created by xlp on 15/11/30.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RBRequest.h"

@interface FetchUserInformationRequest : RBRequest
@property (nonatomic, copy) NSString *friendId;

@end
