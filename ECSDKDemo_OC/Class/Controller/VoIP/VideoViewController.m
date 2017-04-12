//
//  VideoViewController.m
//  ytxVoIPDemo
//
//  Created by jzy on 15/3/10.
//  Copyright (c) 2015年 jzy. All rights reserved.
//
#import "VideoViewController.h"
#import "CameraDeviceInfo.h"
#import "DeviceDelegateHelper.h"
#import "DeviceDelegateHelper+VoIP.h"

#define localVideoViewW 80.0f
#define localVideoViewH 107.0f

//视频呼叫是1
@interface VideoViewController () {
    UILabel *statusLabel;
    UILabel *timeLabel;
    UILabel *callStatusLabel;
    UIView *localVideoView;
    UIView *remoteVideoView;
    
    NSInteger curCameraIndex;
    BOOL isKickOff;
    
    UITouch *touch;
    CGPoint curLocation;
    CGPoint preLocation;
}
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *callingView;
//拒接
@property (nonatomic, strong) UIButton *rejectButton;
//接听
@property (nonatomic, strong) UIButton *answerButton;
@end

@implementation VideoViewController

- (instancetype)initWithCallerName:(NSString *)name andVoipNo:(NSString *)voipNo andCallstatus:(NSInteger)status {
    if (self = [super init]) {
        self.callerName = name;
        self.voipNo = voipNo;
        hhInt = 0;
        mmInt = 0;
        ssInt = 0;
        callStatus = status;
        isKickOff = NO;
        [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
        [[ECDevice sharedInstance].VoIPManager setMute:NO];
        
        curCameraIndex = [DemoGlobalClass sharedInstance].cameraInfoArray.count-1;
        
        if (curCameraIndex >= 0) {
            [[DemoGlobalClass sharedInstance] selectCamera:curCameraIndex];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:45.0f/255.0f green:52.0f/255.0f blue:61.0f/255.0f alpha:1.0f];

    if ([UIDevice currentDevice].systemVersion.floatValue >7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    UIImageView *videoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_icon"]];
    videoIcon.center = CGPointMake(KscreenW*0.5, KscreenH*0.5);
    [self.view addSubview:videoIcon];
    
    // 设置界面
    [self prepareUI];
    
    [[ECDevice sharedInstance].VoIPManager setVideoView:remoteVideoView andLocalView:localVideoView];
    
    //0:呼出视频 1:视频呼入 2:视频中
    if (callStatus == 0) {
        //进来之后先拨号
        self.callID = [[ECDevice sharedInstance].VoIPManager makeCallWithType:VIDEO andCalled:self.voipNo];
        //获取CallID失败，即拨打失败
        if (self.callID.length <= 0) {
            statusLabel.text = @"对方不在线或网络不给力";
        } else {
            statusLabel.text = @"正在等待对方接受邀请......";
        }
        
    } else if(callStatus == 1) {
        statusLabel.text = [NSString stringWithFormat:@"%@邀请您进行视频通话", self.voipNo];
        _hangUpButton.hidden = YES;
        _answerButton.hidden = NO;
        _rejectButton.hidden = NO;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallEvents:) name:KNOTIFICATION_onCallEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSystemEvents:) name:KNOTIFICATION_onSystemEvent object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:NO];
    [super viewDidDisappear:animated];
}

- (void)prepareUI {
    
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topView];
    _topView = topView;
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-44-[topView]-44-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[topView(==100)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topView)]];
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[DemoGlobalClass sharedInstance] getOtherImageWithPhone:_voipNo]];
        [topView addSubview:imageView];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[imageView]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
        
        //名字
        UILabel *tempCallerNameLabel = [[UILabel alloc] init];
        tempCallerNameLabel.text = self.callerName;
        tempCallerNameLabel.font = [UIFont systemFontOfSize:20.0f];
        tempCallerNameLabel.textColor = [UIColor whiteColor];
        tempCallerNameLabel.backgroundColor = [UIColor clearColor];
        tempCallerNameLabel.textAlignment = NSTextAlignmentLeft;
        [topView addSubview:tempCallerNameLabel];
        tempCallerNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView(==90)]-[tempCallerNameLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView,tempCallerNameLabel)]];
        
        //电话
        UILabel *tempCallerNoLabel = [[UILabel alloc] init];
        tempCallerNoLabel.text = self.voipNo;
        tempCallerNoLabel.font = [UIFont systemFontOfSize:18.0f];
        tempCallerNoLabel.textColor = [UIColor whiteColor];
        tempCallerNoLabel.backgroundColor = [UIColor clearColor];
        tempCallerNoLabel.textAlignment = NSTextAlignmentLeft;
        [topView addSubview:tempCallerNoLabel];
        tempCallerNoLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView(==90)]-[tempCallerNoLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView,tempCallerNoLabel)]];
        //状态
        UILabel *statusLabeltmp = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 265.0f, 29.0f)];
        statusLabeltmp.backgroundColor = [UIColor clearColor];
        statusLabeltmp.textColor = [UIColor whiteColor];
        statusLabeltmp.font = [UIFont systemFontOfSize:13.0f];
        statusLabeltmp.textAlignment = NSTextAlignmentLeft;
        statusLabel = statusLabeltmp;
        [topView addSubview:statusLabeltmp];
        statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView(==90)]-[statusLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView,statusLabel)]];
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tempCallerNameLabel(==25)]-[tempCallerNoLabel(==25)]-[statusLabel(==30@700)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tempCallerNameLabel,tempCallerNoLabel,statusLabel)]];
    }
    
    UIView *tmpView1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, KscreenW, KscreenH)];
    remoteVideoView = tmpView1;
    tmpView1.contentMode = [DemoGlobalClass sharedInstance].viewcontentMode;
    tmpView1.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tmpView1];
    
    UIView *tmpView2 = [[UIView alloc] initWithFrame:CGRectMake(15.0f, KscreenH*0.5, localVideoViewW, localVideoViewH)];
    tmpView1.backgroundColor = [UIColor clearColor];
    localVideoView = tmpView2;
    [self.view addSubview:tmpView2];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewToExchangeView:)];
    tapGesture.numberOfTapsRequired = 1;
    [localVideoView addGestureRecognizer:tapGesture];
    
    _callingView = [[UIView alloc] init];
    [self.view addSubview:self.callingView];
    _callingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-44-[_callingView]-44-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_callingView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_callingView(==44)]-44-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_callingView)]];
    {
        UIButton* hangupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"call_hang_up_button"] forState:UIControlStateNormal];
        [hangupBtn setBackgroundImage:[UIImage imageNamed:@"call_hang_up_button_on"] forState:UIControlStateHighlighted];
        [hangupBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
        self.hangUpButton = hangupBtn;
        [self.callingView addSubview:self.hangUpButton];
        _hangUpButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_callingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_hangUpButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_hangUpButton)]];
        [_callingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_hangUpButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_hangUpButton)]];
        
        UILabel *timeLabeltmp = [[UILabel alloc] init];
        timeLabel = timeLabeltmp;
        timeLabeltmp.backgroundColor =  [UIColor clearColor];
        [_hangUpButton addSubview:timeLabeltmp];
        timeLabeltmp.textColor = [UIColor whiteColor];
        timeLabeltmp.textAlignment = NSTextAlignmentRight;
        timeLabeltmp.font = [UIFont systemFontOfSize:14];
        timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_hangUpButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[timeLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(timeLabel)]];
        [_hangUpButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[timeLabel(==55)]-30-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(timeLabel)]];

    }
    
    {
        //拒接
        UIButton *tempRejectButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button"] forState:UIControlStateNormal];
        [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button_on"] forState:UIControlStateHighlighted];
        [tempRejectButton setImage:[UIImage imageNamed:@"call_refuse_button_on"] forState:UIControlStateSelected];
        [tempRejectButton  addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
        self.rejectButton = tempRejectButton;
        _rejectButton.hidden = YES;
        [self.callingView addSubview:self.rejectButton];
        _rejectButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.callingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rejectButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_rejectButton)]];
        
        //接听
        UIButton *tempAnswerButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button"] forState:UIControlStateNormal];
        [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button_on"] forState:UIControlStateHighlighted];
        [tempAnswerButton setImage:[UIImage imageNamed:@"call_answer_button_on"] forState:UIControlStateSelected];
        [tempAnswerButton  addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
        self.answerButton = tempAnswerButton;
        _answerButton.hidden = YES;
        [self.callingView addSubview:self.answerButton];
        _answerButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.callingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_answerButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_answerButton)]];
        [self.callingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_rejectButton]-5-[_answerButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_rejectButton,_answerButton)]];
        [self.callingView addConstraint:[NSLayoutConstraint constraintWithItem:_rejectButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_answerButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    }
    
    if ([DemoGlobalClass sharedInstance].cameraInfoArray.count>1) {
        UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [switchBtn setImage:[UIImage imageNamed:@"camera_switch"] forState:UIControlStateNormal];
        [self.view addSubview:switchBtn];
        [switchBtn addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        switchBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[switchBtn(==70)]-35-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(switchBtn)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-35-[switchBtn(==35)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(switchBtn)]];
    }

}

