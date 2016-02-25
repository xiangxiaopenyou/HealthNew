//
//  UsersTrendsViewController.m
//  fitplus
//
//  Created by xlp on 15/12/2.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "UsersTrendsViewController.h"
#import "UserCourseTrendModel.h"
#import <MJRefresh.h>
#import "LimitResultModel.h"
#import "UserCourseTrendModel.h"
#import "MyCourseTrendCell.h"
#import "Util.h"
#import <MBProgressHUD.h>

@interface UsersTrendsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) NSInteger courseTrendsPage;
@property (nonatomic, strong) NSMutableArray *courseTrendsArray;
@property (nonatomic, assign) BOOL isRequest;

@end

@implementation UsersTrendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_friendId) {
        self.navigationItem.title = @"TA的训练";
    } else {
        self.navigationItem.title = @"我的训练";
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _courseTrendsPage = 1;
        if (_friendId) {
            [self fetchUserCourseTrends];
        } else {
            [self fetchMyCourseTrends];
        }
    }]];
    [_tableView setFooter:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (_friendId) {
            [self fetchUserCourseTrends];
        } else {
            [self fetchMyCourseTrends];
        }
    }]];
    _tableView.footer.hidden = YES;
    
    _courseTrendsPage = 1;
    if (_friendId) {
        [self fetchUserCourseTrends];
    } else {
        [self fetchMyCourseTrends];
    }
    
}

- (void)fetchMyCourseTrends {
    [UserCourseTrendModel fetchMyCourseTrends:_courseTrendsPage handler:^(id object, NSString *msg) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        _isRequest = YES;
        if (!msg) {
            LimitResultModel *limitTempModel = [LimitResultModel new];
            limitTempModel = object;
            if (_courseTrendsPage ==1) {
                _courseTrendsArray = [limitTempModel.result mutableCopy];
            } else {
                NSMutableArray *temArray = [NSMutableArray arrayWithArray:_courseTrendsArray];
                [temArray addObjectsFromArray:limitTempModel.result];
                _courseTrendsArray = temArray;
            }
            [_tableView reloadData];
            BOOL haveMore = limitTempModel.haveMore;
            if (haveMore) {
                _courseTrendsPage = limitTempModel.page;
                _tableView.footer.hidden = NO;
            } else {
                [_tableView.footer noticeNoMoreData];
                _tableView.footer.hidden = YES;
            }
        }
    }];
}
- (void)fetchUserCourseTrends {
    [UserCourseTrendModel fetchUserCourseTrends:_courseTrendsPage otherId:_friendId handler:^(id object, NSString *msg) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        _isRequest = YES;
        if (!msg) {
            LimitResultModel *limitTempModel = [LimitResultModel new];
            limitTempModel = object;
            if (_courseTrendsPage ==1) {
                _courseTrendsArray = [limitTempModel.result mutableCopy];
            } else {
                NSMutableArray *temArray = [NSMutableArray arrayWithArray:_courseTrendsArray];
                [temArray addObjectsFromArray:limitTempModel.result];
                _courseTrendsArray = temArray;
            }
            [_tableView reloadData];
            BOOL haveMore = limitTempModel.haveMore;
            if (haveMore) {
                _courseTrendsPage = limitTempModel.page;
                _tableView.footer.hidden = NO;
            } else {
                [_tableView.footer noticeNoMoreData];
                _tableView.footer.hidden = YES;
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _courseTrendsArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MyCourseTrendCell";
    MyCourseTrendCell *cell = (MyCourseTrendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
    }
    UserCourseTrendModel *tempModel = [UserCourseTrendModel new];
    tempModel = _courseTrendsArray[indexPath.row];
    cell.trendTitleLabel.text = [NSString stringWithFormat:@"已持续挑战%@", tempModel.courseName];
    cell.courseDayLabel.text = [NSString stringWithFormat:@"第%@天", @(tempModel.courseDay)];
    NSString *energyString = [NSString stringWithFormat:@"%@", @(tempModel.calorie)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@千卡", @(tempModel.calorie)]];
    [attributedString setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:20], NSFontAttributeName, nil] range:NSMakeRange(0, energyString.length)];
    cell.energyLabel.attributedText = attributedString;
    NSString *timeString = tempModel.createDate;
    NSTimeInterval time = [timeString doubleValue];
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [formatter stringFromDate: detaildate];
    //NSString *tempString = [Util getDateString:tempDate];
    NSDate *date = [Util getTimeDate:currentDateStr];
    if ([[Util compareDate:date] isEqualToString:@"今天"]) {
        currentDateStr = [currentDateStr substringWithRange:NSMakeRange(11, 5)];
    } else if ([[Util compareDate:date] isEqualToString:@"昨天"]) {
        currentDateStr = [NSString stringWithFormat:@"昨天%@", [currentDateStr substringWithRange:NSMakeRange(11, 5)]];
    } else {
        currentDateStr = [currentDateStr substringWithRange:NSMakeRange(5, 11)];
    }
    cell.trendTimeLabel.text = currentDateStr;
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (_courseTrendsArray.count == 0 && _isRequest) ? 160 : 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, 0, 160);
    headerView.backgroundColor = [UIColor clearColor];
    
    UIImageView *norecordImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 44, 30, 89, 70)];
    norecordImage.image = [UIImage imageNamed:@"mine_prompt_norecord"];
    [headerView addSubview:norecordImage];
    
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, SCREEN_WIDTH, 20)];
    emptyLabel.font = [UIFont systemFontOfSize:14];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor grayColor];
    [headerView addSubview:emptyLabel];
    UILabel *emptyLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, SCREEN_WIDTH, 20)];
    emptyLabel2.font = [UIFont systemFontOfSize:14];
    emptyLabel2.textAlignment = NSTextAlignmentCenter;
    emptyLabel2.textColor = kRGBColor(181, 181, 181, 1.0);
    [headerView addSubview:emptyLabel2];
    if (_friendId) {
        emptyLabel.text = @"TA还没有完成过课程哦~";
        emptyLabel2.text = nil;
    } else {
        emptyLabel.text = @"你还没有完成过课程哦~";
        emptyLabel2.text = @"去训练里面看看吧";
    }
    return headerView;
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
