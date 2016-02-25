//
//  CourseTrainingViewController.m
//  fitplus
//
//  Created by xlp on 15/10/8.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "CourseTrainingViewController.h"
#import "CircleProgressView.h"
#import "VideoModel.h"
#import <AVFoundation/AVFoundation.h>
#import "Util.h"
#import <UIImageView+AFNetworking.h>
#import "TipCloseView.h"
#import "RBBlockAlertView.h"
#import "CourseModel.h"
#import "FinishCourseTipView.h"
#import <MBProgressHUD.h>
#import "InformationModel.h"
#import <ShareSDK/ShareSDK.h>
#import "DownloadVideo.h"

@interface CourseTrainingViewController ()<AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewOfPlayer;
@property (weak, nonatomic) IBOutlet UILabel *actionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *allActionTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *currenProgressView;
@property (weak, nonatomic) IBOutlet CircleProgressView *circleProgressView;
@property (weak, nonatomic) IBOutlet UIView *crossCircleBackView;
@property (weak, nonatomic) IBOutlet CircleProgressView *crossCircleProgressView;
@property (weak, nonatomic) IBOutlet UILabel *actionProgressLabel;
@property (weak, nonatomic) IBOutlet UILabel *crossActionTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *crossActionProgressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentProgressWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewOfPlayerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewBottomConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *finishViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *greatLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showButtonCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleViewHeightconstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseImageRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseTitleLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseTitleTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseLevelLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseTipLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseKeyLegtConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleProgressViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *pauseView;
@property (weak, nonatomic) IBOutlet UIImageView *pauseViewImage;
@property (weak, nonatomic) IBOutlet UILabel *pauseTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pauseLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *pauseBodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *pauseKeyLabel;
@property (weak, nonatomic) IBOutlet UILabel *restTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *restLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *restBodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *restKeyLabel;
@property (weak, nonatomic) IBOutlet UIView *restView;
@property (weak, nonatomic) IBOutlet UILabel *restBackcountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rankImageView;
@property (weak, nonatomic) IBOutlet UILabel *energyLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *showButton;
@property (weak, nonatomic) IBOutlet UIButton *crossStartButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *closeBackView;
@property (nonatomic, strong) FinishCourseTipView *finishTipView;
@property (nonatomic, strong) TipCloseView *tipView;
@property (assign, nonatomic) NSInteger nowGroup;
@property (assign, nonatomic) NSInteger currentGroupNum;
@property (assign, nonatomic) NSInteger currentTime;
@property (assign, nonatomic) NSInteger allPregressTime;
@property (assign, nonatomic) NSInteger allActionCurrentTime;
@property (assign, nonatomic) NSInteger counterNumber;
@property (strong, nonatomic) NSMutableArray *actionArray;
@property (assign, nonatomic) NSInteger currentAction;
@property (strong, nonatomic) NSTimer *circleProgressTimer;
@property (strong, nonatomic) NSTimer *counterTimer;
@property (strong, nonatomic) NSTimer *restCounterTimer;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (copy, nonatomic) NSString *playerUrl;
@property (assign, nonatomic) NSInteger restCountNumber;
@property (assign, nonatomic) NSInteger selectedDifficulty;
@property (strong, nonatomic) InformationModel *userInformation;

@property (strong, nonatomic) AVAudioPlayer *actionAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *actionNameAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *togetherGroupsAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *timesAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *firstGroupAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *backwardsAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *nextOrLastGroupAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *countNumberAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *restAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *backgroundMusicPlayer;
@property (strong, nonatomic) AVAudioPlayer *finishAudioPlayer;
@property (assign, nonatomic) NSInteger canOrientations;

@end

