//
//  MyHomepageViewController.m
//  fitplus
//
//  Created by xlp on 15/11/26.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "MyHomepageViewController.h"
#import "RBColorTool.h"
#import "CommonsDefines.h"
#import "ChangeInforModel.h"
#import <UIImageView+AFNetworking.h>
#import "Util.h"
#import "UIImage+ImageEffects.h"
#import "PersonalViewController.h"
#import "AttentionViewController.h"
#import "FansViewController.h"
#import "UsersTopicViewController.h"
#import "UsersTrendsViewController.h"
#import "UsersCollectionViewController.h"
#import "EnergySearchViewController.h"
#import <MBProgressHUD.h>
#import "EditInformationViewController.h"
#import "AddAttentionModel.h"
#import "DailyRecordViewController.h"
#import "BlackListViewController.h"
#import "UserCardsViewController.h"
#import "MessageUnreadCommentModel.h"
#import "MyHomeCell.h"
#import "MobClick.h"
@interface MyHomepageViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *headBackgroundImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headBackgroundImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headBackgroundImageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;
@property (weak, nonatomic) IBOutlet UILabel *huoNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *attentionNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *editInfoButton;
@property (weak, nonatomic) IBOutlet UIButton *attentionButton;
@property (nonatomic, copy) NSArray *array;
@property (nonatomic, strong) ChangeInforModel *information;

@property (nonatomic, strong)UILabel *messageLabel;


@end

