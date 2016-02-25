//
//  CommentDeleteRequest.h
//  fitplus
//
//  Created by xlp on 15/12/21.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RBRequest.h"

@interface CommentDeleteRequest : RBRequest
@property (nonatomic, copy) NSString *commentId;

@end
