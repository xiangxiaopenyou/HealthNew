//
//  BodyResultViewController.m
//  fitplus
//
//  Created by xlp on 15/11/23.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "BodyResultViewController.h"
#import <MBProgressHUD.h>
#import "RBNoticeHelper.h"
#import "UserInfoModel.h"

@interface BodyResultViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BodyResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _webView.scalesPageToFit = YES;
    _webView.allowsInlineMediaPlayback = YES;
    [self fetchBodyResult];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)fetchBodyResult {
    NSString *userSex = [[NSUserDefaults standardUserDefaults] stringForKey:UserSex];
    NSString *userHeight = [[NSUserDefaults standardUserDefaults] stringForKey:UserHeight];
    NSString *userWeight = [[NSUserDefaults standardUserDefaults] stringForKey:UserWeight];
    NSString *userAge = [[NSUserDefaults standardUserDefaults] stringForKey:UserAge];
    NSString *userBody = [[NSUserDefaults standardUserDefaults] stringForKey:UserBody];
    NSString *userTrainingTime = [[NSUserDefaults standardUserDefaults] stringForKey:UserTrainingTime];
    NSString *userTag = [[NSUserDefaults standardUserDefaults] stringForKey:UserTag];
    NSMutableDictionary *tempParam = [@{@"sex" : userSex,
                                        @"height" : userHeight,
                                        @"weight" : userWeight,
                                        @"age" : userAge,
                                        @"body" : userBody,
                                        @"sporttime" : userTrainingTime,
                                        @"tag" : userTag} mutableCopy];
    [UserInfoModel fetchBodyResultWith:tempParam handler:^(NSDictionary *object, NSString *msg) {
        if (!msg) {
            _dictionary = [object copy];
            NSString *urlString = [object[@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            [_webView loadRequest:urlRequest];
            
        }
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -UIWebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [RBNoticeHelper showNoticeAtView:self.view y:0 msg:@"加载失败"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)reTestClick:(id)sender {
    if (_isInformationViewIn) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIViewController *guideVC = [[UIStoryboard storyboardWithName:@"Guide" bundle:nil] instantiateViewControllerWithIdentifier:@"FifthGuideView"];
        [self.navigationController pushViewController:guideVC animated:YES];
    }
}
- (IBAction)importTrainingClick:(id)sender {
    if ([_dictionary objectForKey:@"url"]) {
        [UserInfoModel addRecommendedCourseWith:_dictionary[@"subjectIds"] handler:^(id object, NSString *msg) {
            if (!msg) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}

@end
