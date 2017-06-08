//
//  AppDelegate+RedpacketConfig.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/22.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "AppDelegate+RedpacketConfig.h"
#import <AlipaySDK/AlipaySDK.h>
#import "RPRedpacketConstValues.h"
#import "RPRedpacketBridge.h"
#import "RPRedpacketModel.h"

#define DefaultRongLianAppID       @"20150314000000110000000000000010"

@interface AppDelegate () <RPRedpacketBridgeDelegate>

@end

@implementation AppDelegate (RedpacketConfig)

- (void)configRedpacket
{
    [RPRedpacketBridge sharedBridge].delegate = self;
    [RPRedpacketBridge sharedBridge].isDebug = YES;//开发者调试的的时候，设置为YES，看得见日志。
}

- (RPUserInfo *)redpacketUserInfo
{
    RPUserInfo *user = [[RPUserInfo alloc] init];
    DemoGlobalClass * selfUser = [DemoGlobalClass sharedInstance];
    user.userID = [selfUser userName];
    user.userName = [selfUser nickName];
    user.avatar = nil;
    return user;
}

- (NSString *)userId
{
    if ([[DemoGlobalClass sharedInstance] userName]) {
        return [DemoGlobalClass sharedInstance].userName;
    }
    return nil;
}

/* MARK:红包Token注册回调**/
- (void)redpacketFetchRegisitParam:(RPFetchRegisitParamBlock)fetchBlock withError:(NSError *)error
{
    NSString *userId = [self userId];
    if (userId.length) {
        RPRedpacketRegisitModel *model = [RPRedpacketRegisitModel rongCloudModelWithAppId:DefaultRongLianAppID appUserId:userId];
        fetchBlock(model);
    }else {
        fetchBlock(nil);
    }
}
@end
