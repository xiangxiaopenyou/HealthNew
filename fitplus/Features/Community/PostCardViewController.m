//
//  PostCardViewController.m
//  fitplus
//
//  Created by xlp on 15/12/15.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import "PostCardViewController.h"
#import <CTAssetsPickerController.h>
#import <Photos/Photos.h>
#import <CTAssetsPageViewController.h>
#import "RBBlockActionSheet.h"
#import "RBBlockAlertView.h"
#import "Util.h"
#import "CardModel.h"
#import "UploadPicturesRequest.h"
#import "RBNoticeHelper.h"
#import "PhotoBrowserViewController.h"

@interface PostCardViewController ()<CTAssetsPickerControllerDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *contentPlaceholder;
@property (weak, nonatomic) IBOutlet UIButton *addPictureButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addPictureButtonLeftConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *pictureView;

@property (nonatomic, strong) PHImageRequestOptions *requestOptions;
//@property (nonatomic, strong) NSMutableArray *assetsArray;
@property (nonatomic, strong) NSMutableArray *picturesArray;
@property (nonatomic, strong) NSMutableArray *keysArray;

@end

@implementation PostCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    _tableView.tableFooterView = [UIView new];
    
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setupPictureView {
    for (NSInteger i = [_pictureView.subviews count] - 1; i >= 0; i --) {
        if ([_pictureView.subviews[i] isKindOfClass:[UIImageView class]]) {
            [_pictureView.subviews[i] removeFromSuperview];
        }
    }
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addImage) userInfo:nil repeats:NO];
    [timer fire];
}
- (void)addImage {
    if (_picturesArray.count >= 4) {
        _addPictureButton.hidden = YES;
    } else {
        _addPictureButton.hidden = NO;
    }
    _addPictureButtonLeftConstraint.constant = 14 + _picturesArray.count * 74;
    for (NSInteger i = 0; i < _picturesArray.count; i ++) {
        UIImageView *picture = [[UIImageView alloc] initWithFrame:CGRectMake(14 + i * 74, 0, 64, 64)];
        picture.tag = i;
        picture.userInteractionEnabled = YES;
        picture.clipsToBounds = YES;
        picture.contentMode = UIViewContentModeScaleAspectFill;
        [picture addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureGestureRecognizer:)]];
        [_pictureView addSubview:picture];
        picture.image = _picturesArray[i];
        
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

#pragma mark UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (![text isEqualToString:@""]) {
        _contentPlaceholder.hidden = YES;
    } else {
        if (range.location == 0 && range.length == 1) {
            _contentPlaceholder.hidden = NO;
        }
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location >= 20) {
        [RBNoticeHelper showNoticeAtView:self.view y:0 msg:@"标题别超过20个字哦~"];
        return NO;
    }
    return YES;
}
#pragma mark - CTAssetsPickerController Delegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    self.requestOptions = [[PHImageRequestOptions alloc] init];
    self.requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    self.requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    self.requestOptions.synchronous = YES;
    self.requestOptions.networkAccessAllowed = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSMutableArray *tempPictureArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < assets.count; i ++) {
        NSString *fileName = @(ceil([[NSDate date] timeIntervalSince1970])).stringValue;
        fileName = [NSString stringWithFormat:@"%@%@", fileName, @(i)];
        if (_keysArray.count == 0) {
            _keysArray = [[NSMutableArray alloc] init];
        }
        [_keysArray addObject:fileName];
        PHAsset *asset = assets[i];
        PHImageManager *manager = [PHImageManager defaultManager];
        //CGSize targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        
        [manager requestImageForAsset:asset
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:self.requestOptions
                        resultHandler:^(UIImage *image, NSDictionary *info){
                            if (!image) {
                                return;
                            }
                            [tempPictureArray addObject:image];
                            if (tempPictureArray.count >= assets.count) {
                                if (_picturesArray.count > 0) {
                                    [_picturesArray addObjectsFromArray:tempPictureArray];
                                } else {
                                    _picturesArray = [tempPictureArray mutableCopy];
                                }
                                [[UploadPicturesRequest new] request:^BOOL(UploadPicturesRequest *request) {
                                    request.keys = _keysArray;
                                    request.images = _picturesArray;
                                    return YES;
                                } result:^(id object, NSString *msg) {
                                    if (msg) {
                                        NSLog(@"图片上传失败");
                                    } else {
                                        NSLog(@"上传成功");
                                    }
                                }];
                                [self setupPictureView];
                            }
                        }];
    }
    
}
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset {
    NSInteger maxNumber = 4 - _picturesArray.count;
    if (picker.selectedAssets.count >= maxNumber) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"最多只能上传4张照片" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [picker presentViewController:alert animated:YES completion:nil];

    }
    return (picker.selectedAssets.count < maxNumber);
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString *fileName = @(ceil([[NSDate date] timeIntervalSince1970])).stringValue;
    if (_picturesArray.count > 0) {
        //[_assetsArray addObjectsFromArray:assets];
        [_picturesArray addObject:image];
        [_keysArray addObject:fileName];
    } else {
        //_picturesArray = [assets mutableCopy];
        _picturesArray = [NSMutableArray arrayWithObjects:image, nil];
        _keysArray = [NSMutableArray arrayWithObjects:fileName, nil];
    }
    [[UploadPicturesRequest new] request:^BOOL(UploadPicturesRequest *request) {
        request.keys = @[fileName];
        request.images = @[image];
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            NSLog(@"图片上传失败");
        } else {
            NSLog(@"上传成功");
        }
    }];
    [self setupPictureView];
}


