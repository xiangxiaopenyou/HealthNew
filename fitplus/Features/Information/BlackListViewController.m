//
//  BlackListViewController.m
//  fitplus
//
//  Created by xlp on 15/12/8.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "BlackListViewController.h"
#import "BlackUserModel.h"
#import <MJRefresh.h>
#import "LimitResultModel.h"
#import <UIImageView+AFNetworking.h>
#import "Util.h"
#import "RBBlockAlertView.h"

@interface BlackListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation BlackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我的黑名单";
    _tableView.tableFooterView = [UIView new];
    [_tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self fetchBlackList];
        
    }]];
    [_tableView setFooter:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self fetchBlackList];
    }]];
    _page = 1;
    [self fetchBlackList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)fetchBlackList {
    [BlackUserModel fetchBlackList:^(LimitResultModel *object, NSString *msg) {
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        if (!msg) {
            if (_page == 1) {
                _array = [object.result mutableCopy];
            } else {
                NSMutableArray *tempArray = [_array mutableCopy];
                [tempArray addObjectsFromArray:object.result];
                _array = tempArray;
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
#pragma mark - UITableView Delegate DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    BlackUserModel *model = _array[indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 10, 40, 40)];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 20;
    [imageView setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:model.blackPortrait]] placeholderImage:[UIImage imageNamed:@"default_headportrait"]];
    [cell .contentView addSubview:imageView];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 60)];
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textColor = [UIColor colorWithRed:81/255.0 green:81/255.0 blue:81/255.0 alpha:1.0];
    textLabel.text = [NSString stringWithFormat:@"%@", model.blackNickname];
    [cell.contentView addSubview:textLabel];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BlackUserModel *model = _array[indexPath.row];
    [[[RBBlockAlertView alloc] initWithTitle:@"提示" message:@"你要把TA移出黑名单吗?" block:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self addBlackListUser:model.blackId];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"是的", nil] show];
}
/*
 黑名单
 */
- (void)addBlackListUser:(NSString *)userId {
    [BlackUserModel deleteBlack:userId handler:^(id object, NSString *msg) {
        if (!msg) {
            _page = 1;
            [self fetchBlackList];
        } else {
            [[[RBBlockAlertView alloc] initWithTitle:@"提示" message:@"移出黑名单失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
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

@end
