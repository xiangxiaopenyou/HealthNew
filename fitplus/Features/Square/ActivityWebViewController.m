//
//  ActivityWebViewController.m
//  fitplus
//
//  Created by xlp on 15/7/9.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "ActivityWebViewController.h"
#import <MBProgressHUD.h>
#import "RBNoticeHelper.h"
#import "MoreCourseViewController.h"
@interface ActivityWebViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *activityWebView;

@end

@implementation ActivityWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _activityWebView.scalesPageToFit = YES;
    _activityWebView.allowsInlineMediaPlayback = YES;
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    [_activityWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"requestStr=%@",request);
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components=[requestString componentsSeparatedByString:@"?"];
    
    NSLog(@"com=%@",components);
    
    if ([components count]>1 && [(NSString*)[components objectAtIndex:1] rangeOfString:@"all"].location != NSNotFound) {
        MoreCourseViewController *moreCourseViewController = [[UIStoryboard storyboardWithName:@"Drysaltery" bundle:nil] instantiateViewControllerWithIdentifier:@"MoreCourseView"];
        [self.navigationController pushViewController:moreCourseViewController animated:YES];

        
        return NO;
        
    }else
    {
        NSLog(@"llll");
        return YES;
    }
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"start");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [RBNoticeHelper showNoticeAtViewController:self msg:@"加载失败"];
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
