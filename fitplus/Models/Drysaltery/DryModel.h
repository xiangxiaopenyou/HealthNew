//
//  DryModel.h
//  fitplus
//
//  Created by xlp on 15/11/26.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "BaseModel.h"

@interface DryModel : BaseModel
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *enable;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString<Optional> *area;
@property (nonatomic, copy) NSString *portrait;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *labelName;
@property (nonatomic, copy) NSString *createdate;
@property (nonatomic, copy) NSString *labellids;
@property (nonatomic, copy) NSString *headimage;
@property (nonatomic, copy) NSString *portraitUrl;
@property (nonatomic, assign) NSInteger *readsum;
@property (nonatomic, copy) NSString<Optional> *articleFavoriteId;
@end
