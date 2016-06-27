//
//  RedpacketMessage.m
//  LeanChat
//
//  Created by YANG HONGBO on 2016-5-6.
//  Copyright © 2016年 云帐户. All rights reserved.
//
#import "RedpacketMessage.h"
#import <objc/runtime.h>
@implementation ECMessage(RedPacketMessage)

- (void)setRpModel:(RedpacketMessageModel *)rpModel{
    [self willChangeValueForKey:@"rpModel"];
    objc_setAssociatedObject(self, @"RedpacketMessageModel", rpModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSDictionary * rp = [rpModel redpacketMessageModelToDic];
    if (!rp) return;
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:rp options:NSJSONWritingPrettyPrinted error:&error];
    if (!error) {
        NSString * rpString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        self.userData = rpString;
    };
    [self didChangeValueForKey:@"rpModel"];
}
- (RedpacketMessageModel *)rpModel{
    return objc_getAssociatedObject(self, @"RedpacketMessageModel");
}

- (BOOL)isRedpacket{
    
    if (self.userData) {
        NSError * error;
        NSString * userString = self.userData;
        NSData * userDate = [userString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * userMessage = [NSJSONSerialization JSONObjectWithData:userDate options:NSJSONReadingMutableContainers error:&error];
        if (userMessage && [RedpacketMessageModel isRedpacketRelatedMessage:userMessage]) {
            RedpacketMessageModel * redpacketModel = [RedpacketMessageModel redpacketMessageModelWithDic:userMessage];
            self.rpModel = redpacketModel;
            return YES;
        }
    }
    return NO;
}

- (BOOL)isRedpacketOpenMessage
{
    if (self.userData) {
        NSError * error;
        NSString * userString = self.userData;
        NSData * userDate = [userString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * userMessage = [NSJSONSerialization JSONObjectWithData:userDate options:NSJSONReadingMutableContainers error:&error];
        return  ![RedpacketMessageModel isRedpacket:userMessage];
    }
    return NO;
}

- (NSString *)redpacketString
{
    if (!self.rpModel) {
        return @"";
    }
    
    if (RedpacketMessageTypeRedpacket == self.rpModel.messageType) {
        return [NSString stringWithFormat:@"[%@]%@", self.rpModel.redpacket.redpacketOrgName, self.rpModel.redpacket.redpacketGreeting];
    }
    else if (RedpacketMessageTypeTedpacketTakenMessage == self.rpModel.messageType) {
        NSString *s = nil;
        if([self.rpModel.currentUser.userId isEqualToString:self.rpModel.redpacketReceiver.userId]) {
            // 显示我抢了别人的红包的提示
            if ([self.rpModel.redpacketSender.userId isEqualToString:self.rpModel.redpacketReceiver.userId]) {
                s = @"你领取了自己的红包";
            }
            else {
                s =[NSString stringWithFormat:@"%@%@%@", // 你领取了 XXX 的红包
                    NSLocalizedString(@"你领取了", @"领取红包消息"),
                    self.rpModel.redpacketSender.userNickname,
                    NSLocalizedString(@"的红包", @"领取红包消息结尾")
                    ];
            }
        }
        else { // 收到了别人抢了我的红包的消息提示
            s = [NSString stringWithFormat:@"%@%@", // XXX 领取了你的红包
                 self.rpModel.redpacketReceiver.userNickname,
                 NSLocalizedString(@"领取了你的红包", @"领取红包消息")];
        }
        return s;
    }
    return @"";
}
@end