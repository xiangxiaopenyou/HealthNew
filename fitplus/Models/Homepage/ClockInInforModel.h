//
//  HomepageModel.h
//  fitplus
//
//  Created by 陈 on 15/7/3.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "BaseModel.h"

@interface ClockInInforModel : BaseModel

+ (void)getclockMessgeWithFrendid:(NSString *)frendid WithLimit:(NSInteger)page handler:(RequestResultHandler)handler;
@end
