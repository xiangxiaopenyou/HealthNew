//
//  BlackUserModel.h
//  fitplus
//
//  Created by xlp on 15/12/8.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "BaseModel.h"

@interface BlackUserModel : BaseModel
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *blackId;
@property (nonatomic, copy) NSString<Optional> *userNickname;
@property (nonatomic, copy) NSString<Optional> *userPortrait;
@property (nonatomic, copy) NSString<Optional> *blackNickname;
@property (nonatomic, copy) NSString<Optional> *blackPortrait;

+ (void)addBlack:(NSString *)blackId handler:(RequestResultHandler)handler;
+ (void)deleteBlack:(NSString *)blackId handler:(RequestResultHandler)handler;
+ (void)fetchBlackList:(RequestResultHandler)handler;

@end
