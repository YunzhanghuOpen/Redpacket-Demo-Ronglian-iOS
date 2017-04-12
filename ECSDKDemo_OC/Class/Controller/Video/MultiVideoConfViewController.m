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

#import "MultiVideoConfViewController.h"
#import "CameraDeviceInfo.h"
#import "DeviceDelegateHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "ECMeetingMember.h"
#import "DeviceDelegateHelper+Meeting.h"

#define VideoConfVIEW_speakListen    9991
#define VideoConfVIEW_addNullNumber  9992
#define VideoConfVIEW_addmember      9993
#define VideoConfVIEW_addmember_voip 9994
#define VideoConfVIEW_exitAlert      9995
#define VideoConfVIEW_kickOff        9996
#define VideoConfVIEW_ConfDisslove   9997
#define VideoConfVIEW_refuse         9998

#define VideoConfVIEW_BtnChangeCam   8001
#define VideoConfVIEW_BtnMic         8002
#define VideoConfVIEW_BtnExit        8003

#define VideoConfVIEW_ViewMain       7000
#define VideoConfVIEW_View1          7001
#define VideoConfVIEW_View2          7002
#define VideoConfVIEW_View3          7003
#define VideoConfVIEW_View4          7004
#define VideoConfVIEW_View5          7005

#define VideoConfSheet               6001

#define topLabel 20.0
#define footViewH 160.0
#define marginHV 11.0
#define bito 0.4

@interface MultiVideoConfViewController ()
{
    UILabel *statusView;
    BOOL isMute;
    NSInteger videoCount;
    dispatch_once_t errOnce;
}
@property (nonatomic, strong) NSMutableArray *membersArray;
@property (nonatomic, assign) NSInteger myVideoState;
@property (nonatomic, copy) NSString *confAddr;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *midView;
@property (nonatomic, strong) UIView *footView;

@end

@implementation MultiVideoConfViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self controllerSpeak:YES];
        self.isCreatorExit = NO;
        self.membersArray = [[NSMutableArray alloc] init] ;
        [[ECDevice sharedInstance].VoIPManager setMute:NO];
        
        //默认使用前置摄像头
        curCameraIndex = [DemoGlobalClass sharedInstance].cameraInfoArray.count-1;
        if (curCameraIndex >= 0) {
            CameraDeviceInfo *camera = [[DemoGlobalClass sharedInstance].cameraInfoArray objectAtIndex:curCameraIndex];
            [[DemoGlobalClass sharedInstance] selectCamera:camera.index];
        }
    }
    return self;
}

-(void)controllerSpeak:(BOOL)isSpeak{
    
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:isSpeak];
}

