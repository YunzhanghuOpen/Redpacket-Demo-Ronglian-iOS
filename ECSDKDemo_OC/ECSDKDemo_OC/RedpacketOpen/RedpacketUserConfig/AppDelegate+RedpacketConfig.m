//
//  AppDelegate+RedpacketConfig.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/22.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "AppDelegate+RedpacketConfig.h"
#import <AlipaySDK/AlipaySDK.h>
#import "YZHRedpacketBridgeProtocol.h"
#import "RedpacketOpenConst.h"
#import "YZHRedpacketBridge.h"
#import "RedpacketMessageModel.h"


#define DefaultRongLianAppID       @"20150314000000110000000000000010"

@interface AppDelegate () <YZHRedpacketBridgeDataSource,
                           YZHRedpacketBridgeDelegate>

@end

@implementation AppDelegate (RedpacketConfig)

- (void)configRedpacket
{
    [YZHRedpacketBridge sharedBridge].isDebug = YES;
    [YZHRedpacketBridge sharedBridge].dataSource = self;
    [YZHRedpacketBridge sharedBridge].delegate = self;
}

- (RedpacketUserInfo *)redpacketUserInfo
{
    RedpacketUserInfo *user = [[RedpacketUserInfo alloc] init];
    DemoGlobalClass * selfUser = [DemoGlobalClass sharedInstance];
    user.userId = [selfUser userName];
    user.userNickname = [selfUser nickName];
    user.userAvatar = nil;
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
- (void)redpacketFetchRegisitParam:(FetchRegisitParamBlock)fetchBlock withError:(NSError *)error
{
    NSString *userId = [self userId];
    if (userId.length) {
        RedpacketRegisitModel *model = [RedpacketRegisitModel rongCloudModelWithAppId:DefaultRongLianAppID appUserId:userId];
        fetchBlock(model);
    }else {
        fetchBlock(nil);
    }
}

@end