@implementation MyHomepageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableView.tableFooterView = [UIView new];
    if (![self isMyHomepage]) {
        _array = [NSArray arrayWithObjects:@"TA的训练", @"TA的话题", @"TA的收藏", @"TA的帖子", nil];
        _editInfoButton.hidden = YES;
    } else{
        _array = [NSArray arrayWithObjects:@"我的训练", @"我的话题", @"我的收藏", @"我的帖子", @"每日记录", @"热量查询", @"身体数据", @"设置", nil];
        _editInfoButton.hidden = NO;
    }
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = 29;
    
    [_tableView registerNib:[UINib nibWithNibName:@"MyHomeCell" bundle:nil] forCellReuseIdentifier:@"MyHomeCell"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
         // 这里判断是否第一次
        [self firstSave];
    }
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"UserHomePage"];
    [MessageUnreadCommentModel unreadMessage:^(MessageUnreadCommentModel *object, NSString *msg) {
        NSInteger allNum = [object.allNum integerValue];
       
        if (allNum > 0) {
            
            if (allNum>99) {
                
                allNum=99;
            }
            
            [self receivedMessages:allNum];
        } else {
            _messageLabel.text=nil;
            _messageLabel.hidden=YES;
        }
    }];

}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"UserHomePage"];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchUserInfo];
}
- (void)fetchUserInfo {
    NSString *userId;
    if (![self isMyHomepage]) {
        userId = _friendId;
    } else {
        userId = nil;
    }
    [ChangeInforModel fetchUserInformation:userId handler:^(ChangeInforModel *object, NSString *msg) {
        if (!msg) {
            _information = object;
            _nicknameLabel.text = [NSString stringWithFormat:@"%@", object.nickname];
            _introduceLabel.text = [NSString stringWithFormat:@"%@", object.introduce];
            _huoNumberLabel.text = [NSString stringWithFormat:@"%@", object.score];
            _attentionNumberLabel.text = [NSString stringWithFormat:@"%@", object.AttentionNum];
            _fansNumberLabel.text = [NSString stringWithFormat:@"%@", object.fansNum];
            if ([object.sex integerValue] == 1) {
                _sexImageView.image = [UIImage imageNamed:@"info_man_sex"];
            } else {
                _sexImageView.image = [UIImage imageNamed:@"info_sex_women"];
            }
            [_headImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[Util urlZoomPhoto:object.portrait]]] placeholderImage:[UIImage imageNamed:@"default_headportrait"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                UIImage *effectImage = [image applyLightEffect];
                [_headImageView setImage:image];
                [_headBackgroundImage setImage:effectImage];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            }];
            if (![self isMyHomepage]) {
                _attentionButton.hidden = NO;
                switch ([object.flag integerValue]) {
                    case 1:
                        [_attentionButton setBackgroundImage:[UIImage imageNamed:@"add_attention"] forState:UIControlStateNormal];
                        break;
                    case 2:
                        [_attentionButton setBackgroundImage:[UIImage imageNamed:@"each_attention"] forState:UIControlStateNormal];
                        break;
                    case 3:
                        [_attentionButton setBackgroundImage:[UIImage imageNamed:@"add_attention"] forState:UIControlStateNormal];
                        break;
                    case 4:
                        [_attentionButton setBackgroundImage:[UIImage imageNamed:@"is_attention"] forState:UIControlStateNormal];
                        break;
                        
                    default:
                        break;
                }
            } else {
                _attentionButton.hidden = YES;
            }
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self isMyHomepage] ? 3 : 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"MyHomepageCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
   
    MyHomeCell *cell=[tableView dequeueReusableCellWithIdentifier:@"MyHomeCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case 0:{
            cell.titleLabel.text = _array[indexPath.row];
            cell.textNewLabel.hidden=YES;
            cell.redImageView.hidden=YES;
            if (indexPath.row == 0) {
                cell.headImageView.image = [UIImage imageNamed:@"mine_training"];
            } else if (indexPath.row == 1) {
                cell.headImageView.image = [UIImage imageNamed:@"mine_photos"];
            } else if (indexPath.row == 2) {
                cell.headImageView.image = [UIImage imageNamed:@"mine_favorite"];
            } else {
                cell.headImageView.image = [UIImage imageNamed:@"mine_cards"];
            }
        }
            break;
        case 1:{
            cell.titleLabel.text = _array[indexPath.row + 4];
            cell.textNewLabel.hidden=YES;
            cell.redImageView.hidden=YES;
            NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
            NSInteger one = [userDefaultes integerForKey:@"oneLabel"];
            NSInteger two = [userDefaultes integerForKey:@"twoLabel"];
            if (indexPath.row == 0) {
                if (one == 10) {
                cell.textNewLabel.hidden = NO;
                cell.redImageView.hidden =NO;
                cell.textNewLabel.tag=indexPath.row+10;
            
                cell.redImageView.layer.masksToBounds = YES;
                cell.redImageView.layer.cornerRadius = 4.0;
                cell.redImageView.tag = indexPath.row + 20;

                }
                cell.headImageView.image = [UIImage imageNamed:@"mine_record"];
            } else {
                if (two==20) {
                    
                    cell.textNewLabel.hidden = NO;
                    cell.textNewLabel.tag = indexPath.row+10;
                    cell.redImageView.hidden = NO;
                    cell.redImageView.layer.masksToBounds = YES;
                    cell.redImageView.layer.cornerRadius = 4.0;
                    cell.redImageView.tag = indexPath.row+20;
                    
                }
                cell.headImageView.image = [UIImage imageNamed:@"mine_kcal"];
            }
        }
            break;
        case 2:{
            cell.titleLabel.text = _array[indexPath.row + 7];
            cell.headImageView.image = [UIImage imageNamed:@"mine_setting"];
            cell.textNewLabel.hidden=YES;
            cell.redImageView.hidden=YES;
        }
            break;
            
        default:
            break;
    }
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 12)];
    headerView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 0) {
                UsersTrendsViewController *viewController = [[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"UsersTrendsView"];
                viewController.friendId = _friendId;
                [self.navigationController pushViewController:viewController animated:YES];
                
            } else if (indexPath.row == 1) {
                UsersTopicViewController *viewController = [[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"UsersTopicView"];
                viewController.friendId = _friendId;
                [self.navigationController pushViewController:viewController animated:YES];
                
            } else if (indexPath.row == 2) {
                UsersCollectionViewController *viewController = [[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"UsersCollectionView"];
                viewController.friendId = _friendId;
                [self.navigationController pushViewController:viewController animated:YES];
            } else {
                UserCardsViewController *cardViewController = [[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"UserCardsView"];
                if (_friendId) {
                    cardViewController.userId = _friendId;
                } else {
                    cardViewController.userId = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
                }
                [self.navigationController pushViewController:cardViewController animated:YES];
                
            }
        }
            
            break;
        case 1: {
            if (indexPath.row == 0) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                UILabel *oneLabel=(UILabel*)[cell.contentView viewWithTag:10];
                [oneLabel removeFromSuperview];
                UILabel *twoLabel=(UILabel*)[cell.contentView viewWithTag:20];
                [twoLabel removeFromSuperview];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"oneLabel"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                DailyRecordViewController *viewController = [[DailyRecordViewController alloc] init];
                [self.navigationController pushViewController:viewController animated:YES];
            } else {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
              
                UILabel *oneLabel=(UILabel*)[cell.contentView viewWithTag:11];
                [oneLabel removeFromSuperview];
                UILabel *twoLabel=(UILabel*)[cell.contentView viewWithTag:21];
                [twoLabel removeFromSuperview];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"twoLabel"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                EnergySearchViewController *viewController = [[EnergySearchViewController alloc] init];
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
            
            break;
        case 2: {
            PersonalViewController *personalView = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"PersonalInfoView"];
            [self.navigationController pushViewController:personalView animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    if (y < 0) {
        _headBackgroundImageTopConstraint.constant = 0;
        _headBackgroundImageHeightConstraint.constant = 230 - y;
        _backViewTopConstraint.constant = 0;
        _backViewHeightConstraint.constant = 230 - y;
    } else {
        _headBackgroundImageTopConstraint.constant = - y;
        _headBackgroundImageHeightConstraint.constant = 230;
        _backViewTopConstraint.constant = - y;
        _backViewHeightConstraint.constant = 230;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)editInfomationButtonClick:(id)sender {
    EditInformationViewController *modiFyDataVc = [[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"EditInformationView"];
    if ([_information.height integerValue] == 0) {
        _information.height = @"170";
    }
    if ([_information.weight integerValue] == 0) {
        _information.weight = @"60";
    }
    modiFyDataVc.informationModel = _information;
    [self.navigationController pushViewController:modiFyDataVc animated:YES];

}
- (IBAction)fansNumButtonClick:(id)sender {
    FansViewController *fansVc=[[UIStoryboard storyboardWithName:@"Fans" bundle:nil] instantiateViewControllerWithIdentifier:@"fansView"];
    fansVc.frendid = _friendId;
    [self.navigationController pushViewController:fansVc animated:YES];
}
- (IBAction)attentionNumButtonClick:(id)sender {
    AttentionViewController *attentionVc=[[UIStoryboard storyboardWithName:@"Attention" bundle:nil] instantiateViewControllerWithIdentifier:@"attentionView"];
    attentionVc.frendid = _friendId;
    [self.navigationController pushViewController:attentionVc animated:YES];
}
- (IBAction)attentionButtonClick:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    switch ([_information.flag integerValue]) {
        case 1:{
            [AddAttentionModel addAttentionWithfrendid:_friendId handler:^(id object, NSString *msg) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (!msg) {
                    [_attentionButton setBackgroundImage:[UIImage imageNamed:@"is_attention"] forState:UIControlStateNormal];
                    _information.flag = @(4);
                }
            }];
        } break;
        case 2:{
            [AddAttentionModel cancelAttentionWithFriendId:_friendId handler:^(id object, NSString *msg) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (!msg) {
                    [_attentionButton setBackgroundImage:[UIImage imageNamed:@"add_attention"] forState:UIControlStateNormal];
                    _information.flag = @(3);
                }
            }];
        } break;
        case 3:{
            [AddAttentionModel addAttentionWithfrendid:_friendId handler:^(id object, NSString *msg) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (!msg) {
                    [_attentionButton setBackgroundImage:[UIImage imageNamed:@"each_attention"] forState:UIControlStateNormal];
                    _information.flag = @(2);
                }
            }];
        } break;
        case 4:{
            [AddAttentionModel cancelAttentionWithFriendId:_friendId handler:^(id object, NSString *msg) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (!msg) {
                    [_attentionButton setBackgroundImage:[UIImage imageNamed:@"add_attention"] forState:UIControlStateNormal];
                    _information.flag = @(1);
                }else {
                    
                }
            }];
        } break;
        default:
            break;
    }

}

- (UIView *)titleViewForTabbarNav {
    return nil;
}

- (NSString *)titleForTabbarNav {
    if ([self isMyHomepage]) {
        return @"我的主页";
    } else {
        return @"TA的主页";
    }
}

-(NSArray *)leftButtonsForTabbarNav {
    if ([self isMyHomepage]) {
        UIBarButtonItem *blackListButton = [[UIBarButtonItem alloc] initWithTitle:@"黑名单" style:UIBarButtonItemStylePlain target:self action:@selector(blackListButtonClick)];
        return @[blackListButton];
    } else {
        return nil;
    }
}

- (NSArray *)rightButtonsForTabbarNav{
    if ([self isMyHomepage]) {
        
        UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-64,0,64,44)];
        rightButton.tintColor=[UIColor redColor];
        [rightButton setImage:[UIImage imageNamed:@"rightbar_message"]forState:UIControlStateNormal];
        
        if (_messageLabel) {
            
        }else
        {
            _messageLabel=[[UILabel alloc]init];
        }
        _messageLabel.hidden=YES;
        if (!_messageLabel.text.length==0) {
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
        
    } else {
        return nil;
   }
}
- (void)blackListButtonClick {
    BlackListViewController *blackListView = [[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"BlackView"];
    [self.navigationController pushViewController:blackListView animated:YES];
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
- (BOOL)isMyHomepage {
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    if (!_friendId || [_friendId isEqualToString:userid]) {
        return YES;
    } else {
        return NO;
    }
}
-(void)firstSave
{
    //存储数据
    [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"oneLabel"];
    //存储数据
    [[NSUserDefaults standardUserDefaults] setInteger:20 forKey:@"twoLabel"];
}
@end
