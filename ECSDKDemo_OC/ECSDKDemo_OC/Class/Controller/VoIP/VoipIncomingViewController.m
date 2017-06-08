/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.yuntongxun.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
#define kKeyboardBtnpng             @"dial_icon.png"
#define kKeyboardBtnOnpng           @"dial_icon_on.png"
#define kHandsfreeBtnpng            @"handsfree_icon.png"
#define kHandsfreeBtnOnpng          @"handsfree_icon_on.png"
#define kMuteBtnpng                 @"mute_icon.png"
#define kMuteBtnOnpng               @"mute_icon_on.png"
#import "VoipIncomingViewController.h"
#import "AppDelegate.h"
#import "ECDeviceHeaders.h"
#import "DeviceDelegateHelper.h"
#import "DeviceDelegateHelper+VoIP.h"
#import "KeyboardView.h"

#define tempKeyboardButtonW 79
#define viewWidth  86.0f*3
#define viewHeight 46.0*4


@interface VoipIncomingViewController ()<KeyboardViewDelegate>
{
    BOOL isShowKeyboard;
    BOOL isKickOff;
    ECDevice * device;
}

@property (nonatomic,retain) KeyboardView *keyboardView;

- (void)accept;
- (void)refreshView;
- (void)exitView;
- (void)dismissView;
- (void)showKeyboardView;
@end

@implementation VoipIncomingViewController

#define portraitLeft  100
#define portraitTop   120
#define portraitWidth 150
#define portraitHeight 150

#pragma mark - init初始化
- (id)initWithName:(NSString *)name andPhoneNO:(NSString *)phoneNO andCallID:(NSString*)callid
{
    self = [super init];
    if (self)
    {
        device = [ECDevice sharedInstance];
        self.contactName     = name;
        self.callID          = callid;
        self.contactPhoneNO  = phoneNO;
        hhInt = 0;
        mmInt = 0;
        ssInt = 0;
        isLouder = NO;
        isKickOff = NO;
        self.status = IncomingCallStatus_incoming;
        [[ECDevice sharedInstance].VoIPManager setMute:NO];
    }
    return self;
}

#pragma mark - viewDidLoad界面初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:24/255.0 green:24/255.0 blue:24/255.0 alpha:1.0];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    UIImage *backImage = [UIImage imageNamed:kCallBg02pngVoip];
    UIImageView *backGroupImageView = [[UIImageView alloc] initWithImage:backImage];
    backgroundImg = backGroupImageView;
    backGroupImageView.center = CGPointMake(KscreenW*0.5, KscreenH*0.5);
    [self.view addSubview:backGroupImageView];
    
    //设置拨号界面
    [self prepareUI];
    isShowKeyboard = NO;
    [self refreshView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallEvents:) name:KNOTIFICATION_onCallEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSystemEvents:) name:KNOTIFICATION_onSystemEvent object:nil];
}

