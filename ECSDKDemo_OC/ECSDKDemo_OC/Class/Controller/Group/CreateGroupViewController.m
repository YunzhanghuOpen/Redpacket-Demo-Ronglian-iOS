//
//  CreateGroupViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/8.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "InviteJoinViewController.h"
#import "LeftLTextFiledView.h"
#import "SelectBtn.h"

#define publicButton_tag 1001
#define verifyButton_tag 1002

@interface CreateGroupViewController ()<SelectBtnDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIScrollView *myScrollView;
@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) UIPickerView *pickView;
@property (nonatomic, strong) SelectBtn *publicButton;
@property (nonatomic, strong) SelectBtn *verifyButton;
@end

@implementation CreateGroupViewController
{
    UITextField * _groupName;
    UITextField * _groupNotice;
    UITextField * _groupProvince;
    UITextField * _groupCity;
    UIButton * _groupType;
    
    UIImageView *_publicGroup;
    UIImageView *_authGroup;
    UIImageView *_privateGroup;
    
    NSInteger _groupMode;
    NSInteger _type;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self prepareUI];
}

#pragma mark - prepareUI
-(void)prepareUI
{
    self.title = @"建立新群组";
    
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem =leftItem;
    
    _groupMode = 1;
    NSDictionary *metrics = @{
                              @"marginH":@(KscreenW*0.1),
                              @"marginV":@16,
                              @"kscreenW":@(KscreenW)
                              };
    
    LeftLTextFiledView *groupNameView = [[LeftLTextFiledView alloc] init];
    groupNameView.leftLabel.text = @"名称:";
    groupNameView.textField.placeholder = @"群组名称";
    _groupName = groupNameView.textField;
    _groupName.tag = 1000;
    _groupName.delegate = self;
    [self.view addSubview:groupNameView];
    groupNameView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-marginH-[groupNameView]-marginH-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(groupNameView)]];
    
    LeftLTextFiledView *groupNoticeView = [[LeftLTextFiledView alloc] init];
    groupNoticeView.leftLabel.text = @"公告:";
    groupNoticeView.textField.placeholder = @"群组公告（选填）";
    [self.view addSubview:groupNoticeView];
    _groupNotice = groupNoticeView.textField;
    _groupNotice.tag = 1001;
    groupNoticeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-marginH-[groupNoticeView]-marginH-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(groupNoticeView)]];
    
    LeftLTextFiledView *groupProvinceView = [[LeftLTextFiledView alloc] init];
    groupProvinceView.leftLabel.text = @"省份:";
    groupProvinceView.textField.placeholder = @"请输入省份（选填）";
    [self.view addSubview:groupProvinceView];
    _groupProvince = groupProvinceView.textField;
    _groupProvince.tag = 1002;
    groupProvinceView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-marginH-[groupProvinceView]-marginH-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(groupProvinceView)]];

    LeftLTextFiledView *groupCity = [[LeftLTextFiledView alloc] init];
    groupCity.leftLabel.text = @"城市:";
    groupCity.textField.placeholder = @"请输入城市（选填）";
    [self.view addSubview:groupCity];
    _groupCity = groupCity.textField;
    _groupCity.tag = 1003;
    groupCity.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-marginH-[groupCity]-marginH-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(groupCity)]];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"类型：";
    [self.view addSubview:label];
    UIButton *typeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [typeBtn setTitle:@"选择类型" forState:UIControlStateNormal];
    [typeBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    [typeBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:typeBtn.currentTitle attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],NSForegroundColorAttributeName:[UIColor whiteColor]}] forState:UIControlStateNormal];
    [typeBtn addTarget:self  action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:typeBtn];
    _groupType = typeBtn;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    typeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-marginH-[label]-2-[typeBtn(==kscreenW@700)]-marginH-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(label,typeBtn)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:typeBtn attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:typeBtn attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    SelectBtn *publicButton = [SelectBtn buttonWithType:UIButtonTypeCustom];
    publicButton.title = @"公开群组";
    publicButton.delegate = self;
    [self.view addSubview:publicButton];
    _publicButton = publicButton;
    _publicButton.tag = publicButton_tag;
    publicButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    SelectBtn *verifyButton = [SelectBtn buttonWithType:UIButtonTypeCustom];
    verifyButton.title = @"验证群组";
    verifyButton.delegate = self;
    [self.view addSubview:verifyButton];
    _verifyButton = verifyButton;
    _verifyButton.tag = verifyButton_tag;
    verifyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-40-[publicButton(==100)]-[verifyButton(==100)]-40-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(publicButton,verifyButton)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:verifyButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:publicButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:verifyButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:publicButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

    UIButton *createGroupBtn = [[UIButton alloc] init];
    [createGroupBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    [createGroupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [createGroupBtn setTitle:@"创建" forState:UIControlStateNormal];
    [createGroupBtn addTarget:self action:@selector(createGroupBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createGroupBtn];
    createGroupBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-marginH-[createGroupBtn]-marginH-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(createGroupBtn)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-marginV-[groupNameView]-marginV-[groupNoticeView]-marginV-[groupProvinceView]-marginV-[groupCity]-marginV-[typeBtn(==30)]-marginV-[publicButton(==40)]-marginV-[createGroupBtn(==44@700)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(groupNameView,groupNoticeView,groupProvinceView,groupCity,typeBtn,publicButton,createGroupBtn)]];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    [self.view addGestureRecognizer:tap];
    _menuTitles = @[@"同学", @"朋友", @"同事", @"亲友", @"闺蜜", @"粉丝",@"基友", @"驴友", @"出国", @"家政",@"小区", @"比赛", @"其他"];
}

//收起键盘
-(void)keyboardHide {
    [self.view endEditing:YES];
    [_pickView removeFromSuperview];
    _pickView = nil;
}

-(void)returnClicked {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [_pickView removeFromSuperview];
    _pickView = nil;
}
#pragma mark - SelectBtnDelegate
- (void)onclickedBtn:(SelectBtn *)btn {
    [_pickView removeFromSuperview];
    _pickView = nil;
    (btn.tag == publicButton_tag)?[_verifyButton cancelBtnSelected]:[_publicButton cancelBtnSelected];
    _groupMode = (btn.tag == verifyButton_tag)?2:1;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _menuTitles.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _menuTitles[row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [_groupType setTitle:_menuTitles[row] forState:UIControlStateNormal];
    [_groupType setAttributedTitle:[[NSAttributedString alloc] initWithString:_groupType.currentTitle attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],NSForegroundColorAttributeName:[UIColor whiteColor]}] forState:UIControlStateNormal];
    _groupType.tag = row+1;
}
#pragma mark - BtnClick

