//
//  ContactDetailViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/6.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "VoipCallController.h"
#import "VideoViewController.h"

extern NSString * Notification_ChangeMainDisplay;


@interface ContactDetailViewController ()<UIActionSheetDelegate>

@end

@implementation ContactDetailViewController
-(void)prepareUI {
    
    self.title =@"联系人详情";
    
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIImageView * bgImageView = [[UIImageView alloc]init];
    bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
    bgImageView.image = [UIImage imageNamed:@"personal_center_bg"];
    [self.view addSubview:bgImageView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[bgImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgImageView)]];

    UIImageView * headImageView = [[UIImageView alloc]init];
    headImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [headImageView setImage:_dict[imageKey]];
    [bgImageView addSubview:headImageView];
    [bgImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[headImageView(==70)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headImageView)]];
    
    UILabel * nameLabel = [[UILabel alloc]init];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    nameLabel.text = _dict[nameKey];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:23];
    nameLabel.textColor = [UIColor whiteColor];
    [bgImageView addSubview:nameLabel];
    [bgImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[headImageView(==70)]-20-[nameLabel]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headImageView,nameLabel)]];
    
    UILabel * numLabel = [[UILabel alloc]init];
    numLabel.translatesAutoresizingMaskIntoConstraints = NO;
    numLabel.text = _dict[phoneKey];
    numLabel.textColor = [UIColor whiteColor];
    numLabel.backgroundColor = [UIColor clearColor];
    [bgImageView addSubview:numLabel];
    [bgImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[headImageView]-20-[numLabel]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headImageView,numLabel)]];
    
    [bgImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-46-[nameLabel(==30)][numLabel(==30)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(nameLabel,numLabel)]];
    
    
    UIButton * contactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    contactBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [contactBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    [contactBtn setTitle:@"发消息" forState:UIControlStateNormal];
    [contactBtn addTarget:self action:@selector(contactBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:contactBtn];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[contactBtn(==270)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contactBtn)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:contactBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    UIButton * voipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voipBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [voipBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    [voipBtn setTitle:@"音视频聊天" forState:UIControlStateNormal];
    [voipBtn addTarget:self action:@selector(voipCallBtnTouch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:voipBtn];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[voipBtn(contactBtn)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(voipBtn,contactBtn)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:voipBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bgImageView(==140)]-20-[contactBtn(==45)]-20-[voipBtn(==contactBtn)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgImageView,contactBtn,voipBtn)]];
    
    if ([self.dict[phoneKey] isEqualToString:[DemoGlobalClass sharedInstance].userName] || ![DemoGlobalClass sharedInstance].isSDKSupportVoIP) {
        [voipBtn setHidden:YES];
    }
}

-(void)returnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)contactBtnClicked {
    UIViewController* viewController = [[NSClassFromString(@"ChatViewController") alloc] init];
    SEL aSelector = NSSelectorFromString(@"ECDemo_setSessionId:");
    if ([viewController respondsToSelector:aSelector]) {
        IMP aIMP = [viewController methodForSelector:aSelector];
        void (*setter)(id, SEL, NSString*) = (void(*)(id, SEL, NSString*))aIMP;
        setter(viewController, aSelector,_dict[phoneKey]);
    }
    [self.navigationController setViewControllers:[NSArray arrayWithObjects:[self.navigationController.viewControllers objectAtIndex:0],viewController, nil] animated:YES];
}

-(void)voipVoiceCall {
    VoipCallController * VVC = [[VoipCallController alloc] initWithCallerName:_dict[nameKey] andCallerNo:_dict[phoneKey] andVoipNo:_dict[phoneKey] andCallType:1];
    [self presentViewController:VVC animated:YES completion:nil];
}

-(void)voipLandingCall {
#ifndef AppStore
    VoipCallController * VVC = [[VoipCallController alloc] initWithCallerName:_dict[nameKey] andCallerNo:_dict[phoneKey] andVoipNo:_dict[phoneKey] andCallType:0];
    [self presentViewController:VVC animated:YES completion:nil];
#endif
}

-(void)voipCallBack {
    VoipCallController * VVC = [[VoipCallController alloc] initWithCallerName:_dict[nameKey] andCallerNo:_dict[phoneKey] andVoipNo:_dict[phoneKey] andCallType:2];
    [self presentViewController:VVC animated:YES completion:nil];
}

-(void)voipVideoCall {
    VideoViewController * vvc = [[VideoViewController alloc]initWithCallerName:[_dict objectForKey:nameKey] andVoipNo:[_dict objectForKey:phoneKey] andCallstatus:0];
    [self presentViewController:vvc animated:YES completion:nil];    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self prepareUI];
}

- (void)voipCallBtnTouch{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"呼叫类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"音频聊天", @"视频聊天",nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSString* button = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([button isEqualToString:@"音频聊天"]) {
            [self voipVoiceCall];
        } else if ([button isEqualToString:@"视频聊天"]) {
            [self voipVideoCall];
        }
    }
}

@end
