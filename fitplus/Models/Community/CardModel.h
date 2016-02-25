//
//  CardModel.h
//  fitplus
//
//  Created by xlp on 15/12/12.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "BaseModel.h"

@interface CardModel : BaseModel
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString<Optional> *pic;
@property (nonatomic, assign) NSInteger comment;
@property (nonatomic, assign) NSInteger favorite;
@property (nonatomic, copy) NSNumber<Optional> *favoriteState;
@property (nonatomic, copy) NSString *plateId; //圈子id
@property (nonatomic, copy) NSString<Optional> *name;  //圈子名称
@property (nonatomic, copy) NSString<Optional> *tag;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *lastTime;
@property (nonatomic, copy) NSString *isPublic;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *portrait;
@property (nonatomic, copy) NSString<Optional> *tagId;
@property (nonatomic, copy) NSString<Optional> *PlateUserId;
@property (nonatomic, copy) NSString<Optional> *PlateUserNickname;
@property (nonatomic, copy) NSString<Optional> *PlateUserPortrait;


+ (void)fetchCardList:(NSString *)communityId page:(NSInteger)page handler:(RequestResultHandler)handler;
+ (void)fetchRecentCardList:(NSString *)communityId page:(NSInteger)page handler:(RequestResultHandler)handler;
+ (void)postCard:(NSDictionary *)dictionary handler:(RequestResultHandler)handler;
+ (void)submitCard:(NSDictionary *)dictionary pictureArray:(NSArray *)array handler:(RequestResultHandler)handler;
//点赞
+ (void)addFavoriteWith:(NSString *)articleId handler:(RequestResultHandler)handler;
//取消点赞
+ (void)delFavortieWith:(NSString *)articleId handler:(RequestResultHandler)handler;
+ (void)addReportWith:(NSString *)reportId type:(NSString*)type handler:(RequestResultHandler)handler;
+ (void)cardDeleteWith:(NSString *)articleId handler:(RequestResultHandler)handler;
+ (void)commentDeleteWith:(NSString *)commentId handler:(RequestResultHandler)handler;
+ (void)fetchUserCardsWith:(NSString *)userId page:(NSInteger)page handler:(RequestResultHandler)handler;
@end
