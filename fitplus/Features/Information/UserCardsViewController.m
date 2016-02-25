//
//  UserCardsViewController.m
//  fitplus
//
//  Created by xlp on 15/12/24.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "UserCardsViewController.h"
#import <MJRefresh.h>
#import "CardModel.h"
#import "LimitResultModel.h"
#import "CardCell.h"
#import "MyHomepageViewController.h"
#import "CardDetailViewController.h"
#import "CommunityCardsViewController.h"
#import <MBProgressHUD.h>

@interface UserCardsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *cardArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray *communityArray;
@property (nonatomic, assign) BOOL isRequest;

@end

@implementation UserCardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    if ([_userId isEqualToString:userid]) {
        self.navigationItem.title = @"我的帖子";
    } else {
        self.navigationItem.title = @"TA的帖子";
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _tableView.tableFooterView = [UIView new];
    [_tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self fetchCardList];
    }]];
    [_tableView setFooter:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self fetchCardList];
    }]];
    _tableView.footer.hidden = YES;
    [self fetchCommunity];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _page = 1;
    [self fetchCardList];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)fetchCardList {
   [CardModel fetchUserCardsWith:_userId page:_page handler:^(LimitResultModel *object, NSString *msg) {
       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
       [_tableView.header endRefreshing];
       [_tableView.footer endRefreshing];
       _isRequest = YES;
       if (!msg) {
           if (_page == 1) {
               _cardArray = [object.result mutableCopy];
           } else {
               NSMutableArray *tempArray = [_cardArray mutableCopy];
               [tempArray addObjectsFromArray:object.result];
               _cardArray = tempArray;
           }
           [_tableView reloadData];
           BOOL haveMore = object.haveMore;
           if (haveMore) {
               _page = object.page;
               _tableView.footer.hidden = NO;
           } else {
               [_tableView.footer noticeNoMoreData];
               _tableView.footer.hidden = YES;
           }
       }
   }];
}
/*
 获取四个圈子
 */
- (void)fetchCommunity {
    [CommunityModel fetchHotCommunity:^(NSArray *object, NSString *msg) {
        if (!msg) {
            _communityArray = [object copy];
        }
    }];
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
    return _cardArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[CardCell new] heightOfCell:_cardArray[indexPath.row]];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CardCell";
    CardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setupCardContent:_cardArray[indexPath.row]];
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_cardArray.count <= 0 && _isRequest) {
        return 150;
    } else {
        return 0;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    UIImageView *norecordImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 44, 30, 89, 70)];
    norecordImage.image = [UIImage imageNamed:@"mine_prompt_norecord"];
    [headerView addSubview:norecordImage];
    
    UILabel *norecordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, SCREEN_WIDTH, 20)];
    norecordLabel.text = @"还没有贴子哦！";
    norecordLabel.font = [UIFont systemFontOfSize:14];
    norecordLabel.textColor = kRGBColor(181, 181, 181, 1.0);
    norecordLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:norecordLabel];
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CardDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Community" bundle:nil] instantiateViewControllerWithIdentifier:@"CardDetailView"];
    detailViewController.cardModel = _cardArray[indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


@end
