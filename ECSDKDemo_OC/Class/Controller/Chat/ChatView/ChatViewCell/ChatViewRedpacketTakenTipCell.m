//
//  ChatViewRedpacketTakenTipCell.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/22.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewRedpacketTakenTipCell.h"
#import "ECMessage+RedpacketMessage.h"

#define REDPACKET_BUNDLE(name) @"RedpacketCellResource.bundle/" name
#define BACKGROUND_LEFT_RIGHT_PADDING 10
#define ICON_LEFT_RIGHT_PADDING 2

@interface ChatViewRedpacketTakenTipCell ()
@property(nonatomic, strong) UIView *bgView;

@property(strong, nonatomic) UILabel *tipMessageLabel;
@property(strong, nonatomic) UIImageView *iconView;
@property (nonatomic, strong, readwrite) ECMessage * message;

@end

@implementation ChatViewRedpacketTakenTipCell

-(void)prepareCellUIWithSender:(BOOL)aIsSender {

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    
    self.bgView = [[UIView alloc] initWithFrame:self.bounds];
    self.bgView.userInteractionEnabled = NO;
    self.bgView.backgroundColor = [UIColor colorWithRed:0xdd * 1.0f / 255.0f
                                                  green:0xdd * 1.0f / 255.0f
                                                   blue:0xdd * 1.0f / 255.0f
                                                  alpha:1.0f];
    self.bgView.autoresizingMask = UIViewAutoresizingNone;
    self.bgView.layer.cornerRadius = 4.0f;
    [self.contentView addSubview:self.bgView];
    
    self.tipMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.tipMessageLabel.font = [UIFont systemFontOfSize:12];
    self.tipMessageLabel.textColor = [UIColor colorWithRed:0x9e * 1.0f / 255.0f
                                                     green:0x9e * 1.0f / 255.0f
                                                      blue:0x9e * 1.0f / 255.0f
                                                     alpha:1.0f];
    self.tipMessageLabel.userInteractionEnabled = NO;
    self.tipMessageLabel.numberOfLines = 1;
    [self.bgView addSubview:self.tipMessageLabel];
    
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 15)];
    self.iconView.image = [UIImage imageNamed:REDPACKET_BUNDLE(@"redpacket_smallIcon")];
    self.iconView.userInteractionEnabled = NO;
    [self.bgView addSubview:self.iconView];
}

- (void)bubbleViewWithData:(ECMessage *)message{
    [super bubbleViewWithData:message];
    self.message = message;
    
    self.tipMessageLabel.text = [message redpacketString];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.tipMessageLabel sizeToFit];
    
    CGRect frame = self.tipMessageLabel.frame;
    CGRect iconFrame = self.iconView.frame;
    CGRect bgFrame = CGRectMake(0, 0.0f,
                                frame.size.width + iconFrame.size.width + 2 * BACKGROUND_LEFT_RIGHT_PADDING,
                                22);
    
    frame.origin.y = (bgFrame.size.height - frame.size.height) * 0.5;
    iconFrame.origin.x = BACKGROUND_LEFT_RIGHT_PADDING - ICON_LEFT_RIGHT_PADDING;
    iconFrame.origin.y = frame.origin.y + (frame.size.height - iconFrame.size.height) * 0.5;
    self.iconView.frame = iconFrame;
    
    frame.origin.x = ICON_LEFT_RIGHT_PADDING + iconFrame.origin.x + iconFrame.size.width;
    self.tipMessageLabel.frame = frame;
    
    bgFrame.origin.y = (self.frame.size.height - bgFrame.size.height) * 0.5f;
    bgFrame.origin.x = (self.bounds.size.width - bgFrame.size.width) * 0.5;
    
    self.bgView.frame = bgFrame;
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message {
    return 40;
}

@end
