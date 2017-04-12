//
//  SessionViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "SessionViewController.h"
#import "SessionViewCell.h"
#import "ECSession.h"

extern CGFloat NavAndBarHeight;
@interface SessionViewController()

@property (nonatomic, strong) NSMutableArray *sessionArray;
@property (nonatomic, strong) ECGroupNoticeMessage *message;
@property (nonatomic, strong) UIView * linkview;
@end

@implementation SessionViewController{
    UITableViewCell * _memoryCell;
    LinkJudge linkjudge;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,self.view.frame.size.width,self.view.frame.size.height-NavAndBarHeight) style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    self.sessionArray = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:KNOTIFICATION_onMesssageChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:KNOTIFICATION_onReceivedGroupNotice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prepareDisplay) name:@"mainviewdidappear" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linkSuccess:) name:KNOTIFICATION_onConnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:KNotice_ReloadSessionGroup object:nil];
    
    [self autoLoginClient];
    [[ECDevice sharedInstance].messageManager getTopSessionLists:^(ECError *error, NSArray *topContactLists) {
        if (error.errorCode == ECErrorType_NoError) {
            [[DeviceDBHelper sharedInstance].topContactLists removeAllObjects];
            [[DeviceDBHelper sharedInstance].topContactLists addObjectsFromArray:topContactLists];
            for (NSString *sessionId in topContactLists) {
                [[IMMsgDBAccess sharedInstance] updateIsTopSessionId:sessionId isTop:YES];
            }
            [DeviceDBHelper sharedInstance].sessionDic = nil;
        }
    }];
}

-(void)updateLoginStates:(LinkJudge)link{
    
    if (link == success) {
        _tableView.tableHeaderView = nil;
        [_linkview removeFromSuperview];
        _linkview = nil;
    } else {
        [_linkview removeFromSuperview];
        _linkview = nil;
        
        _linkview = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 45.0f)];
        _linkview.backgroundColor = [UIColor colorWithRed:1.00f green:0.87f blue:0.87f alpha:1.00f];
        if (link==failed) {
            UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 8.0f, 30.0f, 30.0f)];
            image.image = [UIImage imageNamed:@"messageSendFailed"];
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(50.0f, 0.0f, self.view.frame.size.width-50.0f , 45.0f)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:14.0f];
            label.textColor =[UIColor colorWithRed:0.46f green:0.40f blue:0.40f alpha:1.00f];
            label.text = @"无法连接到服务器";
            [_linkview addSubview:image];
            [_linkview addSubview:label];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginWithHaveUserLogined)];
            [_linkview addGestureRecognizer:tap];

        } else if(link == linking) {
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(15.0f, 0.0f, self.view.frame.size.width-10.0f , 45.0f)];
            label.font = [UIFont systemFontOfSize:14.0f];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"连接中...";
            label.textColor =[UIColor colorWithRed:0.46f green:0.40f blue:0.40f alpha:1.00f];
            [_linkview addSubview:label];
        }
        _tableView.tableHeaderView = _linkview;
    }
}

-(void)linkSuccess:(NSNotification *)link {
    ECError* error = link.object;
    if (error.errorCode == ECErrorType_NoError) {
        [self updateLoginStates:success];
    } else if (error.errorCode == ECErrorType_Connecting) {
        [self updateLoginStates:linking];
    } else {
        [self updateLoginStates:failed];
    }
}

-(void)prepareDisplay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.sessionArray removeAllObjects];
        [self.sessionArray addObjectsFromArray:[[DeviceDBHelper sharedInstance] getMyCustomSession]];
        [self.tableView reloadData];
    });
}

-(void)autoLoginClient {
    
    if ([DemoGlobalClass sharedInstance].isAutoLogin) {
        [DemoGlobalClass sharedInstance].isAutoLogin = NO;
        [self loginWithHaveUserLogined];
    }
}

