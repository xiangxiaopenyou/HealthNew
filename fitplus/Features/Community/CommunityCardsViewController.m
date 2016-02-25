//
//  CommunityCardsViewController.m
//  fitplus
//
//  Created by xlp on 15/12/14.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "CommunityCardsViewController.h"
#import "CardModel.h"
#import <MJRefresh.h>
#import "LimitResultModel.h"
#import "CardCell.h"
#import "Util.h"
#import <UIImageView+AFNetworking.h>
#import "PostCardViewController.h"
#import "CardDetailViewController.h"
#import "MyHomepageViewController.h"

@interface CommunityCardsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *cardsTableView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *essenceButton;
@property (weak, nonatomic) IBOutlet UIButton *recentButton;
@property (weak, nonatomic) IBOutlet UIImageView *creatorHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *creatorNickname;
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *introduceViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *backgroundCloseButton;

@property (strong, nonatomic) UILabel *selectedLabel;
@property (nonatomic, strong) UIView *tipPhotoView;

@property (nonatomic, strong) NSMutableArray *hotCardArray;
@property (nonatomic, strong) NSMutableArray *recentArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger recentPage;
@property (nonatomic, strong) UIImageView *openIntroduceImage;
@property (nonatomic, assign) CGSize intruduceSize;

@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *lastImageView;
@property (nonatomic, assign)CGRect originalFrame;
@property (nonatomic, assign)BOOL isDoubleTap;

@end

@implementation CommunityCardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postCardSuccess:) name:@"PostCardSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardEditSuccess) name:@"CardEditSuccess" object:nil];
    [self setupNavigationTitleView];
    [self addIntroduceContent];
    _selectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(3 * SCREEN_WIDTH / 4 - 24, 42, 48, 2)];
    _selectedLabel.backgroundColor = kRGBColor(87, 172, 184, 1.0);
    [_topView addSubview:_selectedLabel];
    self.cardsTableView.tableFooterView = [UIView new];
    [self.cardsTableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (_essenceButton.selected) {
            _page = 1;
            [self fetchHotCard];
        } else {
            _recentPage = 1;
            [self fetchRecentList];
        }
    }]];
    [self.cardsTableView setFooter:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (_essenceButton.selected) {
            [self fetchHotCard];
        } else {
            [self fetchRecentList];
        }
    }]];
    _page = 1;
    _recentPage = 1;
    [self fetchHotCard];
    [self fetchRecentList];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:IsFirstOpenCommunity] == 1) {
        [self setupTipView];
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PostCardSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CardEditSuccess" object:nil];
}
- (void)setupNavigationTitleView {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.text = [NSString stringWithFormat:@"%@", _communityModel.name];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titleLabel];
    
    _openIntroduceImage = [[UIImageView alloc] initWithFrame:CGRectMake(68, 34, 14, 8)];
    _openIntroduceImage.image = [UIImage imageNamed:@"circle_introduce_open"];
    [titleView addSubview:_openIntroduceImage];
    
    UIButton *openIntroduceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    openIntroduceButton.frame = CGRectMake(25, 0, 100, 44);
    [openIntroduceButton addTarget:self action:@selector(openIntroduceClick) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:openIntroduceButton];
    
    self.navigationItem.titleView = titleView;
}
- (void)addIntroduceContent {
    [_creatorHeadImage setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:_communityModel.portrait]] placeholderImage:[UIImage imageNamed:@"default_headportrait"]];
    _creatorNickname.text = [NSString stringWithFormat:@"%@", _communityModel.nickname];
    _introduceLabel.text = [NSString stringWithFormat:@"%@", _communityModel.introduce];
    _intruduceSize = [[NSString stringWithFormat:@"%@", _communityModel.introduce] boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 28, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13], NSFontAttributeName, nil] context:nil].size;
}
- (void)setupTipView {
    _tipPhotoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tipPhotoView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:_tipPhotoView];
    UIButton *knowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    knowButton.frame = CGRectMake(SCREEN_WIDTH / 2 - 52, SCREEN_HEIGHT - 320, 104, 32);
    [knowButton setBackgroundImage:[UIImage imageNamed:@"guide_button"] forState:UIControlStateNormal];
    [knowButton addTarget:self action:@selector(knownButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_tipPhotoView addSubview:knowButton];
    
    UIImageView *tipImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 150, SCREEN_HEIGHT - 290, 300, 230)];
    tipImage.image = [UIImage imageNamed:@"tip_post_card"];
    [_tipPhotoView addSubview:tipImage];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 25.5, SCREEN_HEIGHT - 66, 51, 51)];
    image.image = [UIImage imageNamed:@"circle_post_card"];
    [_tipPhotoView addSubview:image];
}
/*
 获取帖子
 */