- (void)pictureGestureRecognizer:(UITapGestureRecognizer *)gesture {
    UIImageView *image = (UIImageView *)gesture.view;
    PhotoBrowserViewController *viewController = [[PhotoBrowserViewController alloc] init];
    viewController.photos = _picturesArray;
    viewController.currentIndex = image.tag;
    viewController.keys = _keysArray;
    [viewController pictureDelete:^(NSArray *resultArray, NSArray *keysResultArray) {
        _picturesArray = [resultArray mutableCopy];
        _keysArray = [keysResultArray mutableCopy];
        [self setupPictureView];
    }];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)addPictureButtonClick:(id)sender {
    [[[RBBlockActionSheet alloc] initWithTitle:nil clickBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
                    picker.delegate = self;
                    picker.defaultAssetCollection = PHAssetCollectionSubtypeSmartAlbumUserLibrary;
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        picker.modalPresentationStyle = UIModalPresentationFormSheet;
                    }
                    PHFetchOptions *fetchOptions = [PHFetchOptions new];
                    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
                    picker.assetsFetchOptions = fetchOptions;
                    [self presentViewController:picker animated:YES completion:nil];
                });
            }];
        } else if (buttonIndex == 2) {
            NSLog(@"拍照");
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *cameraViewController = [[UIImagePickerController alloc] init];
                cameraViewController.delegate = self;
                cameraViewController.allowsEditing = YES;
                cameraViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:cameraViewController animated:YES completion:nil];
            }
        }
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从手机相册选择", @"拍照", nil] showInView:self.view];
    
}
- (IBAction)postButtonClick:(id)sender {
    if ([Util isEmpty:_titleTextField.text]) {
        [[[RBBlockAlertView alloc] initWithTitle:@"提示" message:@"别忘记写标题哦~" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        return;
    }
    if ([Util isEmpty:_contentTextView.text]) {
        [[[RBBlockAlertView alloc] initWithTitle:@"提示" message:@"帖子要写点内容哦~" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        return;
    }
    NSMutableDictionary *param = [@{@"plateId" : _model.id,
                            @"title" : _titleTextField.text,
                            @"text" : _contentTextView.text} mutableCopy];
    [self.navigationController popViewControllerAnimated:YES];
    if (_keysArray.count > 0) {
        NSString *keyString = @"";
        for (NSInteger i = 0; i < _keysArray.count; i ++) {
            if (i >= _keysArray.count - 1) {
                keyString = [NSString stringWithFormat:@"%@%@", keyString, _keysArray[i]];
                [param setObject:keyString forKey:@"pic"];
                [CardModel postCard:param handler:^(id object, NSString *msg) {
                    if (!msg) {
                        NSLog(@"发送成功");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"PostCardSuccess" object:@YES];
                        
                    } else {
                        NSLog(@"%@", msg);
                    }
                }];
            } else {
                keyString = [NSString stringWithFormat:@"%@%@,", keyString, _keysArray[i]];
            }
        }

    } else {
        [CardModel postCard:param handler:^(id object, NSString *msg) {
            if (!msg) {
                NSLog(@"发送成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PostCardSuccess" object:@YES];
                
            } else {
                NSLog(@"%@", msg);
            }
        }];
    }
    
}

@end