- (void)loginWithHaveUserLogined {
    NSString *userName = [DemoGlobalClass sharedInstance].userName;
    if (userName && [DemoGlobalClass sharedInstance].isLogin == NO) {
        [self updateLoginStates:linking];
        
        ECLoginInfo * loginInfo = [[ECLoginInfo alloc] init];
        loginInfo.username = userName;
        loginInfo.userPassword = [DemoGlobalClass sharedInstance].userPassword;
        loginInfo.appToken = [DemoGlobalClass sharedInstance].appToken;
        loginInfo.appKey = [DemoGlobalClass sharedInstance].appKey;
        loginInfo.authType = [DemoGlobalClass sharedInstance].loginAuthType;
        loginInfo.mode = LoginMode_AutoInputLogin;
        
        [[ECDevice sharedInstance] login:loginInfo completion:^(ECError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:error];
        }];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sessionArray.count == 0) {
        return 170.0f;
    }
    return 65.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.sessionArray.count == 0) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ECSession* session = [self.sessionArray objectAtIndex:indexPath.row];
    session.isAt = NO;
    [[IMMsgDBAccess sharedInstance] updateSession:session];
    session.unreadCount = 0;
    if (session.type == 100) {
        [[DeviceDBHelper sharedInstance] markGroupMessagesAsRead];
        UIViewController* viewController = [[NSClassFromString(@"GroupNoticeViewController") alloc] init];
        [self.mainView pushViewController:viewController animated:YES];
        
    } else {
        
        UIViewController* viewController = [[NSClassFromString(@"ChatViewController") alloc] init];
        SEL aSelector = NSSelectorFromString(@"ECDemo_setSessionId:");
        if ([viewController respondsToSelector:aSelector]) {
            IMP aIMP = [viewController methodForSelector:aSelector];
            void (*setter)(id, SEL, NSString*) = (void(*)(id, SEL, NSString*))aIMP;
            setter(viewController, aSelector,session.sessionId);
        }
        [self.mainView pushViewController:viewController animated:YES];
        
    }
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.sessionArray.count == 0) {
        return 1;
    }
    return _sessionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sessionArray.count == 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        static NSString *noMessageCellid = @"sessionnomessageCellidentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noMessageCellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noMessageCellid];
            
            UILabel *noMsgLabel = [[UILabel alloc] init];
            noMsgLabel.text = @"暂无聊天消息";
            noMsgLabel.textColor = [UIColor darkGrayColor];
            noMsgLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:noMsgLabel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            noMsgLabel.translatesAutoresizingMaskIntoConstraints = NO;
            
            [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[noMsgLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noMsgLabel)]];
            [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[noMsgLabel(==50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noMsgLabel)]];

        }
        return cell;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    static NSString *sessioncellid = @"sessionCellidentifier";
    SessionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sessioncellid];
    
    if (cell == nil) {
        cell = [[SessionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sessioncellid];
        
        UILongPressGestureRecognizer  * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
        cell.nameLabel.tag =100;
        [cell.contentView addGestureRecognizer:longPress];
        cell.contentView.userInteractionEnabled = YES;
    }
    
    ECSession* session = [self.sessionArray objectAtIndex:indexPath.row];
    cell.session = session;
    [cell updateCellUI];
    
    return cell;
}

-(void)cellLongPress:(UILongPressGestureRecognizer * )longPress{
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [longPress locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if(indexPath == nil) return ;
        SessionViewCell  * cell = (SessionViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:cell.nameLabel.text delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
        NSString *str = cell.session.isTop?@"取消置顶":@"置顶会话";
        if (cell.session.type !=100) {
            [sheet addButtonWithTitle:str];
        }
        [sheet showInView:cell];
        _memoryCell = cell;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;{
    NSIndexPath * path = [_tableView indexPathForCell:_memoryCell];
    ECSession* session = [self.sessionArray objectAtIndex:path.row];
    if (buttonIndex == 0) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"删除该会话";
        hud.margin = 10.0f;
        hud.removeFromSuperViewOnHide = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (session.type == 100) {
                [[DeviceDBHelper sharedInstance] clearGroupMessageTable];
            } else {
                [[DeviceDBHelper sharedInstance] deleteAllMessageOfSession:session.sessionId];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.sessionArray removeObjectAtIndex:path.row];
                _memoryCell = nil;
                [_tableView reloadData];
            });
        });
    } else if (buttonIndex==2 && session.type !=100) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        BOOL isTop = [buttonTitle isEqualToString:@"置顶会话"];
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = buttonTitle;
        hud.margin = 10.0f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1];
        __weak  __typeof(self) weakSelf = self;
        [[ECDevice sharedInstance].messageManager setSession:session.sessionId IsTop:isTop completion:^(ECError *error, NSString *seesionId) {
            __strong  __typeof(weakSelf)strongSelf = weakSelf;
            if (error.errorCode == ECErrorType_NoError && isTop) {
                [[DeviceDBHelper sharedInstance].topContactLists addObject:session.sessionId];
                NSSet *set = [NSSet setWithArray:[DeviceDBHelper sharedInstance].topContactLists];
                [[DeviceDBHelper sharedInstance].topContactLists removeAllObjects];
                [[DeviceDBHelper sharedInstance].topContactLists addObjectsFromArray:set.allObjects];
                session.isTop = isTop;
                NSIndexPath *zeroIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                if (path.row!=0) {
                    [strongSelf.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:path.row inSection:0] toIndexPath:zeroIndexPath];
                }
            }
            isTop==YES?:[[DeviceDBHelper sharedInstance].topContactLists removeObject:session.sessionId];
            [[IMMsgDBAccess sharedInstance] updateIsTopSessionId:session.sessionId isTop:isTop];
            [DeviceDBHelper sharedInstance].sessionDic = nil;
            [strongSelf prepareDisplay];
        }];
    }
}

@end
