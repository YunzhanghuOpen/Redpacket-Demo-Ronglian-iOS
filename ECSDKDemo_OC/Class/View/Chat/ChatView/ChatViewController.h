//
//  ChatViewController.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    UserState_None=0,
    UserState_Write,
    UserState_Record,
}UserState;
#define KNOTIFICATION_RefreshMoreData   @"KNOTIFICATION_RefreshMoreData"

@interface ChatViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
#pragma mark 红包-------------暴露出变量
    BOOL isGroup;
    dispatch_source_t _timer;
    UserState userInputState;
}
//回话ID
@property (nonatomic, strong) NSString* sessionId;
//消息列表
@property (nonatomic, strong) NSMutableArray* messageArray;

-(instancetype)initWithSessionId:(NSString*)sessionId;
@end
