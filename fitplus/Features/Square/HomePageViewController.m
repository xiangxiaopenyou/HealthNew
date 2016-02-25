//
//  HomePageViewController.m
//  fitplus
//
//  Created by xlp on 15/11/23.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "HomePageViewController.h"
#import "KDTabbarProtocol.h"
#import "AttentionClockinContentCell.h"
#import "RecommendedTopicCell.h"
#import "ClockInDetailModel.h"
#import "LimitResultModel.h"
#import "RecommendationModel.h"
#import "Util.h"
#import <UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>
#import "ActivityWebViewController.h"
#import "TopicModel.h"
#import <MJRefresh.h>
#import "TopicDetailViewController.h"
#import "DrysalteryViewController.h"
#import "AddFriendsViewController.h"
#import "ClockInDetailViewController.h"
#import "MyHomepageViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "MessageUnreadCommentModel.h"
#import "DrysalteryModel.h"
#import "MobClick.h"
@interface HomePageViewController ()<KDTabbarProtocol, UITableViewDataSource, UITableViewDelegate, AttentionClockInDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewForTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewLeftConstraint;
@property (weak, nonatomic) IBOutlet UITableView *attentionTableView;
@property (weak, nonatomic) IBOutlet UITableView *recommendationTableView;
@property (weak, nonatomic) IBOutlet UIScrollView *topScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *encourageButton;
@property (weak, nonatomic) IBOutlet UIButton *skillButton;
@property (weak, nonatomic) IBOutlet UIButton *knowledgeButton;
@property (weak, nonatomic) IBOutlet UIButton *dietButton;
@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *attentionArray;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger selectedSegment;

@property (nonatomic, strong) NSMutableArray *activitiesArray;
@property (nonatomic, strong) NSMutableArray *topicArray;
@property (nonatomic, copy) NSArray *dryTimeArray;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UILabel *messageLabel;
@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _selectedSegment = 0;
    _limit = 0;
    _page = 1;
    _recommendationTableView.tableHeaderView.frame = CGRectMake(0, 0, 0, SCREEN_WIDTH / 2 + 22 * (SCREEN_WIDTH - 14) / 153 + 20);
    //_recommendationTableView.tableHeaderView.frame = CGRectMake(0, 0, 0, 100);
    [self initRefresh];
    _currentPage = 0;
    [self fetchHotTopicList];
    [self fetchRecentDryTime];
    [self fetchFriendsClockIn];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"HomePage"];
    [MessageUnreadCommentModel unreadMessage:^(MessageUnreadCommentModel *object, NSString *msg) {
        NSInteger allNum = [object.allNum integerValue];
        if (allNum > 0) {
            if (allNum>99) {
                
                allNum=99;
            }
            [self receivedMessages:allNum];
        } else {
            _messageLabel.text=nil;
            _messageLabel.hidden=YES;
        }
    }];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"HomePage"];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_selectedSegment == 0) {
        [self fetchActivities];
    } else {
        [self fetchFriendsClockIn];
    }
    
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
- (void)initRefresh {
    [_attentionTableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _limit = 0;
        [self fetchFriendsClockIn];
    }]];
    [_attentionTableView setFooter:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self fetchFriendsClockIn];
    }]];
    [_recommendationTableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self fetchHotTopicList];
        [self fetchActivities];
    }]];
    [_recommendationTableView setFooter:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self fetchHotTopicList];
    }]];
}
- (void)addImageToScrollView:(NSArray *)imageArray {
    _pageControl.numberOfPages = imageArray.count;
    _pageControl.currentPage = 0;
    for (int i = 0; i < imageArray.count; i ++) {
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(i * CGRectGetWidth(_topScrollView.frame), 2, CGRectGetWidth(_topScrollView.frame), CGRectGetHeight(_topScrollView.frame))];
        //image.contentMode = uiview;
        image.clipsToBounds = YES;
        image.tag = i;
        image.userInteractionEnabled = YES;
        [image setImageWithURL:[NSURL URLWithString:[Util urlPhoto:imageArray[i][@"title"]]] placeholderImage:[UIImage imageNamed:@"default_image"]];
        [image addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusImagePress:)]];
        [_topScrollView addSubview:image];
    }
    _topScrollView.contentSize = CGSizeMake(CGRectGetWidth(_topScrollView.frame) * imageArray.count, 0);
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(changeTopImage) userInfo:nil repeats:YES];
    }
    
}

