//
//  TopicDetailViewController.m
//  fitplus
//
//  Created by xlp on 15/11/30.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "TopicDetailViewController.h"
#import "RBColorTool.h"
#import <UIImageView+AFNetworking.h>
#import "Util.h"
#import "TopicPhotoCell.h"
#import "ClockInDetailViewController.h"
#import "SendPhotoViewController.h"
#import "PhotoEditViewController.h"
#import <TuSDK/TuSDK.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ClockInDetailModel.h"
#import "AttentionClockinContentCell.h"
#import <ShareSDK/ShareSDK.h>
#import "MyHomepageViewController.h"
#import "RecommendationModel.h"
#import "LimitResultModel.h"
#import <MJRefresh.h>
#import <TuSDKGeeV1/TuSDKGeeV1.h>

@interface TopicDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AttentionClockInDelegate>
@property (nonatomic, strong) UIImage *shadowImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UILabel *topicNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *popularityLabel;
@property (weak, nonatomic) IBOutlet UILabel *usersLabel;
@property (weak, nonatomic) IBOutlet UILabel *photosLabel;
@property (weak, nonatomic) IBOutlet UILabel *ruleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainImageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *navigationImage;
@property (weak, nonatomic) IBOutlet UILabel *navigationTitleLabel;

@property (strong, nonatomic) UIButton *recommendButton;
@property (strong, nonatomic) UIButton *recentButton;
@property (strong, nonatomic) UILabel *selectedLabel;
@property (strong, nonatomic) UIImagePickerController *cameraController;
@property (strong, nonatomic) UIButton *chooseAlbumButton;
@property (nonatomic, strong) UIView *tipPhotoView;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSMutableArray *recommendedArray;
@property (nonatomic, strong) NSMutableArray *recentArray;
@property (nonatomic, assign) NSInteger page;

@end