@implementation CourseTrainingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _canOrientations = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedShare) name:@"FinishShare" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundPause) name:@"EnterBackground" object:nil];
    if (SCREEN_HEIGHT <= 480) {
        _circleProgressViewTopConstraint.constant = 2;
        _circleViewHeightconstraint.constant = 105;
        _circleViewWidthConstraint.constant = 105;
    } else {
        _circleProgressViewTopConstraint.constant = 35;
        _circleViewHeightconstraint.constant = 120;
        _circleViewWidthConstraint.constant = 120;
    }
    
    _finishViewTopConstraint.constant = SCREEN_HEIGHT;
    _crossCircleBackView.layer.masksToBounds = YES;
    _crossCircleBackView.layer.cornerRadius = 46.0;
    
    _playerUrl = @"";
    _playerItem = [self getPlayerItem:_playerUrl];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, 180);
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_viewOfPlayer.layer addSublayer:_playerLayer];
    
    
    if (_progressView.layer.cornerRadius != 4.0) {
        _progressView.layer.masksToBounds = YES;
        _progressView.layer.cornerRadius = 4.0;
    }
    if (_currenProgressView.layer.cornerRadius != 4.0) {
        _currenProgressView.layer.masksToBounds = YES;
        _currenProgressView.layer.cornerRadius = 4.0;
    }
    [_restView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(restViewGR)]];
    _restView.userInteractionEnabled = YES;
    
    _actionArray = _actionDictionary[@"resolve_list"];
    _nowGroup = 0;
    _currentAction = 0;
    _allActionCurrentTime = 0;
    _allPregressTime = 0;
    
    [self setupVideoView];
    [self setupPauseView];

}
- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (_canOrientations == 0) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGFloat totalTime = [_actionDictionary[@"total_time"] floatValue];
    _currentProgressWidthConstraint.constant = (SCREEN_HEIGHT - 28) / totalTime * _allActionCurrentTime;
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (toInterfaceOrientation == UIDeviceOrientationLandscapeRight || toInterfaceOrientation == UIDeviceOrientationLandscapeLeft) {
        if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
            _viewOfPlayerHeightConstraint.constant = SCREEN_HEIGHT;
            _playerLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            _nextButtonBottomConstraint.constant = SCREEN_HEIGHT / 2 - 21;
            _lastButtonBottomConstraint.constant = SCREEN_HEIGHT / 2 - 21;
            _showButtonBottomConstraint.constant = SCREEN_HEIGHT / 2 - 17;
            if (_backView) {
                _backView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            }
            if (_closeBackView) {
                _closeBackView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            }
            _pauseImageRightConstraint.constant = SCREEN_WIDTH - SCREEN_HEIGHT + 10;
            _pauseTitleLeftConstraint.constant = SCREEN_HEIGHT + 10;
            _pauseLevelLeftConstraint.constant = SCREEN_HEIGHT + 10;
            _pauseTipLeftConstraint.constant = SCREEN_HEIGHT + 10;
            _pauseKeyLegtConstraint.constant = SCREEN_HEIGHT + 10;
        } else {
            _viewOfPlayerHeightConstraint.constant = SCREEN_WIDTH;
            _playerLayer.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
            _nextButtonBottomConstraint.constant = SCREEN_WIDTH / 2 - 21;
            _lastButtonBottomConstraint.constant = SCREEN_WIDTH / 2 - 21;
            _showButtonBottomConstraint.constant = SCREEN_WIDTH / 2 - 17;
            if (_backView) {
                _backView.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
            }
            if (_closeBackView) {
                _closeBackView.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
            }
            _pauseImageRightConstraint.constant = SCREEN_HEIGHT - SCREEN_WIDTH + 10;
            _pauseTitleLeftConstraint.constant = SCREEN_WIDTH + 10;
            _pauseLevelLeftConstraint.constant = SCREEN_WIDTH + 10;
            _pauseTipLeftConstraint.constant = SCREEN_WIDTH + 10;
            _pauseKeyLegtConstraint.constant = SCREEN_WIDTH + 10;
        }
        _pauseButtonHeightConstraint.constant = 60;
        _pauseButtonWidthConstraint.constant = 60;
        _progressViewBottomConstarint.constant = 0;
        _greatLabelTopConstraint.constant = 10;
        _showButtonCenterConstraint.constant = 190;
        _pauseTitleTopConstraint.constant = 45;
        _pauseButton.hidden = YES;
        _crossStartButton.hidden = NO;
        _crossCircleBackView.hidden = NO;
        
    } else {
        _playerLayer.frame = CGRectMake(0, 0, SCREEN_HEIGHT, 180);
        _viewOfPlayerHeightConstraint.constant = 180;
        _progressViewBottomConstarint.constant = 151;
        _nextButtonBottomConstraint.constant = 50;
        _lastButtonBottomConstraint.constant = 50;
        _greatLabelTopConstraint.constant = 110;
        _showButtonBottomConstraint.constant = 35;
        _showButtonCenterConstraint.constant = 0;
        if (_backView) {
            _backView.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
        }
        if (_closeBackView) {
            _closeBackView.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
        }
        _pauseImageRightConstraint.constant = 10;
        _pauseTitleLeftConstraint.constant =  25;
        _pauseLevelLeftConstraint.constant = 25;
        _pauseTipLeftConstraint.constant = 25;
        _pauseKeyLegtConstraint.constant = 25;
        _pauseTitleTopConstraint.constant = 240;
        _pauseButtonHeightConstraint.constant = 80;
        _pauseButtonWidthConstraint.constant = 80;
        _pauseButton.hidden = NO;
        _crossStartButton.hidden = YES;
        _crossCircleBackView.hidden = YES;
    }
    _finishTipView.frame = CGRectMake(CGRectGetWidth(_backView.frame) / 2 - 135, CGRectGetHeight(_backView.frame) / 2 - 110, 270, 206);
    _tipView.frame = CGRectMake(CGRectGetWidth(_closeBackView.frame) / 2 - 135, CGRectGetHeight(_closeBackView.frame) / 2 - 90, 270, 165);
    
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    VideoModel *videoModel = [_videoArray lastObject];
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp3", docDirPath, videoModel.id];
    NSFileManager *fileManeger = [NSFileManager defaultManager];
    if ([fileManeger fileExistsAtPath:filePath]) {
        [self setupCounterTimer];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __block NSInteger i = 0;
        dispatch_queue_t queue = dispatch_queue_create("download", NULL);
        dispatch_async(queue, ^{
            for (VideoModel *tempModel in _videoArray) {
                [self downloadAudioFile:tempModel];
                i += 1;
                if (i >= _videoArray.count) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self setupCounterTimer];
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    });
                    
                }
            }
        });
    }
    _canOrientations = 1;
    
}
-  (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //[UIDevice currentDevice].orientation = UIDeviceOrientationPortrait;
    //UIInterfaceOrientation
    _player = nil;
    [self clear];
    
}
- (void)setupCounterTimer {
    [_backgroundMusicPlayer stop];
    _backgroundMusicPlayer = nil;
    [_counterTimer invalidate];
    _currentGroupNum = 0;
    _counterNumber = 5;
    _actionProgressLabel.font = [UIFont systemFontOfSize:30];
    _actionProgressLabel.text = [NSString stringWithFormat:@"%@", @(_counterNumber)];
    _crossActionProgressLabel.font = [UIFont systemFontOfSize:25];
    _crossActionProgressLabel.text = [NSString stringWithFormat:@"%@", @(_counterNumber) ];
    VideoModel *model = _videoArray[_currentAction];
    NSURL *fileUrl;
    NSInteger delayTime = 7;
    if (_currentAction == 0) {
        //第一个动作
        if (_nowGroup == 0) {
            delayTime = 7;
            fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"first_action" ofType:@"mp3"]];
            _actionAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
            _actionAudioPlayer.delegate = self;
            //[_actionAudioPlayer prepareToPlay];
            [_actionAudioPlayer play];
        } else {
            delayTime = 2;
            if (_nowGroup == model.num - 1) {
                //最后一组
                fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"last_group" ofType:@"mp3"]];
            } else {
                //下一组
                fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"next_group" ofType:@"mp3"]];
            }
            _nextOrLastGroupAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
            _nextOrLastGroupAudioPlayer.delegate = self;
            [_nextOrLastGroupAudioPlayer play];
        }
    } else if (_currentAction == _videoArray.count - 1) {
        //最后一个动作
        if (_nowGroup == 0) {
            delayTime = 7;
            fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"last_action" ofType:@"mp3"]];
            _actionAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
            _actionAudioPlayer.delegate = self;
            //[_actionAudioPlayer prepareToPlay];
            [_actionAudioPlayer play];
        } else {
            delayTime = 2;
            if (_nowGroup == model.num - 1) {
                //最后一组
                fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"last_group" ofType:@"mp3"]];
            } else {
                //下一组
                fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"next_group" ofType:@"mp3"]];
            }
            _nextOrLastGroupAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
            [_nextOrLastGroupAudioPlayer play];
            
        }
    } else {
        if (_nowGroup == 0) {
            delayTime = 7;
            fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"next_action" ofType:@"mp3"]];
            _actionAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
            _actionAudioPlayer.delegate = self;
            //[_actionAudioPlayer prepareToPlay];
            [_actionAudioPlayer play];
        } else {
            delayTime = 2;
            if (_nowGroup == model.num - 1) {
                //最后一组
                fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"last_group" ofType:@"mp3"]];
            } else {
                //下一组
                fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"next_group" ofType:@"mp3"]];
            }
            _nextOrLastGroupAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
            _nextOrLastGroupAudioPlayer.delegate = self;
            [_nextOrLastGroupAudioPlayer play];
        }
    }
    _counterTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countBeforeStart) userInfo:nil repeats:YES];
    [_counterTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:delayTime]];
}
- (void)countBeforeStart {
    if (_counterNumber == 5) {
        NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"count_backwards_new" ofType:@"mp3"]];
        _backwardsAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
        _backwardsAudioPlayer.delegate = self;
        [_backwardsAudioPlayer play];
    }
    _actionProgressLabel.text = [NSString stringWithFormat:@"%@", @(_counterNumber)];
    _crossActionProgressLabel.text = [NSString stringWithFormat:@"%@", @(_counterNumber)];
    if (_counterNumber > 0) {
        _counterNumber -= 1;
    } else {
        [_counterTimer invalidate];
        _counterTimer = nil;
        [self setupCurrentGroup];
        [self circleProgress];
    }
}