- (void)changeTopImage {
    if (_currentPage >= _activitiesArray.count - 1) {
        _pageControl.currentPage = 0;
        [_topScrollView setContentOffset:CGPointMake(0, _topScrollView.contentOffset.y) animated:NO];
        _currentPage = 0;
    } else {
        _currentPage += 1;
        [_topScrollView setContentOffset:CGPointMake(_topScrollView.contentOffset.x + CGRectGetWidth(_topScrollView.frame), _topScrollView.contentOffset.y) animated:YES];
        _pageControl.currentPage = _currentPage;
    }
}
/*
 获取活动信息
 */
- (void)fetchActivities {
    
    [RecommendationModel fetchActivities:^(id object, NSString *msg) {
        if (!msg) {
            _activitiesArray = [object mutableCopy];
            if (_topScrollView.subviews.count == 0) {
                [self addImageToScrollView:_activitiesArray];
            }
        }
    }];
}
/*
 获取热门话题列表
 */
- (void)fetchHotTopicList {
    [TopicModel fetchRecommendedTopicList:^(id object, NSString *msg) {
        [_recommendationTableView.header endRefreshing];
        [_recommendationTableView.footer endRefreshing];
        if (!msg) {
            LimitResultModel *model = [LimitResultModel new];
            model = object;
            if (_page == 1) {
                _topicArray = [model.result mutableCopy];
            } else {
                NSMutableArray *tempArray = [_topicArray mutableCopy];
                [tempArray addObjectsFromArray:model.result];
                _topicArray = tempArray;
            }
            [_recommendationTableView reloadData];
            BOOL haveMore = model.haveMore;
            if (haveMore) {
                _page = model.page;
                _recommendationTableView.footer.hidden = NO;
            } else {
                [_recommendationTableView.footer noticeNoMoreData];
                _recommendationTableView.footer.hidden = YES;
            }
        }
    }];
}

/*
 获取关注人的动态列表
 */
- (void)fetchFriendsClockIn {
    [ClockInDetailModel fetchFriendsClockIn:_limit handler:^(id object, NSString *msg) {
        [_attentionTableView.header endRefreshing];
        [_attentionTableView.footer endRefreshing];
        if (!msg) {
            LimitResultModel *model = [LimitResultModel new];
            model = object;
            if (_limit == 0) {
                _attentionArray = [model.result mutableCopy];
            } else {
                NSMutableArray *tempArray = [_attentionArray mutableCopy];
                [tempArray addObjectsFromArray:model.result];
                _attentionArray = tempArray;
            }
            [_attentionTableView reloadData];
            BOOL haveMore = model.haveMore;
            if (haveMore) {
                _limit = model.limit;
                _attentionTableView.footer.hidden = NO;
            } else {
                [_attentionTableView.footer noticeNoMoreData];
                _attentionTableView.footer.hidden = YES;
            }
        }
        
    }];
}
/*
 获取干货最新发布时间
 */
