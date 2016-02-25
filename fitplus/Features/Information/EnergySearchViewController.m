//
//  EnergySearchViewController.m
//  fitplus
//
//  Created by xlp on 15/12/3.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "EnergySearchViewController.h"
#import "CommonsDefines.h"
#import <MBProgressHUD.h>
#import "RBBlockAlertView.h"
#define DefaultURL @"http://wx.jianshen.so/index.php?s=/addon/BasicBusiness/Tools/searchHeat"


@interface EnergySearchViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, assign) NSInteger selectedSegment;

@end

@implementation EnergySearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _selectedSegment = 1;
    _segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"饮食", @"运动", nil]];
    _segment.frame = CGRectMake(SCREEN_WIDTH / 2 - 60, 8, 120, 30);
    _segment.layer.masksToBounds = YES;
    _segment.layer.cornerRadius = 15.0;
    _segment.layer.borderWidth = 1.0;
    _segment.layer.borderColor = [UIColor whiteColor].CGColor;
    [_segment addTarget:self action:@selector(controlPressed:) forControlEvents:UIControlEventValueChanged];
    _segment.selectedSegmentIndex = 0;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar addSubview:_segment];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    [self.view addSubview:_webView];
    _webView.allowsInlineMediaPlayback = YES;
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self loadRequest];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_segment removeFromSuperview];
}
- (void)loadRequest {
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSString *urlString = [NSString stringWithFormat:@"%@&userId=%@&type=%@", DefaultURL, userid, @(_selectedSegment)];
    [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *requst = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [_webView loadRequest:requst];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UIWebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[RBBlockAlertView alloc] initWithTitle:@"提示" message:@"加载失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
}



- (void)controlPressed:(id)sender {
    if (_segment.selectedSegmentIndex == 0) {
        _selectedSegment = 1;
        [self loadRequest];
    } else {
        _selectedSegment = 2;
        [self loadRequest];
    }
}

@end
