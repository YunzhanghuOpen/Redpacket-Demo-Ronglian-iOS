//
//  LoginViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/4.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "LoginViewController.h"
#import "ECDeviceHeaders.h"
#import "SessionViewController.h"
#import "SwitchIPViewController.h"
#import "AppDelegate+RedpacketConfig.h"

#define lasttimeuser @"lasttimeuser"
#define lasttimeuserpwd @"lasttimeuserpwd"

@interface LoginViewController()<UIAlertViewDelegate,UIViewControllerTransitioningDelegate>
@end

@implementation LoginViewController {
    UITextField * _userName;
    UITextField * _password;
    UIButton * _nextBtn;
}

//界面布局
-(void)prepareUI {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"切换登录" style:UIBarButtonItemStyleDone target:self action:@selector(switchVoipLogin)];
    [rightBtn setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    [DemoGlobalClass sharedInstance].loginAuthType = LoginAuthType_NormalAuth;

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeIPAndAppToken:)];
    [titleView addGestureRecognizer:longGesture];
    
    UILabel	*titleText = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 80, 20)];
    titleText.backgroundColor = [UIColor clearColor];
    [titleText setText:@"云通讯IM"];
    titleText.textColor = [UIColor whiteColor];
    [titleView addSubview:titleText];
    self.navigationItem.titleView = titleView;
    
    _userName = [[UITextField alloc]init];
    _userName.borderStyle = UITextBorderStyleLine;
    _userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    _userName.borderStyle = UITextBorderStyleRoundedRect;
    _userName.keyboardType = UIKeyboardTypeNumberPad;
    _userName.placeholder = @"请输入手机号";
    _userName.text = [[NSUserDefaults standardUserDefaults] objectForKey:lasttimeuser];
    [self.view addSubview:_userName];
    
    _password = [[UITextField alloc] init];
    _password.borderStyle = UITextBorderStyleLine;
    _password.clearButtonMode = UITextFieldViewModeWhileEditing;
    _password.borderStyle = UITextBorderStyleRoundedRect;
    _password.secureTextEntry = YES;
    _password.hidden = YES;
    _password.keyboardAppearance = UIKeyboardTypeASCIICapable;
    _password.placeholder = @"输入账号密码";
    _password.text = [[NSUserDefaults standardUserDefaults] objectForKey:lasttimeuserpwd];
    [self.view addSubview:_password];
    
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextBtn setBackgroundImage:[[UIImage imageNamed:@"select_account_button"] stretchableImageWithLeftCapWidth:50.0f topCapHeight:15.0f] forState:UIControlStateNormal];
    [_nextBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_nextBtn addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
    
    _userName.translatesAutoresizingMaskIntoConstraints = NO;
    _password.translatesAutoresizingMaskIntoConstraints = NO;
    _nextBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *metrics = @{@"textMargin":@30,@"btnMargin":@50,@"textHeight":@35,@"loginHeight":@45,@"forgetHeight":@25,@"topMargin":@(self.view.bounds.size.height*0.1)};
    NSArray* constraintsX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-textMargin-[_userName]-textMargin-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_userName)];
    [self.view addConstraints:constraintsX];
    
    constraintsX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-textMargin-[_password]-textMargin-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_password)];
    [self.view addConstraints:constraintsX];
    
    constraintsX = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-btnMargin-[_nextBtn]-btnMargin-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_nextBtn)];
    [self.view addConstraints:constraintsX];
    
    NSArray* constraintsY = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[_userName(==textHeight)]-textMargin-[_password(_userName)]-textMargin-[_nextBtn(==loginHeight)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_userName,_password,_nextBtn)];
    [self.view addConstraints:constraintsY];
}

- (void)switchVoipLogin {
    if ([DemoGlobalClass sharedInstance].loginAuthType == LoginAuthType_NormalAuth) {
        [DemoGlobalClass sharedInstance].loginAuthType = LoginAuthType_PasswordAuth;
        _userName.placeholder = @"输入账号";
        _password.hidden = NO;
    } else {
        _userName.placeholder = @"请输入手机号";
        _password.hidden = YES;
        [DemoGlobalClass sharedInstance].loginAuthType = LoginAuthType_NormalAuth;
    }
}
#pragma mark - 切换ip
-(void)changeIPAndAppToken:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        SwitchIPViewController *view = [[SwitchIPViewController alloc] init];
        [self.navigationController pushViewController:view animated:YES];
    }
}

#pragma mark - 登录
-(void)nextBtnClicked {
    [self.view endEditing:YES];

    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [_userName.text stringByTrimmingCharactersInSet:ws];
    
    if (trimmed.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"账号为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }

    //校验账号是否为手机号
//    if (![CommonTools  verifyMobilePhone:trimmed]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"账号不是手机号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
    
    NSString *userName = trimmed;
    NSString *password = [_password.text stringByTrimmingCharactersInSet:ws];
    if ([DemoGlobalClass sharedInstance].loginAuthType == LoginAuthType_PasswordAuth) {
        if (password.length==0) {
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"密码为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            return;
        }
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:lasttimeuserpwd];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:lasttimeuser];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 记录手机号
    ECLoginInfo * loginInfo = [[ECLoginInfo alloc] init];
    loginInfo.username = userName;
    loginInfo.userPassword = password;
    loginInfo.appKey = [DemoGlobalClass sharedInstance].appKey;
    loginInfo.appToken = [DemoGlobalClass sharedInstance].appToken;
    loginInfo.authType = [DemoGlobalClass sharedInstance].loginAuthType;
    loginInfo.mode = LoginMode_InputPassword;
    
    __weak typeof(self) weakself = self;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
    hud.labelText = @"正在登录...";
    hud.removeFromSuperViewOnHide = YES;
    
    [[DeviceDBHelper sharedInstance] openDataBasePath:userName];
    [DemoGlobalClass sharedInstance].isHiddenLoginError = NO;
    
    [[ECDevice sharedInstance] login:loginInfo completion:^(ECError *error){
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:error];
        if (error.errorCode == ECErrorType_NoError) {
            [DemoGlobalClass sharedInstance].userName = userName;
            [DemoGlobalClass sharedInstance].userPassword = password;
        }
    }];
}

//登录成功，页面跳转
-(void)LoginSuccess {
    MainViewController * lsvc = [[MainViewController alloc]init];
    [self.navigationController pushViewController:lsvc animated:YES];
}

//收起键盘
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
