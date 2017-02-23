//
//  CommunityHomepageViewController.m
//  fitplus
//
//  Created by xlp on 15/12/9.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "CommunityHomepageViewController.h"
#import "KDTabbarProtocol.h"
#import "CommunityModel.h"
#import "CardModel.h"
#import "LimitResultModel.h"
#import <UIImageView+AFNetworking.h>
#import "Util.h"
#import <MJRefresh.h>
#import "CardCell.h"
#import "CommunityCardsViewController.h"
#import <MBProgressHUD.h>
#import "CardDetailViewController.h"
#import <UIImageView+AFNetworking.h>
#import "MoreCardTableViewController.h"
#import "MyHomepageViewController.h"
#import <MJRefresh.h>
#import "MessageUnreadCommentModel.h"
#import "MobClick.h"
@interface CommunityHomepageViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *communityImage1;
@property (weak, nonatomic) IBOutlet UIImageView *communityImage2;
@property (weak, nonatomic) IBOutlet UIImageView *communityImage4;
@property (weak, nonatomic) IBOutlet UIImageView *communityImage3;
@property (weak, nonatomic) IBOutlet UILabel *communityLabel1;
@property (weak, nonatomic) IBOutlet UILabel *communityLabel2;
@property (weak, nonatomic) IBOutlet UILabel *communityLabel3;
@property (weak, nonatomic) IBOutlet UILabel *communityLabel4;
@property (nonatomic, copy) NSArray *communityArray;
@property (nonatomic, strong) NSMutableArray *hotCardArray;




@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIImageView *lastImageView;
@property (nonatomic, assign)CGRect originalFrame;
@property (nonatomic, assign)BOOL isDoubleTap;
@property (nonatomic, strong)UILabel *messageLabel;

//@property (nonatomic, strong) UILabel *badgeLabel;

@end

@implementation CommunityHomepageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardEditSuccess) name:@"CardEditSuccess" object:nil];
    
    [_tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchHotCard];
    }]];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self fetchCommunity];
    [self fetchHotCard];
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"CommunityPage"];
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
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"CommunityPage"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CardEditSuccess" object:nil];
}

/*
 获取四个圈子
 */
- (void)fetchCommunity {
    [CommunityModel fetchHotCommunity:^(NSArray *object, NSString *msg) {
        if (!msg) {
            _communityArray = [object copy];
            [self setupCommunityView];
        }
    }];
}
/*
 获取热门帖子
 */
