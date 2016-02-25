//
//  AppDelegate.m
//  fitplus
//
//  Created by 天池邵 on 15/6/25.
//  Copyright (c) 2015年 realtech. All rights reserved.
//

#import "AppDelegate.h"
#import "UserInfo.h"
#import "UserInfoModel.h"
#import "RequestCacher.h"
#import <AFNetworking.h>
#import "CommonsDefines.h"
#import "UserInfoModel.h"
#import "RBBlockAlertView.h"
#import <TuSDKGeeV1/TuSDKGeeV1.h>
#import <ShareSDK/ShareSDK.h>
#import "RBBlockAlertView.h"
#import "Util.h"
#import "RBNoticeHelper.h"
#import "MessageUnreadCommentModel.h"
#import "MobClick.h"

//static NSString *const UMAppKey = @"559e197b67e58e35fd00326c"; //so
static NSString *const UMAppKey = @"5508e883fd98c590ae0013ca"; //Healthes

static NSString *const ShareSDKAppKey = @"8c05e56712b4";

//static NSString *const TUSDKAppKey = @"bd9115a2e79300ce-00-oimln1"; //so
//static NSString *const TUSDKAppKey = @"747df7438f8b2fe1-00-oimln1"; //RTHealth
static NSString *const TUSDKAppKey = @"1ac9c7143e737182-00-oimln1"; //Healthes

@interface AppDelegate ()

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *openID;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *headportrait;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *unionid;

@property (copy, nonatomic) NSString *deviceToken;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self initAppearance];
    [self initShareSDK];
    [self checkUpdate];
    [WXApi registerApp:wxAppKey];
    [TuSDK initSdkWithAppKey:TUSDKAppKey];
    [MobClick startWithAppkey:UMAppKey reportPolicy:BATCH channelId:nil];
    
    //启动个推sdk
    [GeTuiSdk startSdkWithAppId:GeTuiAppId appKey:GeTuiAppKey appSecret:GeTuiAppSecret delegate:self];
    // 注册APNS
    [self registerNofitication];
    
    //处理远程通知启动APP
    [self receiveNotificationByLaunchingOptions:launchOptions];

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
//    [self saveSqlite];
    
//    if ([UserInfo userHaveLogin]) {
//        [self initPush];
//    }
    
//    NSDictionary *message = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    }
    
//    if (message) {
//        NSString *payloadMsg = [message objectForKey:@"payload"];
//        NSString *record = [NSString stringWithFormat:@"[APN]%@,%@", [NSDate date], payloadMsg];
//    }
   // _timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timerSchedule) userInfo:nil repeats:YES];
    return YES;
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    
    NSString *token = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"token=====%@",token);
    
    [GeTuiSdk registerDeviceToken:token];
    if ([[NSUserDefaults standardUserDefaults] stringForKey:UserIdKey]) {
        [UserInfoModel updateDeviceToken:token handler:^(id object, NSString *msg) {
            if (msg) {
                NSLog(@"update device token failed %@", msg);
            }
        }];
    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"fail to register for remote notification : %@", error.description);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"userinfo=====%@",userInfo);
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if ([[userInfo allKeys] containsObject:@"message"] && [[userInfo[@"message"] allKeys] containsObject:@"system_notice"]) {
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowGeTui" object:@YES];
    
}
/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    application.applicationIconBadgeNumber=0;
    
    // 处理APN
    NSLog(@"=======[Receive RemoteNotification - Background Fetch]:%@",userInfo);
    
    NSDictionary *apsDic=[userInfo objectForKey:@"aps"];
    
    NSString *categoryStr =[apsDic objectForKey:@"category"];
    
    NSLog(@"string=%@",categoryStr);
    
    if (categoryStr) {
        
        if ([categoryStr integerValue] == 1) {
            
        }else
        {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowGeTui" object:self userInfo:apsDic];
            
            NSLog(@"发通知");
            
        }

        
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
}
- (void)timerSchedule {
    [MessageUnreadCommentModel unreadMessage:^(MessageUnreadCommentModel *object, NSString *msg) {
        NSInteger allNum = [object.allNum integerValue];
        allNum=3;
        if (allNum > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ReceivedMessagesNotificationKey object:@(allNum)];
        }
    }];
}
- (void)initShareSDK {
    [ShareSDK registerApp:ShareSDKAppKey];
    
    [ShareSDK connectWeChatWithAppId:wxAppKey
                           wechatCls:[WXApi class]];
    
}

