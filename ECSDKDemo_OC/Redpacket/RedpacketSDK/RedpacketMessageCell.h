      //
//  RedpacketMessageCell.h
//  LeanChat
//
//  Created by YANG HONGBO on 2016-5-7.
//  Copyright © 2016年 云帐户. All rights reserved.
//


#import "ChatViewCell.h"

@class RedpacketMessageCell;
@protocol RedpacketCellDelegate <NSObject>

- (void)redpacketCell:(RedpacketMessageCell *)cell didTap:(ECMessage *)message;

@end

@interface RedpacketMessageCell : ChatViewCell
//@property (nonatomic, strong, readonly) id<XHMessageModel> message;
@property (nonatomic, weak, readwrite) id<RedpacketCellDelegate> redpacketDelegate;
@end
