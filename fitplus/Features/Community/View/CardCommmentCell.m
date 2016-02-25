//
//  CardCommmentCell.m
//  fitplus
//
//  Created by xlp on 15/12/18.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "CardCommmentCell.h"
#import <UIImageView+AFNetworking.h>
#import "Util.h"

@implementation CardCommmentCell

- (void)setupCommentContent:(PostComment *)model {
    _commentModel = model;
    if (_headImage.layer.cornerRadius < 19) {
        _headImage.layer.masksToBounds = YES;
        _headImage.layer.cornerRadius = 19;
    }
    [_headImage setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:model.commentPortrait]] placeholderImage:[UIImage imageNamed:@"default_headportrait"]];
    _headImage.userInteractionEnabled = YES;
    [_headImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headGestureRdcognizer)]];
    _nicknameLabel.text = [NSString stringWithFormat:@"%@", model.commentNickname];
    NSString *currentDateStr = [Util getIntervalDateString:model.createTime];
    NSDate *createdDate  = [Util getTimeDate:currentDateStr];
    if ([[Util compareDate:createdDate] isEqualToString:@"今天"]) {
        currentDateStr = [currentDateStr substringWithRange:NSMakeRange(11, 5)];
    } else if ([[Util compareDate:createdDate] isEqualToString:@"昨天"]) {
        currentDateStr = [NSString stringWithFormat:@"昨天%@", [currentDateStr substringWithRange:NSMakeRange(11, 5)]];
    } else {
        currentDateStr = [currentDateStr substringWithRange:NSMakeRange(5, 11)];
    }
    _timeLabel.text = [NSString stringWithFormat:@"%@", currentDateStr];
    
    _commentContentLabel.text = [NSString stringWithFormat:@"%@", model.commentContent];
    if ((NSInteger)model.isOwn == 1) {
        _hostLabel.hidden = NO;
    } else {
        _hostLabel.hidden = YES;
    }
}
- (CGFloat)heightOfCommentCell:(PostComment *)model {
    CGFloat height = 111;
    CGSize contentSize = [model.commentContent boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 28, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil].size;
    height += contentSize.height;
    return height;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)buttonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == 98) {
        if (_click) {
            _click(1, _commentModel.id, _commentModel.id, _commentModel.commentId);
        }
    } else {
        if (_click) {
            _click(2, _commentModel.id, _commentModel.id, _commentModel.commentId);
        }
    }
}
- (void)click:(ClickButton)button {
    _click = button;
}
- (void)headClick:(ClickHead)head {
    _clickHead = head;
}
- (void)headGestureRdcognizer {
    if (_clickHead) {
        _clickHead(_commentModel.commentId);
    }
}

@end
