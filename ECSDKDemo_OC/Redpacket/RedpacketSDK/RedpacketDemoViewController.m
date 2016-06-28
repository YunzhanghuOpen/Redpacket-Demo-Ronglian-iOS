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
#pragma mark -

#pragma mark - 红包相关的宏定义
#define REDPACKET_BUNDLE(name) @"RedpacketCellResource.bundle/" name
#pragma mark -

static NSString *const RedpacketMessageCellIdentifier = @"RedpacketMessageCellIdentifier";
static NSString *const RedpacketTakenMessageTipCellIdentifier = @"RedpacketTakenMessageTipCellIdentifier";


@interface RedpacketDemoViewController () <RedpacketCellDelegate,RedpacketCellDelegate,RedpacketViewControlDelegate>
{
    NSArray *_members;
}
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
                [self.redpacketControl presentRedPacketMoreViewControllerWithGroupMemberArray:members];
                _members = members;
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
    _redpacketControl.delegate = self;
    //  需要当前聊天窗口的会话ID
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    userInfo.userId = self.sessionId;
    userInfo.isGroup = isGroup;
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
        if ([message isRedpacketOpenMessage]) {
            return [RedpacketTakenMessageTipCell getHightOfCellViewWith:message.messageBody];
        }else{
            return [RedpacketMessageCell getHightOfCellViewWith:message.messageBody];
        }
        
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ECMessage * message = [self.messageArray objectAtIndex:indexPath.row];
    if ([message isKindOfClass:[ECMessage class]]) {
        BOOL isSender = (message.messageState==ECMessageState_Receive?NO:YES);
        NSInteger fileType = message.messageBody.messageBodyType;
        if ([message isRedpacket]) {
            
            if ([message isRedpacketOpenMessage]) {
                NSString *cellidentifier = [NSString stringWithFormat:@"%@_%@_%d", isSender?@"issender":@"isreceiver",RedpacketMessageCellIdentifier,(int)fileType];
                RedpacketTakenMessageTipCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
                if (!cell) {
                    cell = [[RedpacketTakenMessageTipCell alloc]initWithIsSender:isSender reuseIdentifier:cellidentifier];
                }
                [cell bubbleViewWithData:message];
                return cell;
            }else{
                NSString *cellidentifier = [NSString stringWithFormat:@"%@_%@_%d", isSender?@"issender":@"isreceiver",RedpacketTakenMessageTipCellIdentifier,(int)fileType];
                RedpacketMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
                if (!cell) {
                    cell = [[RedpacketMessageCell alloc]initWithIsSender:isSender reuseIdentifier:cellidentifier];
                    cell.redpacketDelegate = self;
                }
                [cell bubbleViewWithData:message];
                return cell;
            }
        }
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}
- (void)redpacketCell:(RedpacketMessageCell *)cell didTap:(ECMessage *)message{
    if(RedpacketMessageTypeRedpacket == message.rpModel.messageType) {
        [self.redpacketControl redpacketCellTouchedWithMessageModel:message.rpModel];
    }
}

- (NSArray *)groupMemberList
{
    NSMutableArray *groupMemberList = [[NSMutableArray alloc]init];
    for (ECGroupMember *member in _members) {
        RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
        userInfo.userId = member.memberId;//可唯一标识用户的ID
        userInfo.userNickname = member.display;//用户昵称
        userInfo.userAvatar = nil; //用户头像地址
        if ([userInfo.userId isEqualToString:[DemoGlobalClass sharedInstance].userName]) {
            
        }else{
            [groupMemberList addObject:userInfo];
        }
    }
    return groupMemberList;
}

// 要在此处根据userID获得用户昵称,和头像地址
- (RedpacketUserInfo *)profileEntityWith:(NSString *)userId
{
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    //    UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:userId];
    //    if (profileEntity) {
    //        if (profileEntity.nickname && profileEntity.nickname.length > 0) {
    //
    //            userInfo.userNickname = profileEntity.nickname;
    //
    //        } else {
    //            userInfo.userNickname = userId;
    //        }
    //    } else {
    //        userInfo.userNickname = userId;
    //    }
    //    userInfo.userAvatar = profileEntity.imageUrl;
    //    userInfo.userId = userId;
    return userInfo;
}

@end
