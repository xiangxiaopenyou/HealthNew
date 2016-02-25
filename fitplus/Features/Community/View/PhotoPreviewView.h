//
//  PhotoPreviewView.h
//  fitplus
//
//  Created by xlp on 15/12/22.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPreviewView : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) UIImageView *imageView;

- (void)showPicture;
@end
