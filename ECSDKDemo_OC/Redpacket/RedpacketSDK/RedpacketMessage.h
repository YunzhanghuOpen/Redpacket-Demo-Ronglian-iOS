//
//  RedpacketMessage.h
//  LeanChat
//
//  Created by YANG HONGBO on 2016-5-6.
//  Copyright © 2016年 云帐户. All rights reserved.
//
#import "ECMessage.h"
#import "RedpacketMessageModel.h"

@interface ECMessage(RedPacketMessage)
@property(nonatomic,strong)RedpacketMessageModel * rpModel;
- (BOOL)isRedpacket;
- (BOOL)isRedpacketOpenMessage;
- (NSString *)redpacketString;
- (NSDictionary *)redPacketDic;
//红包调用
- (NSString *)voluationModele:(RedpacketMessageModel *)model;
//红包消息通知调用
- (NSString *)voluationNoticeModele:(RedpacketMessageModel *)model;
@end