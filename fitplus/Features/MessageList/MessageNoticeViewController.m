//
//  MessageNoticeViewController.m
//  fitplus
//
//  Created by 陈 on 15/7/9.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "MessageNoticeViewController.h"
#import "MessagePraiseModel.h"
#import "UserMessageTableViewCell.h"
#import "RBNoticeHelper.h"
#import "LimitResultModel.h"
#import "Util.h"
#import "ClockInDetailViewController.h"
#import <MBProgressHUD.h>
#import <UIImageView+AFNetworking.h>
#import <MJRefresh.h>
#import "MyHomepageViewController.h"
#import "MessageCommentModel.h"
#import "PostModel.h"
#import "CardDetailViewController.h"
#import "DrysalteryModel.h"
#import "DrysalterDetailViewController.h"

#define imageUrlStr @"http://7u2h8u.com1.z0.glb.clouddn.com/"

@interface MessageNoticeViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSMutableArray *members;

@end

@implementation MessageNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // _page=1;
    [self initRefrsh];
    [self refreshMessageData];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark request

- (void)initRefrsh{
    [self.tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //_page = 1;
        [self refreshMessageData];
    }]];
    [self.tableView setFooter:[MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [self refreshMessageData];
    }]];
}

- (void)refreshMessageData{
    
    [MessageCommentModel MessageNote:^(id object, NSString *msg) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        if (msg) {
            [RBNoticeHelper showNoticeAtViewController:self msg:msg];
        }else {
            LimitResultModel *limitModel = [LimitResultModel new];
            limitModel = object;
            _members = [limitModel.result mutableCopy];
            [_tableView reloadData];
        }
        if (_members.count == 0) {
            _tableView.hidden = YES;
        }else{
            _tableView.hidden = NO;
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
    MessageCommentModel *messagePraiseModel = _members[indexPath.row];
    [cell.InfoHeadImageView setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:messagePraiseModel.sendUserPortrait]] placeholderImage:[UIImage imageNamed:@"default_headportrait"]];
    [cell.InfoNIcknameButton setTitle:messagePraiseModel.sendUserNickName forState:UIControlStateNormal];
   
    NSTimeInterval time = [messagePraiseModel.createTime doubleValue];
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *string=[formatter stringFromDate: detaildate];
    cell.InfoMessageTimeLabel.text = string ;
    //cell.InfoMessageLabel.text = ;
    //[cell.messageImageView setImageWithURL:[NSURL URLWithString:[Util urlPhoto:messagePraiseModel.trendphoto]]];
    if ([messagePraiseModel.type isEqualToString:@"3"]) {
        cell.InfoMessageLabel.text = @"给您加了油";
    }else {
        cell.InfoMessageLabel.text = @"关注了您";
    }
    if ([messagePraiseModel.isRead intValue] == 1) {
        cell.isReadLabel.hidden = YES;
    }else {
        cell.isReadLabel.hidden = NO;
    }
    if (indexPath.row == _members.count-1) {
        cell.lineLabel.hidden = YES;
    }else {
        cell.lineLabel.hidden = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageCommentModel *messageModel = _members[indexPath.row];

    if ([messageModel.type isEqual:@"3"]) {
        //点赞
        if ([messageModel.category isEqualToString:@"2"]) {
            //干货点赞
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
            
        }else if ([messageModel.category isEqualToString:@"4"])
        {
            //热门点赞
            ClockInDetailViewController *clockInDetailVc = [[UIStoryboard storyboardWithName:@"Square" bundle:nil] instantiateViewControllerWithIdentifier:@"ClockInDetailView"];
            clockInDetailVc.clockinId =messageModel.massageid;
            [self.navigationController pushViewController:clockInDetailVc animated:YES];
            
        }else if ([messageModel.category isEqualToString:@"5"])
        {
            //圈子点赞
            [PostModel postWith:messageModel.massageid handler:^(id object, NSString *msg) {
                if (!msg) {
                    _cardModel = [object copy];
                    CardDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Community" bundle:nil] instantiateViewControllerWithIdentifier:@"CardDetailView"];
                    detailViewController.cardModel = _cardModel ;
                    [self.navigationController pushViewController:detailViewController animated:YES];
                }
            }];     
            
        }else
        {
            
        }
        
    }else {
        
        /*
        //关注
        MyHomepageViewController *informationVc=[[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"MyHomepageView"];
        informationVc.friendId = messageModel.sendUserId;
        [self.navigationController pushViewController:informationVc animated:YES];
         */
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
