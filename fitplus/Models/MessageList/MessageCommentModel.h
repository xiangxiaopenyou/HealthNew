//
//  MessageCommentModel.h
//  fitplus
//
//  Created by 陈 on 15/7/9.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "BaseModel.h"

@interface MessageCommentModel : BaseModel
@property (nonatomic, strong) NSString<Optional> *massage;
@property (nonatomic, strong) NSString *recipientUserId;
@property (nonatomic, strong) NSString *recipientNickName;
@property (nonatomic, strong) NSString<Optional> *recipientPortrait;
@property (nonatomic, strong) NSString *sendUserId;
@property (nonatomic, strong) NSString *sendUserNickName;
@property (nonatomic, strong) NSString<Optional> *sendUserPortrait;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *massageid;
@property (nonatomic, strong) NSString *dbTableName;
@property (nonatomic, strong) NSString<Optional> *functionName;
@property (nonatomic, strong) NSString<Optional> *picUrl;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString<Optional> *sendData;
@property (nonatomic, strong) NSString<Optional> *ID;
@property (nonatomic, strong) NSString *isRead;


+ (void)MessageCommentWithPage:(NSInteger)page handler:(RequestResultHandler)handler;
+ (void)MessageNote:(RequestResultHandler)handler;
@end
