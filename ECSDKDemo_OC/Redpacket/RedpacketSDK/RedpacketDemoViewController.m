//
//  RedpacketDemoViewController.m
//  LeanChat
//
//  Created by YANG HONGBO on 2016-5-5.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketDemoViewController.h"



#pragma mark - 红包相关头文件
#import "RedpacketViewControl.h"
#import "YZHRedpacketBridge.h"
#import "RedpacketMessage.h"
#import "RedpacketMessageCell.h"
#import "RedpacketTakenMessageTipCell.h"
#import "DeviceChatHelper.h"
#import "ChatViewCell.h"
#import "RedpacketMessage.h"
#import <objc/runtime.h>
#import <objc/message.h>
#pragma mark -

#pragma mark - 红包相关的宏定义
#define REDPACKET_BUNDLE(name) @"RedpacketCellResource.bundle/" name
#pragma mark -

static NSString *const RedpacketMessageCellReceiverIdentifier = @"RedpacketMessageCellReceiverIdentifier";
static NSString *const RedpacketMessageCellSenderIdentifier = @"RedpacketMessageCellSenderIdentifier";
static NSString *const RedpacketTakenMessageTipCellReceiverIdentifier = @"RedpacketTakenMessageTipCellReceiverIdentifier";
static NSString *const RedpacketTakenMessageTipCellSenderIdentifier = @"RedpacketTakenMessageTipSenderCellIdentifier";

@interface RedpacketDemoViewController () <RedpacketCellDelegate,RedpacketCellDelegate>

@property (nonatomic, strong, readwrite) RedpacketViewControl *redpacketControl;

@end

@implementation RedpacketDemoViewController

//#pragma mark - 红包功能入口事件处理
- (void)redPacketTap:(id)sender{
    if (!isGroup) {
        [self.redpacketControl presentRedPacketViewController];
    }else{
        __weak typeof(self) weakSelf = self;
        [[ECDevice sharedInstance].messageManager queryGroupMembers:self.sessionId completion:^(ECError *error, NSString* groupId, NSArray *members) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error.errorCode == ECErrorType_NoError && [strongSelf.sessionId isEqualToString:groupId]) {
                [self.redpacketControl presentRedPacketMoreViewControllerWithCount:(int)members.count];
            }
        }];
        
        
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    /**
     红包功能的控制器， 产生用户单击红包后的各种动作
     */
    _redpacketControl = [[RedpacketViewControl alloc] init];
    //  需要当前的聊天窗口
    _redpacketControl.conversationController = self;
    //  需要当前聊天窗口的会话ID
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    userInfo.userId = self.sessionId;
    _redpacketControl.converstationInfo = userInfo;
    
    __weak typeof(self) weakSelf = self;
    
    //  用户抢红包和用户发送红包的回调
    [_redpacketControl setRedpacketGrabBlock:^(RedpacketMessageModel *messageModel) {
        //  发送通知到发送红包者处
        [weakSelf sendRedpacketHasBeenTaked:messageModel];
        
    } andRedpacketBlock:^(RedpacketMessageModel *model) {
        //  发送红包
        [weakSelf sendRedpacketMessage:model];
        
    }];
    // 通知 红包 SDK 刷新 Token
    [[YZHRedpacketBridge sharedBridge] reRequestRedpacketUserToken];
}
//
//
#pragma mark - 消息与红包插件消息转换与处理
// 发送红包消息
- (void)sendRedpacketMessage:(RedpacketMessageModel *)redpacket
{
    userInputState = 0;
    if (_timer) {
        [[DeviceChatHelper sharedInstance] sendUserState:UserState_None to:self.sessionId];
    }
    
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:@"红包消息"];
    ECMessage *message = [[ECMessage alloc] initWithReceiver:self.sessionId body:messageBody];
    message.rpModel = redpacket;
    
    ECMessage* sendMessage = [[DeviceChatHelper sharedInstance] sendMessage:message];;

    [[DemoGlobalClass sharedInstance].AtPersonArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:sendMessage];
    
}