- (void)loadView
{
    self.title = self.Confname;
    CGRect range = [UIScreen mainScreen].bounds;

    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.backgroundColor = [UIColor grayColor];
    
    UIBarButtonItem *leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"videoConf03"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(exitAlert)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"videoConf03"] style:UIBarButtonItemStyleDone target:self action:@selector(exitAlert)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    
    if (self.isCreator) {
        
        UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:@"管理" style:UIBarButtonItemStyleDone target:self action:@selector(management)];
        [rightBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        [rightBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = rightBar;
        
    }
    
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_topView];
    _midView = [[UIView alloc] init];
    _midView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_midView];
    _footView = [[UIView alloc] init];
    _footView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_footView];
    _topView.translatesAutoresizingMaskIntoConstraints = NO;
    _midView.translatesAutoresizingMaskIntoConstraints = NO;
    _footView.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *views = NSDictionaryOfVariableBindings(_topView,_footView,_midView);
    NSDictionary *metrics = @{
                              @"_topViewV":@topLabel,
                              @"_footViewV":@footViewH,
                              @"marginHV":@marginHV
                              };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_topView]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_midView]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_footView]|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topView(==_topViewV)]-marginHV-[_midView]-[_footView(==_footViewV)]|" options:0 metrics:metrics views:views]];
    //创建头部UI
    [self createTitleUI];

    //创建视频窗口
    [self createVideoUI];
    
    //创建控麦、切换摄像头和结束视频
    [self createFootView];
    
    [[ECDevice sharedInstance].VoIPManager setVideoView:nil andLocalView:self.view1.bgView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallEvents:) name:@"KNOTIFICATION_onCallEvent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMultiVideoMeetingMsg:) name:KNOTIFICATION_onReceiveMultiVideoMeetingMsg object:nil];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (self.callID.length > 0) {
        dispatch_once(&errOnce, ^{
            _alertView = [[UIAlertView alloc] initWithTitle:@"是否加入会议" message:[NSString stringWithFormat:@"是否加入%@会议",self.curVideoConfId] delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"加入", nil];
            _alertView.tag = 100;
            [_alertView show];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

-(void)management
{
    if (self.menuView == nil) {
        
        self.menuView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ClearView)];
        [self.menuView addGestureRecognizer:tap];
        
        NSArray *menuTitles = @[@"邀请用户(VoIP)",@"邀请用户(电话)",@"设置可听",@"设置可讲",@"设置禁言",@"设置禁听"];
        
        CGFloat menuHeight = 40.0f;
        CGFloat menuWidht = self.view.bounds.size.width*bito;
        CGFloat menuX = self.view.bounds.size.width*(1-bito);
        
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(menuX, 64.0f, menuWidht, menuHeight*menuTitles.count)];
        view.tag = 50;
        view.backgroundColor = [UIColor blackColor];
        [self.menuView addSubview:view];
        
        for (NSString* title in menuTitles) {
            NSUInteger index = [menuTitles indexOfObject:title];
            UIButton * menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            menuBtn.tag = index;
            menuBtn.frame =CGRectMake(0.0f, menuHeight*index, menuWidht, menuHeight);
            [menuBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [menuBtn setTitle:title forState:UIControlStateNormal];
            [menuBtn addTarget:self action:@selector(menuListBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:menuBtn];
        }
    }
    
    if (self.menuView.superview == nil) {
        [self.view.window addSubview:self.menuView];
    }
}

-(void)ClearView {
    [self.menuView removeFromSuperview];
    self.menuView = nil;
}

-(void)menuListBtnClicked:(id)sender {
    UIButton *button = (UIButton*)sender;
    switch (button.tag)
    {
        case 0:
            [self addMember:NO];
            break;
            
        case 1:
            [self addMember:YES];
            break;
        case 2:
            [self setMemberSeapkListenState:4 withBtn:button];
            break;
        case 3:
            [self setMemberSeapkListenState:2 withBtn:button];
            break;
        case 4:
            [self setMemberSeapkListenState:1 withBtn:button];
            break;
        case 5:
            [self setMemberSeapkListenState:3 withBtn:button];
            break;

        default:
            break;
    }
    [self ClearView];
}

const char  KSeapkListenSheet;
- (void)setMemberSeapkListenState:(NSInteger)count withBtn:(UIButton*)btn{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:btn.currentTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    for (ECMultiVideoMeetingMember* member in self.membersArray) {
        if (![member.voipAccount.account isEqualToString:[DemoGlobalClass sharedInstance].userName]) {
            [sheet addButtonWithTitle:member.voipAccount.account];
        }
    }
    sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    sheet.tag = VideoConfSheet;
    objc_setAssociatedObject(sheet, &KSeapkListenSheet, @(count), OBJC_ASSOCIATION_ASSIGN);
    [sheet showInView:self.view];
}

-(void)addMember:(BOOL)isloading {
    if (isloading == NO) {
        
        UIAlertView *alertView = alertView = [[UIAlertView alloc] initWithTitle:@"VoIP加入群聊" message:@"请输入要邀请加入聊天室的VoIP账号，对方接听后即可加入聊天。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = VideoConfVIEW_addmember_voip;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.placeholder = @"请输入VoIP号";
        [alertView show];
    } else {
        
        UIAlertView *alertView = alertView = [[UIAlertView alloc] initWithTitle:@"接听电话加入群聊" message:@"请输入要邀请加入聊天室的号码（固号需加区号），对方接听免费电话后即可加入聊天。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = VideoConfVIEW_addmember;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.keyboardType = UIKeyboardTypePhonePad;
        textField.placeholder = @"请输入号码，固话需加拨区号";
        [alertView show];
    }
}


//创建头部UI
- (void)createTitleUI {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_Tips.png"]];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    [images addObject:[UIImage imageNamed:@"video_Tips.png"]];
    [images addObject:[UIImage imageNamed:@"video_new_tips.png"]];
    imgView.animationImages = images;
    imgView.frame = CGRectMake(0.0f, 0.0f, KscreenW, topLabel);
    [_topView addSubview:imgView];
    self.pointImg = imgView;
    self.pointImg.animationDuration = 0.5;//设置动画时间
    self.pointImg.animationRepeatCount = 6;//设置动画次数 0 表示无限
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.0f, KscreenW, topLabel)];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.font = [UIFont systemFontOfSize:13.0f];
    statusLabel.textAlignment = NSTextAlignmentLeft;
    statusView = statusLabel;
    statusLabel.text = [NSString stringWithFormat:@"正在加入会议..."];
    [_topView addSubview:statusLabel];
}

//创建视频窗口
- (void)createVideoUI {
    CGFloat ViewWH = KscreenW*0.25;
    CGFloat marginV = (KscreenW-3*ViewWH)/4;
    CGFloat mainViewWH = KscreenW-marginV*3-ViewWH;
    
    MultiVideoView *mainView = [[MultiVideoView alloc] init];
    mainView.myDelegate = self;
    mainView.tag = VideoConfVIEW_ViewMain;
    mainView.icon.hidden = YES;
    [_midView addSubview:mainView];
    self.mainView = mainView;
    
    MultiVideoView *view1 = [[MultiVideoView alloc] init];
    view1.tag = VideoConfVIEW_View1;
    view1.bgView.contentMode = [DemoGlobalClass sharedInstance].viewcontentMode;
    view1.myDelegate = self;
    [_midView addSubview:view1];
    self.view1 = view1;
    self.view1.isDisplayVideo=YES;
    
    MultiVideoView *view2 = [[MultiVideoView alloc] init];
    view2.tag = VideoConfVIEW_View2;
    view2.myDelegate = self;
    view2.bgView.contentMode = [DemoGlobalClass sharedInstance].viewcontentMode;
    [_midView addSubview:view2];
    self.view2 = view2;
    
    MultiVideoView *view3 = [[MultiVideoView alloc] init];
    view3.tag = VideoConfVIEW_View3;
    view3.myDelegate = self;
    view3.bgView.contentMode = [DemoGlobalClass sharedInstance].viewcontentMode;
    [_midView addSubview:view3];
    self.view3 = view3;
    
    MultiVideoView *view4 = [[MultiVideoView alloc] init];
    view4.tag = VideoConfVIEW_View4;
    view4.myDelegate = self;
    view4.bgView.contentMode = [DemoGlobalClass sharedInstance].viewcontentMode;
    [_midView addSubview:view4];
    self.view4 = view4;
    
    MultiVideoView *view5 = [[MultiVideoView alloc] init];
    view5.tag = VideoConfVIEW_View5;
    view5.myDelegate = self;
    view5.bgView.contentMode = [DemoGlobalClass sharedInstance].viewcontentMode;
    [_midView addSubview:view5];
    self.view5 = view5;
    
    self.mainView.frame = CGRectMake(marginV, 0.0f, mainViewWH, mainViewWH);
    self.view1.frame = CGRectMake(CGRectGetMaxX(self.mainView.frame)+marginV, 0.0f, ViewWH, ViewWH);
    self.view2.frame = CGRectMake(CGRectGetMinX(self.view1.frame), CGRectGetMaxY(self.view1.frame)+marginV, ViewWH, ViewWH);
    self.view3.frame = CGRectMake(marginV, CGRectGetMaxY(self.mainView.frame)+marginV, ViewWH, ViewWH);
    self.view4.frame = CGRectMake(CGRectGetMaxX(self.view3.frame)+marginV, CGRectGetMinY(self.view3.frame), ViewWH, ViewWH);
    self.view5.frame = CGRectMake(CGRectGetMaxX(self.view4.frame)+marginV,CGRectGetMinY(self.view3.frame), ViewWH, ViewWH);
}

//创建控麦和摄像头
- (void)createFootView
{
    NSDictionary *metrics = @{
                              @"btncamW":@44,
                              @"btncamH":@30,
                              @"btnexitH":@44,
                              @"btnmargin":@20,
                              @"btnexitMargin":@44,
                              };
    UIButton *btnChangeCam = [UIButton buttonWithType:UIButtonTypeCustom];
    btnChangeCam.tag = VideoConfVIEW_BtnChangeCam;
    [btnChangeCam setImage:[UIImage imageNamed:@"videoConf05"] forState:UIControlStateNormal];
    [btnChangeCam setImage:[UIImage imageNamed:@"videoConf05_on"] forState:UIControlStateSelected];
    [btnChangeCam addTarget:self action:@selector(changeCam:) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:btnChangeCam];
    btnChangeCam.translatesAutoresizingMaskIntoConstraints = NO;
    [_footView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-btnmargin-[btnChangeCam(==btncamH)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(btnChangeCam)]];
    
    UIButton *btnMic = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMic.tag = VideoConfVIEW_BtnMic;
    [btnMic setImage:[UIImage imageNamed:@"videoConf07"] forState:UIControlStateNormal];
    [btnMic setImage:[UIImage imageNamed:@"videoConf07_on"] forState:UIControlStateSelected];
    [btnMic addTarget:self action:@selector(muteMic:) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:btnMic];
    btnMic.translatesAutoresizingMaskIntoConstraints = NO;
    [_footView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-btnmargin-[btnMic(==btncamH)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(btnMic)]];
    [_footView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-btnmargin-[btnChangeCam(==btncamW)]-btnmargin-[btnMic]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(btnChangeCam,btnMic)]];
    
    UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExit.tag = VideoConfVIEW_BtnExit;
    [btnExit setImage:[UIImage imageNamed:@"videoConf58"] forState:UIControlStateNormal];
    [btnExit setImage:[UIImage imageNamed:@"videoConf58_on"] forState:UIControlStateSelected];
    [btnExit addTarget:self action:@selector(exitAlert) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:btnExit];
    btnExit.translatesAutoresizingMaskIntoConstraints = NO;
    [_footView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-btnmargin-[btnExit]-btnmargin-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(btnExit)]];
    [_footView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[btnExit(==btnexitH)]-btnexitMargin-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(btnExit)]];
}