- (void)circleProgress {
    _currentTime = 0;
    [_playerItem seekToTime:kCMTimeZero];
    [_player play];
    [self setBackgroundAudioPlayer];
    _circleProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCircleAction) userInfo:nil repeats:YES];
}
- (void)updateCircleAction {
    _currentTime += 1;
    _allActionCurrentTime += 1;
    _allPregressTime += 1;
    VideoModel *tempModel = _videoArray[_currentAction];
    NSInteger duration = 1;
    if (tempModel.type == 1) {
        duration = tempModel.duration;
    } else {
        duration = 1;
    }
    CGFloat progressF = (float)(_currentTime + 1) / (float)(tempModel.group_num * duration);
    [_circleProgressView updateProgressCircle:progressF];
    [_crossCircleProgressView updateProgressCircle:progressF];
    _actionTimeLabel.text = [self changeTimeString:_currentTime];
    _crossActionTimeLabel.text = [self changeTimeString:_currentTime];
    _allActionTimeLabel.text = [self changeTimeString:_allPregressTime];
    CGFloat totalTime = [_actionDictionary[@"total_time"] floatValue];
    _currentProgressWidthConstraint.constant = (SCREEN_WIDTH - 28) / totalTime * _allActionCurrentTime;
    [UIView animateWithDuration:1.0 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    if (_currentTime % duration == 0) {
        _currentGroupNum += 1;
        if (_currentGroupNum == tempModel.group_num) {
            [_circleProgressTimer invalidate];
            if (_currentAction != (_actionArray.count - 1)) {
                NSLog(@"不是最后一个动作");
                //_pauseView.hidden = NO;
                [self clear];
                _restCountNumber = [tempModel.intervals integerValue];
                _restView.hidden = NO;
                _restCounterTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(restcounterSelector) userInfo:nil repeats:YES];
                [self setRestAudioPlayer];
                if (_nowGroup == tempModel.num - 1) {
                    //最后一组
                    [self setupRestView];
                    _currentAction += 1;
                    [self endOfOneAction];
                    _nowGroup = 0;
                } else {
                    [self setupRestView];
                    [self endOfOneAction];
                    _nowGroup += 1;
                
                }
            } else {
                NSLog(@"最后一个动作");
                [self clear];
                if (_nowGroup == tempModel.num - 1) {
                    //最后一个动作的最后一组
                    [_player pause];
                    [self setFinishCourseAudioPlayer];
                    [self showFinishCourseTip];
                } else {
                    //最后一个动作，非最后一组
                    [self setRestAudioPlayer];
                    _restCountNumber = [tempModel.intervals integerValue];
                    [self setupRestView];
                    [self endOfOneAction];
                    _restView.hidden = NO;
                    _restCounterTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(restcounterSelector) userInfo:nil repeats:YES];
                    _nowGroup += 1;
                    
                }
            }
            
        } else {
            [self setupCurrentGroup];
        }
        
    }
    
}
- (void)restcounterSelector {
    _restBackcountLabel.text = [NSString stringWithFormat:@"%@", @(_restCountNumber)];
    if (_restCountNumber == 0) {
        [_restCounterTimer invalidate];
        _restCounterTimer = nil;
        _restView.hidden = YES;
        [self setupCounterTimer];
    } else {
        _restCountNumber --;
    }
}

