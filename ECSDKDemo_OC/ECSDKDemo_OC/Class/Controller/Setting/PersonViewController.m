//
//  PersonViewController.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "PersonViewController.h"
#import "CellBaseModel.h"
#import "RedpacketViewControl.h"
#import "WebBrowserBaseViewController.h"
#import <BQMM/BQMM.h>
#import "AFNHttpTool.h"

#define personCellHeight 70.0f
#define otherCellHeight 40.0f

@interface PersonViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *myTableview;

@property (nonatomic, strong) NSMutableDictionary *dataSourceDict;

@end

@implementation PersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我";
    self.view.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.96f alpha:1.00f];
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem =leftItem;
    
    _myTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, -10, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _myTableview.delegate =self;
    _myTableview.dataSource = self;
    _myTableview.tableHeaderView = [[UIView alloc] init];
    _myTableview.tableFooterView = [[UIView alloc] init];
    _myTableview.sectionHeaderHeight = 25.0f;
    _myTableview.sectionFooterHeight = 0;
    [self.view addSubview:_myTableview];
    
    NSString *userPhone = [DemoGlobalClass sharedInstance].userName;
    UIImage *img = [CommonTools compressImage:[UIImage imageNamed:@"RedpacketCellResource.bundle/redpacket_changeMoney_high"] withSize:CGSizeMake(20, 20)];
    UIImage *setImg = [CommonTools changeImage:[UIImage imageNamed:@"login_setting"] WithColor:[UIColor blueColor]];

    _dataSourceDict = [NSMutableDictionary dictionary];
    [_dataSourceDict setDictionary:@{
                                     @0:@[[CellBaseModel baseModelWithText:userPhone detailText:[DemoGlobalClass sharedInstance].nickName img:[[DemoGlobalClass sharedInstance] getOtherImageWithPhone:userPhone] modelType:nil]] ,
                                     @1:@[[CellBaseModel baseModelWithText:@"设置" detailText:nil img:setImg modelType:nil]],
                                     @2:@[[CellBaseModel baseModelWithText:@"关于云通讯" detailText:nil img:nil modelType:nil],[CellBaseModel baseModelWithText:@"意见与反馈" detailText:nil img:nil modelType:nil]]
                                     }];
    
    [_dataSourceDict setObject:@[[CellBaseModel baseModelWithText:@"表情" detailText:nil img:[UIImage imageNamed:@"EmotionsEmojiHL@2x"] modelType:nil],[CellBaseModel baseModelWithText:@"钱包" detailText:nil img:img modelType:nil]] forKey:@3];
<<<<<<< HEAD
    
=======
>>>>>>> alipayOpenUI
    [DemoGlobalClass sharedInstance].linkDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WebUrlPlist ofType:nil]];
}

-(void)returnClicked{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate和UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataSourceDict.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_dataSourceDict objectForKey:@(section)] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = [_dataSourceDict objectForKey:@(indexPath.section)];
    CellBaseModel *cellModel = array[indexPath.row];
    static NSString *cellId = @"personTableCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = cellModel.text;
    cell.detailTextLabel.text = cellModel.detailText;
    cell.imageView.image = cellModel.iconImg;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: {
            UIViewController* viewController = [[NSClassFromString(@"PersonInfoViewController") alloc] init];
            SEL aSelector = NSSelectorFromString(@"setIsDisplayBack:");
            if ([viewController respondsToSelector:aSelector]) {
                IMP aIMP = [viewController methodForSelector:aSelector];
                void (*setter)(id, SEL, BOOL) = (void(*)(id, SEL, BOOL))aIMP;
                setter(viewController, aSelector, YES);
            }
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 1: {
            id viewController = [[NSClassFromString(@"SettingViewController") alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 2: {
            if (indexPath.row==0) {
                id viewController = [[NSClassFromString(@"AboutViewController") alloc] init];
                [self.navigationController pushViewController:viewController animated:YES];
            } else if (indexPath.row==1) {
                WebBrowserBaseViewController *web = [[WebBrowserBaseViewController alloc] init];
                web.urlStr = [NSString stringWithFormat:@"%@%@/IMPlus/Suggestion.shtml?userName=%@",URLHead,[DemoGlobalClass sharedInstance].appKey,[DemoGlobalClass sharedInstance].userName];
                web.view.tag = Web_Base;
                [self.navigationController pushViewController:web animated:YES];
            }
        }
            break;
        case 3: {
            if (indexPath.row==0) {
                [[MMEmotionCentre defaultCentre] presentShopViewController];
            } else if (indexPath.row==1) {
                [RedpacketViewControl presentChangePocketViewControllerFromeController:self];
            }
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section==0?personCellHeight:otherCellHeight;
}

@end