//  MARK: 发送红包被抢的消息
- (void)sendRedpacketHasBeenTaked:(RedpacketMessageModel *)redpacket
{
    NSString *text = [NSString stringWithFormat:@"%@领取了你的红包", redpacket.redpacketReceiver.userNickname];
    
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:text];
    ECMessage *message = [[ECMessage alloc] initWithReceiver:self.sessionId body:messageBody];
    message.rpModel = redpacket;
    message.isRead = YES;
    ECMessage* sendMessage = [[DeviceChatHelper sharedInstance] sendMessage:message];;
    
    [[DemoGlobalClass sharedInstance].AtPersonArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:sendMessage];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECMessage * message = [self.messageArray objectAtIndex:indexPath.row];
    if ([message isKindOfClass:[ECMessage class]] && [message isRedpacket]) {
        return [RedpacketMessageCell getHightOfCellViewWith:message.messageBody];
    }
    
//    struct objc_super sp;
//    sp.receiver = self;
//    sp.super_class = object_getClass(class_getSuperclass(self.class));
//    double returnValue = ((double (*)(id self, SEL op, ...))objc_msgSend_fpret)(self, @selector(tableView:heightForRowAtIndexPath:),tableView,indexPath);
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ECMessage * message = [self.messageArray objectAtIndex:indexPath.row];
    BOOL isSender = (message.messageState==ECMessageState_Receive?NO:YES);
    NSInteger fileType = message.messageBody.messageBodyType;
    NSString *cellidentifier = [NSString stringWithFormat:@"%@_%@_%d", isSender?@"issender":@"isreceiver",RedpacketMessageCellReceiverIdentifier,(int)fileType];
    
    if ([message isKindOfClass:[ECMessage class]] && [message isRedpacket]) {
        
         if ([message isRedpacketOpenMessage]) {
             RedpacketTakenMessageTipCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
             if (!cell) {
                 cell = [[RedpacketTakenMessageTipCell alloc]initWithIsSender:isSender reuseIdentifier:cellidentifier];
                 [cell bubbleViewWithData:message];
             }
             return cell;
         }else{
             
         NSString *cellRedpacketMessageidentifier = @"cellRedpacketMessageidentifier";
         RedpacketMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:cellRedpacketMessageidentifier];
         if (!cell) {
             cell = [[RedpacketMessageCell alloc]initWithIsSender:isSender reuseIdentifier:cellRedpacketMessageidentifier];
             [cell bubbleViewWithData:message];
             cell.redpacketDelegate = self;
         }
             return cell;
         }
    }
