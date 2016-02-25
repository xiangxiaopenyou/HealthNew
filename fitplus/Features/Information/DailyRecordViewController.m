//
//  DailyRecordViewController.m
//  fitplus
//
//  Created by xlp on 15/12/4.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "DailyRecordViewController.h"
#import "CommonsDefines.h"
#import <MBProgressHUD.h>
#import "RBBlockAlertView.h"
#import "Util.h"
#import <JTCalendar.h>
#import "Util.h"
#define BaseUrl @"http://wx.jianshen.so/index.php?s=/addon/BasicBusiness/Tools/dailyRecord"

@interface DailyRecordViewController ()<UIWebViewDelegate, JTCalendarDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) JTCalendarMenuView *calendarMenuView;
@property (nonatomic, strong) JTHorizontalCalendarView *calendarContentView;
@property (nonatomic, strong) JTCalendarManager *calendarManager;
@property (nonatomic, strong) UILabel *naviagtionLabel;
@property (nonatomic, strong) UIImageView *navigationImage;
@property (nonatomic, strong) UIButton *navigationButton;

@property (nonatomic, strong) NSDate *dateSelected;


@end

@implementation DailyRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _dateSelected = [NSDate date];
    [self createNavigationTitleView];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    [self.view addSubview:_webView];
    _webView.allowsInlineMediaPlayback = YES;
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self loadRequest];
    [self createCalendarView];
}
- (void)createNavigationTitleView {
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    _naviagtionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    _naviagtionLabel.font = [UIFont boldSystemFontOfSize:18];
    _naviagtionLabel.textColor = [UIColor whiteColor];
    _naviagtionLabel.textAlignment = NSTextAlignmentCenter;
    [navigationView addSubview:_naviagtionLabel];
    [self setNavigationTitle];
    
    _navigationImage = [[UIImageView alloc] initWithFrame:CGRectMake(140, 2, 40, 40)];
    _navigationImage.image = [UIImage imageNamed:@"daily_record_open"];
    [navigationView addSubview:_navigationImage];
    
    _navigationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _navigationButton.frame = CGRectMake(25, 2, 150, 40);
    _navigationButton.selected = NO;
    [_navigationButton addTarget:self action:@selector(navigationButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [navigationView addSubview:_navigationButton];
    
    self.navigationItem.titleView = navigationView;
}
- (void)createCalendarView {
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.clipsToBounds = YES;
    _calendarMenuView = [[JTCalendarMenuView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    [_contentView addSubview:_calendarMenuView];
    
    _calendarContentView = [[JTHorizontalCalendarView alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, SCREEN_HEIGHT / 2)];
    [_contentView addSubview:_calendarContentView];
    
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setDate:[NSDate date]];
    
    [self.view addSubview:_contentView];
    
}
- (void)setNavigationTitle {
    NSString *navigationString;
    if ([[Util compareDate:_dateSelected] isEqualToString:@"今天"]) {
        NSString *dateString = [Util getDateString:_dateSelected];
        navigationString = [NSString stringWithFormat:@"%@ 今天", [dateString substringWithRange:NSMakeRange(5, 5)]];
    } else {
        NSString *dateString = [Util getDateString:_dateSelected];
        navigationString = [NSString stringWithFormat:@"%@", [dateString substringWithRange:NSMakeRange(5, 5)]];
    }
    _naviagtionLabel.text = navigationString;
}
- (void)loadRequest {
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSString *timeString = [Util getDateString:_dateSelected];
    NSString *urlString = [NSString stringWithFormat:@"%@&userId=%@&time=%@", BaseUrl, userid, [timeString substringWithRange:NSMakeRange(0, 10)]];
    [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *requst = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [_webView loadRequest:requst];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
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

#pragma mark - CalendarManager Delegate
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView {
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = kRGBColor(82, 172, 184, 1.0);
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.textLabel.textColor = [UIColor blackColor];
    }
}
- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _dateSelected = dayView.date;
    [self setNavigationTitle];
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
    [self navigationButtonClick];
    [self loadRequest];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)navigationButtonClick {
    CGFloat rotation = 0;
    if (_navigationButton.selected) {
        rotation = 0;
        _navigationButton.selected = NO;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
        } completion:nil];
    } else {
        rotation = M_PI;
        _navigationButton.selected = YES;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _contentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT / 2 + 50);
        } completion:nil];
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(rotation);
        _navigationImage.transform = transform;
    } completion:nil];
}

@end
