//
//  ApplyJoinGroupViewController.m
//  ECSDKDemo_OC
//
//  Created by jzy on 14/12/10.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ApplyJoinGroupViewController.h"

@interface ApplyJoinGroupViewController ()<UIAlertViewDelegate>
@end

const char KAlertGroup;

@implementation ApplyJoinGroupViewController
{
    UILabel * tellLabel;
    UILabel * groupLabel;
    UILabel * groupOwner;
    UILabel * groupName;
    UILabel * groupNum;
    
}

#pragma mark - prepareUI

-(void)prepareUI {
    
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;

    UILabel * label1 = [[UILabel alloc]init];
    label1.translatesAutoresizingMaskIntoConstraints = NO;
    label1.backgroundColor =[UIColor colorWithRed:0.97f green:0.96f blue:0.97f alpha:1.00f];
    label1.text = @"  群简介";
    [self.view addSubview:label1];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[label1]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label1)]];
    
    groupName = [[UILabel alloc]init];
    groupName.translatesAutoresizingMaskIntoConstraints = NO;
    groupName.font = [UIFont systemFontOfSize:18];
    groupName.textColor =[UIColor colorWithRed:0.39f green:0.39f blue:0.39f alpha:1.00f];
    [self.view addSubview:groupName];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[groupName]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(groupName)]];
    
    groupOwner = [[UILabel alloc]init];
    groupOwner.translatesAutoresizingMaskIntoConstraints = NO;
    groupOwner.font = [UIFont systemFontOfSize:18];
    groupOwner.textColor =[UIColor colorWithRed:0.39f green:0.39f blue:0.39f alpha:1.00f];
    [self.view addSubview:groupOwner];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[groupOwner]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(groupOwner)]];
    
    groupLabel = [[UILabel alloc]init];
    groupLabel.translatesAutoresizingMaskIntoConstraints = NO;
    groupLabel.font = [UIFont systemFontOfSize:18];
    groupLabel.textColor =[UIColor colorWithRed:0.39f green:0.39f blue:0.39f alpha:1.00f];
    [self.view addSubview:groupLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[groupLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(groupLabel)]];

    UILabel * label = [[UILabel alloc]init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.backgroundColor =[UIColor colorWithRed:0.97f green:0.96f blue:0.97f alpha:1.00f];
    label.text = @"  群公告";
    [self.view addSubview:label];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[label]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    
    tellLabel = [[UILabel alloc]init];
    tellLabel.translatesAutoresizingMaskIntoConstraints = NO;
    tellLabel.numberOfLines = 0;
    tellLabel.font = [UIFont systemFontOfSize:18];
    tellLabel.textColor =[UIColor colorWithRed:0.39f green:0.39f blue:0.39f alpha:1.00f];
    [self.view addSubview:tellLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tellLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tellLabel)]];

    UIButton * joinBtn = [[UIButton alloc]init];
    joinBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [joinBtn setTitle:@"申请加入" forState:UIControlStateNormal];
    [joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [joinBtn setBackgroundImage:[CommonTools createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    [joinBtn addTarget:self action:@selector(joinBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:joinBtn];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[joinBtn(==300)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(joinBtn)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:joinBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label1(==50)][groupName(==40)][groupOwner(==40)][groupLabel(==40)][label(==50)][tellLabel]-20-[joinBtn(==50)]-90-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label1,groupName,groupOwner,groupLabel,label,tellLabel,joinBtn)]];
}

#pragma mark - BtnClick
-(void)joinBtnClicked {
    if (self.applyGroup.mode == ECGroupPermMode_NeedIdAuth) {
        [self popDeclaredAlertView:self.applyGroup];
    }else if (self.applyGroup.mode == ECGroupPermMode_DefaultJoin){
        [self joinGroup:self.applyGroup.groupId withReason:nil];
    }
}

-(void)returnClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self prepareUI];
    
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager getGroupDetail:self.applyGroup.groupId completion:^(ECError *error, ECGroup *group) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (group.declared.length == 0) {
            tellLabel.text = @"  该群组无公告";
        }else{
            tellLabel.text = [NSString stringWithFormat:@"  %@",group.declared];
        }
        groupLabel.text =[NSString stringWithFormat:@"  群ID:%@",group.groupId]; ;
        groupOwner.text =[NSString stringWithFormat:@"  群主:%@",group.owner];
        groupName.text = [NSString stringWithFormat:@"  群名字:%@",group.name];
        
        strongSelf.title = group.name;
        strongSelf.applyGroup.name = group.name;
        strongSelf.applyGroup.owner = group.owner;
        strongSelf.applyGroup.declared = group.declared;
    }];
}

-(void)popDeclaredAlertView:(ECGroup*)group
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"理由" message:@"加入群组理由" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    objc_setAssociatedObject(alertView, &KAlertGroup, group, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        ECGroup* group = objc_getAssociatedObject(alertView, &KAlertGroup);
        [self joinGroup:group.groupId withReason:textField.text];
    }
}

-(void)joinGroup:(NSString*)groupId withReason:(NSString*)reason
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍等...";
    hud.removeFromSuperViewOnHide = YES;
    
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager joinGroup:groupId reason:reason completion:^(ECError *error, NSString *groupId) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [MBProgressHUD hideHUDForView:strongSelf.view animated:NO];
        if (error.errorCode==ECErrorType_Have_Joined) {
            
            UIViewController* viewController = [[NSClassFromString(@"ChatViewController") alloc] init];
            SEL aSelector = NSSelectorFromString(@"ECDemo_setSessionId:");
            if ([viewController respondsToSelector:aSelector]) {
                IMP aIMP = [viewController methodForSelector:aSelector];
                void (*setter)(id, SEL, NSString*) = (void(*)(id, SEL, NSString*))aIMP;
                setter(viewController, aSelector, strongSelf.applyGroup.groupId);
            }
            [strongSelf.navigationController setViewControllers:[NSArray arrayWithObjects:[strongSelf.navigationController.viewControllers objectAtIndex:0],viewController, nil] animated:YES];
            
        }else if(error.errorCode==ECErrorType_NoError){
            if (strongSelf.applyGroup.mode == ECGroupPermMode_DefaultJoin) {
                
                UIViewController* viewController = [[NSClassFromString(@"ChatViewController") alloc] init];
                SEL aSelector = NSSelectorFromString(@"ECDemo_setSessionId:");
                if ([viewController respondsToSelector:aSelector]) {
                    IMP aIMP = [viewController methodForSelector:aSelector];
                    void (*setter)(id, SEL, NSString*) = (void(*)(id, SEL, NSString*))aIMP;
                    setter(viewController, aSelector, strongSelf.applyGroup.groupId);
                }
                [strongSelf.navigationController setViewControllers:[NSArray arrayWithObjects:[strongSelf.navigationController.viewControllers objectAtIndex:0],viewController, nil] animated:YES];
                
            }else{
                [strongSelf showToast:@"申请加入已发出，请等待群主同意请求"];
            }
        } else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
            [strongSelf showToast:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
        }
    }];
}

//Toast错误信息
-(void)showToast:(NSString *)message
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = message;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}
@end
