//
//  PhotoBrowserViewController.h
//  fitplus
//
//  Created by xlp on 15/12/22.
//  Copyright © 2015年 realtech. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^DeletePicture)(NSArray *resultArray, NSArray *keysResultArray);

@interface PhotoBrowserViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *keys;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, copy) DeletePicture deletePic;

- (void)pictureDelete:(DeletePicture)dele;

@end
