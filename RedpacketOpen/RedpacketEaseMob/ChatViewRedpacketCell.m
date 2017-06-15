//
//  ChatViewRedpacketCell.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/22.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewRedpacketCell.h"
#import "RPRedpacketConstValues.h"

#define Redpacket_Message_Font_Size 14
#define Redpacket_SubMessage_Font_Size 12
#define Redpacket_SubMessage_Text NSLocalizedString(@"查看红包", @"查看红包")
#define Redpacket_Label_Padding 2

#define REDPACKET_BUNDLE(name) @"RedpacketCellResource.bundle/" name

static const CGFloat kXHAvatorPaddingX = 8.0;

@interface ChatViewRedpacketCell ()
@property(strong, nonatomic) UILabel *greetingLabel;
@property(strong, nonatomic) UILabel *subLabel; // 显示 "查看红包"
@property(strong, nonatomic) UILabel *orgLabel;
@property(strong, nonatomic) UIImageView *iconView;
@property(strong, nonatomic) UILabel *orgTypeLabel;

@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

@end

@implementation ChatViewRedpacketCell

-(void)prepareCellUIWithSender:(BOOL)aIsSender {
    [super prepareCellUIWithSender:aIsSender];
    
    [self.bubleimg removeFromSuperview];
    
    self.bubbleView.backgroundColor = self.backgroundColor;
    
    // 设置背景
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,198, 94)];
    self.bubbleBackgroundView.autoresizingMask = UIViewAutoresizingNone;
    [self.bubbleView addSubview:self.bubbleBackgroundView];
    
    [self prepareRedpacketUI];
    
    if (self.isSender) {
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-198, self.portraitImg.frame.origin.y, 198, 94.0);
        UIImage *image = [UIImage imageNamed:REDPACKET_BUNDLE(@"redpacket_sender_bg")];
        self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 25, 20)];
        
    } else {
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 198, 94.0f);
        UIImage *image = [UIImage imageNamed:REDPACKET_BUNDLE(@"redpacket_receiver_bg")];
        self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 25, 20)];
    }
}

- (void)prepareRedpacketUI {
    
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.bubbleBackgroundView addGestureRecognizer:tap];
    
    // 设置红包图标
    UIImage *icon = [UIImage imageNamed:REDPACKET_BUNDLE(@"redPacket_redPacktIcon")];
    self.iconView = [[UIImageView alloc] initWithImage:icon];
    self.iconView.frame = CGRectMake(13, 19, 26, 34);
    [self.bubbleBackgroundView addSubview:self.iconView];
    
    // 设置红包文字
    self.greetingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.greetingLabel.frame = CGRectMake(48, 19, 137, 15);
    self.greetingLabel.font = [UIFont systemFontOfSize:Redpacket_Message_Font_Size];
    self.greetingLabel.textColor = [UIColor whiteColor];
    self.greetingLabel.numberOfLines = 1;
    [self.greetingLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.greetingLabel setTextAlignment:NSTextAlignmentLeft];
    [self.bubbleBackgroundView addSubview:self.greetingLabel];
    
    // 设置次级文字
    self.subLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    CGRect frame = self.greetingLabel.frame;
    frame.origin.y = 41;
    self.subLabel.frame = frame;
    self.subLabel.text = Redpacket_SubMessage_Text;
    self.subLabel.font = [UIFont systemFontOfSize:Redpacket_SubMessage_Font_Size];
    self.subLabel.numberOfLines = 1;
    self.subLabel.textColor = [UIColor whiteColor];
    self.subLabel.numberOfLines = 1;
    [self.subLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.subLabel setTextAlignment:NSTextAlignmentLeft];
    [self.bubbleBackgroundView addSubview:self.subLabel];
    
    // 设置次级文字
    self.orgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    frame = CGRectMake(13, 76, 150, 12);
    self.orgLabel.frame = frame;
    self.orgLabel.text = Redpacket_SubMessage_Text;
    self.orgLabel.font = [UIFont systemFontOfSize:Redpacket_SubMessage_Font_Size];
    self.orgLabel.numberOfLines = 1;
    self.orgLabel.textColor = [UIColor lightGrayColor];
    self.orgLabel.numberOfLines = 1;
    [self.orgLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.orgLabel setTextAlignment:NSTextAlignmentLeft];
    [self.bubbleBackgroundView addSubview:self.orgLabel];
    
    // 设置红包类型
    self.orgTypeLabel = [[UILabel alloc] init];
    self.orgTypeLabel.textColor = [self hexColor:0xf14e46];
    self.orgTypeLabel.font = [UIFont systemFontOfSize:12.0];
    [self.bubbleBackgroundView addSubview:self.orgTypeLabel];
    
    
    CGRect rt = self.orgTypeLabel.frame;
    rt.origin = CGPointMake(145, 75);
    if (self.isSender) {
        rt.origin = CGPointMake(141, 75);
    }
    rt.size = CGSizeMake(51, 14);
    self.orgTypeLabel.frame = rt;
}

- (UIColor *)hexColor:(uint)color
{
    float r = (color&0xFF0000) >> 16;
    float g = (color&0xFF00) >> 8;
    float b = (color&0xFF);
    
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
}

- (void)bubbleViewWithData:(ECMessage *)message{
    [super bubbleViewWithData:message];
    
    self.greetingLabel.text = message.analysisModel.greeting;
    self.orgLabel.text = @"容联云红包";//orgString;
    
    if (message.rpModel.redpacketType == RPRedpacketTypeGoupMember) {
        self.orgTypeLabel.text = @"专属红包";
    }else
    {
        self.orgTypeLabel.text = @"";
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat bubbleX = 0.0f;
    
    if (self.isSender) {
        bubbleX = CGRectGetMinX(self.portraitImg.frame) - 198 - kXHAvatorPaddingX;
    } else {
        bubbleX = CGRectGetMaxX(self.portraitImg.frame) + kXHAvatorPaddingX;
    }
    
    CGFloat bubbleViewY = CGRectGetMinY(self.portraitImg.frame);
    
    
    CGRect frame = CGRectMake(bubbleX,
                              bubbleViewY,
                              198.0F,
                              94.0f);
    self.bubbleView.frame = frame;
    [super updateMessageSendStatus:self.displayMessage.messageState];
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message {
    return 110.0f;
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(redpacketCell:didTap:)]) {
            [self.delegate redpacketCell:self didTap:self.displayMessage];
        }
    }
}
@end
