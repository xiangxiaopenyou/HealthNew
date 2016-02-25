//
//  TopicPhotoCell.m
//  fitplus
//
//  Created by xlp on 15/11/30.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "TopicPhotoCell.h"
#import <UIImageView+AFNetworking.h>
#import "Util.h"

@implementation TopicPhotoCell

- (void)setupContent:(NSDictionary *)leftDictionary right:(NSDictionary *)rightDictionary {
    _leftImage.clipsToBounds = YES;
    _rightImage.clipsToBounds = YES;
    _leftImage.contentMode = UIViewContentModeScaleAspectFill;
    _rightImage.contentMode = UIViewContentModeScaleAspectFill;
    _leftImage.userInteractionEnabled = YES;
    _rightImage.userInteractionEnabled = YES;
    [_leftImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftImageRecognizer)]];
    [_rightImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightImageRecognizer)]];
    [_leftImage setImageWithURL:[NSURL URLWithString:[Util urlPhoto:leftDictionary[@"trendpicture"]]] placeholderImage:[UIImage imageNamed:@"default_image"]];
    _leftLabel.text = [NSString stringWithFormat:@"  %@", leftDictionary[@"trendcontent"]];
    if (rightDictionary) {
        _rightImage.hidden = NO;
        _rightLabel.hidden = NO;
        [_rightImage setImageWithURL:[NSURL URLWithString:[Util urlPhoto:rightDictionary[@"trendpicture"]]] placeholderImage:[UIImage imageNamed:@"default_image"]];
        _rightLabel.text = [NSString stringWithFormat:@"  %@", rightDictionary[@"trendcontent"]];
    } else {
        _rightImage.hidden = YES;
        _rightLabel.hidden = YES;
    }
}
- (void)leftImageRecognizer {
    if (_clickPhoto) {
        _clickPhoto(1);
    }
}
- (void)rightImageRecognizer {
    if (_clickPhoto) {
        _clickPhoto(2);
    }
}
- (void)photoClick:(ClickPhoto)item {
    _clickPhoto = item;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