#pragma mark -点击按钮处理方法
-(void)changeCam:(id)sender
{
    curCameraIndex ++;
    if (curCameraIndex >= [DemoGlobalClass sharedInstance].cameraInfoArray.count)
    {
        curCameraIndex = 0;
    }
    [[DemoGlobalClass sharedInstance] selectCamera:curCameraIndex];
}

- (void)muteMic:(id)sender
{
    isMute = !isMute;
    UIButton *btn = (UIButton*) sender;
    [[ECDevice sharedInstance].VoIPManager setMute:isMute];
    if (isMute)
    {
        [btn setImage:[UIImage imageNamed:@"videoConf13_on.png"] forState:(UIControlStateSelected)];
        [btn setImage:[UIImage imageNamed:@"videoConf13.png"] forState:(UIControlStateNormal)];
    }
    else
    {
        [btn setImage:[UIImage imageNamed:@"videoConf07_on.png"] forState:(UIControlStateSelected)];
        [btn setImage:[UIImage imageNamed:@"videoConf07.png"] forState:(UIControlStateNormal)];
        [self controllerSpeak:YES];
    }
}

-(void)exitAlert
{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"退出视频会议" message:@"真的要结束会议吗？" delegate:self cancelButtonTitle:@"结束" otherButtonTitles:@"取消", nil];
    if (self.myAlertView)
    {
        [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    self.myAlertView = alertview;
    alertview.tag = VideoConfVIEW_exitAlert;
    [alertview show];
}

#pragma mark -UIAlertView的代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == VideoConfVIEW_ConfDisslove|| alertView.tag == VideoConfVIEW_kickOff) {
        
        if (self.myAlertView) {
            [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
        [self exitVideoConf];
    } else if(alertView.tag == VideoConfVIEW_exitAlert) {
        
        if (buttonIndex == 0) {
            
            if (self.isCreator) {
                
                self.isCreatorExit = YES;
                
                if (self.isAutoDelete == NO||self.isAutoClose == NO) {
                    
                    [self exitVideoConf];
                    return;
                }
                
                [self deleteMultiVideo];
            } else {
                [self exitVideoConf];
            }
        }
    } else if(alertView.tag==VideoConfVIEW_addmember_voip || alertView.tag == VideoConfVIEW_addmember) {
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        if (buttonIndex == 1) {
            if ([textField.text length]==0) {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"邀请的号码不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                alert.tag = VideoConfVIEW_addNullNumber;
                [alert show];
                return;
            } else {
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager inviteMembersJoinMultiMediaMeeting:self.curVideoConfId andIsLoandingCall:(alertView.tag == VideoConfVIEW_addmember) andMembers:@[textField.text] andDisplayNumber:nil andSDKUserData:nil andServiceUserData:nil completion:^(ECError *error, NSString *meetingNumber) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if (error.errorCode != ECErrorType_NoError) {
                    
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
                        [strongSelf showProgress:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
                    }
                }];
            }
        }
    } else if (alertView.tag == 100) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            [self hangup];
        } else {
            [self accept];
        }
    }
}