- (void)setupCurrentGroup {
    VideoModel *model = _videoArray[_currentAction];
    if (model.type == 1) {
        NSURL *fileUrl;
        if (_currentGroupNum == 3) {
            fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"keep_abdo" ofType:@"mp3"]];
        } else if (_currentGroupNum == 7) {
            fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"attention_breathing" ofType:@"mp3"]];
        } else if (_currentGroupNum == model.group_num - 2) {
            fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"remaining_two_times" ofType:@"mp3"]];
        } else if (_currentGroupNum == model.group_num - 1) {
            fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"last_times" ofType:@"mp3"]];
        } else {
            fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@", @(_currentGroupNum + 1)] ofType:@"mp3"]];
        }
        _countNumberAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
        _countNumberAudioPlayer.delegate = self;
        [_countNumberAudioPlayer prepareToPlay];
        [_countNumberAudioPlayer play];
    } else {
        NSURL *fileUrl;
        if ((_currentGroupNum + 1) % 5 == 0) {
            fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"second%@", @(_currentGroupNum + 1)] ofType:@"mp3"]];
            _countNumberAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
            _countNumberAudioPlayer.delegate = self;
            [_countNumberAudioPlayer prepareToPlay];
            [_countNumberAudioPlayer play];
        }
    }
    
    _actionProgressLabel.font = [UIFont systemFontOfSize:20];
    NSString *string = [NSString stringWithFormat:@"%@", @(_currentGroupNum + 1)];
    NSString *groupString = [NSString stringWithFormat:@"%@/%@", string, @(model.group_num)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:groupString];
    [attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:42], NSFontAttributeName, [UIColor colorWithRed:87/255.0 green:172/255.0 blue:184/255.0 alpha:1.0], NSForegroundColorAttributeName, nil] range:NSMakeRange(0, [string length])];
    _actionProgressLabel.attributedText = attributedString;
    
    _crossActionProgressLabel.font = [UIFont systemFontOfSize:15];
    NSString *crossString = [NSString stringWithFormat:@"%@", @(_currentGroupNum + 1)];
    NSString *crossGroupString = [NSString stringWithFormat:@"%@/%@", crossString, @(model.group_num)];
    NSMutableAttributedString *crossAttributedString = [[NSMutableAttributedString alloc] initWithString:crossGroupString];
    [crossAttributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:28], NSFontAttributeName, [UIColor colorWithRed:87/255.0 green:172/255.0 blue:184/255.0 alpha:1.0], NSForegroundColorAttributeName, nil] range:NSMakeRange(0, [string length])];
    _crossActionProgressLabel.attributedText = crossAttributedString;
}
- (void)setupVideoView {
    NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private/Documents/Cache"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    VideoModel *tempModel = _videoArray[_currentAction];
    _actionNameLabel.text = [NSString stringWithFormat:@"%@ %@", @(_currentAction + 1), tempModel.video_name];
    if (![fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", tempModel.id]]]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadVideoSuccess:) name:@"DownloadSuccess" object:nil];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DownloadVideo new] downloadFileURL:tempModel.path fileName:[NSString stringWithFormat:@"%@.mp4", tempModel.id] tag:[tempModel.id integerValue]];
    } else {
        [self replaceCurrentItemWithUrl:[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", tempModel.id]]];
        [_player play];
    }
}
- (void)downloadVideoSuccess:(NSNotification *)notification {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private/Documents/Cache"];
    VideoModel *tempModel = _videoArray[_currentAction];
    [self replaceCurrentItemWithUrl:[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", tempModel.id]]];
    [_player play];
}

- (AVPlayerItem *)getPlayerItem:(NSString *)urlString {
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:urlString]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    return item;
}
- (void)playFinished:(NSNotification *)notification {
    NSLog(@"播放完成");
    AVPlayerItem *item = [notification object];
    [item seekToTime:kCMTimeZero];
    [_player play];
}
//替换播放地址
- (void)replaceCurrentItemWithUrl:(NSString*)urlString{
    if (urlString) {
        [_player replaceCurrentItemWithPlayerItem:[self getPlayerItem:urlString]];
    }
}
- (void)setupPauseView {
    VideoModel *tempModel = _videoArray[_currentAction];
    [_pauseViewImage setImageWithURL:[NSURL URLWithString:[Util urlPhoto:tempModel.picurl]] placeholderImage:[UIImage imageNamed:@"default_image"]];
    _pauseTitleLabel.text = tempModel.video_name;
    switch (_courseModel.courseModel) {
        case 1:{
            _pauseLevelLabel.text = @"初级";
        }
            break;
        case 2:{
            _pauseLevelLabel.text = @"中级";
        }
            break;
        case 3:{
            _pauseLevelLabel.text = @"高级";
        }
            break;
            
        default:
            break;
    }
    _pauseBodyLabel.text = [NSString stringWithFormat:@"%@", _courseModel.courseBody];
    _pauseKeyLabel.text = tempModel.content;
}
- (void)setupRestView {
    VideoModel *tempModel = _videoArray[_currentAction];
    VideoModel *nextModel;
    if (_nowGroup == tempModel.num - 1) {
        nextModel = _videoArray[_currentAction + 1];
    } else {
        nextModel = _videoArray[_currentAction];
    }
    _restTitleLabel.text = nextModel.video_name;
    switch (_courseModel.courseModel) {
        case 1:{
            _pauseLevelLabel.text = @"初级";
        }
            break;
        case 2:{
            _pauseLevelLabel.text = @"中级";
        }
            break;
        case 3:{
            _pauseLevelLabel.text = @"高级";
        }
            break;
            
        default:
            break;
    }
    _restBodyLabel.text = [NSString stringWithFormat:@"%@", _courseModel.courseBody];
    _restKeyLabel.text = nextModel.content;
    _restBackcountLabel.text = [NSString stringWithFormat:@"%@", @(_restCountNumber)];
}
- (NSString *)changeTimeString:(NSInteger)time {
    NSInteger second = time % 60;
    NSInteger minute = time / 60;
    if (time < 60) {
        return [NSString stringWithFormat:@"00:%02ld", (long)time];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minute, (long)second];
    }
}

/*
 训练结束展示
 */
- (void)showFinishCourseTip {
    _backView = [[UIView alloc] init];
//    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
//        _backView.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
//    } else {
    _backView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//    }
    [_backView setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
    [self.view addSubview:_backView];
    _finishTipView = [[FinishCourseTipView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_backView.frame) / 2 - 135, CGRectGetHeight(_backView.frame) / 2 - 110, 270, 206) clickBlock:^(NSInteger index) {
        //_currentAction = 0;
        _selectedDifficulty = index;
        [self setupFinishView];
        [_backView removeFromSuperview];
    }];
    [_backView addSubview:_finishTipView];
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
#pragma mark - AVAudioPlayer Delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (player == _actionAudioPlayer) {
        VideoModel *tempModel = _videoArray[_currentAction];
        NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSURL *fileUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.mp3", docDirPath, tempModel.id]];
        _actionNameAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
        _actionNameAudioPlayer.delegate = self;
        [_actionNameAudioPlayer prepareToPlay];
        [_actionNameAudioPlayer play];
        
    }
    if (player == _actionNameAudioPlayer) {
        VideoModel *tempModel = _videoArray[_currentAction];
        NSString *groupNumString = nil;
        if (tempModel.num == 1) {
            groupNumString = @"altogether_one_group";
        } else if (tempModel.num == 2) {
            groupNumString = @"altogether_two_group";
        } else {
            groupNumString = @"altogether_three_group";
        }
        NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:groupNumString ofType:@"mp3"]];
        _togetherGroupsAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
        _togetherGroupsAudioPlayer.delegate = self;
        [_togetherGroupsAudioPlayer prepareToPlay];
        [_togetherGroupsAudioPlayer play];
    }
    if (player == _togetherGroupsAudioPlayer) {
        VideoModel *tempModel = _videoArray[_currentAction];
        NSString *timesString = nil;
        if (tempModel.type == 1) {
            if (tempModel.group_num == 10) {
                timesString = @"10times_per_group";
            } else if(tempModel.group_num == 12) {
                timesString = @"12times_per_group";
            } else {
                timesString = @"15times_per_group";
            }
        } else {
            if (tempModel.group_num == 30) {
                timesString = @"30second_per_group";
            } else if(tempModel.group_num == 45) {
                timesString = @"45second_per_group";
            } else {
                timesString = @"60second_per_group";
            }
        }
        NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:timesString ofType:@"mp3"]];
        _timesAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
        _timesAudioPlayer.delegate = self;
        [_timesAudioPlayer prepareToPlay];
        [_timesAudioPlayer play];
    }
    if (player == _timesAudioPlayer) {
        NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"first_group" ofType:@"mp3"]];
        _firstGroupAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
        _firstGroupAudioPlayer.delegate = self;
        [_firstGroupAudioPlayer prepareToPlay];
        [_firstGroupAudioPlayer play];
    }
    if (player == _backgroundMusicPlayer) {
        [self setBackgroundAudioPlayer];
    }
    [player stop];
    player = nil;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishedShare" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DownloadSuccess" object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EnterBackground" object:nil];
}
- (void)endOfOneAction {
    _actionTimeLabel.text = @"00:00";
    _crossActionTimeLabel.text = @"00:00";
    [_circleProgressView updateProgressCircle:0];
    [_crossCircleProgressView updateProgressCircle:0];
    [_circleProgressTimer invalidate];
    _currentTime = 0;
    [self setupVideoView];
    [self setupPauseView];
}

