//
//  ChangeInforModel.h
//  fitplus
//
//  Created by 陈 on 15/7/15.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "BaseModel.h"

@interface ChangeInforModel : BaseModel
@property (nonatomic, strong) NSString<Optional> *duration;
@property (nonatomic, strong) NSString *height;
@property (nonatomic, strong) NSString *introduce;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *portrait;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *tel;
@property (nonatomic, strong) NSString *weight;
@property (nonatomic, strong) NSString<Optional> *weightT;
@property (nonatomic, copy) NSString<Optional> *score;
@property (nonatomic, copy) NSString<Optional> *fansNum;
@property (nonatomic, copy) NSString<Optional> *AttentionNum;
@property (nonatomic, copy) NSNumber<Optional> *flag;
@property (nonatomic, copy) NSString<Optional> *age;

+ (void)fetchMyInfomation:(RequestResultHandler)handler;
+ (void)fetchUserInformation:(NSString *)friendId handler:(RequestResultHandler)handler;

@end
