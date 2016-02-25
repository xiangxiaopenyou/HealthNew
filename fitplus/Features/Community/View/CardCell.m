//
//  CardCell.m
//  fitplus
//
//  Created by xlp on 15/12/10.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "CardCell.h"
#import <UIImageView+AFNetworking.h>
#import "Util.h"
//#import "CommonsDefines.h"

@implementation CardCell

- (void)setupCardContent:(CardModel *)model {
    _cardModel = model;
    _headImageView.userInteractionEnabled = YES;
    if (_headImageView.layer.cornerRadius != 19) {
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = 19.0;
    }
    [_headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageGestureRecognizer)]];
    [_headImageView setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:model.portrait]] placeholderImage:[UIImage imageNamed:@"default_headportrait"]];
    _nicknameLabel.text = [NSString stringWithFormat:@"%@", model.nickname];
    NSString *currentDateStr = [self getTime:model.createTime];
    NSDate *createdDate  = [Util getTimeDate:currentDateStr];
    if ([[Util compareDate:createdDate] isEqualToString:@"今天"]) {
        currentDateStr = [currentDateStr substringWithRange:NSMakeRange(11, 5)];
    } else if ([[Util compareDate:createdDate] isEqualToString:@"昨天"]) {
        currentDateStr = [NSString stringWithFormat:@"昨天%@", [currentDateStr substringWithRange:NSMakeRange(11, 5)]];
    } else {
        currentDateStr = [currentDateStr substringWithRange:NSMakeRange(5, 11)];
    }
    _timeLabel.text = [NSString stringWithFormat:@"%@", currentDateStr];
    
    _cardTitleLabel.text = [NSString stringWithFormat:@"%@", model.title];
    _cardTitleLabel.numberOfLines=0;
    _cardContentLabel.text = [NSString stringWithFormat:@"%@", model.content];
    
    NSString *communityString = [NSString stringWithFormat:@"%@", model.name];
    [_communityButton setTitle:communityString forState:UIControlStateNormal];
    
    _likeNumberLabel.text = [NSString stringWithFormat:@"点赞 %@", @(model.favorite)];
    _commentNumberLabel.text = [NSString stringWithFormat:@"评论 %@", @(model.comment)];
    
    [_viewOfTag removeFromSuperview];
    if (![Util isEmpty:model.tagId]) {
        _viewOfTag = [[UIView alloc] initWithFrame:CGRectMake(14, 58, 200, 17)];
        _viewOfTag.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_viewOfTag];
        NSArray *tagArray = [[model.tagId componentsSeparatedByString:@","] copy];
        if ([tagArray[0] integerValue] == 0) {
            _titleLabelLeftConstraint.constant = 14 + 20 * (tagArray.count - 1) + 36;
        } else {
            _titleLabelLeftConstraint.constant = 14 + 20 * tagArray.count;
        }
        for (NSInteger i = 0; i < tagArray.count; i ++) {
            UIImageView *tagImage = [[UIImageView alloc] init];
            if ([tagArray[0] integerValue] == 0) {
                if (i == 0) {
                    tagImage.frame = CGRectMake(0, 0, 33, 17);
                } else {
                    tagImage.frame = CGRectMake(36 + 20 * (i - 1), 0, 17, 17);
                }
            } else {
                tagImage.frame = CGRectMake(20 * i, 0, 17, 17);
            }
            tagImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"circle_card_tag%@", @([tagArray[i] integerValue])]];
            [_viewOfTag addSubview:tagImage];
        }
    } else {
        _titleLabelLeftConstraint.constant = 14;
    }    for (NSInteger i = _viewOfCardImage.subviews.count - 1; i >= 0; i --) {
        [_viewOfCardImage.subviews[i] removeFromSuperview];
    }
    if (![Util isEmpty:model.pic]) {
        NSArray *tagImageArray = [[model.pic componentsSeparatedByString:@","] copy];
        if (tagImageArray.count > 4) {
            tagImageArray = [tagImageArray subarrayWithRange:NSMakeRange(0, 4)];
        }
        _viewOfImageRightConstraint.constant = 14;
        _viewOfImageTopConstraint.constant = 10;
        for (NSInteger i = 0; i < tagImageArray.count; i ++) {
            UIImageView *cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * (SCREEN_WIDTH / 4 - 5.5), 0, SCREEN_WIDTH / 4 - 11.5, SCREEN_WIDTH / 4 - 11.5)];
            cardImageView.clipsToBounds = YES;
            cardImageView.contentMode = UIViewContentModeScaleAspectFill;
            //cardImageView.userInteractionEnabled = YES;
            [cardImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardImageVIewGestureRecognizer)]];
            [cardImageView setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:tagImageArray[i]]] placeholderImage:[UIImage imageNamed:@"default_image"]];
            [_viewOfCardImage addSubview:cardImageView];
        }
    } else {
        _viewOfImageRightConstraint.constant = SCREEN_WIDTH - 14;
        _viewOfImageTopConstraint.constant = 0;
    }
}
- (CGFloat)heightOfCell:(CardModel *)model {
    _height = 131;
    CGSize contentSize = [model.content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 28, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13], NSFontAttributeName, nil] context:nil].size;
    if (contentSize.height > 36) {
        _height += 32;
    } else {
        _height += contentSize.height;
    }
    if (![Util isEmpty:model.pic]) {
        _height += (SCREEN_WIDTH - 46) / 4 + 10;
    }
    return _height;
}
- (void)headImageGestureRecognizer {
    if (_clickClock) {
        _clickClock(_cardModel.userId);
    }
}
- (void)headClick:(ClickHeadPortrait)click {
    _clickClock = click;
}
-(void)cardImageVIewGestureRecognizer
{
     NSArray *picArray = [[_cardModel.pic componentsSeparatedByString:@","] copy];
    if (_cardImageView) {
        _cardImageView(picArray);
    }
}
- (void)cardImageViewClick:(ClickCardImageViewShow)click
{
    _cardImageView =click;
}
- (NSString *)getTime:(NSString *)timeString {
    NSTimeInterval time = [timeString doubleValue];
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate: detaildate];
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)communityButtonClick:(id)sender {
    if (_clickCommunity) {
        _clickCommunity(_cardModel.plateId);
    }
}
- (void)communityClick:(ClickCommunity)click {
    _clickCommunity = click;
}

@end
