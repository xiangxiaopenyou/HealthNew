//
//  DrysalterDetailViewController.m
//  fitplus
//
//  Created by 陈 on 15/8/6.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "DrysalterDetailViewController.h"
#import <MBProgressHUD.h>
#import "RBNoticeHelper.h"
#import <ShareSDK/ShareSDK.h>
#import "DrysalteryCommentViewController.h"
#import "DrysalteryModel.h"
#import "RBColorTool.h"
#import "Util.h"
#import <UIImageView+AFNetworking.h>
#import "WXApi.h"

@interface DrysalterDetailViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *trainingButton;
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (strong, nonatomic) UIImage *shadowImage;
@property (strong, nonatomic) UIButton *collectButton;
@property (assign, nonatomic) BOOL isCollected;
@property (strong, nonatomic) NSMutableArray *videoArray;
@property (copy, nonatomic) NSString *favoriteId;
//@property (strong, nonatomic) UIView *tipView;

@end

@implementation DrysalterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _shadowImage = self.navigationController.navigationBar.shadowImage;
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(0, 0, 44, 44);
    [shareButton setImage:[UIImage imageNamed:@"foundDetails_button_share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item_share = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commentButton.frame = CGRectMake(0, 0, 44, 44);
    [commentButton setImage:[UIImage imageNamed:@"foundDetails_button_comment"] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(messageClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item_comment = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    _collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _collectButton.frame = CGRectMake(0, 0, 44, 44);
    [_collectButton addTarget:self action:@selector(addCollectionClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item_collect = [[UIBarButtonItem alloc] initWithCustomView:_collectButton];
    
    NSArray *array;
    if ([WXApi isWXAppInstalled]) {
        array = [[NSArray alloc] initWithObjects:item_share, item_comment, item_collect, nil];
    } else {
        array = [[NSArray alloc] initWithObjects:item_share, item_collect, nil];
    }
    
    self.navigationItem.rightBarButtonItems = array;

    
    [self.view sendSubviewToBack:_detailWebView];
    _detailWebView.scalesPageToFit = YES;
    _detailWebView.allowsInlineMediaPlayback = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSString *urlString = [NSString stringWithFormat:@"%@&userId=%@&id=%@", DryShareUrl, userid, _drysalteryId];
    
    [_detailWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    [self fetchDetail];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"drysaltery_detail_header"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[RBColorTool imageWithColor:[UIColor colorWithRed:0.234 green:0.180 blue:0.292 alpha:1.000]]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.shadowImage = _shadowImage;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)fetchDetail {
    [DrysalteryModel drysalteryDetailWith:_drysalteryId handler:^(NSDictionary *object, NSString *msg) {
        if (!msg) {
            _favoriteId = [NSString stringWithFormat:@"%@", object[@"articleFavoriteId"]];
            if ([Util isEmpty:_favoriteId]) {
                [_collectButton setImage:[UIImage imageNamed:@"foundDetails_button_fav"] forState:UIControlStateNormal];
                _isCollected = NO;
                
            } else {
                [_collectButton setImage:[UIImage imageNamed:@"foundDetails_btn_fav_selected"] forState:UIControlStateNormal];
                _isCollected = YES;
            }
        }
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [RBNoticeHelper showNoticeAtViewController:self msg:error.description];
    if ([error code] == NSURLErrorCancelled) {
        return;
    }
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)shareButton:(id)sender {
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSString *shareUrl = [NSString stringWithFormat:@"%@&userId=%@&id=%@", DryShareUrl, userid, _drysalteryId];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -SCREEN_HEIGHT, 100, 100)];
    [imageView setImageWithURL:[NSURL URLWithString:[Util urlWeixinPhoto:_model.headimage]] placeholderImage:[UIImage imageNamed:@"share_default"]];
    id<ISSContent> publishContent = [ShareSDK content:@"健身坊,口袋运动健身学院" defaultContent:@"一起健身吧" image:[ShareSDK pngImageWithImage:imageView.image] title:_titleStr url:shareUrl description:@"" mediaType:SSPublishContentMediaTypeNews];
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    //    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    NSArray *shareList = [ShareSDK getShareListWithType: /*ShareTypeSinaWeibo, ShareTypeQQSpace, ShareTypeQQ,*/ ShareTypeWeixiSession, ShareTypeWeixiTimeline,nil];
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess) {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
                                } else if (state == SSResponseStateFail) {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                }
                            }];
}
- (void)collectDrysaltery {
    [DrysalteryModel collectDrysalteryWith:_drysalteryId handler:^(id object, NSString *msg) {
        if (!msg) {
            NSLog(@"收藏成功");
        }
    }];
}
- (void)cancelCollentDrysaltery {
    [DrysalteryModel cancelCollectDrysalteryWith:_drysalteryId handler:^(id object, NSString *msg) {
        if (!msg) {
            NSLog(@"取消收藏成功");
        }
    }];
}
- (IBAction)messageClick:(UIButton *)sender {
    DrysalteryCommentViewController *commentViewController = [[UIStoryboard storyboardWithName:@"Drysaltery" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentView"];
    commentViewController.title = _titleStr;
    commentViewController.articleId = _drysalteryId;
    [self.navigationController pushViewController:commentViewController animated:YES];
}
- (IBAction)addCollectionClick:(UIButton *)sender {
    if (_isCollected) {
        [self cancelCollentDrysaltery];
        _isCollected = NO;
        [_collectButton setImage:[UIImage imageNamed:@"foundDetails_button_fav"] forState:UIControlStateNormal];
    } else {
        [self collectDrysaltery];
        _isCollected = YES;
        [_collectButton setImage:[UIImage imageNamed:@"foundDetails_btn_fav_selected"] forState:UIControlStateNormal];
    }
}
- (IBAction)downloadClick:(UIButton *)sender {
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPlayerView"]) {
//        TrainingViewController *playerViewController = segue.destinationViewController;
//        playerViewController.videoArray = [_videoArray mutableCopy];
        
    }
}

@end
