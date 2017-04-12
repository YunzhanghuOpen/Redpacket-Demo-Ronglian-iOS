//
//  SettingViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "SettingViewController.h"
#import "CameraDeviceInfo.h"
#import "SetCodecViewController.h"

#define TAG_SwitchSound     100
#define TAG_SwitchShake     101
#define TAG_SwitchPlayEar   102

#define Group_Margin_Heigth 20.0f
#define Line_Margin_Heigth 1.0f

@interface SettingViewController()<UIAlertViewDelegate,UIActionSheetDelegate>
@end

@implementation SettingViewController
#pragma mark - prepareUI
-(void)prepareUI {
    
    UIView *soundView = [self switchViewFrameY:(10) andTag:TAG_SwitchSound];
    
    UIView *shakeView = [self switchViewFrameY:(Line_Margin_Heigth+soundView.frame.origin.y+soundView.frame.size.height) andTag:TAG_SwitchShake];
    
    UIView *playEarView = [self switchViewFrameY:(Group_Margin_Heigth+shakeView.frame.origin.y+shakeView.frame.size.height) andTag:TAG_SwitchPlayEar];
    
    //版本号显示
    int major = ECDevice_SDK_VERSION / 1000000;
    int minor = (ECDevice_SDK_VERSION / 1000) % 1000;
    int micro = ECDevice_SDK_VERSION % 1000;

    UIButton * settingBtn = [self addBottonWithFrameY:CGRectGetMaxY(playEarView.frame)+Group_Margin_Heigth text:[NSString stringWithFormat:@"当前版本(%d.%d.%dr)",major,minor,micro] action:@selector(updateBtnClicked)];
    settingBtn.enabled = [DemoGlobalClass sharedInstance].isNeedUpdate;
    if ([DemoGlobalClass sharedInstance].isNeedUpdate) {
        UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(260.0f, 23.0f, 40.0f, 14.0f)];
        newLabel.text = @"new";
        newLabel.font = [UIFont systemFontOfSize:13.0f];
        newLabel.textAlignment = NSTextAlignmentCenter;
        newLabel.backgroundColor = [UIColor redColor];
        newLabel.textColor = [UIColor whiteColor];
        newLabel.layer.cornerRadius = 7.0f;
        newLabel.layer.masksToBounds = YES;
        [settingBtn addSubview:newLabel];
    }
    
    //编解码设置
    settingBtn = [self addBottonWithFrameY:CGRectGetMaxY(settingBtn.frame)+Group_Margin_Heigth text:@"设置编解码" action:@selector(setCodecBtnClicked)];
    
    //视频分辨率
    CameraDeviceInfo *camera = [[DemoGlobalClass sharedInstance].cameraInfoArray objectAtIndex:0];
    CameraCapabilityInfo *capability = [camera.capabilityArray objectAtIndex:[DemoGlobalClass sharedInstance].curResolutionIndex];
    settingBtn = [self addBottonWithFrameY:CGRectGetMaxY(settingBtn.frame)+1.0f text:[NSString stringWithFormat:@"当前分辨率:%ldx%ld",capability.width,capability.height] action:@selector(videoResolutionBtnClicked:)];
    
    //视频view显示模式
    settingBtn = [self addBottonWithFrameY:CGRectGetMaxY(settingBtn.frame)+1.0f text:[NSString stringWithFormat:@"视频显示Mode:%@",[[DemoGlobalClass sharedInstance] viewContentModeToStr:[DemoGlobalClass sharedInstance].viewcontentMode]] action:@selector(videoVievModeBtnClicked:)];
    
    //退出当前账号
    settingBtn = [self addBottonWithFrameY:CGRectGetMaxY(settingBtn.frame)+Group_Margin_Heigth text:@"退出当前账号" action:@selector(excNowNumBtnClicked)];
    
    
    ((UIScrollView*)self.view).contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, CGRectGetMaxY(settingBtn.frame)+Group_Margin_Heigth);
}

- (UIButton*)addBottonWithFrameY:(CGFloat)frameY text:(NSString*)text action:(SEL)action {
    
    UIButton * setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    setBtn.frame = CGRectMake(0.0f, frameY, self.view.frame.size.width, 50.0f);
    [setBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 0.0f, self.view.frame.size.width-30.0f, 50.0f)];
    
    textLabel.text = text;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.tag = 100;
    [setBtn addSubview:textLabel];
    setBtn.titleLabel.textAlignment = NSTextAlignmentLeft;

    [setBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [setBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor whiteColor]] forState:UIControlStateDisabled];

    [setBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setBtn];
    return setBtn;
}