- (void)fetchRecentDryTime {
    [DrysalteryModel fetchRecentDryTime:^(id object, NSString *msg) {
        _dryTimeArray = [object copy];
        [self setupDryButton];
    }];
}
- (void)setupDryButton {
    
    if (![[NSUserDefaults standardUserDefaults] stringForKey:EncourageDryTime]) {
        _encourageButton.selected = YES;
    } else {
        NSString *encourseTimeString = [[NSUserDefaults standardUserDefaults] stringForKey:EncourageDryTime];
        NSDate *localEncourgeDate = [Util getTimeDate:encourseTimeString];
        NSDate *resultEncourgeDate = [Util getTimeDate:_dryTimeArray[0][@"createDate"]];
        if ([Util comparaTwoDate:resultEncourgeDate second:localEncourgeDate]) {
            _encourageButton.selected = YES;
        } else {
            _encourageButton.selected = NO;
        }
    }
    if (![[NSUserDefaults standardUserDefaults] stringForKey:SkillDryTime]) {
        _skillButton.selected = YES;
    } else {
        NSString *skillTimeString = [[NSUserDefaults standardUserDefaults] stringForKey:SkillDryTime];
        NSDate *localSkillDate = [Util getTimeDate:skillTimeString];
        NSDate *resultSkillDate = [Util getTimeDate:_dryTimeArray[1][@"createDate"]];
        if ([Util comparaTwoDate:resultSkillDate second:localSkillDate]) {
            _skillButton.selected = YES;
        } else {
            _skillButton.selected = NO;
        }
    }
    if (![[NSUserDefaults standardUserDefaults] stringForKey:KnownledgeDryTime]) {
        _knowledgeButton.selected = YES;
    } else {
        NSString *knowledgeTimeString = [[NSUserDefaults standardUserDefaults] stringForKey:KnownledgeDryTime];
        NSDate *localKnowledgeDate = [Util getTimeDate:knowledgeTimeString];
        NSDate *resultKnowledgeDate = [Util getTimeDate:_dryTimeArray[2][@"createDate"]];
        if ([Util comparaTwoDate:resultKnowledgeDate second:localKnowledgeDate]) {
            _knowledgeButton.selected = YES;
        } else {
            _knowledgeButton.selected = NO;
        }
    }
    if (![[NSUserDefaults standardUserDefaults] stringForKey:DietDryTime]) {
        _dietButton.selected = YES;
    } else {
        NSString *dietTimeString = [[NSUserDefaults standardUserDefaults] stringForKey:DietDryTime];
        NSDate *localDietDate = [Util getTimeDate:dietTimeString];
        NSDate *resultDietDate = [Util getTimeDate:_dryTimeArray[3][@"createDate"]];
        if ([Util comparaTwoDate:resultDietDate second:localDietDate]) {
            _dietButton.selected = YES;
        } else {
            _dietButton.selected = NO;
        }
    }
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _attentionTableView) {
        return _attentionArray.count;
    } else {
        return _topicArray.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _attentionTableView) {
        CGFloat rowHeight = [[AttentionClockinContentCell new] cellHeightWithDic:[_attentionArray objectAtIndex:indexPath.row]];
        return rowHeight;
    } else {
        return [[RecommendedTopicCell new] heightOfCell:_topicArray[indexPath.row]];
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _attentionTableView) {
        static NSString *CellIdentifier = @"ClockinContentCell";
        AttentionClockinContentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell setupCellViewWithDic:[_attentionArray objectAtIndex:indexPath.row]];
        cell.delegate = self;
        return cell;
    } else {
        static NSString *CellIdentifier = @"RecommendedTopicCell";
        RecommendedTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell setupContent:_topicArray[indexPath.row]];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _attentionTableView) {
        ClockInDetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Square" bundle:nil] instantiateViewControllerWithIdentifier:@"ClockInDetailView"];
        ClockInDetailModel *model = [_attentionArray objectAtIndex:indexPath.row];
        detailVC.clockinId = model.id;
        [self.navigationController pushViewController:detailVC animated:YES];
    } else {
        TopicDetailViewController *viewController = [[UIStoryboard storyboardWithName:@"Square" bundle:nil] instantiateViewControllerWithIdentifier:@"TopicDetailView"];
        viewController.topicModel = _topicArray[indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    
}
#pragma mark - AttentionClockInDelegate
- (void)clickComment:(NSString *)trendId {
    ClockInDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Square" bundle:nil] instantiateViewControllerWithIdentifier:@"ClockInDetailView"];
    detailViewController.isCommentIn = YES;
    detailViewController.clockinId = trendId;
    [self.navigationController pushViewController:detailViewController animated:YES];
}
- (void)clickShare:(ClockInDetailModel *)model image:(UIImage *)image {
    if (!image) {
        image = [UIImage imageNamed:@"share_default"];
    }
    NSString *shareUrl = [NSString stringWithFormat:@"%@%@trendId=%@&f=ios", NewBaseApiURL, CommonShareUrl, model.id];
    id<ISSContent> publishContent = [ShareSDK content:model.clockinContent
                                       defaultContent:@"一起健身吧"
                                                image:[ShareSDK pngImageWithImage:image]
                                                title:@"健身坊,口袋运动健身学院"
                                                  url:shareUrl
                                          description:model.clockinContent
                                            mediaType:SSPublishContentMediaTypeNews];
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
- (void)clickHeadPortrait:(NSString *)userid {
    MyHomepageViewController *informationViewController = [[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"MyHomepageView"];
    informationViewController.friendId = userid;
    [self.navigationController pushViewController:informationViewController animated:YES];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _topScrollView) {
        CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
        NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        _pageControl.currentPage = page;
        _currentPage = page;
    }
    
}

- (IBAction)encouragementButtonClick:(id)sender {
    if (_dryTimeArray.count > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:_dryTimeArray[0][@"createDate"] forKey:EncourageDryTime];
        _encourageButton.selected = NO;
    }
    DrysalteryViewController *viewController = [[UIStoryboard storyboardWithName:@"Drysaltery" bundle:nil] instantiateViewControllerWithIdentifier:@"DrysalteryView"];
    viewController.kindsId = @"4";
    [self.navigationController pushViewController:viewController animated:YES];
}
- (IBAction)skillButtonClick:(id)sender {
    if (_dryTimeArray.count > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:_dryTimeArray[1][@"createDate"] forKey:SkillDryTime];
        _skillButton.selected = NO;
    }
    DrysalteryViewController *viewController = [[UIStoryboard storyboardWithName:@"Drysaltery" bundle:nil] instantiateViewControllerWithIdentifier:@"DrysalteryView"];
    viewController.kindsId = @"5";
    [self.navigationController pushViewController:viewController animated:YES];
}
- (IBAction)knowledgeButtonClick:(id)sender {
    if (_dryTimeArray.count > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:_dryTimeArray[2][@"createDate"] forKey:KnownledgeDryTime];
        _knowledgeButton.selected = NO;
    }
    DrysalteryViewController *viewController = [[UIStoryboard storyboardWithName:@"Drysaltery" bundle:nil] instantiateViewControllerWithIdentifier:@"DrysalteryView"];
    viewController.kindsId = @"6";
    [self.navigationController pushViewController:viewController animated:YES];
}
- (IBAction)dietButtonClick:(id)sender {
    if (_dryTimeArray.count > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:_dryTimeArray[3][@"createDate"] forKey:DietDryTime];
        _dietButton.selected = NO;
    }
    DrysalteryViewController *viewController = [[UIStoryboard storyboardWithName:@"Drysaltery" bundle:nil] instantiateViewControllerWithIdentifier:@"DrysalteryView"];
    viewController.kindsId = @"7";
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - KTTabbarProtocol
- (UIView *)titleViewForTabbarNav {
    _segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"推荐", @"关注", nil]];
    _segment.frame = CGRectMake(0, 0, 120, 30);
    _segment.layer.masksToBounds = YES;
    _segment.layer.cornerRadius = 15.0;
    _segment.layer.borderWidth = 1.0;
    _segment.layer.borderColor = [UIColor whiteColor].CGColor;
    _segment.selectedSegmentIndex = _selectedSegment;
    [_segment addTarget:self action:@selector(controlPressed:) forControlEvents:UIControlEventValueChanged];
    return _segment;
    //return nil;
}
- (NSString *)titleForTabbarNav {
    return nil;
}

