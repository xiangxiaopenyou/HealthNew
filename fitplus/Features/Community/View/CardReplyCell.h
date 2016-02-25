//
//  CardReplyCell.h
//  fitplus
//
//  Created by xlp on 15/12/18.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TYAttributedLabel.h>
typedef void (^ClickHead)(NSString *userId);

@interface CardReplyCell : UITableViewCell<TYAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (nonatomic, strong) TYAttributedLabel *contentLabel;

@property (nonatomic, copy) NSDictionary *dictionary;

@property (nonatomic, copy) ClickHead clickHead;

- (void)setupContainer:(NSDictionary *)dic;
- (CGFloat)heightOfCell:(NSDictionary *)dic;
- (void)headClick:(ClickHead)head;

@end