-(void)changeTextColor {
    if (self.tipsLabel.textColor == [UIColor orangeColor]) {
        self.tipsLabel.textColor = [UIColor whiteColor];
    } else {
        self.tipsLabel.textColor = [UIColor orangeColor];
    }
}

-(void)showTipsLabel {
    self.tipsLabel.textColor = [UIColor whiteColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:17];
    self.tipsLabel.text = [NSString stringWithFormat:@"与%@视频通话中", (self.voipNo.length>3?[self.voipNo substringFromIndex:(self.voipNo.length-3)]:@"")];
}

//选择摄像头
-(void)switchCamera {
    
    curCameraIndex ++;
    if (curCameraIndex >= [DemoGlobalClass sharedInstance].cameraInfoArray.count) {
        curCameraIndex = 0;
    }
    [[DemoGlobalClass sharedInstance] selectCamera:curCameraIndex];
}

- (void)backFront {
    
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    [[ECDevice sharedInstance].VoIPManager setVideoView:nil andLocalView:nil];
    [DemoGlobalClass sharedInstance].isCallBusy = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//通话回调函数，判断通话状态
- (void)onCallEvents:(NSNotification *)notification {
    
    VoIPCall* voipCall = notification.object;
    if (![self.callID isEqualToString:voipCall.callID]) {
        return;
    }
    
    switch (voipCall.callStatus) {
        case ECallProceeding: {
            statusLabel.text = @"呼叫中...";
        }
            break;
            
        case ECallAlerting: {
            statusLabel.text = @"等待对方接听";
        }
            break;
            
        case ECallStreaming: {
            [DemoGlobalClass sharedInstance].isCallBusy = YES;
            statusLabel.text = @"通话中...";
            timeLabel.text = @"00:00";
            if (![timer isValid]) {
                timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(updateRealtimeLabel) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                [timer fire];
            }
        }
            break;
            
        case ECallFailed: {
            [DemoGlobalClass sharedInstance].isCallBusy = NO;
            if( voipCall.reason == ECErrorType_NoResponse) {
                statusLabel.text = @"网络不给力";
            } else if ( voipCall.reason == ECErrorType_CallBusy || voipCall.reason == ECErrorType_Declined ) {
                statusLabel.text = @"您拨叫的用户正忙，请稍后再拨";
            } else if ( voipCall.reason == ECErrorType_OtherSideOffline) {
                statusLabel.text = @"对方不在线";
            } else if ( voipCall.reason == ECErrorType_CallMissed ) {
                statusLabel.text = @"呼叫超时";
            } else if ( voipCall.reason == ECErrorType_SDKUnSupport) {
                statusLabel.text = @"该版本不支持此功能";
            } else if ( voipCall.reason == ECErrorType_CalleeSDKUnSupport ) {
                statusLabel.text = @"对方版本不支持音频";
            } else {
                statusLabel.text = @"呼叫失败";
            }
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(hangup) userInfo:nil repeats:NO];
        }
            break;
            
        case ECallEnd: {
            [DemoGlobalClass sharedInstance].isCallBusy = NO;
            statusLabel.text = @"正在挂机...";
            if (!isKickOff)
                [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backFront) userInfo:nil repeats:NO];
        }
            break;
            
        default:
            break;
    }
}

