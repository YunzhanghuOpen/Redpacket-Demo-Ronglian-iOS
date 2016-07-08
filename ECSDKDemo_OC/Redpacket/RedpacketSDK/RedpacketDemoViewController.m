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
                [self.redpacketControl presentRedPacketMoreViewControllerWithGroupMembers:members];
                _members = members;
            }else
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"网络故障，请稍后" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                
                [alertView show];
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
    
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"[容联云红包]%@",redpacket.redpacket.redpacketGreeting]];
    ECMessage *message = [[ECMessage alloc] initWithReceiver:self.sessionId body:messageBody];
    message.userData = [message voluationModele:redpacket];
    
    ECMessage* sendMessage = [[DeviceChatHelper sharedInstance] sendMessage:message];;
    
    [[DemoGlobalClass sharedInstance].AtPersonArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:sendMessage];
    
}

//  MARK: 发送红包被抢的消息
- (void)sendRedpacketHasBeenTaked:(RedpacketMessageModel *)redpacket
{
    NSString *text = [NSString stringWithFormat:@"%@领取了你的红包", redpacket.redpacketReceiver.userNickname];
    if (redpacket.isRedacketSender) {
        text = @"你领取了自己发的红包";
    }
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:text];
    ECMessage *message = [[ECMessage alloc] initWithReceiver:self.sessionId body:messageBody];
    message.userData = [message voluationNoticeModele:redpacket];
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
        
        message.rpModel.redpacketSender.userNickname = [[DemoGlobalClass sharedInstance] getOtherNameWithPhone:message.from];//根据需求显示，拆红包界面的发送者用户名
        message.rpModel.redpacketSender.userAvatar  = nil;          //根据需求显示，拆红包界面的发送整的用户头像
        message.rpModel.redpacketSender.userId = message.from;
        
        if ([[[message redPacketDic] valueForKey:RedpacketKeyRedapcketToAnyone] isEqualToString:@"member"]) {
            [[ECDevice sharedInstance] getOtherPersonInfoWith:message.rpModel.toRedpacketReceiver.userId completion:^(ECError *error, ECPersonInfo *person) {
                
                message.rpModel.toRedpacketReceiver.userNickname = person.nickName; //根据需求显示，拆红包界面的定向接收者用户名
                message.rpModel.toRedpacketReceiver.userAvatar  = nil;              //根据需求显示，拆红包界面的定向接收者用户头像
                
                [self.redpacketControl redpacketCellTouchedWithMessageModel:message.rpModel];

            }];
        }else
        {
            [self.redpacketControl redpacketCellTouchedWithMessageModel:message.rpModel];
        }
        
    }
}

- (NSArray<RedpacketUserInfo *> *)groupMemberList
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


@end
