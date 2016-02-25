//
//  PhotoBrowserViewController.m
//  fitplus
//
//  Created by xlp on 15/12/22.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "PhotoPreviewView.h"
#import "CommonsDefines.h"
#import "RBBlockAlertView.h"

@interface PhotoBrowserViewController ()
@property (nonatomic, strong) UIScrollView *photoScrollView;
@property (nonatomic, strong) UILabel *navigationLabel;
@end

@implementation PhotoBrowserViewController

- (void)loadView {
    self.view = [UIView new];
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    _navigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    _navigationLabel.textColor = [UIColor whiteColor];
    _navigationLabel.textAlignment = NSTextAlignmentCenter;
    _navigationLabel.font = [UIFont boldSystemFontOfSize:18];
    self.navigationItem.titleView = _navigationLabel;
    
    _photoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(- 10, 0, SCREEN_WIDTH + 20, SCREEN_HEIGHT)];
    _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _photoScrollView.pagingEnabled = YES;
    _photoScrollView.delegate = self;
    _photoScrollView.showsHorizontalScrollIndicator = NO;
    _photoScrollView.showsVerticalScrollIndicator = NO;
    _photoScrollView.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:_photoScrollView];
    
    [self createScrollView];
}
- (void)setNaviLabel {
    if (_photos.count == 0) {
        _navigationLabel.text = [NSString stringWithFormat:@"%@/%@", @(_currentIndex), @(_photos.count)];
    } else {
        _navigationLabel.text = [NSString stringWithFormat:@"%@/%@", @(_currentIndex + 1), @(_photos.count)];
    }
}
- (void)createScrollView {
    [self setNaviLabel];
    
    _photoScrollView.contentSize = CGSizeMake((SCREEN_WIDTH + 20) * _photos.count, 0);
    _photoScrollView.contentOffset = CGPointMake(_currentIndex * (SCREEN_WIDTH + 20), 0);
    
    for (NSInteger i = 0; i < _photos.count; i ++) {
        PhotoPreviewView *photoView = [[PhotoPreviewView alloc] init];
        CGRect bounds = _photoScrollView.bounds;
        CGRect photoViewFrame = bounds;
        photoViewFrame.size.width -= 20;
        photoViewFrame.origin.x = CGRectGetWidth(bounds) * i + 10;
        photoView.tag = i;
        photoView.frame = photoViewFrame;
        photoView.photo = _photos[i];
        [photoView showPicture];
        [_photoScrollView addSubview:photoView];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _currentIndex = floor(scrollView.contentOffset.x / (SCREEN_WIDTH + 20));
    [self setNaviLabel];
}
- (void)deleteClick {
    [[[RBBlockAlertView alloc] initWithTitle:@"提示" message:@"确定删除这张照片吗？" block:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [_photos removeObjectAtIndex:_currentIndex];
            [_keys removeObjectAtIndex:_currentIndex];
            if (_deletePic) {
                _deletePic(_photos, _keys);
            }
            if (_photos.count <= 0) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self createScrollView];
            }
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
}
- (void)pictureDelete:(DeletePicture)dele {
    _deletePic = dele;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
