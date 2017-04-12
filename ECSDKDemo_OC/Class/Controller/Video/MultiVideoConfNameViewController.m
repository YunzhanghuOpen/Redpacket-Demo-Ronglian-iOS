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

#import "MultiVideoConfNameViewController.h"
#import "MultiVideoConfViewController.h"

#define mariginV 30
#define TextFheight 35
#define Lheight 20
#define Btnheight 30
#define CreateBtnheight 40
#define roate 0.25


@interface MultiVideoConfNameViewController ()
{
    NSInteger iVoiceMod;
    BOOL bAutoDelete;
}
@property (nonatomic,retain)UITextField *nameTextField;
@end

@implementation MultiVideoConfNameViewController

- (void)loadView
{
    isAutoClose = YES;
    iVoiceMod = 2;
    bAutoDelete = YES;
    isAutoJoin = YES;
    self.title = @"创建视频会议房间";
    
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];

    UIBarButtonItem *leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"videoConf03"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(popBack)];
        
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"videoConf03"] style:UIBarButtonItemStyleDone target:self action:@selector(popBack)];
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(marighH, 10.0f, KscreenW, Lheight)];
    label.text = @"房间名称:";
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    [self.myScrollView addSubview:label];
    
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoConfPortrait"]];
    imageview.frame = CGRectMake(marighH, CGRectGetMaxY(label.frame)+5, KscreenW*0.1, KscreenW*0.1);
    [self.myScrollView addSubview:imageview];
    
    UITextField *name = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageview.frame)+5, CGRectGetMinY(imageview.frame), KscreenW-CGRectGetMaxX(imageview.frame)-marighH, KscreenW*0.1)];
    name.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    name.keyboardAppearance = UIKeyboardAppearanceAlert;
    name.borderStyle = UITextBorderStyleRoundedRect;
    name.background = [UIImage imageNamed:@"videoConfInput"];
    name.delegate = self;
    name.textColor = [UIColor blackColor];
    name.placeholder = @"请输入房间名称";
    name.attributedPlaceholder = [[NSAttributedString alloc] initWithString:name.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    name.clearButtonMode = UITextFieldViewModeWhileEditing;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        [name setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.nameTextField = name;
    [self.myScrollView addSubview:name];
    
    UILabel *labelVoiceMod = [[UILabel alloc] initWithFrame:CGRectMake(marighH, CGRectGetMaxY(name.frame)+mariginV, Lwidth, Lheight)];
    labelVoiceMod.text = @"声音设置";
    if (KscreenW<=320.0f) {
        labelVoiceMod.font = [UIFont systemFontOfSize:13.0f];
    }
    labelVoiceMod.textColor = [UIColor grayColor];
    [self.myScrollView addSubview:labelVoiceMod];
    
    NSArray *voiceModArray = [[NSArray alloc]initWithObjects:@"仅有背景音",@"全部提示音",@"无声",nil];
    UISegmentedControl *voiceModSgControl = [[UISegmentedControl alloc]initWithItems:voiceModArray];
    voiceModSgControl.frame = CGRectMake(CGRectGetMaxX(labelVoiceMod.frame), 0, Twidth, TextFheight);
    CGPoint point = voiceModSgControl.center;
    point.y = CGRectGetMidY(labelVoiceMod.frame);
    voiceModSgControl.center = point;
    [voiceModSgControl setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f],NSForegroundColorAttributeName:[UIColor whiteColor],NSBackgroundColorDocumentAttribute:[UIColor blackColor]} forState:UIControlStateNormal];
    voiceModSgControl.selectedSegmentIndex = iVoiceMod-1;//设置默认选择项索引
    voiceModSgControl.tag = 1001;
    [self.myScrollView addSubview:voiceModSgControl];
    [voiceModSgControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *labelAutoDelete = [[UILabel alloc] initWithFrame:CGRectMake(marighH, CGRectGetMaxY(labelVoiceMod.frame)+mariginV, Lwidth, Lheight)];
    labelAutoDelete.text = @"房间类型";
    if (KscreenW<=320.0f)
        labelAutoDelete.font = [UIFont systemFontOfSize:13.0f];
    labelAutoDelete.textColor = [UIColor grayColor];
    [self.myScrollView addSubview:labelAutoDelete];
    
    NSArray *autoDeleteSgArray = [[NSArray alloc]initWithObjects:@"自动删除房间",@"不自动删除",nil];
    UISegmentedControl *autoDeleteSgControl = [[UISegmentedControl alloc]initWithItems:autoDeleteSgArray];
    autoDeleteSgControl.frame = CGRectMake(CGRectGetMaxX(labelVoiceMod.frame), 0, Twidth, TextFheight);
    point = autoDeleteSgControl.center;
    point.y = CGRectGetMidY(labelAutoDelete.frame);
    autoDeleteSgControl.center = point;
    autoDeleteSgControl.selectedSegmentIndex = bAutoDelete?0:1;//设置默认选择项索引
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
    [createBtn setImage:[UIImage imageNamed:@"videoConfCreate2"] forState:UIControlStateNormal];
    [createBtn setImage:[UIImage imageNamed:@"videoConfCreate2_on"] forState:UIControlStateHighlighted];
    [createBtn addTarget:self action:@selector(createVideoConference:) forControlEvents:UIControlEventTouchUpInside];
    [self.myScrollView addSubview:createBtn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    [self.view addGestureRecognizer:tap];
    [self.navigationController.navigationBar addGestureRecognizer:tap];
    [self.myScrollView addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.nameTextField becomeFirstResponder];
}

#pragma mark -页面点击处理的方法
- (void)keyboardHide
{
    [self.view endEditing:YES];
    [self.navigationController.navigationBar endEditing:YES];
    [self.myScrollView endEditing:YES];
}

- (void)segmentAction:(UISegmentedControl *)Seg
{
    [self.nameTextField resignFirstResponder];
    switch (Seg.selectedSegmentIndex)
    {
        case 0:
            if(Seg.tag == 1001)
                iVoiceMod = 1;
            else
                bAutoDelete = YES;
            break;
        case 1:
            if(Seg.tag == 1001)
                iVoiceMod = 2;
            else
                bAutoDelete = NO;
            break;
        case 2:
            if(Seg.tag == 1001)
                iVoiceMod = 3;
            break;
        default:
            break;
    }
}

-(void)btnChooseIsAutoJoin:(id)sender
{
    [self.nameTextField resignFirstResponder];
    UIButton* btn = sender;
    if (btn.tag == 0)
    {
        btn.tag = 1;
        UIImage* img = [UIImage imageNamed:@"choose_on.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoJoin = YES;
    }
    else
    {
        btn.tag = 0;
        UIImage* img = [UIImage imageNamed:@"choose.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoJoin = NO;
    }
}

-(void)btnChooseIsAutoClose:(id)sender
{
    [self.nameTextField resignFirstResponder];
    UIButton* btn = sender;
    if (btn.tag == 0)
    {
        btn.tag = 1;
        UIImage* img = [UIImage imageNamed:@"choose_on.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoClose = YES;
    }
    else
    {
        btn.tag = 0;
        UIImage* img = [UIImage imageNamed:@"choose.png"];
        [btn setImage: img forState:(UIControlStateNormal)];
        isAutoClose = NO;
    }
}

#pragma mark -返回
- (void)popBack
{
    [self closeProgress];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.background = [UIImage imageNamed:@"videoConfInput_on.png"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.background = [UIImage imageNamed:@"videoConfInput.png"];
}

#pragma mark -蒙版
-(void)showProgress:(NSString *)labelText{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = labelText;
    hud.mode = MBProgressHUDModeText;
    hud.margin = 30.0f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

-(void)closeProgress{
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark -private method
- (void)createVideoConference:(id)sender
{
    [self.nameTextField resignFirstResponder];
    if (self.nameTextField.text.length > 0 )
    {
        if (isAutoJoin)
        {
            MultiVideoConfViewController *VideoConfview = [[MultiVideoConfViewController alloc] init];
            VideoConfview.navigationItem.hidesBackButton = YES;
            VideoConfview.curVideoConfId = nil;
            VideoConfview.Confname = self.nameTextField.text;
            VideoConfview.backView = self.backView;
            VideoConfview.isCreator = YES;
            VideoConfview.isAutoClose = isAutoClose;
            [self.navigationController pushViewController:VideoConfview animated:YES];
            [VideoConfview createMultiVideoWithAutoClose:isAutoClose andIsPresenter:NO andiVoiceMod:iVoiceMod andAutoDelete:bAutoDelete andIsAutoJoin:isAutoJoin];
            
        }
        else
        {
            ECCreateMeetingParams *params = [[ECCreateMeetingParams alloc]init];
            params.meetingName = self.nameTextField.text;
            params.meetingPwd = @"";
            params.meetingType = ECMeetingType_MultiVideo;
            params.square = 5;
            params.autoClose = isAutoClose;
            params.autoJoin = NO;
            params.autoDelete = bAutoDelete;
            params.voiceMod = iVoiceMod;
            params.keywords = @"";
            
            MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"请稍后...";
            hud.removeFromSuperViewOnHide = YES;
            
            __weak __typeof(self) weakSelf = self;
            [[ECDevice sharedInstance].meetingManager createMultMeetingByType:params completion:^(ECError *error, NSString *meetingNumber) {
                
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf closeProgress];
                if(error.errorCode ==ECErrorType_NoError) {
                    
                    [strongSelf.navigationController popToViewController:strongSelf.backView animated:YES];
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
    }
    else
    {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入会议名称";
        hud.margin = 10.0f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    }
}
- (void)dealloc
{
    self.nameTextField = nil;
    self.myScrollView = nil;
    self.backView = nil;
}
@end
