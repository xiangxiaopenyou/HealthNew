//
//  MoreCardTableViewController.m
//  fitplus
//
//  Created by xlp on 15/12/14.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "MoreCardTableViewController.h"
#import "CardModel.h"
#import <MJRefresh.h>
#import "LimitResultModel.h"
#import "CardCell.h"
#import "CommunityCardsViewController.h"
#import "MyHomepageViewController.h"
#import "CardDetailViewController.h"

@interface MoreCardTableViewController ()
@property (nonatomic, strong) NSMutableArray *hotCardArray;
@property (nonatomic, assign) NSInteger page;
@end

@implementation MoreCardTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardEditSuccess) name:@"CardEditSuccess" object:nil];
    self.navigationItem.title = @"热帖";
    self.tableView.tableFooterView = [UIView new];
    [self.tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self fetchHotCard];
    }]];
    [self.tableView setFooter:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self fetchHotCard];
    }]];
    self.tableView.footer.hidden = YES;
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _page = 1;
    [self fetchHotCard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CardEditSuccess" object:nil];
}
/*
 获取热门帖子
 */
- (void)fetchHotCard {
    [CardModel fetchCardList:nil page:_page handler:^(LimitResultModel *object, NSString *msg) {
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        if (!msg) {
            if (_page == 1) {
                _hotCardArray = [object.result mutableCopy];
            } else {
                NSMutableArray *tempArray = [_hotCardArray mutableCopy];
                [tempArray addObjectsFromArray:object.result];
                _hotCardArray = tempArray;
            }
            [self.tableView reloadData];
            BOOL haveMore = object.haveMore;
            if (haveMore) {
                _page = object.page;
                self.tableView.footer.hidden = NO;
            } else {
                [self.tableView.footer noticeNoMoreData];
                self.tableView.footer.hidden = YES;
            }
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

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
    [cell setupCardContent:_hotCardArray[indexPath.row]];
    [cell headClick:^(NSString *userId) {
        NSLog(@"点击了头像");
        MyHomepageViewController *informationViewController = [[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"MyHomepageView"];
        informationViewController.friendId = userId;
        [self.navigationController pushViewController:informationViewController animated:YES];
    }];;
//    [cell cardImageViewClick:^(UITapGestureRecognizer *tap) {
//        [self cardImageShow:tap];
//    }];
    
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

- (void)cardEditSuccess {
    _page = 1;
    [self fetchHotCard];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
