//
//  ReadMessageViewController.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/6/16.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ReadMessageViewController.h"
#import "AFNHttpTool.h"

#define Color [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1]

@interface ReadMessageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIView *segHeadView;
@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *memberArray;
@property (nonatomic, strong) NSMutableArray *cacheUnReadArray;
@property (nonatomic, strong) NSMutableArray *cacheReadArray;
@property (nonatomic, strong) ECMessage *message;
@end

@implementation ReadMessageViewController
{
    NSInteger readCount;
    NSInteger unReadCount;
}

-(instancetype)initWithMessage:(ECMessage*)message {
    if (self == [super init]) {
        _memberArray = [NSMutableArray array];
        _cacheUnReadArray = [NSMutableArray array];
        _cacheReadArray = [NSMutableArray array];;
        _message = message;
        [self queryMessageReadCount];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息接收人列表";
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];

    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7){
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(popViewController)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popViewController)];
    }
    self.navigationItem.leftBarButtonItem =leftItem;
    
    _segHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0f)];
    _segHeadView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_segHeadView];
  
    unReadCount = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%@",_message.messageId,CellMessageUnReadCount]];
    readCount = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_%@",_message.messageId,CellMessageReadCount]];
    NSString *item1 = [NSString stringWithFormat:@"未读%@",unReadCount>0?[NSString stringWithFormat:@"(%ld)",(long)unReadCount]:@""];
    NSString *item2 = [NSString stringWithFormat:@"已读%@",readCount>0?[NSString stringWithFormat:@"(%ld)",(long)readCount]:@""];
    _segment = [[UISegmentedControl alloc] initWithItems:@[item1,item2]];
    _segment.selectedSegmentIndex = 0;
    _segment.frame = CGRectMake(10, 7.0f, self.view.bounds.size.width-10*2, 30.0f);
    [_segment addTarget:self action:@selector(onclickedSegment:) forControlEvents:UIControlEventValueChanged];
    [_segHeadView addSubview:_segment];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_segHeadView.frame), self.view.bounds.size.width, self.view.bounds.size.height-CGRectGetMaxY(_segHeadView.frame)) style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = Color;
    _tableView.tableHeaderView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)queryMessageReadCount {
    
    __weak typeof(self)weakSelf = self;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
    hud.labelText = @"请求中...";
    hud.removeFromSuperViewOnHide = YES;

    __block BOOL isRead = NO;
    __block BOOL isUnread = NO;
    [[AFNHttpTool sharedInstanced] queryMessageReadStatus:1 msgId:_message.messageId pageSize:50 pageNo:1 completion:^(NSString *err, NSArray *array, NSInteger totalSize) {
        if (err.integerValue != 0) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请求失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        } else {
            isRead = YES;
            [[NSUserDefaults standardUserDefaults] setInteger:totalSize forKey:[NSString stringWithFormat:@"%@_%@",_message.messageId,CellMessageReadCount]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [_cacheReadArray addObjectsFromArray:array];
            if (isRead && isUnread) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }
        }
    }];
    [[AFNHttpTool sharedInstanced] queryMessageReadStatus:2 msgId:_message.messageId pageSize:50 pageNo:1 completion:^(NSString *err, NSArray *array, NSInteger totalSize) {
        
        if (err.integerValue != 0) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请求失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        } else {
            isUnread = YES;
            [[NSUserDefaults standardUserDefaults] setInteger:totalSize forKey:[NSString stringWithFormat:@"%@_%@",_message.messageId,CellMessageUnReadCount]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [_memberArray addObjectsFromArray:array];
            [_cacheUnReadArray addObjectsFromArray:array];
            [weakSelf.tableView reloadData];
            if (isRead && isUnread) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }
        }
    }];
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onclickedSegment:(UISegmentedControl*)segment {
    NSLog(@"%ld",(long)segment.selectedSegmentIndex);
    switch (segment.selectedSegmentIndex) {
        case 0: {
            [_memberArray removeAllObjects];
            [_memberArray addObjectsFromArray:_cacheUnReadArray];
            [self.tableView reloadData];
        }
            break;
        case 1: {
            [_memberArray removeAllObjects];
            [_memberArray addObjectsFromArray:_cacheReadArray];
            [self.tableView reloadData];
        }
            break;
  
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _memberArray.count;
}

static NSString *cellId = @"cellId";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    if (cell==nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    id contact = [_memberArray objectAtIndex:indexPath.row];
    NSString *memberId = nil;
    if ([contact isKindOfClass:[ECReadMessageMember class]]) {
        ECReadMessageMember *member = (ECReadMessageMember*)contact;
        memberId = member.userName;
    } else if ([contact isKindOfClass:[NSString class]]) {
        memberId = (NSString*)contact;
    }
    NSString *nickName = [[DemoGlobalClass sharedInstance] getOtherNameWithPhone:memberId];
    cell.imageView.layer.cornerRadius = 15;
    cell.imageView.layer.masksToBounds = YES;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",memberId,@"iconReadMessage"]];
    UIImage *image = [UIImage imageWithData:data];
    if (image == nil) {
        image = [CommonTools createImageWithColor:[UIColor orangeColor] withSize:CGSizeMake(30, 30) text: nickName.length>2?[nickName substringFromIndex:nickName.length-2]:nickName];
        [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:[NSString stringWithFormat:@"%@_%@",memberId,@"iconReadMessage"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    cell.imageView.image = image;
    cell.textLabel.text = nickName;
    return cell;
}

@end
