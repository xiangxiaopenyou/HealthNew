//
//  MessageListViewController.h
//  fitplus
//
//  Created by 陈 on 15/7/8.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardModel.h"
@interface MessageListViewController : UIViewController
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong)CardModel *cardModel;

@end
