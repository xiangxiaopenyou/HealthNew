//
//  AddReportRequest.h
//  fitplus
//
//  Created by lalala on 15/12/20.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RBRequest.h"

@interface AddReportRequest : RBRequest

@property (nonatomic, copy) NSString *reportid;
@property (nonatomic, copy) NSString *type;

@end
