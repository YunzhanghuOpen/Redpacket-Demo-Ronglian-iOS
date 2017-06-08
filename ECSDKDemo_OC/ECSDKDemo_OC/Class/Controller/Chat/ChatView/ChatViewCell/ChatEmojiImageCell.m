//
//  ChatEmojiImageCell.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/5.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatEmojiImageCell.h"
#import "YLGIFImage.h"
#import "YLImageView.h"

NSString *const KResponderCustomChatViewEmojiImageCellBubbleViewEvent = @"KResponderCustomChatViewEmojiImageCellBubbleViewEvent";
NSString *const KResponderCustomEmojiCodeKey = @"KResponderCustomEmojiCodeKey";

@interface ChatEmojiImageCell ()
@property (nonatomic, strong) YLImageView *emojiImageView;
@property (nonatomic, copy) NSString *emojiCode;
@end

@implementation ChatEmojiImageCell

-(void)prepareCellUIWithSender:(BOOL)aIsSender {
    [super prepareCellUIWithSender:aIsSender];
    _emojiCode = nil;
    [self.bubleimg removeFromSuperview];
    _emojiImageView = [[YLImageView alloc] init];
    _emojiImageView.layer.cornerRadius = 2;
    _emojiImageView.layer.masksToBounds = YES;
    _emojiImageView.contentMode = UIViewContentModeScaleAspectFill;
    _emojiImageView.clipsToBounds = YES;
    
    if (self.isSender) {
        _emojiImageView.frame = CGRectMake(5, 5, 100, 100);
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-130.0f, self.portraitImg.frame.origin.y, 120.0f, 120.0f);
        
    } else {
        _emojiImageView.frame = CGRectMake(15, 5, 100, 100);
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 120.0f, 120.0f);
    }
    [self.bubbleView addSubview:_emojiImageView];
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 140.0f;
}

-(void)bubbleViewTapGesture:(id)sender {
    if (_emojiCode) {
        [self dispatchCustomEventWithName:KResponderCustomChatViewEmojiImageCellBubbleViewEvent userInfo:@{KResponderCustomEmojiCodeKey:_emojiCode}];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.emojiImageView.image = [UIImage imageNamed:@"mm_emoji_loading"];
    if (self.displayMessage.userData) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[self.displayMessage.userData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if (!dict) {
            return;
        }
        if (dict[txt_msgType]) {
            NSArray *codes = nil;
            if (dict[faceEmojiArray]) {
                codes = @[dict[faceEmojiArray][0][0]];
            }
            MMFetchType type = dict[faceEmojiArray][0][1]?MMFetchTypeBig:MMFetchTypeSmall;
            __weak typeof(self) weakself = self;
            [[MMEmotionCentre defaultCentre] fetchEmojisByType:type codes:codes completionHandler:^(NSArray *emojis) {
                __strong typeof(weakself)strongSelf = weakself;
                if (emojis.count > 0) {
                    MMEmoji *emoji = emojis[0];
                    if ([codes[0] isEqualToString:emoji.emojiCode]) {
                        strongSelf.emojiImageView.image = [YLGIFImage imageWithData:emoji.emojiData];
                        _emojiCode = emoji.emojiCode;
                    }
                }
                else {
                    strongSelf.emojiImageView.image = [UIImage imageNamed:@"mm_emoji_error"];
                }
                
            }];
        }
    }
    [super updateMessageSendStatus:self.displayMessage.messageState];
}
@end
