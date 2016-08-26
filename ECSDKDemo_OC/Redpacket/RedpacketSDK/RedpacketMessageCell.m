//
//  RedpacketMessageCell.m
//  LeanChat
//
//  Created by YANG HONGBO on 2016-5-7.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketMessageCell.h"
#import "RedpacketMessage.h"
@import ObjectiveC;

#define Redpacket_Message_Font_Size 14
#define Redpacket_SubMessage_Font_Size 12
#define Redpacket_SubMessage_Text NSLocalizedString(@"查看红包", @"查看红包")
#define Redpacket_Label_Padding 2

#define REDPACKET_BUNDLE(name) @"RedpacketCellResource.bundle/" name


static const CGFloat kXHAvatorPaddingX = 8.0;


#define kPeerNameZoneHeight(displayPeerName)  (displayPeerName ? kXHPeerNameLabelHeight : 0)

@interface RedpacketMessageCell ()
@property(strong, nonatomic) UILabel *greetingLabel;
@property(strong, nonatomic) UILabel *subLabel; // 显示 "查看红包"
@property(strong, nonatomic) UILabel *orgLabel;
@property(strong, nonatomic) UIImageView *iconView;
@property(strong, nonatomic) UIImageView *orgIconView;

@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

@property (nonatomic, weak) UIView *messageContentView;

@property (nonatomic, strong, readwrite) ECMessage * message;
@end

@implementation RedpacketMessageCell
- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.messageContentView = self.contentView;
        
        // 设置背景
        self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.bubbleBackgroundView.autoresizingMask = UIViewAutoresizingNone;
        [self.messageContentView addSubview:self.bubbleBackgroundView];
        
        self.bubbleView.hidden = YES;
        [self initialize];
        
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    
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
    
    //    self.orgIconView = [[UIImageView alloc] initWithImage:icon];
    [self.bubbleBackgroundView addSubview:self.orgIconView];
    
    
    CGRect rt = self.orgIconView.frame;
    rt.origin = CGPointMake(165, 75);
    rt.size = CGSizeMake(21, 14);
    self.orgIconView.frame = rt;
    
}

- (void)bubbleViewWithData:(ECMessage *)message{
    [super bubbleViewWithData:message];
    
    self.message = message;
    RedpacketMessageModel *redpacketMessage = message.rpModel;
    NSString *messageString = redpacketMessage.redpacket.redpacketGreeting;
    self.greetingLabel.text = messageString;
    
    NSString *orgString = redpacketMessage.redpacket.redpacketOrgName;
    self.orgLabel.text = orgString;
    
    
    CGRect messageContentViewRect = self.messageContentView.frame;
    
    // 设置红包文字
    if (!self.isSender) {
        messageContentViewRect.size.width = 198;
        self.messageContentView.frame = messageContentViewRect;
        
        self.bubbleBackgroundView.frame = CGRectMake(-8, 0,198, 94);
        UIImage *image;
        if ([self.message isTransfer]) {
            image = [UIImage imageNamed:REDPACKET_BUNDLE(@"transfer_receiver_bg")];
            self.greetingLabel.text = @"已收到对方转账";
        }else
        {
            image = [UIImage imageNamed:REDPACKET_BUNDLE(@"redpacket_receiver_bg")];
        }
        
        self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 25, 20)];
    } else {
        
        messageContentViewRect.size.width = 198;
        messageContentViewRect.origin.x = self.messageContentView.bounds.size.width - (messageContentViewRect.size.width + 12 + 50 /*头像部分尺寸*/ + 10);
        self.messageContentView.frame = messageContentViewRect;
        
        self.bubbleBackgroundView.frame = CGRectMake(-8, 0, 198, 94);
        UIImage *image;
        if ([self.message isTransfer]) {
            image = [UIImage imageNamed:REDPACKET_BUNDLE(@"transfer_sender_bg")];
            self.greetingLabel.text = @"对方已收到转账";
        }else
        {
            image = [UIImage imageNamed:REDPACKET_BUNDLE(@"redpacket_sender_bg")];
        }
        self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(70, 9, 25, 20)];
    }
    if ([self.message isTransfer]) {
        UIImage *icon = [UIImage imageNamed:REDPACKET_BUNDLE(@"redPacket_transferIcon")];
        self.iconView.frame = CGRectMake(13, 19, 34, 34);
        [self.iconView setImage:icon];
        self.subLabel.text = [NSString stringWithFormat:@"%@元",self.message.rpModel.redpacket.redpacketMoney];
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
                              198,
                              94);
    self.bubbleBackgroundView.frame = frame;
    [super updateMessageSendStatus:self.displayMessage.messageState];
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        //        [self.delegate didTapMessageCell:self.model];
        [self.redpacketDelegate redpacketCell:self didTap:self.message];
    }
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message {
    //    CGSize bubbleSize = CGSizeMake(198, 94);
    return 110;
}



@end
