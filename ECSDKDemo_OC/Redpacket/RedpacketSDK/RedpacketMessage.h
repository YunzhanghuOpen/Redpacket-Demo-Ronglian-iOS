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
- (BOOL)isTransfer;
- (NSString *)redpacketString;
- (NSDictionary *)redPacketDic;
- (NSString *)voluationModele:(RedpacketMessageModel *)model;
- (NSString *)voluationNoticeModele:(RedpacketMessageModel *)model;
@end