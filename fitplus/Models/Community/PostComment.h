//
//  PostComment.h
//  fitplus
//
//  Created by lalala on 15/12/12.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "BaseModel.h"

@interface PostComment : BaseModel
@property (nonatomic ,copy) NSString *userNickname;
@property (nonatomic ,copy) NSString *userPortrait;
@property (nonatomic ,copy) NSString<Optional> *commentNickname;
@property (nonatomic ,copy) NSString<Optional> *commentPortrait;
@property (nonatomic ,copy) NSString *id;
@property (nonatomic ,copy) NSString *userId;
@property (nonatomic ,copy) NSString *articleId;
@property (nonatomic ,copy) NSString *commentId;
@property (nonatomic ,copy) NSString *commentContent;
@property (nonatomic ,copy) NSString *createTime;
@property (nonatomic ,assign) NSInteger ispublic;
@property (nonatomic ,assign) NSInteger isRead;
@property (nonatomic ,copy) NSString *type;
@property (nonatomic ,assign) NSInteger isUser;
@property (nonatomic ,assign) NSInteger isOwn;
@property (nonatomic ,strong) NSArray *reply;
@property (nonatomic ,copy) NSString *commendId;

//@property (nonatomic ,strong) NSArray *list;
//@property (nonatomic ,assign) NSInteger count;
//@property (nonatomic ,assign) NSInteger page;
//@property (nonatomic ,assign) NSInteger pagesize;
//@property (nonatomic ,assign) NSInteger totalpage;

//获取评论或者回复
+ (void)postCommentWith:(NSString *)articleId page:(NSInteger)page handler:(RequestResultHandler)handler;
//点赞
+ (void)postLikeWith:(NSString *)articleId handler:(RequestResultHandler)handler;
//取消点赞
+ (void)postDelCommentWith:(NSString *)articleId handler:(RequestResultHandler)handler;
//评论或者回复
+ (void)postAddArticleCommentWith:(NSString *)articleId userId:(NSString *)userId type:(NSString*)type commentId:(NSString*)commentId commentContent:(NSString*)commentContent replyId:(NSString*)replyId commendId:(NSString*)commendId handler:(RequestResultHandler)handler;
//删除评论
+ (void)postDeleteCommentWith:(NSString *)commendId handler:(RequestResultHandler)handler;

@end
