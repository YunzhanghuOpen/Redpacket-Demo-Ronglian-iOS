//
//  RedpacketConfig.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketConfig.h"
#import <objc/runtime.h>
#import "AFNetworking.h"
#import "DemoGlobalClass.h"
#import "YZHRedpacketBridge.h"
#import "RedpacketMessageModel.h"

//	*此为演示地址* App需要修改为自己AppServer上的地址, 数据格式参考此地址给出的格式。 详情http://yunzhanghu-com.oss-cn-qdjbp-a.aliyuncs.com/云账户红包SDK接入指南%28iOS%29%20v3.pdf
static NSString *requestUrl = @"http://10.10.1.10:32773/api/sign?duid=";

@interface RedpacketConfig ()

@end

@implementation RedpacketConfig

+ (instancetype)sharedConfig
{
    static RedpacketConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[RedpacketConfig alloc] init];
        [[YZHRedpacketBridge sharedBridge] setDataSource:config];
        [[YZHRedpacketBridge sharedBridge] setDelegate:config];
        [YZHRedpacketBridge sharedBridge].redacketURLScheme = @"com.redpacket.RLCloudDemo";//支付宝回调使用Key;
        [YZHRedpacketBridge sharedBridge].isDebug = YES;
        [YZHRedpacketBridge sharedBridge].urlHost = @"http://10.10.1.10:32773/";//baseUrl 赋值举例
    });
    return config;
}

+ (void)config
{
    [[self sharedConfig] config];
}

+ (void)logout
{
//    [[YZHRedpacketBridge sharedBridge] redpacketUserLoginOut];
}

+ (void)reconfig
{
    [self logout];
    [[self sharedConfig] config];
}

- (void)configWithSignDict:(NSDictionary *)dict
{
    NSString *partner = [dict valueForKey:@"partner"];
    NSString *appUserId = [dict valueForKey:@"user_id"];
    NSString *timeStamp = [NSString stringWithFormat:@"%@",[dict valueForKey:@"timestamp"]];
    NSString *sign = [dict valueForKey:@"sign"];
    
    
    [[YZHRedpacketBridge sharedBridge] configWithSign:sign partner:partner appUserId:appUserId timestamp:timeStamp];
}

- (void)config
{
        NSString *userId = [self userId];
        
        if (userId) {
            
            // 获取应用自己的签名字段。实际应用中需要开发者自行提供相应在的签名计算服务
            
            NSString *urlStr = [NSString stringWithFormat:@"%@%@",requestUrl, userId];
            NSURL *url = [NSURL URLWithString:urlStr];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            [[[AFHTTPRequestOperationManager manager] HTTPRequestOperationWithRequest:request
                                                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                  if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                                                                      [self configWithSignDict:responseObject];
                                                                                  }
                                                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                  NSLog(@"request redpacket sign failed:%@", error);
                                                                              }] start];
        }
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

- (void)redpacketError:(NSString *)error withErrorCode:(NSInteger)code
{
    [self config];
}

@end
