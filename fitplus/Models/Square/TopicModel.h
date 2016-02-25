//
//  TopicModel.h
//  fitplus
//
//  Created by xlp on 15/11/27.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "BaseModel.h"

@interface TopicModel : BaseModel
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *pic;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *ctime;
@property (nonatomic, assign) NSInteger tag_num; //点击人数
@property (nonatomic, assign) NSInteger attend_num; //参与人数
@property (nonatomic, assign) NSInteger pic_num;
@property (nonatomic, copy) NSString *recommedId;
@property (nonatomic, copy) NSArray<Optional> *hostList;
@property (nonatomic, copy) NSString *hostName;

+ (void)fetchRecommendedTopicList:(RequestResultHandler)handler;
+ (void)fetchOneTopicDetail:(NSString *)hotTopicId recommendationId:(NSString *)recommendationId handler:(RequestResultHandler)handler;

@end
