//
//  UploadPicturesRequest.h
//  fitplus
//
//  Created by xlp on 15/12/16.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RBRequest.h"

@interface UploadPicturesRequest : RBRequest
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSArray *keys;

@end
