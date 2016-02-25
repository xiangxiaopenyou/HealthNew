//
//  UsersCollectionViewController.m
//  fitplus
//
//  Created by xlp on 15/12/2.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "UsersCollectionViewController.h"
#import "DrysalteryModel.h"
#import <MJRefresh.h>
#import "LimitResultModel.h"
#import "DrysalteryCell.h"
#import "DrysalterDetailViewController.h"

@interface UsersCollectionViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSInteger collectionLimit;
@property (nonatomic, strong) NSMutableArray *collectionArray;

@end

@implementation UsersCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_friendId) {
        self.navigationItem.title = @"TA的收藏";
    } else {
        self.navigationItem.title = @"我的收藏";
    }
    [_tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _collectionLimit = 0;
        [self fetchCollectionList];
    }]];
    [_tableView setFooter:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self fetchCollectionList];
    }]];
    _tableView.footer.hidden = YES;
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _collectionLimit = 0;
    [self fetchCollectionList];
}

- (void)fetchCollectionList {
    [DrysalteryModel drysalteryCollectionListWith:_collectionLimit friendId:_friendId handler:^(id object, NSString *msg) {
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        if (!msg) {
            LimitResultModel *limitModel = [LimitResultModel new];
            limitModel = object;
            if (_collectionLimit == 0) {
                _collectionArray = [limitModel.result mutableCopy];
            } else {
                NSMutableArray *tempArray = [_collectionArray mutableCopy];
                [tempArray addObjectsFromArray:limitModel.result];
                _collectionArray = tempArray;
            }
            [_tableView reloadData];
            if (limitModel.haveMore) {
                _collectionLimit = limitModel.limit;
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
#pragma mark UITableView Delegate DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _collectionArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (SCREEN_WIDTH - 18) / 302 * 179 + 9;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DrysalteryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DryCell" forIndexPath:indexPath];
    [cell setupDrysalteryContentWithModel:_collectionArray[indexPath.row]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return _collectionArray.count == 0 ? 150 : 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, 0, 150);
    headerView.backgroundColor = [UIColor clearColor];
    
    UIImageView *norecordImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 41, 30, 82, 76)];
    norecordImage.image = [UIImage imageNamed:@"mine_prompt_nocollect"];
    [headerView addSubview:norecordImage];
    
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, SCREEN_WIDTH, 20)];
    emptyLabel.font = [UIFont systemFontOfSize:14];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = kRGBColor(181, 181, 181, 1.0);
    [headerView addSubview:emptyLabel];
    if (_friendId) {
        emptyLabel.text = @"他还没有收藏哦~";
    } else {
        emptyLabel.text = @"你还没有收藏哦~";
    }
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DrysalterDetailViewController *detailView = [[UIStoryboard storyboardWithName:@"DrysalteryDetail" bundle:nil] instantiateViewControllerWithIdentifier:@"DrysalterDetailView"];
    DrysalteryModel *tempModel = _collectionArray[indexPath.row];
    detailView.model = tempModel;
    detailView.drysalteryId = tempModel.dryId;
    detailView.titleStr = tempModel.title;
    [self.navigationController pushViewController:detailView animated:YES];
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
