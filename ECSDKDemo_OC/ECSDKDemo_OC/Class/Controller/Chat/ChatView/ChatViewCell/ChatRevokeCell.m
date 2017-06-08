//
//  ChatRevokeCell.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/6/13.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatRevokeCell.h"
#import "ECRevokeMessageBody.h"

#define BubbleMaxSize CGSizeMake(260.0f, 80.0f)
@interface ChatRevokeCell ()
@property (nonatomic, strong) UILabel *revokeLabel;
@end

@implementation ChatRevokeCell
+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)messageBody {
    CGFloat height = 40.0f;
    ECRevokeMessageBody *body = (ECRevokeMessageBody*)messageBody;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize bubbleSize = [body.text sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:BubbleMaxSize lineBreakMode:NSLineBreakByCharWrapping];
#pragma clang diagnostic pop
    
    if (bubbleSize.height>45.0f) {
        height = bubbleSize.height+20.0f;
    }
    return height;
}

-(void)prepareCellUIWithSender:(BOOL)aIsSender {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30.0f)];
    [self.contentView addSubview:self.timeLabel];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.font = [UIFont systemFontOfSize:11.0f];
    self.timeLabel.backgroundColor = self.backgroundColor;
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.hidden = YES;
    
    _revokeLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-110)/2,CGRectGetMaxY(self.timeLabel.frame), 110, 20.0f)];
    _revokeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_revokeLabel];
    _revokeLabel.font = [UIFont systemFontOfSize:12.0f];
    _revokeLabel.textColor = [UIColor whiteColor];
    _revokeLabel.highlightedTextColor = [UIColor whiteColor];
    _revokeLabel.backgroundColor = [UIColor lightGrayColor];
    _revokeLabel.layer.cornerRadius = 5;
    _revokeLabel.layer.masksToBounds = YES;
    _revokeLabel.numberOfLines = 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    ECRevokeMessageBody *body = (ECRevokeMessageBody*)self.displayMessage.messageBody;
    _revokeLabel.text = body.text;
    
    //是否显示时间
    NSNumber *isShowNumber = objc_getAssociatedObject(self.displayMessage, &KTimeIsShowKey);
    BOOL isShow = isShowNumber.boolValue;
    self.timeLabel.hidden = !isShow;
    
    CGRect frame = _revokeLabel.frame;
    CGSize size = [body.text sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:BubbleMaxSize lineBreakMode:NSLineBreakByCharWrapping];
    frame.size.width = size.width+10;
    frame.origin.x = (self.frame.size.width - frame.size.width)/2;
    if (isShow) {
        self.timeLabel.text = [self getDateDisplayString:self.displayMessage.timestamp.longLongValue];
        frame.origin.y = 40.0f;
    } else {
        frame.origin.y = 0;
    }
    _revokeLabel.frame = frame;
}
@end
