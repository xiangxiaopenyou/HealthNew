//
//  CardCell.h
//  fitplus
//
//  Created by xlp on 15/12/10.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardModel.h"
#import <TYAttributedLabel.h>

typedef void (^ClickHeadPortrait)(NSString *userId);
typedef void (^ClickCardImageViewShow)(NSArray *picArray);
typedef void (^ClickCommunity)(NSString *communityId);

@interface CardCell : UITableViewCell<TYAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardContentLabel;
@property (weak, nonatomic) IBOutlet UIView *viewOfCardImage;
@property (weak, nonatomic) IBOutlet UILabel *likeNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentNumberLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewOfImageRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewOfImageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeftConstraint;
@property (weak, nonatomic) IBOutlet UIButton *communityButton;
@property (nonatomic, strong) UIView *viewOfTag;
@property (nonatomic, copy) ClickHeadPortrait clickClock;
@property (nonatomic, copy) ClickCommunity clickCommunity;
@property (nonatomic, copy) ClickCardImageViewShow cardImageView;
@property (nonatomic, strong) CardModel *cardModel;
@property (nonatomic, assign) CGFloat height;

- (void)setupCardContent:(CardModel *)model;
- (CGFloat)heightOfCell:(CardModel *)model;
- (void)headClick:(ClickHeadPortrait)click;
- (void)communityClick:(ClickCommunity)click;

@end