/*
 完成训练View
 */
- (void)setupFinishView {
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = 18.0;
    _difficultyLabel.layer.masksToBounds = YES;
    _difficultyLabel.layer.cornerRadius = 9.0;
    switch (_selectedDifficulty) {
        case 1:
            _difficultyLabel.text = @"轻松";
            break;
        case 2:
            _difficultyLabel.text = @"一般";
            break;
        case 3:
            _difficultyLabel.text = @"较难";
            break;
        case 4:
            _difficultyLabel.text = @"困难";
            break;
        default:
            break;
    }
    _showButton.layer.masksToBounds = YES;
    _showButton.layer.cornerRadius = 9.0;
    _courseNameLabel.text = [NSString stringWithFormat:@"%@", _courseModel.courseName];
    _courseDayLabel.text = [NSString stringWithFormat:@"第%@天", _actionDictionary[@"day_name"]];
    _energyLabel.text = [NSString stringWithFormat:@"%@", _actionDictionary[@"calories"]];
    _scoreLabel.text = [NSString stringWithFormat:@"%@", _actionDictionary[@"calories"]];
    NSInteger timeInt = _allPregressTime / 60 + 1;
    NSString *timeString = [NSString stringWithFormat:@"%@", @(timeInt)];
    NSString *string = [NSString stringWithFormat:@"%@分钟", timeString];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, [timeString length])];
    _timeLabel.attributedText = attString;
    NSArray *tempArray = [_actionDictionary[@"resolve_list"] copy];
    NSInteger actionInt = tempArray.count;
    NSString *actionString = [NSString stringWithFormat:@"%@", @(actionInt)];
    NSString *string_action = [NSString stringWithFormat:@"%@个", actionString];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string_action];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, [actionString length])];
    _actionNumberLabel.attributedText = attrString;
    
    //NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    [InformationModel getInfoMassggeWithFrendid:nil handler:^(id object, NSString *msg) {
        if (!msg) {
            _userInformation = object;
            [_headImageView setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:_userInformation.portrait]] placeholderImage:[UIImage imageNamed:@"default_headportrait"]];
        }
    }];
    _finishViewTopConstraint.constant = 0;
    [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
    [self finishDayCourseRequest];
}

