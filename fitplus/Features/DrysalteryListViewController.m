//
//  DrysalteryListViewController.m
//  fitplus
//
//  Created by xlp on 15/8/6.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "DrysalteryListViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "CommonsDefines.h"
#import "DrysalteryCell.h"
#import "KDTabbarProtocol.h"
#import "DrysalteryModel.h"
#import "LimitResultModel.h"
#import "DrysalterDetailViewController.h"
#import <MBProgressHUD.h>
#import "CourseCell.h"
#import "CourseModel.h"
#import "MyCourseCell.h"
#import "MoreCourseViewController.h"
#import "CourseDetailViewController.h"
#import <MBProgressHUD.h>
#import "UserInfo.h"
#import "BodyResultViewController.h"
#import "MessageUnreadCommentModel.h"
#import "ClockInDetailViewController.h"
#import "PostModel.h"
#import "CardDetailViewController.h"
#import "CourseDetailModel.h"
#import "MobClick.h"

@interface DrysalteryListViewController ()<UITableViewDataSource, UITableViewDelegate, KDTabbarProtocol>
@property (weak, nonatomic) IBOutlet UITableView *courseTableView;
@property (assign, nonatomic) NSInteger limit;
@property (strong, nonatomic) NSMutableArray *drysalteryArray;
@property (weak, nonatomic) IBOutlet UILabel *todayEnergyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewForTableLeftConstraint;
@property (weak, nonatomic) IBOutlet UIView *myDataView;
@property (weak, nonatomic) IBOutlet UILabel *trainingDaysLabel;
@property (strong, nonatomic) UIView *guideTipView;
@property (strong, nonatomic) UIView *containView;
@property (weak, nonatomic) IBOutlet UILabel *allTrainingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longestDaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishedTimesLabel;
@property (weak, nonatomic) IBOutlet UIButton *planButton;
@property (nonatomic, strong) UIView *tipReportView;

@property (nonatomic, assign) BOOL isMyCourse;
@property (nonatomic, strong) NSMutableArray *courseArray;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) CardModel *cardModel;
@property (nonatomic, strong) CourseDetailModel *detailModel;

@end

