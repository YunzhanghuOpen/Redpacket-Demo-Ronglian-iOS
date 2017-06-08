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

#import "RoomNameViewController.h"
#import "ChatRoomViewController.h"

#define TAG_ALERTVIEW_ChatroomPwd  9999
#define TAG_ALERTVIEW_ChatroomName 9998
#define mariginV 30
#define TextFheight 35
#define Lheight 20
#define Btnheight 30
#define CreateBtnheight 40
#define roate 0.25

@interface RoomNameViewController ()
{
    NSInteger iVoiceMod;
    NSInteger bAutoDelete;
}
@property (nonatomic,strong)UITextField *nameTextField;
@property (nonatomic,strong)UITextField *pwdTextField;
@property (nonatomic, strong) UIScrollView *myScrollView;
@end

@implementation RoomNameViewController
@synthesize nameTextField;
@synthesize pwdTextField;
@synthesize backView;

- (void)loadView
{
    self.title = @"创建房间";
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] ;
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];

    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.contentSize = self.view.bounds.size;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.scrollsToTop = NO;
    [self.view addSubview :scrollView];
    self.myScrollView = scrollView;
    self.myScrollView.delegate = self;
    
    CGFloat Twidth = KscreenW*0.7;
    CGFloat Lwidth = KscreenW*0.2;
    CGFloat marighH = KscreenW*0.1/2;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(marighH, Lheight,Lwidth, Lheight)];
    label.text = @"房间名称";
    label.textColor = [UIColor grayColor];
    [self.myScrollView addSubview:label];
    
    UITextField *name = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame),0, Twidth, TextFheight)];
    CGPoint point = name.center;
    point.y = CGRectGetMidY(label.frame);
    name.center = point;
    name.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    name.backgroundColor = [UIColor whiteColor];
    name.borderStyle = UITextBorderStyleRoundedRect;
    name.placeholder = @"请输入房间名";
    self.nameTextField = name;
    self.nameTextField.tag = TAG_ALERTVIEW_ChatroomName;
    self.nameTextField.delegate = self;
    [self.myScrollView addSubview:name];
    
    UILabel *labelPwd = [[UILabel alloc] initWithFrame:CGRectMake(marighH, CGRectGetMaxY(label.frame)+mariginV, Lwidth, Lheight)];
    labelPwd.text = @"房间密码";
    labelPwd.textColor = [UIColor grayColor];
    [self.myScrollView addSubview:labelPwd];
    
    UITextField *pwd = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelPwd.frame), 0, Twidth, TextFheight)];
    point = pwd.center;
    point.y = CGRectGetMidY(labelPwd.frame);
    pwd.center = point;
    pwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    pwd.backgroundColor = [UIColor whiteColor];
    pwd.borderStyle = UITextBorderStyleRoundedRect;
    pwd.placeholder = @"请输入1-8位密码（可选）";
    [pwd setSecureTextEntry:YES];
    pwd.keyboardType = UIKeyboardTypeDefault;
    self.pwdTextField = pwd;
    self.pwdTextField.tag = TAG_ALERTVIEW_ChatroomPwd;
    self.pwdTextField.delegate = self;
    [self.myScrollView addSubview:pwd];
    

    UILabel *labelVoiceMod = [[UILabel alloc] initWithFrame:CGRectMake(marighH, CGRectGetMaxY(labelPwd.frame)+mariginV, Lwidth, Lheight)];
    labelVoiceMod.text = @"声音设置";
    labelVoiceMod.textColor = [UIColor grayColor];
    [self.myScrollView addSubview:labelVoiceMod];
    
    NSArray *voiceModArray = [[NSArray alloc]initWithObjects:@"仅有背景音",@"全部提示音",@"无声",nil];
     UISegmentedControl *voiceModSgControl = [[UISegmentedControl alloc]initWithItems:voiceModArray];
    voiceModSgControl.frame = CGRectMake(CGRectGetMaxX(labelVoiceMod.frame), 0, Twidth, TextFheight);
    point = voiceModSgControl.center;
    point.y = CGRectGetMidY(labelVoiceMod.frame);
    voiceModSgControl.center = point;
    [voiceModSgControl setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f],NSForegroundColorAttributeName:[UIColor whiteColor],NSBackgroundColorDocumentAttribute:[UIColor blackColor]} forState:UIControlStateNormal];
    voiceModSgControl.selectedSegmentIndex = 1;//设置默认选择项索引
    voiceModSgControl.tag = 1001;
    [self.myScrollView addSubview:voiceModSgControl];
    [voiceModSgControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];

    UILabel *labelAutoDelete = [[UILabel alloc] initWithFrame:CGRectMake(marighH, CGRectGetMaxY(labelVoiceMod.frame)+mariginV, Lwidth, Lheight)];
    labelAutoDelete.text = @"房间类型";
    labelAutoDelete.textColor = [UIColor grayColor];
    [self.myScrollView addSubview:labelAutoDelete];
    
    NSArray *autoDeleteSgArray = [[NSArray alloc]initWithObjects:@"自动删除房间",@"不自动删除",nil];
    UISegmentedControl *autoDeleteSgControl = [[UISegmentedControl alloc]initWithItems:autoDeleteSgArray];
    autoDeleteSgControl.frame = CGRectMake(CGRectGetMaxX(labelVoiceMod.frame), 0, Twidth, TextFheight);
    point = autoDeleteSgControl.center;
    point.y = CGRectGetMidY(labelAutoDelete.frame);
    autoDeleteSgControl.center = point;
    autoDeleteSgControl.selectedSegmentIndex = 0;//设置默认选择项索引
    autoDeleteSgControl.tag = 1002;
    [autoDeleteSgControl setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f],NSForegroundColorAttributeName:[UIColor whiteColor],NSBackgroundColorDocumentAttribute:[UIColor blackColor]} forState:UIControlStateNormal];
    [self.myScrollView addSubview:autoDeleteSgControl];
    [autoDeleteSgControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(marighH, CGRectGetMaxY(labelAutoDelete.frame)+mariginV, KscreenW-marighH*2, Btnheight);
    UIImage* img = [UIImage imageNamed:@"choose_on.png"];
    btn.tag = 1;
    [btn setImage: img forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [btn setTitle:@"创建人退出时自动解散(单击选择)" forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnChooseIsAutoClose:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.myScrollView addSubview:btn];
    
    UIButton* btnIsAutoJoin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnIsAutoJoin.frame = CGRectMake(marighH, CGRectGetMaxY(btn.frame)+mariginV, KscreenW-marighH*2, Btnheight);
    UIImage* imgIsAutoJoin = [UIImage imageNamed:@"choose.png"];
    btnIsAutoJoin.tag = 1;
    [btnIsAutoJoin setImage: imgIsAutoJoin forState:(UIControlStateNormal)];
    btnIsAutoJoin.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [btnIsAutoJoin setTitle:@"创建后自动加入会议(单击选择)" forState:UIControlStateNormal];
    btnIsAutoJoin.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btnIsAutoJoin setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnIsAutoJoin addTarget:self action:@selector(btnChooseIsAutoJoin:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.myScrollView addSubview:btnIsAutoJoin];
    
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createBtn.frame = CGRectMake(KscreenW*roate, CGRectGetMaxY(btnIsAutoJoin.frame)+mariginV, KscreenW*(1-roate*2), CreateBtnheight);
    createBtn.titleLabel.textColor = [UIColor whiteColor];
    [createBtn setTitle:@"创建" forState:UIControlStateNormal];
    [createBtn setBackgroundImage:[UIImage imageNamed:@"button03_off"] forState:UIControlStateNormal];
    [createBtn setBackgroundImage:[UIImage imageNamed:@"button03_on"] forState:UIControlStateHighlighted];
    [createBtn addTarget:self action:@selector(createCharRoom:) forControlEvents:UIControlEventTouchUpInside];
    [self.myScrollView addSubview:createBtn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    [self.view addGestureRecognizer:tap];
    [self.navigationController.navigationBar addGestureRecognizer:tap];
    [self.myScrollView addGestureRecognizer:tap];
    
    _myScrollView.contentSize = CGSizeMake(KscreenW, CGRectGetMaxY(createBtn.frame)+marighH);
    iVoiceMod = 2;
    isAutoClose = YES;
    bAutoDelete = YES;
    isAutoJoin = NO;
    square = 30;
}

-(void)returnClicked {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardHide
{
    [self.view endEditing:YES];
    [self.navigationController.navigationBar endEditing:YES];
    [self.myScrollView endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.nameTextField becomeFirstResponder];
}
#pragma mark - 选择属性方法
-(void)segmentAction:(UISegmentedControl *)Seg {
    
    [self.view endEditing:YES];
    switch (Seg.selectedSegmentIndex)
    {
        case 0:
            if(Seg.tag == 1001) {
                iVoiceMod = 1;
            } else {
                bAutoDelete = YES;
            }
            break;
        case 1:
            if(Seg.tag == 1001) {
                iVoiceMod = 2;
            } else {
                bAutoDelete = NO;
            }
            break;
        case 2:
            if(Seg.tag == 1001) {
                iVoiceMod = 3;
            }
            break;
        default:
            break;
    }
}

-(void)btnChooseIsAutoJoin:(id)sender {
    
    [self.view endEditing:YES];
    UIButton* btn = sender;
    if (btn.tag == 0) {
        btn.tag = 1;
        UIImage* img = [UIImage imageNamed:@"choose_on.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoJoin = YES;
    } else {
        btn.tag = 0;
        UIImage* img = [UIImage imageNamed:@"choose.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoJoin = NO;
    }
}

-(void)btnChooseIsAutoClose:(id)sender {
    
    UIButton* btn = sender;
    if (btn.tag == 0) {
        btn.tag = 1;
        UIImage* img = [UIImage imageNamed:@"choose_on.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoClose = YES;
    } else {
        btn.tag = 0;
        UIImage* img = [UIImage imageNamed:@"choose.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoClose = NO;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (range.length == 1) {
        return YES;
    }
    
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];
    if (textField.tag == TAG_ALERTVIEW_ChatroomPwd) {
        return [text length] <= 8;
    }
    return [text length] <= 50;
}

#pragma mark - 创建语音会议房间
- (void)createCharRoom:(id)sender
{
    if (nameTextField.text.length > 0 ) {
        if (isAutoJoin) {
            //创建并加入
            ChatRoomViewController *chatroomview = [[ChatRoomViewController alloc] init];
            chatroomview.navigationItem.hidesBackButton = YES;
            chatroomview.curChatroomId = nil;
            chatroomview.roomname = nameTextField.text;
            chatroomview.backView = self.backView;
            chatroomview.isCreator = YES;
            [self.navigationController pushViewController:chatroomview animated:YES];
            [chatroomview createChatroomWithChatroomName:nameTextField.text andPassword:pwdTextField.text andSquare:square andKeywords:@""  andIsAutoClose:isAutoClose andVoiceMod:iVoiceMod andAutoDelete:bAutoDelete andIsAutoJoin:isAutoJoin];
        } else {
            ECCreateMeetingParams *params = [[ECCreateMeetingParams alloc] init];
            params.meetingType = ECMeetingType_MultiVoice;
            params.meetingName = nameTextField.text;
            params.meetingPwd = pwdTextField.text;
            params.square = square;
            params.autoClose = isAutoClose;
            params.autoDelete = bAutoDelete;
            params.voiceMod = iVoiceMod;
            params.autoJoin = isAutoJoin;
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"请稍后...";
            hud.removeFromSuperViewOnHide = YES;
            
            __weak __typeof(self) weakSelf = self;
            [[ECDevice sharedInstance].meetingManager createMultMeetingByType:params completion:^(ECError *error, NSString *meetingNumber) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                if (error.errorCode == ECErrorType_NoError) {
                    [self returnClicked];
                } else {
                    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"创建会议失败";
                    hud.margin = 10.0f;
                    hud.removeFromSuperViewOnHide = YES;
                    [hud hide:YES afterDelay:2];
                }
            }];
        }
    } else {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入会议名称";
        hud.margin = 10.0f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    }
}
@end
