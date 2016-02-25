//
//  RecommendedTopicCell.m
//  fitplus
//
//  Created by xlp on 15/11/23.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "RecommendedTopicCell.h"
#import "CommonsDefines.h"
#import <UIImageView+AFNetworking.h>
#import "Util.h"

@implementation RecommendedTopicCell
- (void)setupContent:(TopicModel *)model {
    _topicTypeLabel.text = [NSString stringWithFormat:@"%@", model.hostName];
    _topicNameLabel.text = [NSString stringWithFormat:@"%@", model.title];
    _ruleLabel.text = [NSString stringWithFormat:@"%@", model.desc];
    NSArray *photoArray = [model.hostList copy];
    for (NSInteger i = 0; i < photoArray.count; i ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * ((SCREEN_WIDTH - 43) / 4 + 5), 0, (SCREEN_WIDTH - 43) / 4, (SCREEN_WIDTH - 43) / 4)];
        imageView.tag = i;
        [imageView setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:photoArray[i][@"trendpicture"]]] placeholderImage:[UIImage imageNamed:@"default_image"]];
        [_photoContainView addSubview:imageView];
    }
    _popularityNumberLabel.text = [NSString stringWithFormat:@"%@", @(model.tag_num)];
    _userNumberLabel.text = [NSString stringWithFormat:@"%@", @(model.attend_num)];
    _photosNumberLabel.text = [NSString stringWithFormat:@"%@", @(model.pic_num)];
    
}
- (CGFloat)heightOfCell:(TopicModel *)model {
    CGSize ruleSize = [model.desc boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 28, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13], NSFontAttributeName, nil] context:nil].size;
    if (ruleSize.height > 40) {
        return 94 + (SCREEN_WIDTH - 43) / 4 + 32;
    } else {
        return 94 + (SCREEN_WIDTH - 43) / 4 + ruleSize.height;
    }
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
