//
//  PostModel.h
//  fitplus
//
//  Created by lalala on 15/12/12.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "BaseModel.h"

@interface PostModel : BaseModel

//帖子详情
+ (void)postWith:(NSString *)articleId handler:(RequestResultHandler)handler;

@end
