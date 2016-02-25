//
//  CardDetailViewController.m
//  fitplus
//
//  Created by xlp on 15/12/10.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "CardDetailViewController.h"
#import "PostModel.h"
#import "Util.h"
#import <UIImageView+AFNetworking.h>
#import "PostComment.h"
#import "LimitResultModel.h"
#import "CardCommmentCell.h"
#import "CardReplyCell.h"
#import "RBBlockActionSheet.h"
#import "RBBlockAlertView.h"
#import "RBBlockAlertView.h"
#import <MJRefresh.h>
#import "MyHomepageViewController.h"
#import "BlackUserModel.h"
#import <MBProgressHUD.h>
#import "WXApi.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
@interface CardDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *cardTableView;
@property (weak, nonatomic) IBOutlet UIImageView *hostHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *hostNickname;
@property (weak, nonatomic) IBOutlet UILabel *cardTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardTextLabel;
@property (weak, nonatomic) IBOutlet UIView *cardPictureView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *carPictureViewRightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *floorLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardTileLabelLeftConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewOfTextBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, strong) NSMutableArray *commentArray;
@property (nonatomic, strong) NSMutableArray *tagImageArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, copy) NSString *replyId;
@property (nonatomic, copy) NSString *commendId;
@property (nonatomic, assign) NSInteger commentType;
@property (nonatomic, copy) NSString *commentId;
@property (nonatomic, copy) NSString *userid;
@end

