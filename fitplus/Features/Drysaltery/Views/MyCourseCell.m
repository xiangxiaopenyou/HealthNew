//
//  MyCourseCell.m
//  fitplus
//
//  Created by xlp on 15/9/23.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "MyCourseCell.h"
#import <UIImageView+AFNetworking.h>
#import "Util.h"

@implementation MyCourseCell
- (void)setupContent:(CourseModel *)model {
    _courseDaysBar.layer.masksToBounds = YES;
    _courseDaysBar.layer.cornerRadius = 4.0;
    _finishedDaysBar.layer.masksToBounds = YES;
    _finishedDaysBar.layer.cornerRadius = 4.0;
    
    _courseNameLabel.text = model.courseName;
    _courseDaysLabel.text = [NSString stringWithFormat:@"%@天", @(model.courseDays)];
    [_courseImageView setImageWithURL:[NSURL URLWithString:[Util urlPhoto:model.coursePicture]] placeholderImage:[UIImage imageNamed:@"default_image"]];
    
    switch (model.courseDifficulty) {
        case 1:{
            _courseDifficultyLabel.text = @"初级";
        }
            break;
        case 2:{
            _courseDifficultyLabel.text = @"中级";
        }
            break;
        case 3:{_courseDifficultyLabel.text = @"高级";
        }
            break;
        default:
            break;
    }
    _courseBodyLabel.text = [NSString stringWithFormat:@"%@", model.courseBody];
    _finishedDaysLabel.text = [NSString stringWithFormat:@"已完成%@/%@天，已有%@人参加", model.couserDayEnNum, @(model.courseDays), @(model.courseMember)];
    _finishedDaysBarWidthConstraint.constant = (SCREEN_WIDTH - 28)/model.courseDays * [model.couserDayEnNum integerValue];
    
    if ([model.couserDayEnNum integerValue] == model.courseDays) {
        _isTrainingLabel.text = @"训练已完成";
    } else {
        _isTrainingLabel.text = [NSString stringWithFormat:@"接下来训练第%@天", @([model.couserDayEnNum integerValue] + 1)];
    }
    
    NSInteger actionTime = model.total_time / 60 + 1;
    _trainingTimeLabel.text = [NSString stringWithFormat:@"约%@分钟", @(actionTime)];
    _actionNumberLabel.text = [NSString stringWithFormat:@"%@个动作", @(model.total_activity)];
    _energyLabel.text = [NSString stringWithFormat:@"%@千卡", @(model.total_calories)];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