@implementation DrysalteryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //NSLog(@"添加观察");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showGeTuiView:) name:@"ShowGeTui" object:nil];
    
    
    _limit = 0;
    if ([self checkIfLogin]) {
        
    } else {
        [self showLogin];
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [MobClick beginLogPageView:@"TrainingPage"];
    [MessageUnreadCommentModel unreadMessage:^(MessageUnreadCommentModel *object, NSString *msg) {
        NSInteger allNum = [object.allNum integerValue];
    
        if (allNum > 0) {
            
            if (allNum>99) {
                
                allNum=99;
            }
            
            [self receivedMessages:allNum];
        }else
        {
            _messageLabel.text=nil;
            _messageLabel.hidden=YES;
        }
    }];

    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"TrainingPage"];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    //[self fetchDryList];
    [self fetchMyData];
    [self fetchCourseList];
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:IsNewUserKey] integerValue] == 0) {
        [self setupGuideTipView];
        _planButton.selected = YES;
    } else {
        if ([[NSUserDefaults standardUserDefaults] integerForKey:IsFirstOpenTool] == 1) {
            [self setupTipView];
        }
    }
}
- (void)setupGuideTipView {
    _guideTipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _guideTipView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    
    //_containView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 130, SCREEN_HEIGHT / 2 - 152, 260, 304)];
    _containView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 130, SCREEN_HEIGHT, 260, 304)];
    _containView.backgroundColor = [UIColor whiteColor];
    _containView.layer.masksToBounds = YES;
    _containView.layer.cornerRadius = 4.0;
    [_guideTipView addSubview:_containView];
    
    UILabel *helloLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 260, 18)];
    helloLabel.font = [UIFont systemFontOfSize:15];
    helloLabel.textColor = [UIColor colorWithRed:31/255.0 green:31/255.0 blue:31/255.0 alpha:1.0];
    helloLabel.textAlignment = NSTextAlignmentCenter;
    NSString *nicknameString = [[NSUserDefaults standardUserDefaults] stringForKey:UserName];
    helloLabel.text = [NSString stringWithFormat:@"Hi,%@", nicknameString];
    [_containView addSubview:helloLabel];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 42, 260, 18)];
    label1.font = [UIFont systemFontOfSize:15];
    label1.textColor = [UIColor colorWithRed:31/255.0 green:31/255.0 blue:31/255.0 alpha:1.0];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"欢迎来到健身坊,";
    [_containView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 64, 220, 18)];
    label2.font = [UIFont systemFontOfSize:15];
    label2.textColor = [UIColor colorWithRed:31/255.0 green:31/255.0 blue:31/255.0 alpha:1.0];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"告诉我你的身体状况，让我来给";
    label2.numberOfLines = 0;
    label2.lineBreakMode = NSLineBreakByCharWrapping;
    [_containView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 86, 260, 18)];
    label3.font = [UIFont systemFontOfSize:15];
    label3.textColor = [UIColor colorWithRed:31/255.0 green:31/255.0 blue:31/255.0 alpha:1.0];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = @"你制定专属的训练方案吧！";
    label3.lineBreakMode = NSLineBreakByCharWrapping;
    [_containView addSubview:label3];
    
    UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake(85, 135, 90, 90)];
    headImage.layer.masksToBounds = YES;
    headImage.layer.cornerRadius = 45.0;
    NSInteger sexInt = [[NSUserDefaults standardUserDefaults] integerForKey:UserSex];
    if (sexInt == 1) {
        headImage.image = [UIImage imageNamed:@"bg_coachmale"];
    } else {
        headImage.image = [UIImage imageNamed:@"bg_coachfemale"];
    }
    [_containView addSubview:headImage];
    
    UIButton *cancelTipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelTipButton.frame = CGRectMake(14, 250, 110, 44);
    [cancelTipButton setTitle:@"我先看看" forState:UIControlStateNormal];
    [cancelTipButton setTitleColor:[UIColor colorWithRed:77/255.0 green:62/255.0 blue:93/255.0 alpha:1.0] forState:UIControlStateNormal];
    cancelTipButton.titleLabel.font = [UIFont systemFontOfSize:16];
    cancelTipButton.layer.masksToBounds = YES;
    cancelTipButton.layer.cornerRadius = 2.0;
    cancelTipButton.layer.borderWidth = 0.5;
    cancelTipButton.layer.borderColor = [UIColor colorWithRed:77/255.0 green:62/255.0 blue:93/255.0 alpha:1.0].CGColor;
    cancelTipButton.backgroundColor = [UIColor whiteColor];
    cancelTipButton.tag = 98;
    [cancelTipButton addTarget:self action:@selector(tipGuideButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_containView addSubview:cancelTipButton];
    
    UIButton *tellCoachButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tellCoachButton.frame = CGRectMake(136, 250, 110, 44);
    [tellCoachButton setTitle:@"告诉教练" forState:UIControlStateNormal];
    [tellCoachButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    tellCoachButton.titleLabel.font = [UIFont systemFontOfSize:16];
    tellCoachButton.layer.masksToBounds = YES;
    tellCoachButton.layer.cornerRadius = 2.0;
    tellCoachButton.backgroundColor = [UIColor colorWithRed:77/255.0 green:62/255.0 blue:93/255.0 alpha:1.0];
    tellCoachButton.tag = 99;
    [tellCoachButton addTarget:self action:@selector(tipGuideButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_containView addSubview:tellCoachButton];
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:_guideTipView];
    
    [UIView animateWithDuration:0.55 delay:0.5 usingSpringWithDamping:0.7 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _containView.frame = CGRectMake(SCREEN_WIDTH / 2 - 130, SCREEN_HEIGHT / 2 - 152, 260, 304);
    } completion:nil];
}
- (void)setupTipView {
    _tipReportView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tipReportView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:_tipReportView];
    UIButton *knowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    knowButton.frame = CGRectMake(SCREEN_WIDTH/2 - 52, 350, 104, 32);
    [knowButton setBackgroundImage:[UIImage imageNamed:@"guide_button"] forState:UIControlStateNormal];
    [knowButton addTarget:self action:@selector(knownButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_tipReportView addSubview:knowButton];
    
    UIImageView *tipImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 310, 75, 300, 235)];
    tipImage.image = [UIImage imageNamed:@"tip_plan"];
    [_tipReportView addSubview:tipImage];
}
- (void)fetchCourseList {
    [CourseModel fetchMyCourse:1 handler:^(id object, NSString *msg) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!msg){
            LimitResultModel *model = [LimitResultModel new];
            model = object;
            if ([model.result count] > 0) {
                _isMyCourse = YES;
                _myDataView.hidden = NO;
                _courseArray = [model.result mutableCopy];
                [_courseTableView reloadData];
                
            } else {
                _isMyCourse = NO;
                _myDataView.hidden = YES;
                [self fetchRecommendedCourse];
            }
        }
        
    }];
}
- (void)fetchRecommendedCourse {
    [CourseModel fetchRecommendedCourse:1 handler:^(id object, NSString *msg) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!msg) {
            LimitResultModel *model = [LimitResultModel new];
            model = object;
            _courseArray = [model.result mutableCopy];
            [_courseTableView reloadData];
        }
        
    }];
}
- (void)fetchMyData {
    [CourseModel fetchMyData:^(id object, NSString *msg) {
        if (!msg) {
            NSDictionary *dataDictionary = [object copy];
            NSInteger todayTime = [dataDictionary[@"Time"] integerValue];
            NSInteger allTime = [dataDictionary[@"allTime"] integerValue];
            if (allTime % 60 == 0) {
                allTime = allTime / 60;
            } else {
                allTime = allTime / 60 + 1;
            }
            NSString *allTimeString = [NSString stringWithFormat:@"%@", @(allTime)];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@分钟", allTimeString]];
            [attString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16], NSFontAttributeName, nil] range:NSMakeRange(0, allTimeString.length)];
            _allTrainingTimeLabel.attributedText = attString;
//            NSDictionary *levelDictionary = dataDictionary[@"level"];
//            NSInteger level2Time = [levelDictionary[@"V2"][@"exp"] integerValue] / 60;
//            NSInteger level3Time = [levelDictionary[@"V3"][@"exp"] integerValue] / 60;
            NSInteger trainingDays = [dataDictionary[@"trainNum"] integerValue];
            if (trainingDays == 0) {
                _trainingDaysLabel.text = @"今日训练";
            } else {
                _trainingDaysLabel.text = [NSString stringWithFormat:@"今日训练（连续第%@天）", @(trainingDays)];
            }
            if (todayTime == 0) {
                _todayEnergyLabel.text = @"0";
            } else {
                _todayEnergyLabel.text = [NSString stringWithFormat:@"%@", @(todayTime / 60 + 1)];
            }
            
            NSString *longestDaysString = [NSString stringWithFormat:@"%@", dataDictionary[@"trainNumLong"]];
            NSMutableAttributedString *longestAttString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@天", longestDaysString]];
            [longestAttString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16], NSFontAttributeName, nil] range:NSMakeRange(0, longestDaysString.length)];
            _longestDaysLabel.attributedText = longestAttString;
            
            NSInteger finishedTimeInt = [dataDictionary[@"trainAllNum"] integerValue];
            NSString *finishedTimesString = [NSString stringWithFormat:@"%@", @(finishedTimeInt)];
            NSMutableAttributedString *finishedAttString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@次", finishedTimesString]];
            [finishedAttString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16], NSFontAttributeName, nil] range:NSMakeRange(0, finishedTimesString.length)];
            _finishedTimesLabel.attributedText = finishedAttString;
        }
    }];
}