- (void)prepareUI {
    NSDictionary *metrics = @{
                              @"topmargin":@54,
                              @"labelmarginH":@60,
                              @"tempKeyboardButtonW":@(tempKeyboardButtonW),
                              @"tempKeyboardButtonMarginH":@((KscreenW-tempKeyboardButtonW*3)/4),
                              @"labelV":@20,
                              @"hangUpButtonmarginH":@24,
                              @"hangUpButtonH":@44,
                              @"keyboardViewH":@(viewHeight)
                              };
    //名字
    UILabel *tempCallerNameLabel = [[UILabel alloc] init];
    tempCallerNameLabel.text = self.contactName;
    tempCallerNameLabel.font = [UIFont systemFontOfSize:20.0f];
    tempCallerNameLabel.textColor = [UIColor whiteColor];
    tempCallerNameLabel.backgroundColor = [UIColor clearColor];
    tempCallerNameLabel.textAlignment = NSTextAlignmentCenter;
    self.lblName = tempCallerNameLabel;
    [self.view addSubview:self.lblName];
    _lblName.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-labelmarginH-[_lblName]-labelmarginH-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_lblName)]];
    
    //电话
    UILabel *tempCallerNoLabel = [[UILabel alloc] init];
    tempCallerNoLabel.text = self.contactPhoneNO.length>0?self.contactPhoneNO:self.contactVoip;
    tempCallerNoLabel.font = [UIFont systemFontOfSize:18.0f];
    tempCallerNoLabel.textColor = [UIColor whiteColor];
    tempCallerNoLabel.backgroundColor = [UIColor clearColor];
    tempCallerNoLabel.textAlignment = NSTextAlignmentCenter;
    self.lblPhoneNO = tempCallerNoLabel;
    [self.view addSubview:self.lblPhoneNO];
    _lblPhoneNO.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-labelmarginH-[_lblPhoneNO]-labelmarginH-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_lblPhoneNO)]];
    
    //连接状态提示
    UILabel *tempRealTimeStatusLabel = [[UILabel alloc] init];
    tempRealTimeStatusLabel.numberOfLines = 2;
    tempRealTimeStatusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tempRealTimeStatusLabel.text = @"网络正在连接请稍后...";
    tempRealTimeStatusLabel.textColor = [UIColor whiteColor];
    tempRealTimeStatusLabel.backgroundColor = [UIColor clearColor];
    tempRealTimeStatusLabel.textAlignment = NSTextAlignmentCenter;
    tempRealTimeStatusLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    self.lblIncoming = tempRealTimeStatusLabel;
    [self.view addSubview:self.lblIncoming];
    _lblIncoming.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_lblIncoming]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_lblIncoming)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topmargin-[_lblName(==labelV)]-labelV-[_lblPhoneNO(==labelV)]-labelV-[_lblIncoming(==labelV)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_lblName,_lblPhoneNO,_lblIncoming)]];
    
    KeyboardView *tmpKeyboardView = [[KeyboardView alloc] init];
    tmpKeyboardView.backgroundColor = [UIColor clearColor];
    self.keyboardView = tmpKeyboardView;
    [self.view addSubview:tmpKeyboardView];
    _keyboardView.hidden = YES;
    _keyboardView.delegate = self;
    _keyboardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-keyboardViewmarginH-[_keyboardView]-keyboardViewmarginH-|" options:0 metrics:@{@"keyboardViewmarginH":@((KscreenW-viewWidth)/2),@"keyboardViewW":@(viewWidth)} views:NSDictionaryOfVariableBindings(_keyboardView)]];
    
    //免提和静音背景图
    UIView *tempfunctionAreaView = [[UIView alloc] init];
    self.functionAreaView = tempfunctionAreaView;
    tempfunctionAreaView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tempfunctionAreaView];
    _functionAreaView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_functionAreaView]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_functionAreaView)]];
    {
        //键盘显示按钮
        UIButton *tempKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.KeyboardButton = tempKeyboardButton;
        [tempKeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnpng] forState:UIControlStateNormal];
        tempKeyboardButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [tempKeyboardButton setTitle:@"键盘" forState:UIControlStateNormal];
        tempKeyboardButton.titleEdgeInsets  = UIEdgeInsetsMake(50,-29, 0, 0);
        tempKeyboardButton.imageEdgeInsets = UIEdgeInsetsMake(-10,22, 0, 0);
        [tempKeyboardButton addTarget:self action:@selector(showKeyboardView) forControlEvents:UIControlEventTouchUpInside];
        [self.functionAreaView addSubview:tempKeyboardButton];
        tempKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tempKeyboardButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tempKeyboardButton)]];
        
        //静音按钮
        UIButton *tempMuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tempMuteButton setImage:[UIImage imageNamed:@"mute_icon.png"] forState:UIControlStateNormal];      tempMuteButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [tempMuteButton setTitle:@"静音" forState:UIControlStateNormal];
        tempMuteButton.titleEdgeInsets  = UIEdgeInsetsMake(50,-29, 0, 0);
        tempMuteButton.imageEdgeInsets = UIEdgeInsetsMake(-10,21, 0, 0);
        [tempMuteButton addTarget:self action:@selector(mute) forControlEvents:UIControlEventTouchUpInside];
        self.muteButton = tempMuteButton;
        tempMuteButton.enabled = NO;
        [self.functionAreaView addSubview:tempMuteButton];
        tempMuteButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tempMuteButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tempMuteButton)]];
        
        //免提按钮
        UIButton *tempHandFreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tempHandFreeButton setImage:[UIImage imageNamed:@"handsfree_icon.png"] forState:UIControlStateNormal];
        tempHandFreeButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [tempHandFreeButton setTitle:@"免提" forState:UIControlStateNormal];
        tempHandFreeButton.titleEdgeInsets  = UIEdgeInsetsMake(50,-29, 0, 0);
        tempHandFreeButton.imageEdgeInsets = UIEdgeInsetsMake(-10,22, 0, 0);
        self.handfreeButton = tempHandFreeButton;
        [tempHandFreeButton addTarget:self action:@selector(handfree) forControlEvents:UIControlEventTouchUpInside];
        [self.functionAreaView addSubview:tempHandFreeButton];
        tempHandFreeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-tempKeyboardButtonMarginH-[tempKeyboardButton(==tempKeyboardButtonW)]-tempKeyboardButtonMarginH-[tempMuteButton(==tempKeyboardButtonW)]-tempKeyboardButtonMarginH-[tempHandFreeButton(==tempKeyboardButtonW)]-tempKeyboardButtonMarginH-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(tempKeyboardButton,tempMuteButton,tempHandFreeButton)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tempHandFreeButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tempHandFreeButton)]];
    }
    
    //最后的view
    _footView = [[UIView alloc] init];
    [self.view addSubview:self.footView];
    _footView.translatesAutoresizingMaskIntoConstraints = NO;
    {
        //挂机
        UIButton *tempHangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button.png"] forState:UIControlStateNormal];
        [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button_on.png"] forState:UIControlStateHighlighted];
        [tempHangupButton setImage:[UIImage imageNamed:@"call_hang_up_button_on.png"] forState:UIControlStateSelected];
        [tempHangupButton addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
        tempHangupButton.hidden = YES;
        self.hangUpButton = tempHangupButton;
        [self.footView addSubview:self.hangUpButton];
        _hangUpButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.footView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_hangUpButton]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_hangUpButton)]];
        [self.footView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_hangUpButton]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_hangUpButton)]];
    }
    
    {
        //拒接
        UIButton *tempRejectButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button.png"] forState:UIControlStateNormal];
        [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button_on.png"] forState:UIControlStateHighlighted];
        [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button_on.png"] forState:UIControlStateSelected];
        [tempRejectButton  addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
        self.rejectButton = tempRejectButton;
        [self.footView addSubview:self.rejectButton];
        _rejectButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.footView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rejectButton]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_rejectButton)]];
        
        //接听
        UIButton *tempAnswerButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button.png"] forState:UIControlStateNormal];
        [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button_on.png"] forState:UIControlStateHighlighted];
        [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button_on.png"] forState:UIControlStateSelected];
        [tempAnswerButton  addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
        self.answerButton = tempAnswerButton;
        [self.footView addSubview:self.answerButton];
        _answerButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.footView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_answerButton]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_answerButton)]];
        [self.footView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_rejectButton]-5-[_answerButton]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_rejectButton,_answerButton)]];
        [self.footView addConstraint:[NSLayoutConstraint constraintWithItem:_rejectButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_answerButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    }

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-hangUpButtonmarginH-[_footView]-hangUpButtonmarginH-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_footView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_keyboardView(==keyboardViewH)]-5-[_functionAreaView(==50)]-hangUpButtonH-[_footView(==hangUpButtonH)]-20-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_keyboardView,_functionAreaView,_footView)]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - 按钮点击
- (void)updateRealtimeLabel
{
    ssInt +=1;
    if (ssInt >= 60) {
        mmInt += 1;
        ssInt -= 60;
        if (mmInt >=  60) {
            hhInt += 1;
            mmInt -= 60;
            if (hhInt >= 24) {
                hhInt = 0;
            }
        }
    }
    
    if (hhInt > 0) {
        self.lblIncoming.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hhInt,mmInt,ssInt];
    } else {
        self.lblIncoming.text = [NSString stringWithFormat:@"%02d:%02d",mmInt,ssInt];
    }
}

