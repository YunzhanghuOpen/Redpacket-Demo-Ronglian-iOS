//
//  callTextWidth.m
//  ECSDKDemo_OC
//
//  Created by admin on 15/11/18.
//  Copyright © 2015年 ronglian. All rights reserved.
//
#import <CoreText/CoreText.h>
#import "ChatViewCallTextCell.h"

#define LabelFont [UIFont systemFontOfSize:15.0f]
#define BubbleMaxSize CGSizeMake(self.frame.size.width-140.0f, 10000.0f)

@interface ChatViewCallTextCell()

@end
@implementation ChatViewCallTextCell
{
    UILabel *_label;
}

-(void)prepareCellUIWithSender:(BOOL)aIsSender {
    [super prepareCellUIWithSender:aIsSender];
    if (!aIsSender) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 2.0f, self.bubbleView.frame.size.width-15.0f, self.bubbleView.frame.size.height-6.0f)];
    }
    _label.numberOfLines = 0;
    _label.font = [UIFont systemFontOfSize:15.0f];
    _label.lineBreakMode = NSLineBreakByCharWrapping;
    _label.backgroundColor = [UIColor clearColor];
    [self.bubbleView addSubview:_label];
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    
    return 65;
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    ECCallMessageBody *body = (ECCallMessageBody*)self.displayMessage.messageBody;
    _label.text = body.callText;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize bubbleSize = [body.callText sizeWithFont:LabelFont constrainedToSize:BubbleMaxSize lineBreakMode:NSLineBreakByCharWrapping];
#pragma clang diagnostic pop
    if (bubbleSize.height<40.0f) {
        bubbleSize.height=40.0f;
    }

    if (!self.isSender) {
        _label.frame = CGRectMake(16.0f, 2.0f, bubbleSize.width, bubbleSize.height);
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+self.portraitImg.frame.size.width+10.0f, self.portraitImg.frame.origin.y, bubbleSize.width+25, bubbleSize.height+9);
    }
    [self updateMessageSendStatus:self.displayMessage.messageState];
}

@end
