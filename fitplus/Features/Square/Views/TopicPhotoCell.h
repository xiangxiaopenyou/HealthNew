//
//  TopicPhotoCell.h
//  fitplus
//
//  Created by xlp on 15/11/30.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ClickPhoto)(NSInteger index);

@interface TopicPhotoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *leftImage;
@property (weak, nonatomic) IBOutlet UIImageView *rightImage;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@property (nonatomic, copy) ClickPhoto clickPhoto;

- (void)setupContent:(NSDictionary *)leftDictionary right:(NSDictionary *)rightDictionary;
- (void)photoClick:(ClickPhoto)item;

@end
