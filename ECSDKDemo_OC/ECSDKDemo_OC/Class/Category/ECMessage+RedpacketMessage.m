//
//  ECMessage+RedpacketMessage.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/25.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ECMessage+RedpacketMessage.h"
//#import <objc/runtime.h>
#import "DemoGlobalClass.h"
#import "RPRedpacketUnionHandle.h"
#define redpacketMessageModel @"RPRedpacketModel"
#define analysisMessageModel @"AnalysisRedpacketModel"

@implementation ECMessage(RedPacketMessage)

- (void)setRpModel:(RPRedpacketModel *)rpModel{
    [self willChangeValueForKey:@"rpModel"];
    objc_setAssociatedObject(self,redpacketMessageModel, rpModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"rpModel"];
}

- (void)setAnalysisModel:(AnalysisRedpacketModel *)analysisModel
{
    [self willChangeValueForKey:@"analysisModel"];
    objc_setAssociatedObject(self,redpacketMessageModel, analysisModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"analysisModel"];
}


- (RPRedpacketModel *)rpModel{
    RPRedpacketModel *model = [RPRedpacketUnionHandle modelWithChannelRedpacketDic:[self redPacketDic] andSender:nil];
    return model;
}

- (AnalysisRedpacketModel *)analysisModel
{
    return [AnalysisRedpacketModel analysisRedpacketWithDict:[self redPacketDic] andIsSender:[self.from isEqualToString:[DemoGlobalClass sharedInstance].userName]];
}

- (BOOL)isRedpacket{
    if (self.rpModel) {
        return YES;
    }
    if (self.userData) {
        NSDictionary * dict = [self redPacketDic];
        if (dict && [AnalysisRedpacketModel messageCellTypeWithDict:dict] != MessageCellTypeUnknown ) {
            self.analysisModel = [AnalysisRedpacketModel analysisRedpacketWithDict:dict andIsSender:[self.from isEqualToString:[DemoGlobalClass sharedInstance].userName]];
            return YES;
        }
    }
    return NO;
}

- (AnalysisRedpacketModel *)getRpmodel:(NSString*)userdata {
    if (self.userData) {
        NSDictionary * dict = [self redPacketDic];
        if (dict &&  [AnalysisRedpacketModel messageCellTypeWithDict:dict] != MessageCellTypeUnknown) {
            self.analysisModel = [AnalysisRedpacketModel analysisRedpacketWithDict:dict andIsSender:[self.from isEqualToString:[DemoGlobalClass sharedInstance].userName]];
        }
    }
    return self.analysisModel;
}

- (BOOL)isRedpacketOpenMessage
{
    if (self.userData) {
        NSDictionary * dict = [self redPacketDic];
        return  [AnalysisRedpacketModel messageCellTypeWithDict:dict] == MessageCellTypeRedpaketTaken;
    }
    return NO;
}

- (NSString *)redpacketString
{
    if (!self.rpModel) {
        return @"";
    }
    
    if (MessageCellTypeRedpaket == self.analysisModel.type ) {
        
        return [NSString stringWithFormat:@"[%@]%@", self.analysisModel.redpacketOrgName, self.analysisModel.greeting];
        
    } else if (MessageCellTypeRedpaketTaken == self.analysisModel.type) {
        
        NSString *s = nil;
        if (self.isGroup) {
            
            if([[DemoGlobalClass sharedInstance].userName isEqualToString:self.analysisModel.receiver.userID]) {
                s = @"你领取了自己的红包";
            } else if (self.rpModel.isSender) {
                s = [NSString stringWithFormat:@"%@领取了你的红包",self.analysisModel.receiver.userName];
            } else if (![[DemoGlobalClass sharedInstance].userName isEqualToString:self.rpModel.receiver.userName]) {
                s = [NSString stringWithFormat:@"%@领取了%@的红包",self.analysisModel.receiver.userName,self.analysisModel.sender.userName];
            } else {
                s = [NSString stringWithFormat:@"你领取了%@的红包",self.analysisModel.sender.userName];
            }
            
        } else {
            
            if ([[DemoGlobalClass sharedInstance].userName isEqualToString:self.analysisModel.sender.userID]) {
                s = [NSString stringWithFormat:@"%@领取了你的红包",self.analysisModel.receiver.userName];
            } else {
                s = [NSString stringWithFormat:@"你领取了%@的红包",self.analysisModel.sender.userName];
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

+ (NSString *)voluationModele:(RPRedpacketModel *)model
{
    NSString * rpString = nil;
    objc_setAssociatedObject(self,redpacketMessageModel, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSDictionary * rp = [RPRedpacketUnionHandle dictWithRedpacketModel:model isACKMessage:model.receiveMoney.floatValue > 0.009];
    if (rp){
        NSError * error;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:rp options:NSJSONWritingPrettyPrinted error:&error];
        if (!error) {
            rpString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    [self didChangeValueForKey:@"rpModel"];
    
    return rpString;
}

@end