- (void)fetchHotCard {
    [CardModel fetchCardList:_communityModel.id page:_page handler:^(LimitResultModel *object, NSString *msg) {
        [self.cardsTableView.header endRefreshing];
        [self.cardsTableView.footer endRefreshing];
        if (!msg) {
            if (_page == 1) {
                _hotCardArray = [object.result mutableCopy];
            } else {
                NSMutableArray *tempArray = [_hotCardArray mutableCopy];
                [tempArray addObjectsFromArray:object.result];
                _hotCardArray = tempArray;
            }
            [self.cardsTableView reloadData];
            BOOL haveMore = object.haveMore;
            if (haveMore) {
                _page = object.page;
                self.cardsTableView.footer.hidden = NO;
            } else {
                [self.cardsTableView.footer noticeNoMoreData];
                self.cardsTableView.footer.hidden = YES;
            }
        }
    }];
}
- (void)fetchRecentList {
    [CardModel fetchRecentCardList:_communityModel.id page:_recentPage handler:^(LimitResultModel *object, NSString *msg) {
        [_cardsTableView.header endRefreshing];
        [_cardsTableView.footer endRefreshing];
        if (!msg) {
            if (_recentPage == 1) {
                _recentArray = [object.result mutableCopy];
            } else {
                NSMutableArray *tempArray = [_recentArray mutableCopy];
                [tempArray addObjectsFromArray:object.result];
                _recentArray = tempArray;
            }
            if (_recentButton.selected) {
                [_cardsTableView reloadData];
            }
            BOOL haveMore = object.haveMore;
            if (haveMore) {
                _recentPage = object.page;
                _cardsTableView.footer.hidden = NO;
            } else {
                [_cardsTableView.footer noticeNoMoreData];
                _cardsTableView.footer.hidden = YES;
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _essenceButton.selected ? _hotCardArray.count : _recentArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight;
    if (_essenceButton.selected) {
        rowHeight = [[CardCell new] heightOfCell:_hotCardArray[indexPath.row]];
    } else {
        rowHeight = [[CardCell new] heightOfCell:_recentArray[indexPath.row]];
    }
    
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CardCell";
    CardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (_essenceButton.selected) {
        [cell setupCardContent:_hotCardArray[indexPath.row]];
    } else {
        [cell setupCardContent:_recentArray[indexPath.row]];
    }
    [cell headClick:^(NSString *userId) {
        NSLog(@"点击了头像");
        MyHomepageViewController *informationViewController = [[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"MyHomepageView"];
        informationViewController.friendId = userId;
        [self.navigationController pushViewController:informationViewController animated:YES];
    }];;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CardDetailViewController *detailViewContrller = [[UIStoryboard storyboardWithName:@"Community" bundle:nil] instantiateViewControllerWithIdentifier:@"CardDetailView"];
    CardModel *tempModel = [CardModel new];
    if (_essenceButton.selected) {
        tempModel = _hotCardArray[indexPath.row];
    } else {
        tempModel = _recentArray[indexPath.row];
    }
    detailViewContrller.cardModel = tempModel;
    [self.navigationController  pushViewController:detailViewContrller animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)openIntroduceClick {
    NSLog(@"打开介绍");
    _openIntroduceImage.hidden = YES;
    _introduceViewHeightConstraint.constant = _intruduceSize.height + 104;
    _backgroundCloseButton.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (IBAction)closeIntroduceClick:(id)sender {
    _openIntroduceImage.hidden = NO;
    _introduceViewHeightConstraint.constant = 0;
    _backgroundCloseButton.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (IBAction)essenceButtonClick:(id)sender {
    if (!_essenceButton.selected) {
        _essenceButton.selected = YES;
        _recentButton.selected = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _selectedLabel.frame = CGRectMake(SCREEN_WIDTH / 4 - 24, 42, 48, 2);
        }];
        [_cardsTableView reloadData];
    }
}
- (IBAction)recentButtonClick:(id)sender {
    if (!_recentButton.selected) {
        _essenceButton.selected = NO;
        _recentButton.selected = YES;
        [UIView animateWithDuration:0.3 animations:^{
            _selectedLabel.frame = CGRectMake(3 * SCREEN_WIDTH / 4 - 24, 42, 48, 2);
        }];
        [_cardsTableView reloadData];
    }
}
- (IBAction)postCardClick:(id)sender {
    PostCardViewController *postCardView = [[UIStoryboard storyboardWithName:@"Community" bundle:nil] instantiateViewControllerWithIdentifier:@"PostCardView"];
    postCardView.model = _communityModel;
    [self.navigationController pushViewController:postCardView animated:YES];
}
- (void)postCardSuccess:(NSNotification *)notification {
    [self recentButtonClick:nil];
    _recentPage = 1;
    [self fetchRecentList];
}
- (void)cardEditSuccess {
    _page = 1;
    _recentPage = 1;
    [self fetchHotCard];
    [self fetchRecentList];
}
-(void)cardImageShow:(UITapGestureRecognizer*)tap
{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    //scrollView作为背景
    UIScrollView *bgView = [[UIScrollView alloc] init];
    bgView.frame = [UIScreen mainScreen].bounds;
    bgView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapBg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView:)];
    [bgView addGestureRecognizer:tapBg];
    
    UIImageView *picView = (UIImageView *)tap.view;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = picView.image;
    imageView.frame = [bgView convertRect:picView.frame fromView:self.view];
    [bgView addSubview:imageView];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:bgView];
    
    self.lastImageView = imageView;
    self.originalFrame = imageView.frame;
    self.scrollView = bgView;
    //最大放大比例
    self.scrollView.maximumZoomScale = 1.5;
    self.scrollView.delegate = self;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = imageView.frame;
        frame.size.width = bgView.frame.size.width;
        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        frame.origin.x = 0;
        frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
        imageView.frame = frame;
    }];
}
-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer
{
    self.scrollView.contentOffset = CGPointZero;
    [UIView animateWithDuration:0.5 animations:^{
        self.lastImageView.frame = self.originalFrame;
        tapBgRecognizer.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [tapBgRecognizer.view removeFromSuperview];
        self.scrollView = nil;
        self.lastImageView = nil;
    }];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.lastImageView;
}
- (void)knownButtonClick {
    [_tipPhotoView removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:IsFirstOpenCommunity];
}
@end