#pragma mark -删除多路视频会议
- (void)deleteMultiVideo
{
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager deleteMultMeetingByMeetingType:ECMeetingType_MultiVideo andMeetingNumber:self.curVideoConfId completion:^(ECError *error, NSString *meetingNumber) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf closeProgress];
        
        if (error.errorCode == ECErrorType_NoError) {
            
            [strongSelf exitVideoConf];
        } else {
            
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
            hud.labelText = [NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail];
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:2];
            [self exitVideoConf];
        }
    }];

}

#pragma mark -退出当前的会议

- (void)exitVideoConf {
    if (self.callID.length > 0) {
        [DemoGlobalClass sharedInstance].isCallBusy = NO;
        [[ECDevice sharedInstance].VoIPManager releaseCall:self.callID];
    }
    [[ECDevice sharedInstance].meetingManager exitMeeting];
    [self backToView];
}

- (void)backToView {
    _backView = nil;
    [[ECDevice sharedInstance].VoIPManager setVideoView:nil andLocalView:nil];
    [self closeProgress];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.backView) {
        [self.navigationController popToViewController:self.backView animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -蒙版
-(void)showProgress:(NSString *)labelText{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.detailsLabelText = labelText;
    hud.mode = MBProgressHUDModeText;
    hud.margin = 30.0f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.0];
}

-(void)closeProgress{
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark -joinInVideoConf
- (void)joinInVideoConf
{
    statusView.text =@"连接中，请稍后....";
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager joinMeeting:self.curVideoConfId ByMeetingType:ECMeetingType_MultiVideo andMeetingPwd:nil completion:^(ECError *error, NSString *meetingNumber) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf closeProgress];
        
        if (error.errorCode == ECErrorType_NoError) {
            
            strongSelf.curVideoConfId = meetingNumber;
            if (strongSelf.curVideoConfId.length>0) {
                [strongSelf queryMemberInVideoMeeting];
            }
            statusView.text = [NSString stringWithFormat:@"正在%@会议",strongSelf.curVideoConfId];
        }
        else {
            if (error.errorCode == ECErrorType_NotExist) {
                error.errorDescription = [NSString stringWithFormat: @"会议已不存在！"];
            }
            
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
            [strongSelf showProgress:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
        }
    }];
}

#pragma mark -创建会议房间
- (void)createMultiVideoWithAutoClose:(BOOL)isAutoClose andIsPresenter:(BOOL)isPresenter andiVoiceMod:(NSInteger)voiceMod andAutoDelete:(BOOL)autoDelete andIsAutoJoin:(BOOL)isAutoJoin
{
    ECCreateMeetingParams *params = [[ECCreateMeetingParams alloc]init];
    params.meetingName=_Confname;
    params.meetingPwd = @"";
    params.meetingType = ECMeetingType_MultiVideo;
    params.square = 5;
    params.autoClose = isAutoClose;
    params.autoJoin = isAutoJoin;
    params.autoDelete = autoDelete;
    params.voiceMod = voiceMod;
    params.keywords = @"";
    
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    __weak __typeof(self) weakSelf = self;
    [[ECDevice sharedInstance].meetingManager createMultMeetingByType:params completion:^(ECError *error, NSString *meetingNumber) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf closeProgress];
        
        if(error.errorCode ==ECErrorType_NoError) {
            
            strongSelf.curVideoConfId = meetingNumber;
            strongSelf.isAutoClose = isAutoClose;
            strongSelf.isAutoDelete = autoDelete;
            if (strongSelf.curVideoConfId.length>0) {
                [strongSelf queryMemberInVideoMeeting];
            }
            statusView.text = [NSString stringWithFormat:@"正在%@会议",strongSelf.curVideoConfId];
        }
        else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
            [strongSelf showProgress:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
        }
    }];
}

-(void)queryMemberInVideoMeeting{
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍后...";
    hud.removeFromSuperViewOnHide = YES;
    
    if(self.curVideoConfId){
        
        __weak __typeof(self) weakSelf = self;
        [[ECDevice sharedInstance].meetingManager queryMeetingMembersByMeetingType:ECMeetingType_MultiVideo andMeetingNumber:self.curVideoConfId completion:^(ECError *error, NSArray *members) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf closeProgress];
            
            if(error.errorCode == ECErrorType_NoError){
                
                [strongSelf.membersArray removeAllObjects];
                [strongSelf.membersArray addObjectsFromArray:members];
                
                ECMultiVideoMeetingMember *meInfo = nil;
                NSArray *tmpMemberarr = [NSArray arrayWithArray:self.membersArray];
                for (ECMultiVideoMeetingMember *videoMembers in tmpMemberarr)
                {
                    if ([[DemoGlobalClass sharedInstance].userName isEqualToString:videoMembers.voipAccount.account])
                    {
                        meInfo = videoMembers;
                        strongSelf.myVideoState = videoMembers.videoState;
                        [strongSelf.membersArray removeObject:videoMembers];
                    }
                    [strongSelf addMemberToView:videoMembers];
                }
                if (meInfo) {
                    [strongSelf.membersArray insertObject:meInfo atIndex:0];
                }
            }
            else {
                
                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
                [strongSelf showProgress:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
            }
        }];
    }
}