/*
 完成训练接口
 */
- (void)finishDayCourseRequest {
    NSMutableDictionary *param = [@{@"courseId" : _courseModel.courseId,
                                    @"courseDayId" : _actionDictionary[@"day_id"],
                                    @"courseDay" : _actionDictionary[@"day_name"],
                                    @"calorie" : _actionDictionary[@"calories"],
                                    @"courseName" : _courseModel.courseName,
                                    @"difficulty" : @(_selectedDifficulty),
                                    @"period" : @(_allPregressTime)} mutableCopy];
    [CourseModel finishDayCourse:param handler:^(id object, NSString *msg) {
        if (msg) {
            NSLog(@"完成课程失败");
        } else {
            NSLog(@"完成课程");
        }
    }];
}

/*
 退出训练按钮
 */
- (IBAction)closeButtonClick:(id)sender {
    //[self viewRotate];
    if (_currentTime > 0) {
        [_circleProgressTimer invalidate];
        _circleProgressTimer = nil;
    } else {
        [self clear];
    }
    [_player pause];
    _closeBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [_closeBackView setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
    [self.view addSubview:_closeBackView];
    
    NSString *titleString = @"训练还没结束，结果将不会保存，确定要退出吗？";
    _tipView = [[TipCloseView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_closeBackView.frame) / 2 - 135, CGRectGetHeight(_closeBackView.frame) / 2 - 90, 270, 165) clickBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [_player play];
            [_closeBackView removeFromSuperview];
            if (_currentTime > 0) {
                _circleProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCircleAction) userInfo:nil repeats:YES];
            } else {
                if (_counterNumber == 5) {
                    [self setupCounterTimer];
                } else {
                    _counterNumber = 5;
                    _counterTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countBeforeStart) userInfo:nil repeats:YES];
                }
            }
        }
    } title:titleString closeButtonTitle:@"退出训练" continueButtonTitle:@"再练一会儿"];
    [_closeBackView addSubview:_tipView];
    
}
- (IBAction)nextButtonClick:(id)sender {
    if (_currentAction != _actionArray.count - 1) {
        [self clear];
        VideoModel *tempModel = _videoArray[_currentAction];
        NSInteger duration = 1;
        if (tempModel.type == 1) {
            duration = tempModel.duration;
        } else {
            duration = 1;
        }
        _allActionCurrentTime += duration * tempModel.group_num * (tempModel.num - _nowGroup) - _currentTime;
        CGFloat totalTime = [_actionDictionary[@"total_time"] floatValue];
        _currentProgressWidthConstraint.constant = (SCREEN_WIDTH - 28) / totalTime * _allActionCurrentTime;
        _currenProgressView.layer.masksToBounds = YES;
        _currenProgressView.layer.cornerRadius = 4.0;
        [UIView animateWithDuration:1.0 animations:^{
            [self.view layoutIfNeeded];
        }];
        [self setupRestView];
        _currentAction += 1;
        _currentTime = 0;
        _nowGroup = 0;
        [self endOfOneAction];
        [self setupCounterTimer];
    }
}
- (IBAction)lastButtonClick:(id)sender {
    if (_currentAction != 0) {
        [self clear];
        VideoModel *tempModel = _videoArray[_currentAction];
        NSInteger duration = 1;
        if (tempModel.type == 1) {
            duration = tempModel.duration;
        } else {
            duration = 1;
        }
        _currentAction -= 1;
        VideoModel *temp = _videoArray[_currentAction];
        NSInteger duration1 = 1;
        if (temp.type == 1) {
            duration1 = temp.duration;
        } else {
            duration1 = 1;
        }
        _allActionCurrentTime -= duration1 * temp.group_num * temp.num + _currentTime + duration * tempModel.group_num * _nowGroup;
        CGFloat totalTime = [_actionDictionary[@"total_time"] floatValue];
        _currentProgressWidthConstraint.constant = (SCREEN_WIDTH - 28) / totalTime * _allActionCurrentTime;
        _currenProgressView.layer.masksToBounds = YES;
        _currenProgressView.layer.cornerRadius = 4.0;
        [UIView animateWithDuration:1.0 animations:^{
            [self.view layoutIfNeeded];
        }];
        _currentTime = 0;
        _nowGroup = 0;
        [self setupRestView];
        [self endOfOneAction];
        [self setupCounterTimer];
        
    }
}
- (IBAction)pauseButtonClick:(id)sender {
    //[_player pause];
    _pauseView.hidden = NO;
    if (_currentTime > 0) {
        [_circleProgressTimer invalidate];
        _circleProgressTimer = nil;
    } else {
        [self clear];
    }
}
- (IBAction)startButtonClick:(id)sender {
    [_player play];
    _pauseView.hidden = YES;
    if (_currentTime > 0) {
        _circleProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCircleAction) userInfo:nil repeats:YES];
    } else {
        if (_counterNumber == 5) {
            [self setupCounterTimer];
        } else {
            _counterNumber = 5;
            _counterTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countBeforeStart) userInfo:nil repeats:YES];
        }
    }
    
}
- (IBAction)showButtonClick:(id)sender {
    UIImage *shareImage = _headImageView.image;
    if ([Util isEmpty:_userInformation.portrait]) {
        shareImage = [UIImage imageNamed:@"share_default"];
    } else {
        shareImage = _headImageView.image;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    NSString *difficultyString = @"";
    switch (_selectedDifficulty) {
        case 1:
            difficultyString = @"简单";
            break;
        case 2:
            difficultyString = @"一般";
            break;
        case 3:
            difficultyString = @"较难";
            break;
        case 4:
            difficultyString = @"困难";
            break;
        default:
            break;
    }
    NSString *shareUrl = [NSString stringWithFormat:@"%@/subject_id/%@/userid/%@/day_id/%@/difficulty/%@/resolve_name/%@", CourseShareUrl, _courseModel.courseId, userid, _actionDictionary[@"day_id"], difficultyString, _actionDictionary[@"resolve_name"]];
    NSString *shareContent = [NSString stringWithFormat:@"%@刚完成了%@第%@天挑战，太棒了！你也一起加入吧！", _userInformation.nickname, _courseModel.courseName, _actionDictionary[@"day_name"]];
    id<ISSContent> publishContent = [ShareSDK content:@"健身坊，让健身更简单~"
                                       defaultContent:@"一起健身吧"
                                                image:[ShareSDK pngImageWithImage:shareImage]
                                                title:shareContent
                                                  url:shareUrl
                                          description:shareContent
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
                                    [self closeFinishViewButtonClick:nil];
                                } else if (state == SSResponseStateFail) {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                }
                            }];
}
- (IBAction)closeFinishViewButtonClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishShare" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)restViewGR {
    [_restCounterTimer invalidate];
    _restCounterTimer = nil;
    _restView.hidden = YES;
    [self setupCounterTimer];
}
- (void)downloadAudioFile:(VideoModel *)model {
    NSString *urlString = [NSString stringWithFormat:@"%@", model.voice];
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *audioData = [NSData dataWithContentsOfURL:url];
    
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp3", docDirPath, model.id];
    [audioData writeToFile:filePath atomically:YES];
}
- (void)setRestAudioPlayer {
    NSURL *restUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"rest" ofType:@"mp3"]];
    _restAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:restUrl error:nil];
    _restAudioPlayer.delegate = self;
    [_restAudioPlayer prepareToPlay];
    [_restAudioPlayer play];
}
- (void)setBackgroundAudioPlayer {
    NSURL *backUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"backvideo" ofType:@"mp3"]];
    _backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backUrl error:nil];
    _backgroundMusicPlayer.delegate = self;
    [_backgroundMusicPlayer prepareToPlay];
    [_backgroundMusicPlayer play];
}
- (void)setFinishCourseAudioPlayer {
    NSURL *backUrl = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"finish_course" ofType:@"mp3"]];
    _finishAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backUrl error:nil];
    _finishAudioPlayer.delegate = self;
    [_finishAudioPlayer prepareToPlay];
    [_finishAudioPlayer play];
}
- (void)clear {
    [_actionAudioPlayer stop];
    [_actionNameAudioPlayer stop];
    [_togetherGroupsAudioPlayer stop];
    [_timesAudioPlayer stop];
    [_firstGroupAudioPlayer stop];
    [_backwardsAudioPlayer stop];
    [_nextOrLastGroupAudioPlayer stop];
    [_countNumberAudioPlayer stop];
    [_restAudioPlayer stop];
    [_backgroundMusicPlayer stop];
    _backgroundMusicPlayer = nil;
    _actionAudioPlayer = nil;
    _actionNameAudioPlayer = nil;
    _togetherGroupsAudioPlayer = nil;
    _firstGroupAudioPlayer = nil;
    _timesAudioPlayer = nil;
    _backwardsAudioPlayer = nil;
    _nextOrLastGroupAudioPlayer = nil;
    _countNumberAudioPlayer = nil;
    _restAudioPlayer = nil;
    [_circleProgressTimer invalidate];
    _circleProgressTimer = nil;
    [_counterTimer invalidate];
    _counterTimer = nil;
    [_restCounterTimer invalidate];
    _restCounterTimer = nil;
}
- (void)finishedShare {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)enterBackgroundPause {
    [self pauseButtonClick:nil];
}
//- (void)viewRotate {
//    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
//        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
//        self.view.transform = CGAffineTransformMakeRotation(0);
//        self.view.bounds = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
//    }
//}

@end