- (void)onCallEvents:(NSNotification *)notification {
    
    VoIPCall* voipCall = notification.object;
    if (![self.callID isEqualToString:voipCall.callID])
    {
        return;
    }
    
    switch (voipCall.callStatus) {
            
        case ECallProceeding:
        {
        }
            break;
            
        case ECallStreaming:
        {
            isLouder = NO;
            [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:isLouder];
            self.lblIncoming.text = @"00:00";
            if (![timer isValid])
            {
                timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateRealtimeLabel) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                [timer fire];
            }
            
            self.rejectButton.enabled = NO;
            self.rejectButton.hidden = YES;
            
            self.answerButton.enabled = NO;
            self.answerButton.hidden = YES;
            
            self.handfreeButton.enabled = YES;
            self.handfreeButton.hidden = NO;
            
            self.muteButton.enabled = YES;
            self.muteButton.hidden = NO;
            
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden = NO;
            
            self.functionAreaView.hidden = NO;
            backgroundImg.image = [UIImage imageNamed:@"call_bg01.png"];
        }
            break;
            
        case ECallAlerting:
        {
            self.handfreeButton.enabled = YES;
            self.handfreeButton.hidden = NO;
            self.muteButton.enabled = YES;
            self.muteButton.hidden = NO;
            self.hangUpButton.enabled = YES;
            self.hangUpButton.hidden =NO;
            
        }
            break;
            
        case ECallEnd:
        {
            [self releaseCall];
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(exitView) userInfo:nil repeats:NO];
        }
            break;
            
        case ECallRing:
        {
        }
            break;
            
        case ECallPaused:
        {
            self.lblIncoming.text = @"呼叫保持...";
        }
            break;
            
        case ECallPausedByRemote:
        {
            self.lblIncoming.text = @"呼叫被对方保持...";
        }
            break;
            
        case ECallResumed:
        {
            self.lblIncoming.text = @"呼叫恢复...";
        }
            break;
            
        case ECallResumedByRemote:
        {
            self.lblIncoming.text = @"呼叫被对方恢复...";
        }
            break;
            
        case ECallTransfered:
        {
            self.lblIncoming.text = @"呼叫被转移...";
        }
            break;
            
        case ECallFailed:
        {
            [DemoGlobalClass sharedInstance].isCallBusy = NO;
        }
            break;
            
        default:
            break;
    }
}

