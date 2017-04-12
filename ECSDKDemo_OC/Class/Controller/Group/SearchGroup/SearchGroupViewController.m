//
//  SearchGroupViewController.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 15/3/20.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "SearchGroupViewController.h"
#import "GroupListViewCell.h"
#import "ECDevice.h"
#import "ApplyJoinGroupViewController.h"

@interface SearchGroupViewController()<UISearchBarDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * resultArray;
@property (nonatomic, strong) UIView *refreshFootView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) ECGroupMatch *match;
@end


@implementation SearchGroupViewController
{
    ECGroupSearchType _searchType;
}

-(instancetype)initWithMode:(ECGroupSearchType)searchType
{
    if (self = [super init]) {
        _searchType = searchType;
    }
    return self;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    if (_searchType == ECGroupSearchType_GroupId) {
        self.title = @"精确查询";
    }else{
        self.title = @"模糊查询";
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    _resultArray = [NSMutableArray array];
    UIBarButtonItem * leftItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"title_bar_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }else{
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_bar_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnClicked)];
    }
    self.navigationItem.leftBarButtonItem =leftItem;

    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self setFootView];
}

- (void)setFootView {
    if (_refreshFootView==nil) {
        _refreshFootView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, 44)];
        _refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width*0.3,0, self.view.bounds.size.width*0.4, _refreshFootView.bounds.size.height)];
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadMoreGroup)];
        [_refreshFootView addGestureRecognizer:tapgesture];
        
        _refreshLabel.textAlignment = NSTextAlignmentCenter;
        _refreshLabel.text = @"加载更多";
        _refreshLabel.textColor = [UIColor blackColor];
        [_refreshFootView addSubview:_refreshLabel];
        
        _indicatorView.frame = CGRectMake(self.view.bounds.size.width*0.1,0, self.view.bounds.size.width*0.2, _refreshFootView.bounds.size.height);
        [_refreshFootView addSubview:_indicatorView];
        _indicatorView.hidden = YES;
        _indicatorView.color = [UIColor blackColor];
    }
}

- (void)loadMoreGroup {
    NSLog(@"loadMoreGroup");
    _indicatorView.hidden = NO;
    [_indicatorView startAnimating];
    _refreshLabel.text = @"正在加载数据...";
    
    _match.pageNo +=1;
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager searchPublicGroups:_match completion:^(ECError *error, NSArray *groups) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [_indicatorView stopAnimating];
        strongSelf.tableView.tableFooterView = nil;
        [strongSelf.resultArray  addObjectsFromArray:groups];
        [strongSelf.tableView reloadData];
        [[IMMsgDBAccess sharedInstance] addGroupIDs:groups];
        if (error.errorCode != ECErrorType_NoError) {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
            [strongSelf showToast:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
        } else if(groups.count==0) {
            [strongSelf showToast:@"获取到的群组为空"];
        }
    }];
}

-(void)hideKeyboard
{
    [self.view endEditing:YES];
}

-(void)returnClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [searchBar.text stringByTrimmingCharactersInSet:ws];
    if (trimmed.length==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"输入内容为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (_searchType == ECGroupSearchType_GroupId) {
        if (![searchBar.text hasPrefix:@"g"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"群组id的前缀是'g'" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            return;
        }
    } else {
        if (searchBar.text.length >20) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"输入的内容在20个字内" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            return;
        }
    }
    
    [self.view endEditing:YES];
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在搜索群组";
    hud.removeFromSuperViewOnHide = YES;

    ECGroupMatch *match = [[ECGroupMatch alloc] init];
    match.searchType = _searchType;
    match.keywords = searchBar.text;
    _match = match;
    
    __weak __typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].messageManager searchPublicGroups:match completion:^(ECError *error, NSArray *groups) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.resultArray addObjectsFromArray:groups];
        [strongSelf.tableView reloadData];
        [[IMMsgDBAccess sharedInstance] addGroupIDs:groups];
        [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:NO];
        if (error.errorCode != ECErrorType_NoError) {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
            [strongSelf showToast:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]];
        }
        else if(groups.count==0)
        {
            [strongSelf showToast:@"获取到的群组为空"];
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

#pragma mark - UITableViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideKeyboard];
    if (_tableView.tableFooterView==nil&&_match.searchType == ECGroupSearchType_GroupName) {
        _tableView.tableFooterView = _refreshFootView;
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self hideKeyboard];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_match.searchType == ECGroupSearchType_GroupName &&  scrollView.contentOffset.y == scrollView.contentSize.height-scrollView.frame.size.height) {
        [self loadMoreGroup];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 44.0f;
    }
    return 65.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==0) {
        return;
    }
    ECGroup* group = [self.resultArray objectAtIndex:indexPath.row-1];
    
    for (ECGroup* joingroup in [DeviceDBHelper sharedInstance].joinGroupArray) {
        if ([joingroup.groupId isEqualToString:group.groupId]) {
            
            UIViewController* viewController = [[NSClassFromString(@"ChatViewController") alloc] init];
            SEL aSelector = NSSelectorFromString(@"ECDemo_setSessionId:");
            if ([viewController respondsToSelector:aSelector]) {
                IMP aIMP = [viewController methodForSelector:aSelector];
                void (*setter)(id, SEL, NSString*) = (void(*)(id, SEL, NSString*))aIMP;
                setter(viewController, aSelector,group.groupId);
            }
            [self.navigationController setViewControllers:[NSArray arrayWithObjects:[self.navigationController.viewControllers objectAtIndex:0],viewController, nil] animated:YES];
            
            return;
        }
    }
    
    ApplyJoinGroupViewController * ajgvc = [[ApplyJoinGroupViewController alloc]init];
    ajgvc.applyGroup = group;
    [self.navigationController pushViewController:ajgvc animated:YES];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultArray.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row==0) {
        static NSString *GroupListViewsearchCellid = @"GroupListViewsearchCellidentifier";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:GroupListViewsearchCellid];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupListViewsearchCellid];
            UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
            searchBar.tag = 100;
            searchBar.delegate = self;
            [cell.contentView addSubview:searchBar];
        }
        UISearchBar *searchBar = (UISearchBar *)[cell.contentView viewWithTag:100];
        if (_searchType == ECGroupSearchType_GroupId) {
            searchBar.placeholder = @"请输入群组id";
            searchBar.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        }else{
            searchBar.placeholder = @"请输入群组名称";
            searchBar.keyboardType = UIKeyboardTypeDefault;
        }
        return cell;
    }
    static NSString *GroupListViewCellid = @"GroupListViewCellidentifier";
    GroupListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupListViewCellid];
    if (cell == nil) {
        cell = [[GroupListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupListViewCellid];
    }
    
    ECGroup *group = [self.resultArray objectAtIndex:indexPath.row-1];
    [cell setTableViewCellNameLabel:group.name andNumberLabel:group.groupId andIsJoin:NO andMemberNumber:0];
    
    return cell;
}
@end