-(UIView*)switchViewFrameY:(CGFloat)frameY andTag:(NSInteger)tag {
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0.0f, frameY, self.view.frame.size.width, 50.0f)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(30.0f, 5.0f, self.view.frame.size.width-120.0f, 40.0f)];
    label.textColor = [UIColor blackColor];
    [view addSubview:label];
    
    UISwitch * switchs = [[UISwitch alloc] init];//[[UISwitch alloc]initWithFrame:CGRectMake(250.0f, 10.0f, 50.0f, 40.0f)];
    switchs.tag = tag;
    [switchs addTarget:self action:@selector(switchsChanged:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:switchs];
    
    CGRect frame = switchs.frame;
    frame.origin.x = view.frame.size.width-switchs.frame.size.width-20.0f;
    frame.origin.y = (view.frame.size.height-switchs.frame.size.height)*0.5;
    switchs.frame = frame;
    
    switch (tag) {
        case TAG_SwitchPlayEar: {
            label.text = @"听筒模式";
            [switchs setOn:[DemoGlobalClass sharedInstance].isPlayEar];
            break;
        }
        case TAG_SwitchShake: {
            label.text = @"新消息震动";
            [switchs setOn:[DemoGlobalClass sharedInstance].isMessageShake];
            break;
        }
        case TAG_SwitchSound: {
            label.text = @"新消息声音";
            [switchs setOn:[DemoGlobalClass sharedInstance].isMessageSound];
            break;  
        }
        default:
            break;
    }
    return view;
}

#pragma mark - BtnClick

-(void)returnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)switchsChanged:(UISwitch *)switches {
    switch (switches.tag) {
        case TAG_SwitchSound:
            [DemoGlobalClass sharedInstance].isMessageSound = switches.isOn;
            break;
        case TAG_SwitchShake:
            [DemoGlobalClass sharedInstance].isMessageShake = switches.isOn;
            break;
        case TAG_SwitchPlayEar:
            [DemoGlobalClass sharedInstance].isPlayEar = switches.isOn;
            break;
        default:
            break;
    }
}

-(void)updateBtnClicked {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://dwz.cn/F8pPd"]];
}

//退出客户端
-(void)excOrderBtnClicked {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"退出" message:@"确认要退出客户端吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 100;
    [alertView show];
}

//退出当前账号
-(void)excNowNumBtnClicked {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注销" message:@"确认要退出当前账号吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 101;
    [alertView show];
}

- (void)setCodecBtnClicked {
    SetCodecViewController* viewController = [[NSClassFromString(@"SetCodecViewController") alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == 100) {
            exit(0);
        } else if (alertView.tag == 101) {

            MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hub.removeFromSuperViewOnHide = YES;
            hub.labelText = @"正在注销...";
            
            [[ECDevice sharedInstance] logout:^(ECError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                [DemoGlobalClass sharedInstance].userName = nil;
                
                [DemoGlobalClass sharedInstance].isLogin = NO;
                
                //为了页面的跳转，使用了该错误码，用户在使用过程中，可以自定义消息，或错误码值
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:[ECError errorWithCode:10]];
            }];
        }
    }
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    UIScrollView *myview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.view = myview;
    self.view.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.96f alpha:1.00f];
    
    self.title =@"设置";

    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;

    [self prepareUI];
}


const NSInteger videoViewModeSheetTag = 101;
const char  KButtonLabelSheet;
- (void)videoVievModeBtnClicked:(UIButton*)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"视频View.contentMode" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"ScaleToFill",@"ScaleAspectFit",@"ScaleAspectFill",nil];
    sheet.tag = videoViewModeSheetTag;
    sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    objc_setAssociatedObject(sheet, &KButtonLabelSheet, [sender viewWithTag:100], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [sheet showInView:self.view];
}

const NSInteger videoResolutionSheetTag = 100;
- (void)videoResolutionBtnClicked:(UIButton*)sender {
    CameraDeviceInfo *camera = [[DemoGlobalClass sharedInstance].cameraInfoArray objectAtIndex:0];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"设置分辨率" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    sheet.tag = videoResolutionSheetTag;
    for (CameraCapabilityInfo *capability in camera.capabilityArray) {
        [sheet addButtonWithTitle:[NSString stringWithFormat:@"%ldx%ld",capability.width,capability.height]];
    }
    sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    objc_setAssociatedObject(sheet, &KButtonLabelSheet, [sender viewWithTag:100], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex!=actionSheet.cancelButtonIndex) {
        switch (actionSheet.tag) {
            case videoResolutionSheetTag:
            {
                UILabel *btnLabel = objc_getAssociatedObject(actionSheet, &KButtonLabelSheet);
                btnLabel.text = [NSString stringWithFormat:@"当前分辨率:%@",[actionSheet buttonTitleAtIndex:buttonIndex]];
                [[DemoGlobalClass sharedInstance] setCurResolutionIndex:buttonIndex-1];
                [[DemoGlobalClass sharedInstance] selectCamera:0];
            }
                break;
                
            case videoViewModeSheetTag: {
                UILabel *btnLabel = objc_getAssociatedObject(actionSheet, &KButtonLabelSheet);
                NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
                btnLabel.text = [NSString stringWithFormat:@"视频显示Mode:%@",[actionSheet buttonTitleAtIndex:buttonIndex]];
                [[DemoGlobalClass sharedInstance] setViewcontentMode:[[DemoGlobalClass sharedInstance] viewContentModeFromStr:btnTitle]];
            }
                break;
                
            default:
                break;
        }
        
    }
}
@end