- (void)showGeTuiView:(NSNotification*)notification{
    
    NSString *categoryStr=[notification.userInfo objectForKey:@"category"];
    
    NSDictionary *alertDic=[notification.userInfo objectForKey:@"alert"];
    NSDictionary *bodyDic=[alertDic objectForKey:@"body"];
    NSString *idStr=[bodyDic objectForKey:@"id"];

    if ([categoryStr integerValue] == 2) {
       //干货
        DrysalterDetailViewController *detailView = [[UIStoryboard storyboardWithName:@"DrysalteryDetail" bundle:nil] instantiateViewControllerWithIdentifier:@"DrysalterDetailView"];
        detailView.drysalteryId=idStr;
        [self.navigationController pushViewController:detailView animated:YES];
        
    }else if ([categoryStr integerValue] == 3)
    {
        [CourseDetailModel fetchCourseDetailWith:idStr handler:^(id object, NSString *msg) {
            if (!msg) {
                
                _detailModel = [CourseDetailModel new];
                _detailModel = object;
                //课程
                CourseDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Drysaltery" bundle:nil] instantiateViewControllerWithIdentifier:@"CourseDetailView"];
                detailViewController.courseId = idStr;
                CourseModel *tempModel = [CourseModel new];
                tempModel.courseName = _detailModel.subject_name;
                tempModel.courseDays = _detailModel.traning_day;
                tempModel.courseBody = _detailModel.traning_site;
                tempModel.couserDayEnNum = @"0";
                tempModel.coursePicture = _detailModel.subject_pic;
                tempModel.courseModel = _detailModel.traning_model;
                detailViewController.courseModel = tempModel;
                [self.navigationController pushViewController:detailViewController animated:YES];
                
      }
        }];
        
        
    
        
    }else if ([categoryStr integerValue] == 4)
    {
        //热门话题
        ClockInDetailViewController *clockInDetailVc = [[UIStoryboard storyboardWithName:@"Square" bundle:nil] instantiateViewControllerWithIdentifier:@"ClockInDetailView"];
        clockInDetailVc.clockinId =idStr;
        [self.navigationController pushViewController:clockInDetailVc animated:YES];
        
        
    }else if ([categoryStr integerValue] == 5)
    {
        //圈子
       
        [PostModel postWith:idStr handler:^(id object, NSString *msg) {
            if (!msg) {
                _cardModel = [object copy];
                CardDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Community" bundle:nil] instantiateViewControllerWithIdentifier:@"CardDetailView"];
                detailViewController.cardModel = _cardModel ;
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
        }];
        
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _courseArray.count;
        //return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SCREEN_WIDTH/2 + 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isMyCourse) {
        static NSString *cellIdentifier = @"MyCourseCell";
        MyCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [cell setupContent:_courseArray[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        static NSString *cellIdentifier = @"CourseCell";
        CourseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [cell setupContent:_courseArray[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (_isMyCourse) {
        CourseDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Drysaltery" bundle:nil] instantiateViewControllerWithIdentifier:@"CourseDetailView"];
        detailViewController.courseModel = _courseArray[indexPath.row];
        detailViewController.courseId=detailViewController.courseModel.courseId;
        detailViewController.isJoin = YES;
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else {
        CourseDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Drysaltery" bundle:nil] instantiateViewControllerWithIdentifier:@"CourseDetailView"];
        detailViewController.courseModel = _courseArray[indexPath.row];
        detailViewController.courseId=detailViewController.courseModel.courseId;
        detailViewController.isJoin = NO;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        return 40;
    
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    headerView.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 80, 0, 160, 40)];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:84/255.0 green:84/255.0 blue:84/255.0 alpha:1.0];
    if (_isMyCourse) {
        titleLabel.text = @"我的训练课程";
    } else {
        titleLabel.text = @"为你推荐的课程";
    }
    [headerView addSubview:titleLabel];
    UIImageView *moreImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 22, 15, 10, 10)];
    moreImage.image = [UIImage imageNamed:@"fitness_button_more"];
    [headerView addSubview:moreImage];
    UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 0, 76, 40)];
    moreLabel.textAlignment = NSTextAlignmentRight;
    moreLabel.text = @"更多课程";
    moreLabel.textColor = [UIColor colorWithRed:84/255.0 green:84/255.0 blue:84/255.0 alpha:1.0];
    moreLabel.font = [UIFont systemFontOfSize:14];
    [headerView addSubview:moreLabel];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH - 200, 0, 190, 40);
    [moreButton addTarget:self action:@selector(moreCourseClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:moreButton];
    
    
    return headerView;
}
- (void)moreCourseClick {
    MoreCourseViewController *moreCourseViewController = [[UIStoryboard storyboardWithName:@"Drysaltery" bundle:nil] instantiateViewControllerWithIdentifier:@"MoreCourseView"];
    [self.navigationController pushViewController:moreCourseViewController animated:YES];
}

//- (void)controlPressed:(id)sender {
//    if (_segment.selectedSegmentIndex == 0) {
//        _segmentIndex = 0;
//        _viewForTableLeftConstraint.constant = 0;
//        [UIView animateWithDuration:0.3 animations:^{
//            [self.view layoutIfNeeded];
//        }];
//    } else {
//        _segmentIndex = 1;
//        _viewForTableLeftConstraint.constant = -SCREEN_WIDTH;
//        [UIView animateWithDuration:0.3 animations:^{
//            [self.view layoutIfNeeded];
//        }];
//    }
//}

- (UIView *)titleViewForTabbarNav {
//    _segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"训练", @"干货", nil]];
//    _segment.frame = CGRectMake(0, 0, 120, 30);
//    _segment.layer.masksToBounds = YES;
//    _segment.layer.cornerRadius = 15.0;
//    _segment.layer.borderWidth = 1.0;
//    _segment.layer.borderColor = [UIColor whiteColor].CGColor;
//    _segment.selectedSegmentIndex = _segmentIndex;
//    [_segment addTarget:self action:@selector(controlPressed:) forControlEvents:UIControlEventValueChanged];
//    return _segment;
    return nil;
}

- (NSString *)titleForTabbarNav {
    return @"训练";
}

-(NSArray *)leftButtonsForTabbarNav {
    return nil;
}
- (NSArray *)rightButtonsForTabbarNav {
    
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-64,0,64,44)];
    rightButton.tintColor=[UIColor redColor];
    [rightButton setImage:[UIImage imageNamed:@"rightbar_message"]forState:UIControlStateNormal];
    
    if (_messageLabel) {
        
    }else
    {
        _messageLabel=[[UILabel alloc]init];
    }
    _messageLabel.hidden=YES;
    if (!_messageLabel.text.length==0) {
        _messageLabel.hidden=NO;
    }
    
    _messageLabel.layer.masksToBounds=YES;
    _messageLabel.layer.cornerRadius = 7;
    _messageLabel.frame=CGRectMake(60, 5, 15,15);
    _messageLabel.backgroundColor=[UIColor redColor];
    _messageLabel.font=[UIFont systemFontOfSize:10];
    _messageLabel.textColor=[UIColor whiteColor];
    _messageLabel.textAlignment=NSTextAlignmentCenter;
    [rightButton addSubview:_messageLabel];
    [rightButton addTarget:self action:@selector(messageClick)forControlEvents:UIControlEventTouchUpInside];
    rightButton.imageEdgeInsets=UIEdgeInsetsMake(0, 20, 0, -20);
    UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    return @[rightItem];
}
- (void)messageClick {
    _messageLabel.hidden=YES;
    _messageLabel.text=nil;
    UIViewController *messageListViewController = [[UIStoryboard storyboardWithName:@"MessageList" bundle:nil] instantiateViewControllerWithIdentifier:@"messageListView"];
    [self.navigationController pushViewController:messageListViewController animated:YES];
}
- (void)receivedMessages:(NSInteger)allNum {
    _messageLabel.hidden=NO;
    _messageLabel.text=[NSString stringWithFormat:@"%@", @(allNum)];
}
- (BOOL)checkIfLogin {
    if (![UserInfo userHaveLogin]) {
        return NO;
    }
    return YES;
}

