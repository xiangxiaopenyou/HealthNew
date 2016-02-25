//
//  MessageListViewController.m
//  fitplus
//
//  Created by 陈 on 15/7/8.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "MessageListViewController.h"
#import "MessageUnreadCommentModel.h"
#import "MessageCommentModel.h"
#import "UserMessageTableViewCell.h"
#import "RBNoticeHelper.h"
#import "LimitResultModel.h"
#import <MBProgressHUD.h>
#import <UIImageView+AFNetworking.h>
#import <MJRefresh.h>
#import "Util.h"
#import "MyHomepageViewController.h"
#import "KDTabbarProtocol.h"
#import "ClockInDetailViewController.h"
#import "CardDetailViewController.h"
#import "PostModel.h"
#import "DrysalterDetailViewController.h"
#import "DrysalteryModel.h"

#define VIEW_SIZE_WIDTH  [UIScreen mainScreen].bounds.size.width
#define VIEW_SIZE_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface MessageListViewController ()<UITableViewDelegate, UITableViewDataSource, KDTabbarProtocol>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageNumconstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *noMessageImageView;
@property (weak, nonatomic) IBOutlet UILabel *unReadMessageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageConstraint;
@property (copy, nonatomic) NSMutableArray *members;
@end

@implementation MessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.navigationController setNavigationBarHidden:NO];
    //self.navigationItem.title = @"消息";
    _tableView.tableFooterView = [UIView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _page=1;
    [self initRefrsh];
    [self refreshMessageData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
   // [self refreshMessageData];
    _unReadMessageLabel.hidden = YES;
    
    [MessageUnreadCommentModel unreadMessage:^(MessageUnreadCommentModel *object, NSString *msg) {
    
        _unReadMessageLabel.text=object.num;
        if (![object.num intValue] == 0) {
            _unReadMessageLabel.hidden=NO;
            if ([object.num intValue] < 10) {
                _messageNumconstraint.constant = 22;
            }else {
                _messageNumconstraint.constant = 32;
            }
        }
    }];
}
-(void)viewWillDisappear:(BOOL)animated
{
   // [_members removeAllObjects];
   //  _page=0;
}
#pragma mark request

- (void)initRefrsh{
    [self.tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self refreshMessageData];
        
    }]];
    [self.tableView setFooter:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self refreshMessageData];
    }]];
}

- (void)refreshMessageData{
    [MessageCommentModel MessageCommentWithPage:_page handler:^(id object, NSString *msg) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        if (msg) {
            [RBNoticeHelper showNoticeAtViewController:self msg:msg];
        }else {
            LimitResultModel *limitModel = [LimitResultModel new];
            limitModel = object;
            if (_page == 1) {
                _members = [limitModel.result mutableCopy];
            }else {
                NSMutableArray *temArray = [_members mutableCopy];
                [temArray addObjectsFromArray:limitModel.result];
                _members = temArray;
            }
            [_tableView reloadData];
            BOOL haveMore = limitModel.haveMore;
            if (haveMore) {
                _page = limitModel.page;
                _tableView.footer.hidden = NO;
            }else {
                [_tableView.footer noticeNoMoreData];
                _tableView.footer.hidden = YES;
            }
        }
        if (_members.count == 0) {
            _tableView.hidden = YES;
            _noMessageImageView.hidden = NO;
        }else {
            _tableView.hidden = NO;
            _noMessageImageView.hidden = YES;
        }
    }];
}

#pragma mark tableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UserMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userMessageCell" forIndexPath:indexPath];
    MessageCommentModel *messageCommentModel = _members[indexPath.row];
    [cell.InfoHeadImageView setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:messageCommentModel.sendUserPortrait]] placeholderImage:[UIImage imageNamed:@"default_headportrait"]];
    [cell.InfoNIcknameButton setTitle:messageCommentModel.sendUserNickName forState:UIControlStateNormal];
    
    NSTimeInterval time = [messageCommentModel.createTime doubleValue];
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *string=[formatter stringFromDate: detaildate];
    cell.InfoMessageTimeLabel.text=string;
    if ([messageCommentModel.type intValue] == 1) {
        cell.InfoMessageLabel.text = messageCommentModel.massage;
        cell.messageLabel.hidden = YES;
        [cell.messageImageView setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:messageCommentModel.picUrl]]];
    }else {
        cell.messageImageView.hidden = YES;
        cell.InfoMessageLabel.text = messageCommentModel.massage;
        //cell.messageLabel.text = messageCommentModel.trendscommentcontent;
    }
    if ([messageCommentModel.isRead intValue] == 1) {
        cell.isReadLabel.hidden = YES;
    } else {
        cell.isReadLabel.hidden = NO;
    }
    if (indexPath.row == _members.count-1) {
        cell.lineLabel.hidden = YES;
    } else {
        cell.lineLabel.hidden = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageCommentModel *messageCommentModel = _members[indexPath.row];
    CGSize labelSize = [messageCommentModel.massage boundingRectWithSize:CGSizeMake(VIEW_SIZE_WIDTH - 148, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} context:nil].size;
    if (labelSize.height > 15) {
        return 76;
    } else {
        return 62;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageCommentModel *messageModel = _members[indexPath.row];
    if ([messageModel.category isEqual:@"2"]) {
        //干货
        [DrysalteryModel drysalteryDetailWith:messageModel.massageid handler:^(NSDictionary *object, NSString *msg) {
            if (!msg) {
                
                DrysalterDetailViewController *detailView = [[UIStoryboard storyboardWithName:@"DrysalteryDetail" bundle:nil] instantiateViewControllerWithIdentifier:@"DrysalterDetailView"];
                DrysalteryModel *tempModel = [object copy];
                detailView.model = tempModel;
                detailView.drysalteryId = tempModel.dryId;
                detailView.titleStr = tempModel.title;
                [self.navigationController pushViewController:detailView animated:YES];
            }
        }];
    } else if ([messageModel.category isEqual:@"4"]) {
       //热门话题
        ClockInDetailViewController *clockInDetailVc = [[UIStoryboard storyboardWithName:@"Square" bundle:nil] instantiateViewControllerWithIdentifier:@"ClockInDetailView"];
        clockInDetailVc.clockinId = messageModel.massageid;
        [self.navigationController pushViewController:clockInDetailVc animated:YES];
        
    } else if ([messageModel.category isEqual:@"5"]) {
        //圈子
        [PostModel postWith:messageModel.massageid handler:^(id object, NSString *msg) {
            if (!msg) {
                _cardModel = [object copy];
                CardDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Community" bundle:nil] instantiateViewControllerWithIdentifier:@"CardDetailView"];
                detailViewController.cardModel = _cardModel ;
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
        }];     
        
    } else {
        
    }
    
    messageModel.isRead = @"1";
    [_members replaceObjectAtIndex:indexPath.row withObject:messageModel];
    [_tableView reloadData];
}

#pragma mark buttonClick

- (IBAction)goToInformationClick:(UIButton *)sender {
    NSIndexPath *indexPath = [_tableView indexPathForCell:(UITableViewCell *)sender.superview.superview];
    MyHomepageViewController *informationVc=[[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"MyHomepageView"];
    MessageCommentModel *messageModel = _members[indexPath.row];
    informationVc.friendId = messageModel.sendUserId;
    [self.navigationController pushViewController:informationVc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tabbar
- (UIView *)titleViewForTabbarNav {
    return nil;
}

- (NSString *)titleForTabbarNav {
    return @"消息";
}

-(NSArray *)leftButtonsForTabbarNav {
    return nil;
}
- (NSArray *)rightButtonsForTabbarNav{
    return nil;
}


@end
