//
//  SettingViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "SetCodecViewController.h"
#import "CameraDeviceInfo.h"
#import "ECEnumDefs.h"

#define Group_Margin_Heigth 20.0f
#define Line_Margin_Heigth 1.0f

@interface SetCodecViewController()
@end

@implementation SetCodecViewController
#pragma mark - prepareUI
-(void)prepareUI {
    
    self.title =@"编解码设置";
    
    UIView *switchView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 0, 0)];
    
    for (int index = Codec_iLBC; index<=Codec_OPUS8; index++) {
        if (index==Codec_iLBC || index==Codec_PCMA || index==Codec_SILK8K || index==Codec_AMR || index==Codec_SILK16K) {
            continue;
        }
        switchView = [self switchViewFrameY:(Line_Margin_Heigth+switchView.frame.origin.y+switchView.frame.size.height) andTag:index];
    }
    
    ((UIScrollView*)self.view).contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, switchView.frame.origin.y+switchView.frame.size.height+Group_Margin_Heigth);
    
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
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
    
    BOOL isOn = [[DemoGlobalClass sharedInstance] GetSDKIsEnableCodecType:tag];
    [switchs setOn:isOn];
    switch (tag) {
        case Codec_iLBC: {
            label.text = @"Codec_iLBC";
            break;
        }
        case Codec_G729: {
            label.text = @"Codec_G729";
            break;
        }
        case Codec_PCMU: {
            label.text = @"Codec_PCMU";
            break;
        }
        case Codec_PCMA: {
            label.text = @"Codec_PCMA";
            break;
        }
        case Codec_H264: {
            label.text = @"Codec_H264";
            break;
        }
        case Codec_SILK8K: {
            label.text = @"Codec_SILK8K";
            break;
        }
        case Codec_AMR: {
            label.text = @"Codec_AMR";
            break;
        }
        case Codec_VP8: {
            label.text = @"Codec_VP8";
            break;
        }
        case Codec_SILK16K: {
            label.text = @"Codec_SILK16K";
            break;
        }
        case Codec_OPUS48: {
            label.text = @"Codec_OPUS48";
            break;
        }
        case Codec_OPUS16: {
            label.text = @"Codec_OPUS16";
            break;
        }
        case Codec_OPUS8: {
            label.text = @"Codec_OPUS8";
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
    [[DemoGlobalClass sharedInstance] SetSDKCodecType:switches.tag andEnable:switches.isOn];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    UIScrollView *myview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.view = myview;
    self.view.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.96f alpha:1.00f];
    [self prepareUI];
}

@end
