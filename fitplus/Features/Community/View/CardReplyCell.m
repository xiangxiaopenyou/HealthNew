//
//  CardReplyCell.m
//  fitplus
//
//  Created by xlp on 15/12/18.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "CardReplyCell.h"
#import "Util.h"
#import "CommonsDefines.h"
#import <UIImageView+AFNetworking.h>

@implementation CardReplyCell

- (void)setupContainer:(NSDictionary *)dic {
    _dictionary = [dic copy];
    if (_headImage.layer.cornerRadius < 10) {
        _headImage.layer.masksToBounds = YES;
        _headImage.layer.cornerRadius = 10;
    }
    [_headImage setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:dic[@"commentPortrait"]]] placeholderImage:[UIImage imageNamed:@"default_headportrait"]];
    TYTextContainer *textContainer = [self addContrainer:dic];
    textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    
    if (!_contentLabel) {
        _contentLabel = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(62, 10, SCREEN_WIDTH - 76, 0)];
    }
    [self.contentView addSubview:_contentLabel];
    _contentLabel.delegate = self;
    _contentLabel.textContainer = textContainer;
    [_contentLabel sizeToFit];
}
- (CGFloat)heightOfCell:(NSDictionary *)dic {
    TYTextContainer *container = [self addContrainer:dic];
    return 20 + container.textHeight;
    
}
- (TYTextContainer *)addContrainer:(NSDictionary *)dic {
    NSString *contentString = @"";
    NSString *currentDateStr = [Util getIntervalDateString:dic[@"createTime"]];
    NSDate *createdDate  = [Util getTimeDate:currentDateStr];
    if ([[Util compareDate:createdDate] isEqualToString:@"今天"]) {
        currentDateStr = [currentDateStr substringWithRange:NSMakeRange(11, 5)];
    } else if ([[Util compareDate:createdDate] isEqualToString:@"昨天"]) {
        currentDateStr = [NSString stringWithFormat:@"昨天%@", [currentDateStr substringWithRange:NSMakeRange(11, 5)]];
    } else {
        currentDateStr = [currentDateStr substringWithRange:NSMakeRange(5, 11)];
    }
    if ([dic[@"type"] integerValue] == 1) {
        if ([dic[@"isOwn"] integerValue] == 1) {
            contentString = [NSString stringWithFormat:@"%@[image]: %@  %@", dic[@"commentNickname"], dic[@"commentContent"], currentDateStr];
        } else {
            contentString = [NSString stringWithFormat:@"%@: %@  %@", dic[@"commentNickname"], dic[@"commentContent"], currentDateStr];
        }
    } else {
        if ([dic[@"isOwn"] integerValue] == 1) {
            contentString = [NSString stringWithFormat:@"%@[image]回复%@: %@  %@", dic[@"commentNickname"], dic[@"userNickname"], dic[@"commentContent"], currentDateStr];
        } else {
            contentString = [NSString stringWithFormat:@"%@回复%@: %@  %@", dic[@"commentNickname"], dic[@"userNickname"], dic[@"commentContent"], currentDateStr];
        }
    }
    TYTextContainer *textContainer = [[TYTextContainer alloc] init];
    textContainer.font = [UIFont systemFontOfSize:14];
    textContainer.text = contentString;
    [textContainer addLinkWithLinkData:nil linkColor:kRGBColor(87, 172, 184, 1.0) underLineStyle:kCTUnderlineStyleNone range:[contentString rangeOfString:dic[@"commentNickname"]]];
    TYTextStorage *textStorage = [[TYTextStorage alloc] init];
    textStorage.range = [contentString rangeOfString:currentDateStr];
    textStorage.font = [UIFont systemFontOfSize:11];
    textStorage.textColor = kRGBColor(184, 184, 184, 1.0);
    [textContainer addTextStorage:textStorage];
    
    TYImageStorage *imageStorage = [[TYImageStorage alloc] init];
    imageStorage.range = [contentString rangeOfString:@"[image]"];
    imageStorage.size = CGSizeMake(33, 17);
    imageStorage.image = [UIImage imageNamed:@"circle_post_host"];
    [textContainer addTextStorage:imageStorage];
    [textContainer createTextContainerWithTextWidth:SCREEN_WIDTH - 76];
    
    return textContainer;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - Delegate
- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)textStorage atPoint:(CGPoint)point {
    if ([textStorage isKindOfClass:[TYLinkTextStorage class]]) {
        if (_clickHead) {
            _clickHead(_dictionary[@"commentId"]);
        }
    }
}
- (void)headClick:(ClickHead)head {
    _clickHead = head;
}

@end
