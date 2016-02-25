//
//  RecommendedTopicCell.h
//  fitplus
//
//  Created by xlp on 15/11/23.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicModel.h"

@interface RecommendedTopicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *topicNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *ruleLabel;
@property (weak, nonatomic) IBOutlet UIView *photoContainView;
@property (weak, nonatomic) IBOutlet UILabel *popularityNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *photosNumberLabel;

- (void)setupContent:(TopicModel *)model;
- (CGFloat)heightOfCell:(TopicModel *)model;

@end
