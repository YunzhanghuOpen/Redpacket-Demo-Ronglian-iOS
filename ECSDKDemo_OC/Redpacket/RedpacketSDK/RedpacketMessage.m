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
    [rpModel redpacketMessageModelToDic];
    //    if (rp){
    //        NSError * error;
    //        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:rp options:NSJSONWritingPrettyPrinted error:&error];
    //        if (!error) {
    //            NSString * rpString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    //            self.userData = rpString;
    //        }
    //    }
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

- (BOOL)isTransfer{
    
    if (self.userData) {
        NSError * error;
        NSString * userString = self.userData;
        NSData * userDate = [userString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * userMessage = [NSJSONSerialization JSONObjectWithData:userDate options:NSJSONReadingMutableContainers error:&error];
        if (userMessage && [RedpacketMessageModel isRedpacketTransferMessage:userMessage]) {
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
    if ([self isTransfer]) {
        return @"[转账]";
    }
    
    if (RedpacketMessageTypeRedpacket == self.rpModel.messageType) {
        return [NSString stringWithFormat:@"[%@]%@", self.rpModel.redpacket.redpacketOrgName, self.rpModel.redpacket.redpacketGreeting];
    }
    else if (RedpacketMessageTypeTedpacketTakenMessage == self.rpModel.messageType) {
        NSString *s = nil;
        if (self.isGroup) {
            
            if([self.rpModel.redpacketSender.userId isEqualToString:self.rpModel.redpacketReceiver.userId]) {
                s = @"你领取了自己发的红包";
            }
            else if (self.rpModel.isRedacketSender)
            {
                s = [NSString stringWithFormat:@"%@领取了你的红包",self.rpModel.redpacketReceiver.userNickname];
            }
            else
            {
                s = [NSString stringWithFormat:@"你领取了%@的红包",self.rpModel.redpacketSender.userNickname];
            }
            
        }else
        {
            if ([self.rpModel.currentUser.userId isEqualToString:self.rpModel.redpacketSender.userId]) {
                s = [NSString stringWithFormat:@"%@领取了你的红包",self.rpModel.redpacketReceiver.userNickname];
            }else
            {
                s = [NSString stringWithFormat:@"你领取了%@",self.rpModel.redpacketSender.userNickname];
            }
        }
        return s;
    }
    return @"";
}

- (NSDictionary *)redPacketDic
{
    NSData *data = [self.userData dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 1) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    return dict;
}

- (NSString *)voluationModele:(RedpacketMessageModel *)model
{
    objc_setAssociatedObject(self, @"RedpacketMessageModel", model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSDictionary * rp = [model redpacketMessageModelToDic];
    if (rp){
        NSError * error;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:rp options:NSJSONWritingPrettyPrinted error:&error];
        if (!error) {
            NSString * rpString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            self.userData = rpString;
        }
    }
    [self didChangeValueForKey:@"rpModel"];
    
    return self.userData;
}

- (NSString *)voluationNoticeModele:(RedpacketMessageModel *)model
{
    objc_setAssociatedObject(self, @"RedpacketMessageModel", model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSDictionary * rp = [model.redpacketMessageModelToDic mutableCopy];
    if (rp){
        NSError * error;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:rp options:NSJSONWritingPrettyPrinted error:&error];
        if (!error) {
            NSString * rpString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            self.userData = rpString;
        }
    }
    [self didChangeValueForKey:@"rpModel"];
    
    return self.userData;
}

@end