- (void)fetchHotCard {
    [CardModel fetchCardList:nil page:1 handler:^(LimitResultModel *object, NSString *msg) {
        [_tableView.header endRefreshing];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!msg) {
            _hotCardArray = [object.result mutableCopy];
            [_tableView reloadData];
        }
    }];
}
- (void)setupCommunityView {
    CommunityModel *model1 = _communityArray[0];
    CommunityModel *model2 = _communityArray[1];
    CommunityModel *model3 = _communityArray[2];
    CommunityModel *model4 = _communityArray[3];
    [_communityImage1 setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:model1.ico]] placeholderImage:[UIImage imageNamed:@"default_headportrait"]];
    [_communityImage2 setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:model2.ico]] placeholderImage:[UIImage imageNamed:@"default_headportrait"]];
    [_communityImage3 setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:model3.ico]] placeholderImage:[UIImage imageNamed:@"default_headportrait"]];
    [_communityImage4 setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:model4.ico]] placeholderImage:[UIImage imageNamed:@"default_headportrait"]];
    _communityLabel1.text = [NSString stringWithFormat:@"%@", model1.name];
    _communityLabel2.text = [NSString stringWithFormat:@"%@", model2.name];
    _communityLabel3.text = [NSString stringWithFormat:@"%@", model3.name];
    _communityLabel4.text = [NSString stringWithFormat:@"%@", model4.name];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITableView Delegate DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _hotCardArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = [[CardCell new] heightOfCell:_hotCardArray[indexPath.row]];
    return rowHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CardCell";
    CardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[CardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setupCardContent:_hotCardArray[indexPath.row]];
    [cell headClick:^(NSString *userId) {
        NSLog(@"点击了头像");
        MyHomepageViewController *informationViewController = [[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"MyHomepageView"];
        informationViewController.friendId = userId;
        [self.navigationController pushViewController:informationViewController animated:YES];
    }];
    [cell communityClick:^(NSString *communityId) {
        CommunityCardsViewController *viewController = [[UIStoryboard storyboardWithName:@"Community" bundle:nil] instantiateViewControllerWithIdentifier:@"CommunityCardView"];
        for (CommunityModel *tempModel in _communityArray) {
            if ([tempModel.id isEqualToString:communityId]) {
                viewController.communityModel = tempModel;
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
    }];
    return cell;
}
     

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CardDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Community" bundle:nil] instantiateViewControllerWithIdentifier:@"CardDetailView"];
    detailViewController.cardModel = _hotCardArray[indexPath.row];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 46;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 46)];
    
    UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, 100, 26)];
    headLabel.text = @"热帖";
    headLabel.textColor = kRGBColor(49, 49, 49, 1.0);
    headLabel.font = [UIFont systemFontOfSize:14];
    [headView addSubview:headLabel];
    UIImageView *rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 36, 12, 22, 22)];
    rightImage.image =[UIImage imageNamed:@"cell_right"];
    [headView addSubview:rightImage];
    UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 86, 10, 50, 26)];
    moreLabel.text = @"更多";
    moreLabel.textColor = kRGBColor(184, 184, 184, 1.0);
    moreLabel.font = [UIFont systemFontOfSize:13];
    moreLabel.textAlignment = NSTextAlignmentRight;
    [headView addSubview:moreLabel];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 45.5, SCREEN_WIDTH, 0.5)];
    line.backgroundColor = kRGBColor(224, 224, 224, 1.0);
    [headView addSubview:line];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 2, 45);
    [moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:moreButton];
    headView.backgroundColor = [UIColor whiteColor];
    return headView;
}

- (IBAction)communityButtonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    CommunityModel *tempModel = [CommunityModel new];
    switch (button.tag) {
        case 11:{
            tempModel = _communityArray[0];
        }
            break;
        case 12:{
            tempModel = _communityArray[1];
        }
            break;
        case 13:{
            tempModel = _communityArray[2];
        }
            break;
        case 14:{
            tempModel = _communityArray[3];
        }
            break;
        default:
            break;
    }
    CommunityCardsViewController *view = [[UIStoryboard storyboardWithName:@"Community" bundle:nil] instantiateViewControllerWithIdentifier:@"CommunityCardView"];
    view.communityModel = tempModel;
    [self.navigationController pushViewController:view animated:YES];
    
}
- (void)moreButtonClick {
    MoreCardTableViewController *viewControler = [[UIStoryboard storyboardWithName:@"Community" bundle:nil] instantiateViewControllerWithIdentifier:@"MoreCardView"];
    viewControler.communityArray = [_communityArray copy];
    [self.navigationController pushViewController:viewControler animated:YES];
}

- (UIView *)titleViewForTabbarNav {
    return nil;
}
- (NSString *)titleForTabbarNav {
    return @"圈子";
}

-(NSArray *)leftButtonsForTabbarNav {
    return nil;
}
- (NSArray *)rightButtonsForTabbarNav {
    //UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftbar_message"] style:UIBarButtonItemStylePlain target:self action:@selector(messageClick)];
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-64,0,64,44)];
    rightButton.tintColor=[UIColor redColor];
    [rightButton setImage:[UIImage imageNamed:@"rightbar_message"]forState:UIControlStateNormal];
    
    if (_messageLabel) {
        
    }else
    {
       _messageLabel=[[UILabel alloc]init];
    }
    _messageLabel.hidden=YES;
    if (_messageLabel.text.length != 0) {
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
- (void)cardEditSuccess {
    [self fetchHotCard];
}

@end
