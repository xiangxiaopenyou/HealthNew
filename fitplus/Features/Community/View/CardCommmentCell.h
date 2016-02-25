//
//  CardCommmentCell.h
//  fitplus
//
//  Created by xlp on 15/12/18.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostComment.h"
typedef void (^ClickButton)(NSInteger index, NSString *commendId, NSString *replyId, NSString *commentId);
typedef void (^ClickHead)(NSString *userId);

@interface CardCommmentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *floorLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentContentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *hostLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineLeftConstraint;
@property (nonatomic, strong) PostComment *commentModel;
@property (nonatomic, copy) ClickButton click;
@property (nonatomic, copy) ClickHead clickHead;

- (void)setupCommentContent:(PostComment *)model;
- (CGFloat)heightOfCommentCell:(PostComment *)model;
- (void)click:(ClickButton)button;
- (void)headClick:(ClickHead)head;

@end