- (void)addMemberToView:(ECMultiVideoMeetingMember *)member
{
    if (member && [member.voipAccount.account isEqualToString:[DemoGlobalClass sharedInstance].userName] && member.voipAccount.isVoIP)
    {
        self.view1.isDisplayVideo = YES;
        self.view1.strVoip = member.voipAccount;
        if (member.voipAccount.account.length >=4) {
            
            self.view1.voipLabel.text = [member.voipAccount.account substringFromIndex:[member.voipAccount.account length]-4];
        } else {
            
            self.view1.voipLabel.text = member.voipAccount.account;
        }
        self.view1.videoLabel.text = @"";
        return;
    }
    for (int i = VideoConfVIEW_View1+1; i<VideoConfVIEW_View1+5; i++)
    {
        MultiVideoView *tmpView = (MultiVideoView*)[_midView viewWithTag:i];
        
        if (tmpView && tmpView.strVoip == nil)
        {
            if (member)
            {
                tmpView.strVoip = member.voipAccount;
                if (member.voipAccount.account.length >=4) {
                    
                    tmpView.voipLabel.text = [member.voipAccount.account substringFromIndex:[member.voipAccount.account length]-4];
                } else {
                    
                    tmpView.voipLabel.text = member.voipAccount.account;
                }
                tmpView.videoLabel.text = @"";
                if (videoCount > 10) return;
                else
                {
                    NSArray *addrarr = [member.videoSource componentsSeparatedByString:@":"];
                    if (addrarr.count == 2)
                    {
                        tmpView.isDisplayVideo = YES;
                        
                        NSString *port = [addrarr objectAtIndex:1];
                        
                        [self setVideoConf:[addrarr objectAtIndex:0]];
                        
                        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        hud.labelText = @"请稍后...";
                        hud.removeFromSuperViewOnHide = YES;
                        
                        __weak __typeof(self) weakSelf = self;
                        [[ECDevice sharedInstance].meetingManager requestMemberVideoWithAccount:member.voipAccount.account andDisplayView:tmpView.bgView andVideoMeeting:self.curVideoConfId andPwd:nil andPort:[port integerValue] completion:^(ECError *error, NSString *meetingNumber, NSString *member) {
                            
                            __strong __typeof(weakSelf)strongSelf = weakSelf;
                            [strongSelf closeProgress];
                            
                            if (error.errorCode == ECErrorType_NoError) {
                                
                                 videoCount ++;
                            }
                            else {
                                
                                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
                                [strongSelf showProgress:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
                            }
                        }];
                    }
                }
            }
            break;
        }
    }
}

- (void) setVideoConf:(NSString *)videoConf {
    if (self.confAddr == nil && videoConf!=nil && videoConf.length > 0) {
        self.confAddr = videoConf;
        [[ECDevice sharedInstance].meetingManager setVideoConferenceAddr:self.confAddr];
    }
}

#pragma mark -视频分辨率发生变化
- (void)onCallVideoRatioChanged:(NSString *)callid andVoIP:(NSString *)voip andIsConfrence:(BOOL)isConference andWidth:(NSInteger)width andHeight:(NSInteger)height {
    
    if (isConference && voip.length > 0) {
        
        for (int i = VideoConfVIEW_View1+1; i<VideoConfVIEW_View1+5; i++) {
            MultiVideoView* tmpView = (MultiVideoView*)[_midView viewWithTag:i];
            if (tmpView.strVoip.account.length > 0 && [tmpView.strVoip.account isEqualToString:voip]) {
                [tmpView setVideoRatioChangedWithHeight:height withWidth:width];
                break;
            }
        }
    }
}

#pragma mark -通知客户端收到新的会议信息
-(void)receiveMultiVideoMeetingMsg:(NSNotification *)notification
{
    ECMultiVideoMeetingMsg *msg = (ECMultiVideoMeetingMsg *)notification.object;
    if (![msg.roomNo isEqualToString:self.curVideoConfId]) {
        return;
    }
    
    ECMultiVideoMeetingMsgType type=  msg.type;
    
    NSString *voip = [DemoGlobalClass sharedInstance].userName;
    if(type == MultiVideo_JOIN)
    {
        if ([self.curVideoConfId isEqualToString:msg.roomNo])
        {
            NSInteger joinCount = 0;
            for (ECVoIPAccount *who in msg.joinArr)
            {
                BOOL isJoin = NO;
                for (ECMultiVideoMeetingMember  *m in self.membersArray )
                {
                    if ([m.voipAccount.account isEqualToString:who.account] && m.voipAccount.isVoIP==who.isVoIP)
                    {
                        isJoin = YES;
                        break;
                    }
                }
                if (isJoin)
                {
                    continue;
                }
                
                ECMultiVideoMeetingMember *member = [[ECMultiVideoMeetingMember alloc] init];
                member.voipAccount = [[ECVoIPAccount alloc] init];
                member.voipAccount.account = who.account;
                member.voipAccount.isVoIP = who.isVoIP;
                
                if(![voip isEqualToString:who.account] && who.account.length>4){
                    [self showProgress:[NSString stringWithFormat:@"%@加入会议",[who.account substringFromIndex:[who.account length]-4]]];
                }
                member.role = 0;
                member.videoState = msg.videoState;
                member.videoSource = msg.videoSource;
                [self.membersArray addObject:member];
                [self addMemberToView:member];
                joinCount++;
            }
            
            if (joinCount > 0)
            {
                [self.pointImg stopAnimating];
                [self.pointImg startAnimating];
                statusView.text = @"有人加入会议";
            }
        }
    }
    else if(type == MultiVideo_EXIT)//有人退出
    {
        if ([self.curVideoConfId isEqualToString:msg.roomNo])
        {
            NSMutableArray *exitArr = [[NSMutableArray alloc] init];
            for (ECVoIPAccount *who in msg.exitArr)
            {
                for (ECMultiVideoMeetingMember *member in self.membersArray)
                {
                    if ([who.account isEqualToString:member.voipAccount.account] && who.isVoIP==member.voipAccount.isVoIP)
                    {
                        [exitArr addObject:member];
                        if(![voip isEqualToString:who.account] && who.account.length>4){
                            statusView.text = [NSString stringWithFormat:@"%@退出了会议",[who.account substringFromIndex:[who.account length]-4]];
                        }
                        [self removeMemberFromView:member];
                    }
                }
            }
            if (exitArr.count > 0)
            {
                [self.membersArray removeObjectsInArray:exitArr];
                [self.pointImg stopAnimating];
                [self.pointImg startAnimating];
                statusView.text = @"有人退出会议";
            }
        }
    }
    else if(type == MultiVideo_DELETE)
    {
        if ([msg.roomNo isEqualToString:self.curVideoConfId])
        {
            if (_isCreatorExit)//创建者退出时解散会议则不提示
            {
                if (self.myAlertView)
                {
                    [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
                }
                [self exitVideoConf];
            }
            else
            {
                UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"会议被解散" message:@"抱歉，该会议已经被创建者解散，点击确定可以退出！"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                if (self.myAlertView)
                {
                    [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
                }
                self.myAlertView = alertview;
                alertview.tag = VideoConfVIEW_ConfDisslove;
                [alertview show];
            }
        };
    }
    else if(type == MultiVideo_REMOVEMEMBER)
    {
        if ([msg.roomNo isEqualToString: self.curVideoConfId])
        {
            if ([msg.who.account isEqualToString:[DemoGlobalClass sharedInstance].userName] && msg.who.isVoIP)//自己被踢出
            {
                UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"您已被请出会议" message:@"抱歉，您被创建者请出会议了，点击确定以退出"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                if (self.myAlertView)
                {
                    [self.myAlertView dismissWithClickedButtonIndex:0 animated:NO];
                }
                self.myAlertView = alertview;
                
                alertview.tag = VideoConfVIEW_kickOff;
                [alertview show];
                return;
            }
            NSInteger* exitCount = 0;
            NSMutableArray *removeArray = [NSMutableArray array];
            for (ECMultiVideoMeetingMember *member in self.membersArray)
            {
                if ([msg.who.account isEqualToString:member.voipAccount.account] && msg.who.isVoIP==member.voipAccount.isVoIP)
                {
                    [removeArray addObject:member];
                    if(![[DemoGlobalClass sharedInstance].userName isEqualToString:msg.who.account] && msg.who.account.length>4){
                        statusView.text = [NSString stringWithFormat:@"%@踢出了会议",[msg.who.account substringFromIndex:[msg.who.account length]-4]];
                    }
                    [self removeMemberFromView:member];
                    exitCount++;
                }
            }
            if (exitCount > 0)
            {
                [self.membersArray removeObjectsInArray:removeArray];
                [self.pointImg stopAnimating];
                [self.pointImg startAnimating];
                statusView.text = @"有人被踢出会议";
            }
        }
    }
    else if(type == MultiVideo_PUBLISH)
    {
        if ([msg.roomNo isEqualToString: self.curVideoConfId])
        {
            
            for (ECMultiVideoMeetingMember *member in self.membersArray)
            {
                if ([msg.who.account isEqualToString:member.voipAccount.account] && msg.who.isVoIP==member.voipAccount.isVoIP)
                {
                    member.videoState = msg.videoState;
                    member.videoSource = msg.videoSource;
                    break;
                }
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@发布视频",msg.who.account] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
    else if(type == MultiVideo_UNPUBLISH)
    {
        if ([msg.roomNo isEqualToString: self.curVideoConfId])
        {
            
            for (ECMultiVideoMeetingMember *member in self.membersArray)
            {
                if ([msg.who.account isEqualToString:member.voipAccount.account] && msg.who.isVoIP==member.voipAccount.isVoIP)
                {
                    member.videoState = msg.videoState;
                    member.videoSource = nil;
                    break;
                }
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@取消发布视频",msg.who.account] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    } else if (type == MultiVideo_REFUSE) {
        
        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"拒接" message:@"抱歉，对方拒绝了你的请求"  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertview.tag = VideoConfVIEW_refuse;
        [alertview show];
    } else if (type == MultiVideo_SPEAKLISTEN) {
        NSString *str = nil;
        switch (msg.speakListen.integerValue) {
            case 00:
                str = [NSString stringWithFormat:@"%@已被禁言禁听",msg.who.account];
                break;
            case 01:
                str = [NSString stringWithFormat:@"%@已被禁听",msg.who.account];
                break;
            case 10:
                str = [NSString stringWithFormat:@"%@已被禁言",msg.who.account];
                break;
            case 11:
                str = [NSString stringWithFormat:@"%@可听可讲",msg.who.account];
                break;
            default:
                break;
        }
        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"提示" message:str  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertview.tag = VideoConfVIEW_speakListen;
        [alertview show];
    }
}

#pragma mark -删除多路视频会议成员
-(void)removeMemberFromView:(ECMultiVideoMeetingMember *)member
{
    for (int i = VideoConfVIEW_View1; i<VideoConfVIEW_View1+5; i++)
    {
        MultiVideoView* tmpView = (MultiVideoView*)[_midView viewWithTag:i];
        if (tmpView && tmpView.strVoip != nil)
        {
            if (member && [tmpView.strVoip.account isEqualToString:member.voipAccount.account] && tmpView.strVoip.isVoIP==member.voipAccount.isVoIP)
            {
                
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager cancelMemberVideoWithAccount:member.voipAccount.account andVideoMeeting:self.curVideoConfId andPwd:nil completion:^(ECError *error, NSString *meetingNumber, NSString *member) {
                    
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    [strongSelf closeProgress];
                    if (error.errorCode == ECErrorType_NoError) {
                        
                        videoCount --;
                    } else {
                        
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
                        [strongSelf showProgress:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
                    }
                }];
                
                tmpView.isDisplayVideo = NO;
                tmpView.ivChoose.hidden = YES;
                for (UIView *view in tmpView.bgView.subviews) {
                    [view removeFromSuperview];
                }
                tmpView.bgView.backgroundColor = [UIColor clearColor];
                tmpView.bgView.layer.contents = nil;
                tmpView.strVoip = nil;
                tmpView.videoLabel.text = @"待加入";
                tmpView.voipLabel.text = @"";
                tmpView.icon.hidden = YES;
                break;
            }
        }
    }
}

#pragma mark -发布多路视频和取消多路视频
- (void)onChooseIndex:(NSInteger)index andVoipAccount:(ECVoIPAccount *)voip
{
    MultiVideoView* video = (MultiVideoView*)[_midView viewWithTag:index];
   
    self.curMember = voip;
    int i = 0;
    UIActionSheet *menu = nil;
    if ([[DemoGlobalClass sharedInstance].userName isEqualToString:voip.account] && voip.isVoIP) {
        menu = [[UIActionSheet alloc] initWithTitle: @"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        menu.tag = 105;

        if (self.myVideoState == 1 || self.myVideoState==0) {//2代表未发布
            
            [menu addButtonWithTitle:@"取消发布视频"];
        } else if(self.myVideoState == 2){//1代表发布
            
            [menu addButtonWithTitle:@"发布视频"];
        }
        i++;
    } else {
        menu = [[UIActionSheet alloc] initWithTitle: @"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        menu.tag = 100;
        
        if (video.isDisplayVideo ) {
            
            [menu addButtonWithTitle:@"取消视频"];
        } else {
            
            [menu addButtonWithTitle:@"请求视频"];
        }
        i++;
    }
        
    if (video.isZoomBig) {
        
        [menu addButtonWithTitle:@"缩小"];
    } else {
        
        [menu addButtonWithTitle:@"放大"];
    }
    i++;
    
    if (self.isCreator && (![[DemoGlobalClass sharedInstance].userName isEqualToString:voip.account] || !voip.isVoIP)) {
        
        [menu addButtonWithTitle:@"移除成员"];
        i++;
    }
    if (menu != nil) {
        if (i > 0) {
            [menu addButtonWithTitle:@"取消"];
            [menu setCancelButtonIndex:i];
            [menu showInView:self.view.window];
        }
    }

}

-(void)resetVideoViewFrame
{
    for (int i = VideoConfVIEW_View1; i<VideoConfVIEW_View1+5; i++)
    {
        MultiVideoView* tmpView = (MultiVideoView*)[_midView viewWithTag:i];
        if (tmpView.isZoomBig)
        {
            tmpView.isZoomBig = NO;
            tmpView.frame = tmpView.originFrame;
        }
    }
}

#pragma mark -UIActionSheet的代理方法
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100)//视频处理
    {
        MultiVideoView *view = nil;
        if ([self.view2.strVoip.account isEqualToString:self.curMember.account] && self.view2.strVoip.isVoIP == self.curMember.isVoIP) {
            view =self.view2;
        }
        else if ([self.view3.strVoip.account isEqualToString:self.curMember.account] && self.view3.strVoip.isVoIP == self.curMember.isVoIP) {
            view = self.view3;
        }
        else if ([self.view4.strVoip.account isEqualToString:self.curMember.account] && self.view4.strVoip.isVoIP == self.curMember.isVoIP) {
            view = self.view4;
        }
        else if ([self.view5.strVoip.account isEqualToString:self.curMember.account] && self.view5.strVoip.isVoIP == self.curMember.isVoIP) {
            view = self.view5;
        }
        
        if (buttonIndex == 0)
        {
            if (view.isDisplayVideo)
            {
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager cancelMemberVideoWithAccount:self.curMember.account andVideoMeeting:self.curVideoConfId andPwd:nil completion:^(ECError *error, NSString *meetingNumber, NSString *member) {
                    
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if (error.errorCode == ECErrorType_NoError) {
                        
                    } else {
                        
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
                        [strongSelf showProgress:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
                    }
                }];
                videoCount --;
                view.isDisplayVideo = NO;
            }
            else {
                if (videoCount>10) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"  message:@"视频数过多，请先取消一个" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                    return;
                }
                
                for (ECMultiVideoMeetingMember *member in self.membersArray)
                {
                    if ([self.curMember.account isEqualToString:member.voipAccount.account] && self.curMember.isVoIP == member.voipAccount.isVoIP)
                    {
                        NSArray *addrarr = [member.videoSource componentsSeparatedByString:@":"];
                        if (addrarr.count == 2)
                        {
                            NSString* port = [addrarr objectAtIndex:1];
                            [self setVideoConf:[addrarr objectAtIndex:0]];
                            
                            __weak __typeof(self) weakSelf = self;
                            [[ECDevice sharedInstance].meetingManager requestMemberVideoWithAccount:self.curMember.account andDisplayView:view.bgView andVideoMeeting:self.curVideoConfId andPwd:nil andPort:port.integerValue completion:^(ECError *error, NSString *meetingNumber, NSString *member) {
                                
                                __strong __typeof(weakSelf)strongSelf = weakSelf;
                                if (error.errorCode == ECErrorType_NoError) {
                                    
                                    videoCount ++;
                                    view.isDisplayVideo = YES;
                                } else {
                                    
                                    NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
                                    [strongSelf showProgress:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
                                }
                            }];
                        }
                    }
                }
            }
        }
        else if(buttonIndex == 1)
        {
            if (view.isZoomBig) {
                [self resetVideoViewFrame];
            } else {
                [self resetVideoViewFrame];
                view.originFrame = view.frame;
                view.isZoomBig = YES;
                view.frame = self.mainView.frame;
            }
        }
        else if (buttonIndex == 2) {
            
            if (self.isCreator) {
                
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"请稍后...";
                hud.removeFromSuperViewOnHide = YES;
                
                ECVoIPAccount *member = [[ECVoIPAccount alloc] init];
                member.account = self.curMember.account;
                member.isVoIP = self.curMember.isVoIP;
                
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager removeMemberFromMultMeetingByMeetingType:ECMeetingType_MultiVideo andMeetingNumber:self.curVideoConfId andMember:member completion:^(ECError *error, ECVoIPAccount *memberVoip) {
                    
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    [strongSelf closeProgress];
                    if (error.errorCode == ECErrorType_NoError) {
                        if (!strongSelf.isCreator) {
                            [strongSelf.membersArray removeObject:memberVoip];
                        }
                    } else {
                        
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
                        [strongSelf showProgress:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
                    }
                }];
            }
        }
    }
   else if (actionSheet.tag == 105)
    {
        if (buttonIndex == 0)
        {
            if (self.myVideoState == 1)
            {
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager cancelPublishSelfVideoFrameInVideoMeeting:self.curVideoConfId completion:^(ECError *error, NSString *meetingNumber) {
                    
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if(error.errorCode==ECErrorType_NoError){
                        
                        strongSelf.myVideoState = 2;
                    }else {
                        
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
                        [strongSelf showProgress:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
                    }
                }];
            }
            else
            {
                __weak __typeof(self) weakSelf = self;
                [[ECDevice sharedInstance].meetingManager publishSelfVideoFrameInVideoMeeting:self.curVideoConfId completion:^(ECError *error, NSString *meetingNumber) {
               
                     __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if(error.errorCode==ECErrorType_NoError){
                        
                        strongSelf.myVideoState = 1;
                    }else {
                        
                        NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
                        [strongSelf showProgress:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
                    }
                }];
            }
        }
        else if (buttonIndex == 1)
        {
            if (self.view1.isZoomBig) {
                
                [self resetVideoViewFrame];
            } else {
                [self resetVideoViewFrame];
                _view1.originFrame = _view1.frame;
                self.view1.frame = self.mainView.frame;
                self.view1.isZoomBig = YES;
            }
        }
    } else if (actionSheet.tag == VideoConfSheet) {
        if (buttonIndex!=actionSheet.cancelButtonIndex) {
            ECMultiVideoMeetingMember* member = [self.membersArray objectAtIndex:buttonIndex];
            NSString *count = objc_getAssociatedObject(actionSheet, &KSeapkListenSheet);
            [[ECDevice sharedInstance].meetingManager setMember:member.voipAccount speakListen:count.integerValue ofMeetingType:ECMeetingType_MultiVideo andMeetingNumber:self.curVideoConfId completion:^(ECError *error, NSString *meetingNumber) {
                if (error.errorCode != ECErrorType_NoError) {
                    [self showProgress:[NSString stringWithFormat:@"%ld%@",(long)error.errorCode,error.description]];
                }
            }];
        }
    }
}

//通话回调函数，判断通话状态
- (void)onCallEvents:(NSNotification *)notification {
    
    VoIPCall* voipCall = notification.object;
    if (![self.callID isEqualToString:voipCall.callID]) {
        return;
    }
    
    switch (voipCall.callStatus) {
            
        case ECallStreaming: {
            [DemoGlobalClass sharedInstance].isCallBusy = YES;
            statusView.text = [NSString stringWithFormat:@"正在%@会议",self.curVideoConfId];
            [self queryMemberInVideoMeeting];
        }
            break;
            
        case ECallFailed: {
            [DemoGlobalClass sharedInstance].isCallBusy = NO;
            if( voipCall.reason == ECErrorType_NoResponse) {
                statusView.text = @"网络不给力";
            } else if ( voipCall.reason == ECErrorType_CallBusy || voipCall.reason == ECErrorType_Declined ) {
                statusView.text = @"您拨叫的用户正忙，请稍后再拨";
            } else if ( voipCall.reason == ECErrorType_OtherSideOffline) {
                statusView.text = @"对方不在线";
            } else if ( voipCall.reason == ECErrorType_CallMissed ) {
                statusView.text = @"呼叫超时";
            } else if ( voipCall.reason == ECErrorType_SDKUnSupport) {
                statusView.text = @"该版本不支持此功能";
            } else if ( voipCall.reason == ECErrorType_CalleeSDKUnSupport ) {
                statusView.text = @"对方版本不支持音频";
            } else {
                statusView.text = @"呼叫失败";
            }
            
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(hangup) userInfo:nil repeats:NO];
        }
            break;
            
        case ECallEnd: {
            [DemoGlobalClass sharedInstance].isCallBusy = NO;
            statusView.text = @"正在挂机...";
            [self backToView];
        }
            break;
            
        default:
            break;
    }
}

- (void)hangup {
    statusView.text = @"正在挂机...";
    [DemoGlobalClass sharedInstance].isCallBusy = NO;
    [[ECDevice sharedInstance].VoIPManager releaseCall:self.callID];
    [self backToView];
}

- (void)accept {
    [self performSelector:@selector(answer) withObject:nil afterDelay:0.1];
}

- (void)answer {
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    if ([[ECDevice sharedInstance].VoIPManager acceptCall:self.callID withType:VIDEO] != 0) {
        [self backToView];
    }
}


@end