- (void)showLogin {
    UIViewController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginView"];
    [self.navigationController pushViewController:loginVC animated:NO];
}
- (void)showGuide {
    [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:IsFirstOpenTool];
    UIViewController *guideVC = [[UIStoryboard storyboardWithName:@"Guide" bundle:nil] instantiateViewControllerWithIdentifier:@"FifthGuideView"];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:guideVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)tipGuideButtonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == 99) {
        [self showGuide];
        _planButton.selected = NO;
    }
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:IsNewUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _containView.frame = CGRectMake(SCREEN_WIDTH / 2 - 130, SCREEN_HEIGHT, 260, 304);
    } completion:^(BOOL finished) {
        [_guideTipView removeFromSuperview];
    }];
}
- (IBAction)makePlanButtonClick:(id)sender {
    _planButton.selected = NO;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:UserBody]) {
        BodyResultViewController *resultViewController = [[UIStoryboard storyboardWithName:@"Guide" bundle:nil] instantiateViewControllerWithIdentifier:@"BodyResultView"];
        resultViewController.isInformationViewIn = NO;
        [self.navigationController pushViewController:resultViewController animated:YES];
    } else {
        [self showGuide];
    }
}
- (void)knownButtonClick {
    [_tipReportView removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:IsFirstOpenTool];
}

@end