-(NSArray *)leftButtonsForTabbarNav {
    UIBarButtonItem *addFriendButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_friends"] style:UIBarButtonItemStylePlain target:self action:@selector(showAddFriend)];
    return @[addFriendButton];
}
- (NSArray *)rightButtonsForTabbarNav {
    
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-64,0,64,44)];
    rightButton.tintColor=[UIColor redColor];
    [rightButton setImage:[UIImage imageNamed:@"rightbar_message"]forState:UIControlStateNormal];
    
    if (_messageLabel) {
        
    } else {
        _messageLabel=[[UILabel alloc]init];
    }
    _messageLabel.hidden=YES;
    if (!_messageLabel.text.length==0) {
        _messageLabel.hidden=NO;
    }
    
    _messageLabel.layer.masksToBounds=YES;
    _messageLabel.layer.cornerRadius = 7.5;
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

- (void)showAddFriend {
    //[self performSegueWithIdentifier:@"Square2AddFriend" sender:self];
    AddFriendsViewController *addFriendsViewController = [[UIStoryboard storyboardWithName:@"Square" bundle:nil] instantiateViewControllerWithIdentifier:@"AddFriendsView"];
    [self.navigationController pushViewController:addFriendsViewController animated:YES];
}
- (void)controlPressed:(id)sender {
    if (_segment.selectedSegmentIndex == 0) {
        _selectedSegment = 0;
        _viewLeftConstraint.constant = 0;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    } else {
        _selectedSegment = 1;
        _viewLeftConstraint.constant = - SCREEN_WIDTH;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}
#pragma mark - FocusImage
- (void)focusImagePress:(UITapGestureRecognizer *)gesture {
    UIImageView *image = (UIImageView *)gesture.view;
    NSDictionary *tempDictionary = [_activitiesArray objectAtIndex:image.tag];
    ActivityWebViewController *activityViewController = [[UIStoryboard storyboardWithName:@"Square" bundle:nil] instantiateViewControllerWithIdentifier:@"ActivityWebView"];
    activityViewController.urlString = tempDictionary[@"url"];
    [self.navigationController pushViewController:activityViewController animated:YES];
}


@end
