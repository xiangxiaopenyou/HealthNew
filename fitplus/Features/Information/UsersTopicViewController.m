//
//  UsersTopicViewController.m
//  fitplus
//
//  Created by xlp on 15/12/1.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "UsersTopicViewController.h"
#import "ClockInInforModel.h"
#import <MJRefresh.h>
#import "LimitResultModel.h"
#import "Util.h"
#import "AttentionClockinContentCell.h"
#import "ClockInDetailViewController.h"
#import "MyHomepageViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <MBProgressHUD.h>


@interface UsersTopicViewController ()<UITableViewDataSource, UITableViewDelegate, AttentionClockInDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray *trendsArray;
@property (nonatomic, assign) BOOL isRequest;

@end

@implementation UsersTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_friendId) {
        self.navigationItem.title = @"TA的话题";
    } else {
        self.navigationItem.title = @"我的话题";
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
   
    [_tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self fetchRecord];
    }]];
    [_tableView setFooter:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self fetchRecord];
    }]];
    _tableView.footer.hidden = YES;
    
    _page = 1;
    [self fetchRecord];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)fetchRecord {
    [ClockInInforModel getclockMessgeWithFrendid:_friendId WithLimit:_page handler:^(id object, NSString *msg) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        _isRequest = YES;
        if (!msg) {
            LimitResultModel *limitModel = [LimitResultModel new];
            limitModel = object;
            if (_page == 1) {
                _trendsArray = [limitModel.result mutableCopy];
            }else {
                NSMutableArray *temArray = [NSMutableArray arrayWithArray:_trendsArray];
                [temArray addObjectsFromArray:limitModel.result];
                _trendsArray = temArray;
            }
            [_tableView reloadData];
            BOOL _haveMore = limitModel.haveMore;
            if (_haveMore) {
                _page = limitModel.page;
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
    return _trendsArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = [[AttentionClockinContentCell new] cellHeightWithDic:[_trendsArray objectAtIndex:indexPath.row]];
    return rowHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (_trendsArray.count == 0 && _isRequest) ? 150 : 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    UIImageView *norecordImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 44, 30, 89, 70)];
    norecordImage.image = [UIImage imageNamed:@"mine_prompt_norecord"];
    [headerView addSubview:norecordImage];
    
    UILabel *norecordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, SCREEN_WIDTH, 20)];
    norecordLabel.text = @"还没有话题动态哦！";
    norecordLabel.font = [UIFont systemFontOfSize:14];
    norecordLabel.textColor = kRGBColor(181, 181, 181, 1.0);
    norecordLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:norecordLabel];
    
    return headerView;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ClockinContentCell";
    AttentionClockinContentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setupCellViewWithDic:[_trendsArray objectAtIndex:indexPath.row]];
    cell.delegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ClockInDetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Square" bundle:nil] instantiateViewControllerWithIdentifier:@"ClockInDetailView"];
    ClockInDetailModel *model = [_trendsArray objectAtIndex:indexPath.row];
    [detailVC trendDelete:^{
        [_trendsArray removeObjectAtIndex:indexPath.row];
        [_tableView reloadData];
    }];
    detailVC.clockinId = model.id;
    [self.navigationController pushViewController:detailVC animated:YES];
}
#pragma mark - AttentionClockInDelegate
- (void)clickComment:(NSString *)trendId {
    ClockInDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Square" bundle:nil] instantiateViewControllerWithIdentifier:@"ClockInDetailView"];
    detailViewController.isCommentIn = YES;
    detailViewController.clockinId = trendId;
    [detailViewController trendDelete:^{
        for (ClockInDetailModel *model in _trendsArray) {
            if ([model.id isEqualToString:trendId]) {
                [_trendsArray removeObject:model];
                [_tableView reloadData];
                break;
            }
        }
        
    }];
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
                                                title:@"健身坊，让健身更简单~"
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
