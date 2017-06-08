//
//  AboutViewController.m
//  ECSDKDemo_OC
//
//  Created by admin on 16/3/9.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "AboutViewController.h"
#import "CellBaseModel.h"
#import "WebBrowserBaseViewController.h"

#define OfficalWeb @"OfficalWeb"
#define IMPlusWeb @"IMPlusWeb"
#define DeveloperDocWeb @"DeveloperDocWeb"
#define ReleaseNoteWeb @"ReleaseNoteWeb"
#define ErrorWeb @"ErrorWeb"
#define DowloadWeb @"DowloadWeb"

@interface AboutViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *myTableview;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"关于";
    self.view.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.96f alpha:1.00f];

    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    } else {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem =leftItem;
    
    _myTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _myTableview.delegate =self;
    _myTableview.dataSource = self;
    _myTableview.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_myTableview];
    
    UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"logo80x80.png"];
    imageBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-image.size.width)/2, 10.0f, image.size.width, image.size.height);
    [imageBtn setImage:image forState:UIControlStateNormal];
    imageBtn.contentMode = UIViewContentModeScaleAspectFill;
    _myTableview.tableHeaderView = imageBtn;
    _myTableview.sectionHeaderHeight = image.size.height+10;

    _dataArray = @[[CellBaseModel baseModelWithText:@"官方网站" detailText:nil img:nil modelType:OfficalWeb],
                   [CellBaseModel baseModelWithText:@"IMPlus平台详细功能" detailText:nil img:nil modelType:IMPlusWeb],
                   [CellBaseModel baseModelWithText:@"开发文档" detailText:nil img:nil modelType:DeveloperDocWeb],
                   [CellBaseModel baseModelWithText:@"更新日志" detailText:nil img:nil modelType:ReleaseNoteWeb],
                   [CellBaseModel baseModelWithText:@"错误码" detailText:nil img:nil modelType:ErrorWeb],
                   ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"aboutTableCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor clearColor];
    }
    CellBaseModel *cellModel = [_dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = cellModel.text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WebBrowserBaseViewController *web = [[WebBrowserBaseViewController alloc] init];
    CellBaseModel *cellModel = [_dataArray objectAtIndex:indexPath.row];
    web.urlStr  = [[DemoGlobalClass sharedInstance].linkDict objectForKey:cellModel.modelType];
    web.view.tag = Web_Base;
    [self.navigationController pushViewController:web animated:YES];
}

- (void)returnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
