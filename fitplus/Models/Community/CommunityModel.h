//
//  CommunityModel.h
//  fitplus
//
//  Created by xlp on 15/12/11.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "BaseModel.h"

@interface CommunityModel : BaseModel
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *ico;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *isPublic;
@property (nonatomic, copy) NSNumber *hotNub;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, copy) NSString<Optional> *introduce;
@property (nonatomic, copy) NSString<Optional> *introducePic;
@property (nonatomic, copy) NSString *icoId;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *portrait;

+ (void)fetchHotCommunity:(RequestResultHandler)handler;
@end
