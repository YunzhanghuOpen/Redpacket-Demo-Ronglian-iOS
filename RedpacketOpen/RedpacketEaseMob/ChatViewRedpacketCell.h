//
//  ChatViewRedpacketCell.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/22.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewCell.h"
#import "ECMessage+RedpacketMessage.h"

@class ChatViewRedpacketCell;
@protocol ChatViewRedpacketCellDelegate <NSObject>

- (void)redpacketCell:(ChatViewRedpacketCell *)cell didTap:(ECMessage *)message;

@end

@interface ChatViewRedpacketCell : ChatViewCell
@property (nonatomic, weak) id<ChatViewRedpacketCellDelegate> delegate;
@end