@implementation CardDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationItem.title = _cardModel.title;
    _userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    [self initRefresh];
    CGFloat imageViewHeight = 0;
    if (![Util isEmpty:_cardModel.pic]) {
        imageViewHeight = (SCREEN_WIDTH - 46) / 4 + 10;
    } else {
        imageViewHeight = 0;
    }
    NSString *string = _cardModel.content;
    CGSize contentSize = [string boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 28, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16], NSFontAttributeName, nil] context:nil].size;
    _cardTableView.tableHeaderView.frame = CGRectMake(0, 0, 0, 150 + contentSize.height + imageViewHeight);
    [self setupHeaderView];
    [self fetchCardContent];
    _page = 1;
    [self fetchCommentList];
    _commentType = 1;
    _commentId = _cardModel.userId;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)initRefresh {
    [_cardTableView setHeader:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self fetchCommentList];
    }]];
    [_cardTableView setFooter:[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self fetchCommentList];
    }]];
}
- (void)setupHeaderView {
    [_hostHeadImage setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:_cardModel.portrait]] placeholderImage:[UIImage imageNamed:@"default_headportrait"]];
    _hostHeadImage.userInteractionEnabled = YES;
    [_hostHeadImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hostHeadGestureRecognizer)]];
    _hostNickname.text = [NSString stringWithFormat:@"%@", _cardModel.nickname];
    NSString *currentDateStr = [Util getIntervalDateString:_cardModel.createTime];
    NSDate *createdDate  = [Util getTimeDate:currentDateStr];
    if ([[Util compareDate:createdDate] isEqualToString:@"今天"]) {
        currentDateStr = [currentDateStr substringWithRange:NSMakeRange(11, 5)];
    } else if ([[Util compareDate:createdDate] isEqualToString:@"昨天"]) {
        currentDateStr = [NSString stringWithFormat:@"昨天%@", [currentDateStr substringWithRange:NSMakeRange(11, 5)]];
    } else {
        currentDateStr = [currentDateStr substringWithRange:NSMakeRange(5, 11)];
    }
    _cardTimeLabel.text = [NSString stringWithFormat:@"%@", currentDateStr];
    _cardTitleLabel.text = [NSString stringWithFormat:@"%@", _cardModel.title];
    _cardTextLabel.text = [NSString stringWithFormat:@"%@", _cardModel.content];
    if ([_cardModel.favoriteState integerValue] == 1) {
        _likeButton.selected = YES;
    } else {
        _likeButton.selected = NO;
    }
    if (![Util isEmpty:_cardModel.tagId]) {
        NSArray *tagArray = [[_cardModel.tagId componentsSeparatedByString:@","] copy];
        if ([tagArray[0] integerValue] == 0) {
            _cardTileLabelLeftConstraint.constant = 14 + 20 * (tagArray.count - 1) + 36;
        } else {
            _cardTileLabelLeftConstraint.constant = 14 + 20 * tagArray.count;
        }
        for (NSInteger i = 0; i < tagArray.count; i ++) {
            UIImageView *tagImage = [[UIImageView alloc] init];
            if ([tagArray[0] integerValue] == 0) {
                if (i == 0) {
                    tagImage.frame = CGRectMake(14, 61, 33, 17);
                } else {
                    tagImage.frame = CGRectMake(14 + 36 + 20 * (i - 1), 61, 17, 17);
                }
            } else {
                tagImage.frame = CGRectMake(14 + 20 * i, 61, 17, 17);
            }
            tagImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"circle_card_tag%@", @([tagArray[i] integerValue])]];
            [_headerView addSubview:tagImage];
            
        }
    } else {
        _cardTileLabelLeftConstraint.constant = 14;
    }
    
    if (![Util isEmpty:_cardModel.pic]) {
        _carPictureViewRightConstraint.constant = 14;
        _tagImageArray = [[_cardModel.pic componentsSeparatedByString:@","] mutableCopy];
        if (_tagImageArray.count > 4) {
            _tagImageArray = [[_tagImageArray subarrayWithRange:NSMakeRange(0, 4)] mutableCopy];
        }
        for (NSInteger i = _cardPictureView.subviews.count - 1; i >= 0; i --) {
            [_cardPictureView.subviews[i] removeFromSuperview];
        }
        
        for (NSInteger i = 0; i < _tagImageArray.count; i ++) {
            UIImageView *cardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * (SCREEN_WIDTH / 4 - 5.5), 0, SCREEN_WIDTH / 4 - 11.5, SCREEN_WIDTH / 4 - 11.5)];
            cardImageView.clipsToBounds = YES;
            cardImageView.contentMode = UIViewContentModeScaleAspectFill;
            [cardImageView setImageWithURL:[NSURL URLWithString:[Util urlZoomPhoto:_tagImageArray[i]]] placeholderImage:[UIImage imageNamed:@"default_image"]];
            cardImageView.userInteractionEnabled = YES;
             cardImageView.tag=i;
            [cardImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagImageShowGestureRecognizer:)]];
            [_cardPictureView addSubview:cardImageView];
        }
    } else {
        _carPictureViewRightConstraint.constant = SCREEN_WIDTH - 14;
    }

}

/*
 获取帖子内容
 */
