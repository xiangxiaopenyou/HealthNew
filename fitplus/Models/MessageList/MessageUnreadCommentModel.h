//
//  MessageListModel.h
//  fitplus
//
//  Created by 陈 on 15/7/8.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "BaseModel.h"

@interface MessageUnreadCommentModel : BaseModel
@property (nonatomic, strong) NSString *allNum;
@property (nonatomic, strong) NSString *num;

+ (void)unreadMessage:(RequestResultHandler)handler;

@end