//系统的回调事件
- (void)onSystemEvents:(NSNotification *)notification {
    
}

#pragma mark - 拖动view
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    touch = [touches anyObject];
    [self setVideoViewWithWiew:localVideoView];
}

- (void)setVideoViewWithWiew:(UIView *)view
{
    preLocation = [touch previousLocationInView:view];
    curLocation = [touch locationInView:view];
    CGRect frame = localVideoView.frame;
    frame.origin.x += curLocation.x - preLocation.x;
    frame.origin.y += curLocation.y - preLocation.y;
    if (frame.origin.x <= 0 ) {
        frame.origin.x = 0;
    } else if (frame.origin.y <= 0) {
        frame.origin.y = 0;
    } else if (frame.origin.x >= (KscreenW-localVideoViewW)) {
        frame.origin.x = KscreenW-localVideoViewW;
    } else if (frame.origin.y >= (KscreenH-localVideoViewH)) {
        frame.origin.y = KscreenH-localVideoViewH;
    }
    view.frame = frame;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect frame = localVideoView.frame;
    CGFloat W = (KscreenW-localVideoViewW);
    if (frame.origin.x<W/2) {
        frame.origin.x = 0;
    } else if (W/2<frame.origin.x<W) {
        frame.origin.x = W;
    }
    localVideoView.frame = frame;
}

#pragma mark - 方法
- (void)updateRealtimeLabel {
    
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
        timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hhInt,mmInt,ssInt];
    } else {
        timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",mmInt,ssInt];
    }
}

- (void)hangup {
    statusLabel.text = @"正在挂机...";
    [self releaseCall];
    [self performSelector:@selector(backFront) withObject:nil afterDelay:1.0];
}

- (void)accept {
    [self performSelector:@selector(answer) withObject:nil afterDelay:0.1];
}

- (void)answer {
    NSInteger ret = [[ECDevice sharedInstance].VoIPManager acceptCall:self.callID withType:VIDEO];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    if (ret == 0) {
        _hangUpButton.hidden = NO;
        _rejectButton.hidden = YES;
        _answerButton.hidden = YES;
    } else {
        [self backFront];
    }
}

- (void)releaseCall {
    [DemoGlobalClass sharedInstance].isCallBusy = NO;
    [[ECDevice sharedInstance].VoIPManager releaseCall:self.callID];
}

- (void)tapViewToExchangeView:(UITapGestureRecognizer*)gesture {
    static NSInteger tapcount = 1;
    if (tapcount%2==1) {
        [[ECDevice sharedInstance].VoIPManager resetVideoView:localVideoView andLocalView:remoteVideoView ofCallId:self.callID];
        tapcount = 2;
    } else {
        [[ECDevice sharedInstance].VoIPManager resetVideoView:remoteVideoView andLocalView:localVideoView ofCallId:self.callID];
        tapcount = 1;
    }
}

- (void)dealloc {
    [timer invalidate];
    timer = nil;
}
@end