- (void)fetchCardContent {
    [PostModel postWith:_cardModel.id handler:^(id object, NSString *msg) {
        if (!msg) {
            _cardModel = [object copy];
            if ([_cardModel.favoriteState integerValue] == 1) {
                _likeButton.selected = YES;
            } else {
                _likeButton.selected = NO;
            }
            
        }
    }];
}
- (void)fetchCommentList {
    [PostComment postCommentWith:_cardModel.id page:_page handler:^(LimitResultModel *object, NSString *msg) {
        [_cardTableView.header endRefreshing];
        [_cardTableView.footer endRefreshing];
        if (!msg) {
            if (_page == 1) {
                _commentArray = [object.result mutableCopy];
            } else {
                NSMutableArray *tempArray = [_commentArray mutableCopy];
                [tempArray addObjectsFromArray:object.result];
                _commentArray = tempArray;
            }
            [_cardTableView reloadData];
            BOOL haveMore = object.haveMore;
            if (haveMore) {
                _page = object.page;
                [_cardTableView.footer setHidden:NO];
            } else {
                [_cardTableView.footer noticeNoMoreData];
                [_cardTableView.footer setHidden:YES];
            }
        }
    }];
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
#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)note {
    NSDictionary *info = [note userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    _viewOfTextBottomConstraint.constant = keyboardSize.height;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (void)keyboardWillHide:(NSNotification *)note {
    _viewOfTextBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (![text isEqualToString:@""]) {
        _placeholderLabel.hidden = YES;
    } else {
        if (range.location == 0 && range.length == 1) {
            _placeholderLabel.hidden = NO;
        }
    }
    return YES;
}
#pragma mark - UITableView Delegate DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _commentArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PostComment *commentModel = _commentArray[section];
    NSArray *replyArray = [commentModel.reply copy];
    return replyArray.count + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [[CardCommmentCell new] heightOfCommentCell:_commentArray[indexPath.section]];
    } else {
        PostComment *commentModel = _commentArray[indexPath.section];
        NSArray *replyArray = [commentModel.reply copy];
        return [[CardReplyCell new] heightOfCell:replyArray[indexPath.row - 1]];
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostComment *commentModel = _commentArray[indexPath.section];
    NSArray *replyArray = [commentModel.reply copy];
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"CardCommentCell";
        CardCommmentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        PostComment *model = _commentArray[indexPath.section];
        [cell setupCommentContent:model];
        cell.floorLabel.text = [NSString stringWithFormat:@"%@楼", @(indexPath.section + 2)];
        if (replyArray.count > 0) {
            cell.lineLeftConstraint.constant = 34;
        } else {
            cell.lineLeftConstraint.constant = 0;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell click:^(NSInteger index, NSString *commendId, NSString *replyId, NSString *commentId) {
            
            if (index == 1) {
                _commendId = commendId;
                _replyId = replyId;
                _commentId = commentId;
                _commentType = 2;
                [_textView becomeFirstResponder];
                _placeholderLabel.text = [NSString stringWithFormat:@"回复%@...", model.commentNickname];
            } else {
                [_textView resignFirstResponder];
                if ([commentId isEqualToString:_userid]) {
                    [[[RBBlockActionSheet alloc] initWithTitle:nil clickBlock:^(NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[[RBBlockAlertView alloc] initWithTitle:nil message:@"确定要删除吗?" block:^(NSInteger buttonIndex) {
                                if (buttonIndex == 1) {
                                    [self deleteComment:commendId];
                                }
                            } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
                        }
                    } cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除评论" otherButtonTitles:nil, nil] showInView:self.view];
                } else {
                    [[[RBBlockActionSheet alloc] initWithTitle:nil clickBlock:^(NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[[RBBlockAlertView alloc] initWithTitle:nil message:@"确定要举报吗?" block:^(NSInteger buttonIndex) {
                                if (buttonIndex == 1) {
                                    [self reportMessage:@"trendscomment" reportId:commendId];
                                }
                            } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
                        } else if (buttonIndex == 2) {
                            [[[RBBlockAlertView alloc] initWithTitle:nil message:@"确定要加入黑名单吗?" block:^(NSInteger buttonIndex) {
                                if (buttonIndex == 1) {
                                    [self addBlackListUser:commentId];
                                }
                            } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
                        }
                    } cancelButtonTitle:@"取消" destructiveButtonTitle:@"举报不良信息" otherButtonTitles:@"加入黑名单", nil] showInView:self.view];
                }
                
            }
        }];
        [cell headClick:^(NSString *userId) {
            MyHomepageViewController *informationViewController = [[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"MyHomepageView"];
            informationViewController.friendId = userId;
            [self.navigationController pushViewController:informationViewController animated:YES];
        }];
        return cell;
    } else {
        static NSString *identifier = @"CardReplyCell";
        CardReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        [cell setupContainer:replyArray[indexPath.row - 1]];
        if (indexPath.row == replyArray.count) {
            cell.lineLabel.hidden = NO;
        } else {
            cell.lineLabel.hidden = YES;
        }
        [cell headClick:^(NSString *userId) {
            MyHomepageViewController *informationViewController = [[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"MyHomepageView"];
            informationViewController.friendId = userId;
            [self.navigationController pushViewController:informationViewController animated:YES];
        }];
        return cell;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row > 0) {
        PostComment *commentModel = _commentArray[indexPath.section];
        NSArray *replyArray = [commentModel.reply copy];
        if ([replyArray[indexPath.row - 1][@"commentId"] isEqualToString:_userid]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.removeFromSuperViewOnHide = YES;
            hud.labelText = @"不要回复自己哦~";
            [hud hide:YES afterDelay:1.0];
        } else {
            if ([WXApi isWXAppInstalled]) {
                _commendId = replyArray[indexPath.row - 1][@"commendId"];
                _replyId = replyArray[indexPath.row - 1][@"id"];
                _commentId = replyArray[indexPath.row - 1][@"commentId"];
                _commentType = 2;
                [_textView becomeFirstResponder];
                _placeholderLabel.text = [NSString stringWithFormat:@"回复%@...", replyArray[indexPath.row - 1][@"commentNickname"]];
            } else {
                [[[RBBlockActionSheet alloc] initWithTitle:nil clickBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        [[[RBBlockAlertView alloc] initWithTitle:nil message:@"确定要举报吗?" block:^(NSInteger buttonIndex) {
                            if (buttonIndex == 1) {
                                [self reportMessage:@"trendscpartak" reportId:replyArray[indexPath.row - 1][@"id"]];
                            }
                        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
                    } else if (buttonIndex == 2) {
                        [[[RBBlockAlertView alloc] initWithTitle:nil message:@"确定要加入黑名单吗?" block:^(NSInteger buttonIndex) {
                            if (buttonIndex == 1) {
                                [self addBlackListUser:replyArray[indexPath.row - 1][@"commentId"]];
                            }
                        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
                    } else if (buttonIndex == 3) {
                        _commendId = replyArray[indexPath.row - 1][@"commendId"];
                        _replyId = replyArray[indexPath.row - 1][@"id"];
                        _commentId = replyArray[indexPath.row - 1][@"commentId"];
                        _commentType = 2;
                        [_textView becomeFirstResponder];
                        _placeholderLabel.text = [NSString stringWithFormat:@"回复%@...", replyArray[indexPath.row - 1][@"commentNickname"]];
                    }
                } cancelButtonTitle:@"取消" destructiveButtonTitle:@"举报不良信息" otherButtonTitles:@"加入黑名单", @"回复", nil] showInView:self.view];
            }
            
        }
        
    }
}

- (IBAction)cardButtonClick:(id)sender {
    
    UIButton *button=(UIButton*)sender;
    //点赞-----还需要把参数articleId传过去
    if (button.tag==97) {
        button.selected = !button.selected;
        if (button.selected) {
            [CardModel addFavoriteWith:_cardModel.id handler:^(id object, NSString *msg) {

            }];

        } else {
            [CardModel delFavortieWith:_cardModel.id handler:^(id object, NSString *msg) {
                
            }];
        }
    } else if (button.tag==98) {
        [self resetTextView];
        [_textView becomeFirstResponder];
    } else{
        [_textView resignFirstResponder];
        if ([_cardModel.userId isEqualToString:_userid]) {
            [[[RBBlockActionSheet alloc] initWithTitle:nil clickBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [[[RBBlockAlertView alloc] initWithTitle:nil message:@"确定要删除吗?" block:^(NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            [self deleteCard:_cardModel.id];
                        }
                    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
                }
            } cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除帖子" otherButtonTitles:nil, nil] showInView:self.view];
        } else {
            //举报
            [[[RBBlockActionSheet alloc] initWithTitle:nil clickBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [[[RBBlockAlertView alloc] initWithTitle:nil message:@"确定要举报吗?" block:^(NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            [self reportMessage:@"plate" reportId:_cardModel.id];
                        }
                    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
                } else if (buttonIndex == 2) {
                    [[[RBBlockAlertView alloc] initWithTitle:nil message:@"确定要加入黑名单吗?" block:^(NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            [self addBlackListUser:_cardModel.userId];
                        }
                    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
                }
            } cancelButtonTitle:@"取消" destructiveButtonTitle:@"举报不良信息" otherButtonTitles:@"加入黑名单", nil] showInView:self.view];
        }
        
    }
}
- (IBAction)sendButtonClick:(id)sender {
    if ([Util isEmpty:_textView.text]) {
        [[[RBBlockAlertView alloc] initWithTitle:@"提示" message:@"先写什么吧" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        return;
    }
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey];
    [PostComment postAddArticleCommentWith:_cardModel.id userId:_commentId type:[NSString stringWithFormat:@"%@", @(_commentType)] commentId:userid commentContent:_textView.text replyId:_commendId commendId:_replyId handler:^(id object, NSString *msg) {
        if (!msg) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.removeFromSuperViewOnHide = YES;
            hud.labelText = @"成功";
            [hud hide:YES afterDelay:1.0];
            _page = 1;
            [self fetchCommentList];
        }
    }];
    [self resetTextView];
    
}

- (void)reportMessage:(NSString *)type reportId:(NSString *)reportId {
    
    [CardModel addReportWith:reportId type:type handler:^(id object, NSString *msg) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.removeFromSuperViewOnHide = YES;
        if (msg) {
            hud.labelText = @"举报失败";
        } else {
            hud.labelText = @"举报成功";
            if ([type isEqualToString:@"plate"]) {
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CardEditSuccess" object:nil];
            } else {
                _page = 1;
                [self fetchCommentList];
            }
            
        }
        [hud hide:YES afterDelay:1.0];
    }];
    
}
- (void)deleteCard:(NSString *)articleId {
    [CardModel cardDeleteWith:articleId handler:^(id object, NSString *msg) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.removeFromSuperViewOnHide = YES;
        if (msg) {
            hud.labelText = @"删除失败";
        } else {
            hud.labelText = @"删除成功";
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CardEditSuccess" object:nil];
        }
        [hud hide:YES afterDelay:1.0];
    }];
}
- (void)deleteComment:(NSString *)commentId {
    [CardModel commentDeleteWith:commentId handler:^(id object, NSString *msg) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.removeFromSuperViewOnHide = YES;
        if (msg) {
            hud.labelText = @"删除失败";
        } else {
            hud.labelText = @"删除成功";
            [self fetchCommentList];
        }
        [hud hide:YES afterDelay:1.0];
    }];
}

- (void)resetTextView {
    [_textView resignFirstResponder];
    _textView.text = nil;
    _commendId = nil;
    _replyId = nil;
    _commentId = _cardModel.userId;
    _commentType = 1;
    _placeholderLabel.text = @"评论楼主...";
    _placeholderLabel.hidden = NO;
}
- (void)hostHeadGestureRecognizer {
    MyHomepageViewController *informationViewController = [[UIStoryboard storyboardWithName:@"Information" bundle:nil] instantiateViewControllerWithIdentifier:@"MyHomepageView"];
    informationViewController.friendId = _cardModel.userId;
    [self.navigationController pushViewController:informationViewController animated:YES];
}
/*
 黑名单
 */
- (void)addBlackListUser:(NSString *)userId {
    [BlackUserModel addBlack:userId handler:^(id object, NSString *msg) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.removeFromSuperViewOnHide = YES;
        if (msg) {
            hud.labelText = @"添加到黑名单失败";
        } else {
            hud.labelText = @"添加到黑名单成功";
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CardEditSuccess" object:nil];
        }
        [hud hide:YES afterDelay:1.0];
    }];
}

-(void)tagImageShowGestureRecognizer:(UITapGestureRecognizer*)gesture {
    UIImageView *image = (UIImageView *)gesture.view;
    NSInteger photosCount = _tagImageArray.count;
    NSMutableArray *photosArray = [NSMutableArray arrayWithCapacity:photosCount];
    for (NSInteger i = 0; i < photosCount; i ++) {
        NSString *url = _tagImageArray[i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:[Util urlPhoto:url]];
        photo.srcImageView = _cardPictureView.subviews[i];
        [photosArray addObject:photo];
    }
    
    //显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = image.tag;
    browser.photos = photosArray;
    [browser show];

    
}
@end