- (void)initPush {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //[self registerNofitication];
}

- (void)registerNofitication {
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8 ) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil]];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}
/** 自定义：APP被“推送”启动时处理推送消息处理（APP 未启动--》启动）*/
- (void)receiveNotificationByLaunchingOptions:(NSDictionary *)launchOptions {
    if (!launchOptions) return;
    
    /*
     通过“远程推送”启动APP
     UIApplicationLaunchOptionsRemoteNotificationKey 远程推送Key
     */
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSLog(@"\n>>>[Launching RemoteNotification]:%@",userInfo);
    }
}


- (void)initAppearance {
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.234 green:0.180 blue:0.292 alpha:1.000]];
    NSShadow *shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shadow.shadowColor = [UIColor clearColor];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                                            NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                                            NSShadowAttributeName: shadow
                                                            }];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterBackground" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)reachabilityDicChanged:(NSNotification *)notification {
    AFNetworkReachabilityStatus status = [notification.userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue];
    if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
        [[RequestCacher sharedInstance] reloadRequest];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDicChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    if ([UserInfo userHaveLogin]) {
        [UserInfoModel addUpUserLiveness:^(id object, NSString *msg) {
            if (!msg) {
                NSLog(@"统计成功");
            }
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [WXApi handleOpenURL:url delegate:self];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [WXApi handleOpenURL:url delegate:self];
    return YES;
}
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    completionHandler(UIBackgroundFetchResultNewData);
}

/*
 保存热量数据库
 */
//- (void)saveSqlite {
//    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSString *savePath = [documentsDirectory stringByAppendingPathComponent:@"calorie.sqlite"];
//    NSFileManager *fileManeger = [NSFileManager defaultManager];
//    if (![fileManeger fileExistsAtPath:savePath]) {
//        NSString *defaultDatabasePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"calorie.sqlite"];
//        [fileManeger copyItemAtPath:defaultDatabasePath toPath:savePath error:nil];
//    }
//}

/*
 微信回调
 */
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *chatResponse = (SendAuthResp *)resp;
        if (chatResponse.errCode == 0) {
            _code = chatResponse.code;
            [self getAccess];
        }
    }
}

- (void)onReq:(BaseReq *)req {
}

- (void)getAccess {
    [UserInfoModel getWeChatAccessToken:_code handler:^(id object, NSString *msg) {
        _openID = [object objectForKey:@"openid"];
        _accessToken = [object objectForKey:@"access_token"];
        [self getWeChatUserInfo];
    }];
}

- (void)getWeChatUserInfo {
    [UserInfoModel getWeChatUserInfo:_openID token:_accessToken handler:^(id object, NSString *msg) {
        _nickname = [object objectForKey:@"nickname"];
        _headportrait = [object objectForKey:@"headimgurl"];
        _sex = [object objectForKey:@"sex"];
        _unionid = [object objectForKey:@"unionid"];
        [self weChatLogin];
    }];
}

