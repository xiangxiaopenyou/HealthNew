//
//  PhotoPreviewView.m
//  fitplus
//
//  Created by xlp on 15/12/22.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "PhotoPreviewView.h"
#import "CommonsDefines.h"

@implementation PhotoPreviewView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //图片
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        //监听事件
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
    }
    return self;
}
- (void)adjustFrame {
    if (!_imageView.image) {
        return;
    }
    CGSize imageSize = _imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    //设置伸缩比例
    CGFloat minScale = SCREEN_WIDTH / imageWidth;
    if (minScale > 1) {
        minScale = 1.0;
    }
    CGFloat maxScale = 3.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
    }
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, 0, SCREEN_WIDTH, imageHeight * SCREEN_WIDTH / imageWidth);
    
    self.contentSize = CGSizeMake(0, CGRectGetHeight(imageFrame));
    
    //y值
    if (CGRectGetHeight(imageFrame) < SCREEN_HEIGHT) {
        imageFrame.origin.y = floorf(SCREEN_HEIGHT - CGRectGetHeight(imageFrame)) / 2.0;
    } else {
        imageFrame.origin.y = 0;
    }
    _imageView.frame = imageFrame;

}
- (void)showPicture {
    _imageView.image = _photo;
    [self adjustFrame];
}
#pragma mark - handleTap
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
}

#pragma mark - UIScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect imageViewFrame = _imageView.frame;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (CGRectGetHeight(imageViewFrame) > CGRectGetHeight(screenBounds)) {
        imageViewFrame.origin.y = 0;
    } else {
        imageViewFrame.origin.y = (CGRectGetHeight(screenBounds) - CGRectGetHeight(imageViewFrame)) / 2.0;
    }
    _imageView.frame = imageViewFrame;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
