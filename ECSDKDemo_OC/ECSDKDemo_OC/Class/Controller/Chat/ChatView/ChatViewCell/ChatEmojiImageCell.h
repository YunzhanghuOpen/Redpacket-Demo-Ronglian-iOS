//
//  ChatEmojiImageCell.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/5.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewCell.h"
//BQMM集成
#import <BQMM/BQMM.h>
#import "MMTextParser.h"

#define txt_msgType @"txt_msgType"
#define faceEmojiArray @"msg_data"
#define EmojiType_BigeEmoji @"EmojiType_BigeEmoji"

extern NSString *const KResponderCustomChatViewEmojiImageCellBubbleViewEvent;
extern NSString *const KResponderCustomEmojiCodeKey;
@interface ChatEmojiImageCell : ChatViewCell

@end