-(void)selectType:(id)sender {
    [self.view endEditing:YES];
    if (_pickView==nil) {
        [_groupType resignFirstResponder];
        UIPickerView *pickView = [[UIPickerView alloc] init];
        pickView.delegate = self;
        pickView.dataSource = self;
        [self.view addSubview:pickView];
        _pickView = pickView;
        NSInteger row = _menuTitles.count/2;
        [_pickView selectRow:row-1 inComponent:0 animated:YES];
        [_groupType setTitle:_menuTitles[row-1] forState:UIControlStateNormal];
        [_groupType setAttributedTitle:[[NSAttributedString alloc] initWithString:_groupType.currentTitle attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],NSForegroundColorAttributeName:[UIColor whiteColor]}] forState:UIControlStateNormal];
        _groupType.tag = row;
        pickView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[pickView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(pickView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pickView(==pickViewV)]|" options:0 metrics:@{@"pickViewV":@(self.view.bounds.size.height*0.2)} views:NSDictionaryOfVariableBindings(pickView)]];
    }
}

-(void)createGroupBtn {
    [self.view endEditing:YES];
    [_pickView removeFromSuperview];
    _pickView = nil;

    if (_groupName.text.length <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请输入名称" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    _groupProvince.text = [_groupProvince.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _groupCity.text = [_groupCity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger maxLength = 50;
    if (_groupProvince.text.length > maxLength) {
        _groupProvince.text = [_groupProvince.text substringToIndex:maxLength];
    }
    
    if (_groupCity.text.length>maxLength) {
        _groupCity.text = [_groupCity.text substringToIndex:maxLength];
    }

    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在创建群组";
    hud.removeFromSuperViewOnHide = YES;
    
    ECGroup * newgroup = [[ECGroup alloc] init];
    newgroup.name = _groupName.text;
    newgroup.declared = _groupNotice.text;
    newgroup.mode = _groupMode;
    newgroup.province = _groupProvince.text;
    newgroup.city = _groupCity.text;
    newgroup.type = _groupType.tag;
    
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager createGroup:newgroup completion:^(ECError *error, ECGroup *group) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        if (error.errorCode == ECErrorType_NoError) {
            
            group.isNotice = YES;
            [[IMMsgDBAccess sharedInstance] addGroupIDs:@[group]];
            
            InviteJoinViewController * ijvc = [[InviteJoinViewController alloc]init];
            ijvc.groupId = group.groupId;
            ijvc.isDiscuss = NO;
            ijvc.isGroupCreateSuccess = NO;
            ijvc.backView = self;
            [strongSelf.navigationController pushViewController:ijvc animated:YES];

        } else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
            [strongSelf showToast:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
        }
    }];
}

//Toast错误信息
-(void)showToast:(NSString *)message {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}
@end