//系统的回调事件
- (void)onSystemEvents:(NSNotification *)notification {
    
}

//呼叫振铃
- (void)removeVoIPCallBackForCallId:(NSString *)callid
{
    VoIPCall * voipcall;
    voipcall.callStatus = ECallAlerting;
}

#pragma mark - private
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2988)
    {
        if (buttonIndex == 1)
        {
            exit(0);
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)showKeyboardView
{
    self.keyboardView.hidden = isShowKeyboard;
    isShowKeyboard = !isShowKeyboard;
    if (isShowKeyboard) {
        [self.KeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnOnpng] forState:UIControlStateNormal];
        [self.KeyboardButton setTitleColor:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
    } else {
        [self.KeyboardButton setImage:[UIImage imageNamed:kKeyboardBtnpng] forState:UIControlStateNormal];
        [self.KeyboardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)onclickedBtn:(UIButton *)btn {
    [self dtmfNumber:btn];
}

- (void)dtmfNumber:(id)sender
{
    NSString *numberString = nil;
    UIButton *button = (UIButton *)sender;
    switch (button.tag)
    {
        case 1000:
            numberString = @"0";
            break;
        case 1001:
            numberString = @"1";
            break;
        case 1002:
            numberString = @"2";
            break;
        case 1003:
            numberString = @"3";
            break;
        case 1004:
            numberString = @"4";
            break;
        case 1005:
            numberString = @"5";
            break;
        case 1006:
            numberString = @"6";
            break;
        case 1007:
            numberString = @"7";
            break;
        case 1008:
            numberString = @"8";
            break;
        case 1009:
            numberString = @"9";
            break;
        case 1010:
            numberString = @"*";
            break;
        case 1011:
            numberString = @"#";
            break;
        default:
            numberString = @"#";
            break;
    }
    [device.VoIPManager sendDTMF:self.callID dtmf:numberString];
}

- (void)answer {
    NSInteger ret = [device.VoIPManager acceptCall:self.callID withType:VOICE];
    if (ret == 0) {
        self.status = IncomingCallStatus_accepted;
        [self refreshView];
    } else {
        [self exitView];
    }
}

- (void)handfree
{
    //成功时返回0，失败时返回-1
    NSInteger returnValue = [device.VoIPManager enableLoudsSpeaker:!isLouder];
    if (0 == returnValue) {
        isLouder = !isLouder;
    }
    
    if (isLouder)  {
        [self.handfreeButton setImage:[UIImage imageNamed:kHandsfreeBtnOnpng] forState:UIControlStateNormal];
        [self.handfreeButton setTitleColor:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
    } else {
        [self.handfreeButton setImage:[UIImage imageNamed:kHandsfreeBtnpng] forState:UIControlStateNormal];
        [self.handfreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)mute {
    
    int muteFlag = [device.VoIPManager getMuteStatus];
    if (muteFlag == MuteFlagNotMute1) {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnOnpng] forState:UIControlStateNormal];
        [device.VoIPManager setMute:MuteFlagIsMute1];
        [self.muteButton setTitleColor:[UIColor colorWithRed:46/255.0 green:184/255.0 blue:111/255.0 alpha:1] forState:UIControlStateNormal];
    } else {
        [self.muteButton setImage:[UIImage imageNamed:kMuteBtnpng] forState:UIControlStateNormal];
        [device.VoIPManager setMute:MuteFlagNotMute1];
        [self.muteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)releaseCall{
    [DemoGlobalClass sharedInstance].isCallBusy = NO;
    [device.VoIPManager releaseCall:self.callID];
}

- (void)hangup{
    [DemoGlobalClass sharedInstance].isCallBusy = NO;
    [device.VoIPManager releaseCall:self.callID];
    
    [self exitView];
}

- (void)refreshView
{
    if (self.status == IncomingCallStatus_accepting) {
        self.lblIncoming.text = @"正在接听...";
        self.rejectButton.enabled = NO;
        self.rejectButton.hidden = YES;
        
        self.answerButton.enabled = NO;
        self.answerButton.hidden = YES;
        
        self.handfreeButton.enabled = YES;
        self.handfreeButton.hidden = NO;
        
        self.muteButton.enabled = YES;
        self.muteButton.hidden = NO;
        
        self.hangUpButton.enabled = YES;
        self.hangUpButton.hidden = NO;
        
        self.functionAreaView.hidden = NO;
        backgroundImg.image = [UIImage imageNamed:@"call_bg01.png"];
        
        [self performSelector:@selector(answers) withObject:nil afterDelay:0.1];
    }
    else if (self.status == IncomingCallStatus_incoming) {}
    else if(self.status == IncomingCallStatus_accepted) {}
    else {}
}
- (void)answers {
    [device.VoIPManager acceptCall:self.callID withType:VOICE];
}

- (void)accept {
    self.status = IncomingCallStatus_accepting;
    [self refreshView];
}

-(void) exitView {
    if ([timer isValid])
    {
        [timer invalidate];
        timer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)process
{
    if ([timer isValid])
    {
        [timer invalidate];
        timer = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissView
{
    [NSThread detachNewThreadSelector:@selector(process) toTarget:self withObject:nil];
}

- (void)dealloc
{
    [timer invalidate];
    timer = nil;
    [DemoGlobalClass sharedInstance].isCallBusy = NO;
}
@end