//    struct objc_super sp;
//    sp.receiver = self;
//    sp.super_class = object_getClass(class_getSuperclass(class_getSuperclass(self.class)));
//    return ((id (*)(struct objc_super *super, SEL op, ...))objc_msgSendSuper)(&sp, @selector(tableView:cellForRowAtIndexPath:),tableView,indexPath);
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}
//// 红包被抢消息处理
//- (void)onRedpacketTakenMessage:(RedpacketMessageModel *)redpacket
//{
//    AVIMMessage *m = [RedpacketTakenAVIMMessage messageWithRedpacket:redpacket];
//    [self.conversation sendMessage:m
//                          callback:^(BOOL succeeded, NSError *error) {
//                          }];
//    RedpacketTakenAVIMTypedMessage *typedMessage = [RedpacketTakenAVIMTypedMessage messageWithAVIMMessage:m];
//    SEL method = @selector(insertMessage:);
//    [self callVoidSuperClass:[CDChatRoomVC class] method:method withObject:typedMessage];
//}
//
//#pragma mark - 红包功能显示界面处理
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    id<XHMessageModel> message = [self.dataSource messageForRowAtIndexPath:indexPath];
//    if ([message isKindOfClass:[RedpacketMessage class]]) {
//        RedpacketMessage *redpacketMessage = (RedpacketMessage *)message;
//        BOOL displayTimestamp = YES;
//        BOOL displayPeerName = NO;
//        if ([self.delegate respondsToSelector:@selector(shouldDisplayTimestampForRowAtIndexPath:)]) {
//            displayTimestamp = [self.delegate shouldDisplayTimestampForRowAtIndexPath:indexPath];
//        }
//        if ([self.delegate respondsToSelector:@selector(shouldDisplayPeerName)]) {
//            displayPeerName = [self.delegate shouldDisplayPeerName];
//        }
//        
//        XHMessageTableViewCell *messageTableViewCell;
//        switch (message.bubbleMessageType) {
//            case XHBubbleMessageTypeReceiving:
//                if (RedpacketMessageTypeRedpacket == redpacketMessage.redpacket.messageType) {
//                    RedpacketMessageCell *redpacketCell = [tableView dequeueReusableCellWithIdentifier:RedpacketMessageCellReceiverIdentifier];
//                    if (!redpacketCell) {
//                        redpacketCell = [[RedpacketMessageCell alloc] initWithMessage:message
//                                                                      reuseIdentifier:RedpacketMessageCellReceiverIdentifier];
//                    }
//                    redpacketCell.delegate = self;
//                    redpacketCell.redpacketDelegate = self;
//                    messageTableViewCell = redpacketCell;
//                }
//                else { // RedpacketMessageTypeTedpacketTakenMessage
//                    RedpacketTakenMessageTipCell *redpacketCell = [tableView dequeueReusableCellWithIdentifier:RedpacketTakenMessageTipCellReceiverIdentifier];
//                    if (!redpacketCell) {
//                        redpacketCell = [[RedpacketTakenMessageTipCell alloc] initWithMessage:message
//                                                                              reuseIdentifier:RedpacketTakenMessageTipCellReceiverIdentifier];
//                    }
//                    redpacketCell.delegate = self;
//                    messageTableViewCell = redpacketCell;
//                }
//                break;
//            case XHBubbleMessageTypeSending:
//                displayPeerName = NO;
//                if (RedpacketMessageTypeRedpacket == redpacketMessage.redpacket.messageType) {
//                    RedpacketMessageCell *redpacketCell = [tableView dequeueReusableCellWithIdentifier:RedpacketMessageCellSenderIdentifier];
//                    if (!redpacketCell) {
//                        redpacketCell = [[RedpacketMessageCell alloc] initWithMessage:message
//                                                                      reuseIdentifier:RedpacketMessageCellSenderIdentifier];
//                    }
//                    redpacketCell.delegate = self;
//                    redpacketCell.redpacketDelegate = self;
//                    messageTableViewCell = redpacketCell;
//                }
//                else {
//                    RedpacketTakenMessageTipCell *redpacketCell = [tableView dequeueReusableCellWithIdentifier:RedpacketTakenMessageTipCellSenderIdentifier];
//                    if (!redpacketCell) {
//                        redpacketCell = [[RedpacketTakenMessageTipCell alloc] initWithMessage:message
//                                                                              reuseIdentifier:RedpacketTakenMessageTipCellSenderIdentifier];
//                    }
//                    redpacketCell.delegate = self;
//                    messageTableViewCell = redpacketCell;
//                }
//                break;
//        }
//        
//        messageTableViewCell.indexPath = indexPath;
//        if (RedpacketMessageTypeTedpacketTakenMessage == redpacketMessage.redpacket.messageType) {
//            [messageTableViewCell configureCellWithMessage:message displaysTimestamp:NO displaysPeerName:NO];
//        }
//        else {
//            [messageTableViewCell configureCellWithMessage:message displaysTimestamp:displayTimestamp displaysPeerName:displayPeerName];
//        }
//        [messageTableViewCell setBackgroundColor:tableView.backgroundColor];
//        
//        if ([self.delegate respondsToSelector:@selector(configureCell:atIndexPath:)]) {
//            [self.delegate configureCell:messageTableViewCell atIndexPath:indexPath];
//        }
//        return messageTableViewCell;
//    }
//    else { // fallback to super
//        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
//    }
//}
//

- (void)redpacketCell:(RedpacketMessageCell *)cell didTap:(ECMessage *)message{
    if(RedpacketMessageTypeRedpacket == message.rpModel.messageType) {
        [self.redpacketControl redpacketCellTouchedWithMessageModel:message.rpModel];
    }
}

@end