@implementation TopicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendInformationSuccess) name:ClockInOverNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takedPhoto:) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rejectedPhoto:) name:@"_UIImagePickerControllerUserDidRejectItem" object:nil];
    _shadowImage = self.navigationController.navigationBar.shadowImage;
    CGSize ruleSize = [_topicModel.desc boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 28, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14], NSFontAttributeName, nil] context:nil].size;
    _tableView.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 147 + ruleSize.height);
    
    _selectedIndex = 1;
    _mainImage.clipsToBounds = YES;
    [_mainImage setImageWithURL:[NSURL URLWithString:[Util urlPhoto:_topicModel.pic]] placeholderImage:[UIImage imageNamed:@"default_image"]];
    _topicNameLabel.text = [NSString stringWithFormat:@"#%@#", _topicModel.title];
    _popularityLabel.text = [NSString stringWithFormat:@"点击%@", @(_topicModel.tag_num)];
    _usersLabel.text = [NSString stringWithFormat:@"参与%@", @(_topicModel.attend_num)];
    _photosLabel.text = [NSString stringWithFormat:@"发布%@", @(_topicModel.pic_num)];
    _ruleLabel.text = [NSString stringWithFormat:@"%@", _topicModel.desc];
    
    [_tableView setFooter:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (_selectedIndex == 2) {
             [self fetchRecentTrend];
        }
    }]];
    _tableView.footer.hidden = YES;
    [self fetchDetail];
    _page = 1;
    //[self fetchRecentTrend];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:IsFirstOpenVideo] == 1) {
        [self setupTipView];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"_UIImagePickerControllerUserDidRejectItem" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ClockInOverNotificationKey object:nil];
    
}
- (void)setupTipView {
    _tipPhotoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tipPhotoView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:_tipPhotoView];
    UIButton *knowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    knowButton.frame = CGRectMake(SCREEN_WIDTH / 2 - 52, SCREEN_HEIGHT - 320, 104, 32);
    [knowButton setBackgroundImage:[UIImage imageNamed:@"guide_button"] forState:UIControlStateNormal];
    [knowButton addTarget:self action:@selector(knownButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_tipPhotoView addSubview:knowButton];
    
    UIImageView *tipImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 150, SCREEN_HEIGHT - 290, 300, 230)];
    tipImage.image = [UIImage imageNamed:@"tip_take_photo"];
    [_tipPhotoView addSubview:tipImage];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 25, SCREEN_HEIGHT - 70, 50, 50)];
    image.image = [UIImage imageNamed:@"topic_camera"];
    [_tipPhotoView addSubview:image];
}
- (void)fetchDetail {
    [TopicModel fetchOneTopicDetail:_topicModel.id recommendationId:_topicModel.recommedId handler:^(id object, NSString *msg) {
        if (!msg) {
            _recommendedArray = [object[@"list"][@"hostList"] mutableCopy];
            [_tableView reloadData];
        }
    }];
}
- (void)fetchRecentTrend {
    [RecommendationModel fetchOneTopicRecentTrend:_topicModel.id page:_page handler:^(LimitResultModel *object, NSString *msg) {
        [_tableView.footer endRefreshing];
        if (!msg) {
            if (_page == 1) {
                _recentArray = [object.result mutableCopy];
            } else {
                NSMutableArray *tempArray = [_recentArray mutableCopy];
                [tempArray addObjectsFromArray:[object.result mutableCopy]];
                _recentArray = tempArray;
            }
            if (_selectedIndex == 2) {
                [_tableView reloadData];
            }
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_selectedIndex == 1) {
        return _recommendedArray.count % 2 == 0 ? _recommendedArray.count / 2 : _recommendedArray.count / 2 + 1;
    } else {
        return _recentArray.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedIndex == 1) {
        return 27 + SCREEN_WIDTH / 2;
    } else {
        return [[AttentionClockinContentCell new] cellHeightWithDic:[_recentArray objectAtIndex:indexPath.row]];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    headerView.backgroundColor = [UIColor whiteColor];
    _recommendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recommendButton.frame = CGRectMake(0, 0, SCREEN_WIDTH / 2, 42);
    _recommendButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_recommendButton setTitle:@"推荐" forState:UIControlStateNormal];
    [_recommendButton setTitleColor:[UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_recommendButton setTitleColor:[UIColor colorWithRed:81/255.0 green:81/255.0 blue:81/255.0 alpha:1.0] forState:UIControlStateSelected];
    [_recommendButton addTarget:self action:@selector(recommendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:_recommendButton];
    
    _recentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recentButton.frame = CGRectMake(SCREEN_WIDTH / 2, 0, SCREEN_WIDTH / 2, 42);
    _recentButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_recentButton setTitle:@"最新" forState:UIControlStateNormal];
    [_recentButton setTitleColor:[UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_recentButton setTitleColor:[UIColor colorWithRed:81/255.0 green:81/255.0 blue:81/255.0 alpha:1.0] forState:UIControlStateSelected];
    [_recentButton addTarget:self action:@selector(recentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:_recentButton];
    _selectedLabel = [[UILabel alloc] init];
    _selectedLabel.backgroundColor = [UIColor colorWithRed:126/255.0 green:186/255.0 blue:194/255.0 alpha:1.0];
    [headerView addSubview:_selectedLabel];
    if (_selectedIndex == 1) {
        _recommendButton.selected = YES;
        _recentButton.selected = NO;
        _selectedLabel.frame = CGRectMake(SCREEN_WIDTH / 4 - 24, 42, 48, 2);
    } else {
        _recommendButton.selected = NO;
        _recentButton.selected = YES;
        _selectedLabel.frame = CGRectMake(3 * SCREEN_WIDTH / 4 - 24, 42, 48, 2);
    }
    return headerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedIndex == 1) {
        static NSString *CellIdentifier = @"TopicPhotoCell";
        TopicPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (indexPath.row * 2 + 1 >= _recommendedArray.count) {
            [cell setupContent:_recommendedArray[indexPath.row * 2] right:nil];
        } else {
            [cell setupContent:_recommendedArray[indexPath.row * 2] right:_recommendedArray[indexPath.row * 2 + 1]];
        }
        [cell photoClick:^(NSInteger index) {
            ClockInDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Square" bundle:nil] instantiateViewControllerWithIdentifier:@"ClockInDetailView"];
            if (index == 1) {
                detailViewController.clockinId = _recommendedArray[indexPath.row * 2][@"id"];
            } else {
                detailViewController.clockinId = _recommendedArray[indexPath.row * 2 + 1][@"id"];
            }
            [detailViewController trendDelete:^{
                if (_selectedIndex == 1) {
                    [self fetchDetail];
                }
            }];
            [self.navigationController pushViewController:detailViewController animated:YES];
            
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        static NSString *CellIdentifier = @"ClockinContentCell";
        AttentionClockinContentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell setupCellViewWithDic:_recentArray[indexPath.row]];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedIndex == 2) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ClockInDetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Square" bundle:nil] instantiateViewControllerWithIdentifier:@"ClockInDetailView"];
        ClockInDetailModel *model = [_recentArray objectAtIndex:indexPath.row];
        detailVC.clockinId = model.id;
        [detailVC trendDelete:^{
            [_recentArray removeObjectAtIndex:indexPath.row];
            [_tableView reloadData];
        }];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    if (y < 0) {
        _mainImageTopConstraint.constant = - y;
        _topViewTopConstraint.constant = - y;
    } else {
        _mainImageTopConstraint.constant = - y;
        _topViewTopConstraint.constant = - y;
    }
    
    NSInteger oldPostionY = 0;
    NSInteger currentPostionY = scrollView.contentOffset.y;
    if (currentPostionY > oldPostionY && (currentPostionY - oldPostionY) > 5) {
        oldPostionY = currentPostionY;
//        [self.navigationController.navigationBar setBackgroundImage:[RBColorTool imageWithColor:[UIColor colorWithRed:0.234 green:0.180 blue:0.292 alpha:1.000]]
//                                                      forBarMetrics:UIBarMetricsDefault];
//        self.navigationController.navigationBar.translucent = NO;
//        self.navigationController.navigationBar.shadowImage = _shadowImage;
        _navigationImage.image = [RBColorTool imageWithColor:[UIColor colorWithRed:0.234 green:0.180 blue:0.292 alpha:1.000]];
        _navigationTitleLabel.text = [NSString stringWithFormat:@"%@", _topicModel.title];
    } else if (currentPostionY < oldPostionY && (oldPostionY - currentPostionY) > 5) {
        oldPostionY = currentPostionY;
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"drysaltery_detail_header"] forBarMetrics:UIBarMetricsDefault];
//        self.navigationController.navigationBar.shadowImage = [UIImage new];
//        self.navigationController.navigationBar.translucent = YES;
        _navigationImage.image = [UIImage imageNamed:@"drysaltery_detail_header"];
        _navigationTitleLabel.text = nil;
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
#pragma mark - AttentionClockInDelegate
- (void)clickComment:(NSString *)trendId {
    ClockInDetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Square" bundle:nil] instantiateViewControllerWithIdentifier:@"ClockInDetailView"];
    detailViewController.isCommentIn = YES;
    detailViewController.clockinId = trendId;
    [detailViewController trendDelete:^{
        for (ClockInDetailModel *model in _recentArray) {
            if ([model.id isEqualToString:trendId]) {
                [_recentArray removeObject:model];
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
- (IBAction)recommendButtonClick:(id)sender {
    _tableView.footer.hidden = YES;
    if (!_recommendButton.selected) {
        _selectedIndex = 1;
        [_tableView reloadData];
    }
}
- (IBAction)recentButtonClick:(id)sender {
    _tableView.footer.hidden = NO;
    if (!_recentButton.selected) {
        _selectedIndex = 2;
        if (_recentArray.count > 0) {
            [_tableView reloadData];
        } else {
            [self fetchRecentTrend];
        }
    }
}
- (IBAction)takePhotoButtonClick:(id)sender {
    [self showPhotoView];
}

- (void)showPhotoView {
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 100, SCREEN_WIDTH, 100)];
    toolView.backgroundColor = [UIColor blackColor];
    UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    takePhotoButton.frame = CGRectMake((SCREEN_WIDTH - 80) / 2, SCREEN_HEIGHT - 80, 80, 80);
    takePhotoButton.backgroundColor = [UIColor whiteColor];
    [toolView addSubview:takePhotoButton];

    if (!_cameraController) {
        _cameraController = [[UIImagePickerController alloc] init];
        _cameraController.delegate = self;
        _cameraController.allowsEditing = YES;
        _cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
        _chooseAlbumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chooseAlbumButton addTarget:self action:@selector(showAlbum) forControlEvents:UIControlEventTouchUpInside];
    }
    [self presentViewController:_cameraController animated:YES completion:^{

        CGPoint origin = CGPointZero;
        CGFloat width = 0;
        for (UIView *subview in _cameraController.view.subviews) {
            if([NSStringFromClass([subview class]) isEqualToString:@"UINavigationTransitionView"]) {
                UIView *theView = (UIView *)subview;
                for (UIView *subview in theView.subviews) {
                    if([NSStringFromClass([subview class]) isEqualToString:@"UIViewControllerWrapperView"]) {
                        UIView *theView = (UIView *)subview;
                        for (UIView *subview in theView.subviews) {
                            if([NSStringFromClass([subview class]) isEqualToString:@"PLImagePickerCameraView"] || [NSStringFromClass([subview class]) isEqualToString:@"PLCameraView"]) {
                                UIView *theView = (UIView *)subview;
                                for (UIView *subview in theView.subviews) {
                                    if([NSStringFromClass([subview class]) isEqualToString:@"CMKBottomBar"] || [NSStringFromClass([subview class]) isEqualToString:@"CAMBottomBar"]) {
                                        UIView *theView = (UIView *)subview;
                                        for (UIView *view in theView.subviews) {
                                            if ([view isKindOfClass:NSClassFromString(@"CMKShutterButton")] || [view isKindOfClass:NSClassFromString(@"CAMShutterButton")]) {
                                                origin = view.frame.origin;
                                                origin.y += CGRectGetMinY(view.superview.frame);
                                                width = CGRectGetWidth(view.frame);
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        _chooseAlbumButton.frame = CGRectMake(SCREEN_WIDTH - width - 20, origin.y, width, width);
        [_cameraController.view addSubview:_chooseAlbumButton];

        [[ALAssetsLibrary defaultLibrary] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                NSUInteger index = [group numberOfAssets] - 1;
                NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
                [group enumerateAssetsAtIndexes:set options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        [_chooseAlbumButton setBackgroundImage:[UIImage imageWithCGImage:[[result defaultRepresentation] fullResolutionImage]] forState:UIControlStateNormal];
                        *stop = YES;
                    }
                }];
                *stop = YES;
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"get album photo failed %@", error.description);
        }];

    }];
}
- (void)showAlbum {
    [self dismissViewControllerAnimated:NO completion:^{
        UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerVC.delegate = self;
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        //[self openEditWithImage:image];
        SendPhotoViewController *photoViewController = [[UIStoryboard storyboardWithName:@"ClockIn" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoView"];
        photoViewController.image = image;
        photoViewController.topicId = _topicModel.id;
        [self.navigationController pushViewController:photoViewController animated:YES];

    }];
}
- (void)sendInformationSuccess {
    if (_selectedIndex == 2) {
        _page = 1;
        [self fetchRecentTrend];
    } else {
        [self fetchDetail];
    }
}
- (void)takedPhoto:(NSDictionary *)userInfo {
    [_chooseAlbumButton removeFromSuperview];
}

- (void)rejectedPhoto:(NSDictionary *)userInfo {
    [_cameraController.view addSubview:_chooseAlbumButton];
}
- (IBAction)backButtonClick:(id)sender {
    [self popViewControllerAnimated:YES];
}
- (void)knownButtonClick {
    [_tipPhotoView removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:IsFirstOpenVideo];
}

@end
