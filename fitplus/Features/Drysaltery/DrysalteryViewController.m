//
//  DrysalteryViewController.m
//  fitplus
//
//  Created by xlp on 15/11/24.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "DrysalteryViewController.h"
#import "CommonsDefines.h"
#import "DrysalteryCell.h"
#import "DrysalteryModel.h"
#import "LimitResultModel.h"
#import <MJRefresh.h>
#import "DrysalterDetailViewController.h"
#import <MBProgressHUD.h>

@interface DrysalteryViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *allButton;
@property (weak, nonatomic) IBOutlet UIButton *encouragementButton;
@property (weak, nonatomic) IBOutlet UIButton *skillButton;
@property (weak, nonatomic) IBOutlet UIButton *knowledgeButton;
@property (weak, nonatomic) IBOutlet UIButton *dietButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedLabelLeftConstraint;
@property (nonatomic, strong) NSMutableArray *dryArray;
@property (nonatomic, assign) NSInteger page;


@end

@implementation DrysalteryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _tableView.tableFooterView = [UIView new];
    [self initRefresh];
    _page = 1;
    switch ([_kindsId integerValue]) {
        case 4: {
            _selectedLabelLeftConstraint.constant = (SCREEN_WIDTH - 56) / 5;
            _allButton.selected = NO;
            _encouragementButton.selected = YES;
            _skillButton.selected = NO;
            _knowledgeButton.selected = NO;
            _dietButton.selected = NO;
        }
            break;
        case 5: {
            _selectedLabelLeftConstraint.constant = 2 * (SCREEN_WIDTH - 56) / 5;
            _allButton.selected = NO;
            _encouragementButton.selected = NO;
            _skillButton.selected = YES;
            _knowledgeButton.selected = NO;
            _dietButton.selected = NO;
        }
            break;
        case 6: {
            _selectedLabelLeftConstraint.constant = 3 * (SCREEN_WIDTH - 56) / 5;
            _allButton.selected = NO;
            _encouragementButton.selected = NO;
            _skillButton.selected = NO;
            _knowledgeButton.selected = YES;
            _dietButton.selected = NO;
        }
            break;
        case 7: {
            _selectedLabelLeftConstraint.constant = 4 * (SCREEN_WIDTH - 56) / 5;
            _allButton.selected = NO;
            _encouragementButton.selected = NO;
            _skillButton.selected = NO;
            _knowledgeButton.selected = NO;
            _dietButton.selected = YES;
        }
            break;
        default: {
            _selectedLabelLeftConstraint.constant = 0;
            _allButton.selected = YES;
            _encouragementButton.selected = NO;
            _skillButton.selected = NO;
            _knowledgeButton.selected = NO;
            _dietButton.selected = NO;
        }
            break;
    }
    [self fetchDryList];
}
- (void)initRefresh {
    [_tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self fetchDryList];
    }]];
    [_tableView setFooter:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self fetchDryList];
    }]];
    _tableView.footer.hidden = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchDryList {
    [DrysalteryModel fetchDryListWithKindsId:_kindsId page:_page handler:^(LimitResultModel *object, NSString *msg) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        if (!msg) {
            if (_page == 1) {
                _dryArray = [object.result mutableCopy];
            } else {
                NSMutableArray *tempArray = [_dryArray mutableCopy];
                [tempArray addObjectsFromArray:object.result];
                _dryArray = tempArray;
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
    return _dryArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (SCREEN_WIDTH - 18) / 302 * 179 + 9;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DryCell";
    DrysalteryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setupDrysalteryContentWithModel:_dryArray[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DrysalterDetailViewController *detailView = [[UIStoryboard storyboardWithName:@"DrysalteryDetail" bundle:nil] instantiateViewControllerWithIdentifier:@"DrysalterDetailView"];
    DrysalteryModel *tempModel = _dryArray[indexPath.row];
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
- (IBAction)allButtonClick:(id)sender {
    _page = 1;
    _kindsId = nil;
    _selectedLabelLeftConstraint.constant = 0;
    _allButton.selected = YES;
    _encouragementButton.selected = NO;
    _skillButton.selected = NO;
    _knowledgeButton.selected = NO;
    _dietButton.selected = NO;
    [self fetchDryList];
}
- (IBAction)encouragementButtonClick:(id)sender {
    _page = 1;
    _kindsId = @"4";
    _selectedLabelLeftConstraint.constant = (SCREEN_WIDTH - 56) / 5;
    _allButton.selected = NO;
    _encouragementButton.selected = YES;
    _skillButton.selected = NO;
    _knowledgeButton.selected = NO;
    _dietButton.selected = NO;
    [self fetchDryList];
}
- (IBAction)skillButtonClick:(id)sender {
    _page = 1;
    _kindsId = @"5";
    _selectedLabelLeftConstraint.constant = 2 * (SCREEN_WIDTH - 56) / 5;
    _allButton.selected = NO;
    _encouragementButton.selected = NO;
    _skillButton.selected = YES;
    _knowledgeButton.selected = NO;
    _dietButton.selected = NO;
    [self fetchDryList];
}
- (IBAction)knowledgeButtonClick:(id)sender {
    _page = 1;
    _kindsId = @"6";
    _selectedLabelLeftConstraint.constant = 3 * (SCREEN_WIDTH - 56) / 5;
    _allButton.selected = NO;
    _encouragementButton.selected = NO;
    _skillButton.selected = NO;
    _knowledgeButton.selected = YES;
    _dietButton.selected = NO;
    [self fetchDryList];
}
- (IBAction)dietButtonClick:(id)sender {
    _page = 1;
    _kindsId = @"7";
    _selectedLabelLeftConstraint.constant = 4 * (SCREEN_WIDTH - 56) / 5;
    _allButton.selected = NO;
    _encouragementButton.selected = NO;
    _skillButton.selected = NO;
    _knowledgeButton.selected = NO;
    _dietButton.selected = YES;
    [self fetchDryList];
}

@end
