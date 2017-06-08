//
//  SessionViewCell.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSession.h"

@interface SessionViewCell : UITableViewCell

@property (nonatomic, strong, readonly) UILabel *nameLabel;

@property (nonatomic, strong) ECSession *session;

-(void)updateCellUI;

@end
