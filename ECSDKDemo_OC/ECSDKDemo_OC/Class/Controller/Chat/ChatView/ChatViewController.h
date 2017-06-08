//
//  ChatViewController.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController

@property (nonatomic, copy) NSString* sessionId;
-(instancetype)initWithSessionId:(NSString*)sessionId;
@end