- (void)weChatLogin {
    [UserInfoModel weChatLogin:_unionid handler:^(id object, NSString *msg) {
        if (msg) {
            RBBlockAlertView *alert =[[RBBlockAlertView alloc] initWithTitle:@"提示" message:@"登录失败" block:^(NSInteger buttonIndex) {
            } cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        } else {
            if ([object[@"state"] integerValue] == 1000) {
                NSLog(@"登录成功");
                [self saveUserInfo:object[@"data"]];
                [self initPush];
            } else if ([object[@"state"] integerValue] == 1003) {
                NSLog(@"还没注册");
                [self weChatRegister];
            } else {
                NSLog(@"登录失败");
            }
        }
    }];
}

- (void)weChatRegister {
    NSDictionary *dic = @{@"unionid" : _unionid,
                          @"nickname" : _nickname,
                          @"sex" : _sex,
                          @"headportrait" : _headportrait};
    [UserInfoModel weChatRegister:dic handler:^(id object, NSString *msg) {
        if (msg) {
            RBBlockAlertView *alert =[[RBBlockAlertView alloc] initWithTitle:@"提示" message:@"注册失败" block:^(NSInteger buttonIndex) {
            } cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        } else {
            [self saveUserInfo:object];
        }
    }];
}

- (void)saveUserInfo:(NSDictionary *)dic {
    if ([Util isEmpty:dic]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginFail object:@YES];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:dic[@"userid"] forKey:UserIdKey];
//        [Answers logCustomEventWithName:@"Save User Info"
//                       customAttributes:@{@"UserToken" :dic[@"usertoken"]}];
        [[NSUserDefaults standardUserDefaults] setValue:dic[@"usertoken"] forKey:UserTokenKey];
        [[NSUserDefaults standardUserDefaults] setValue:dic[@"nickname"] forKey:UserName];
        [[NSUserDefaults standardUserDefaults] setValue:dic[@"userheadportrait"] forKey:UserHeadportrait];
        [[NSUserDefaults standardUserDefaults] setValue:_sex forKey:UserSex];
        [[NSUserDefaults standardUserDefaults] setValue:dic[@"isNewUser"] forKey:IsNewUserKey];
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:IsFirstOpenTool];
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:IsFirstOpenVideo];
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:IsFirstOpenCommunity];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginStateChange object:@YES];
    }
}

- (void)shareWithWeChatFriends:(NSString *)title Description:(NSString *)description Url:(NSString *)urlString Photo:(NSString *)photoUrl {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    //[message setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]]]];
    //[message setThumbImage:[UIImage imageNamed:photoUrl]];
    UIImage *desImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]]];
    UIImage *thumbImg = [self thumbImageWithImage:desImage limitSize:CGSizeMake(150, 150)];
    message.thumbData = UIImageJPEGRepresentation(thumbImg, 1);
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = urlString;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
}
- (void)shareToWechat:(NSString *)title Description:(NSString *)description Url:(NSString *)urlString Photo:(NSString *)photoUrl {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    [message setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]]]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = urlString;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}
- (UIImage *)thumbImageWithImage:(UIImage *)scImg limitSize:(CGSize)limitSize
{
    if (scImg.size.width <= limitSize.width && scImg.size.height <= limitSize.height) {
        return scImg;
    }
    CGSize thumbSize;
    if (scImg.size.width / scImg.size.height > limitSize.width / limitSize.height) {
        thumbSize.width = limitSize.width;
        thumbSize.height = limitSize.width / scImg.size.width * scImg.size.height;
    }
    else {
        thumbSize.height = limitSize.height;
        thumbSize.width = limitSize.height / scImg.size.height * scImg.size.width;
    }
    UIGraphicsBeginImageContext(thumbSize);
    [scImg drawInRect:(CGRect){CGPointZero,thumbSize}];
    UIImage *thumbImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return thumbImg;
}
- (void)checkUpdate {
    [UserInfoModel checkUpdate:^(id object, NSString *msg) {
        if (object) {
            if ([object[@"version"] integerValue] == 2) {
                NSString *updateString = object[@"updateurl"];
                [[[RBBlockAlertView alloc] initWithTitle:@"有新版本更新" message:object[@"data"] block:^(NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateString]];
                    }
                } cancelButtonTitle:@"暂不更新" otherButtonTitles:@"马上更新", nil] show];
            }
        }
    }];
}

/**/
-(void)GeTuiSdkDidRegisterClient:(NSString *)clientId
{
    NSLog(@"=============[GeTuiSdk RegisterClient]:%@", clientId);
}
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"--------------[GexinSdk error]:%@", [error localizedDescription]);
    NSLog(@"error=%@",error);
}
@end
