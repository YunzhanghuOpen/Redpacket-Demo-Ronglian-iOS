//
//  UIButton
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/8/10.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectBtn;

@protocol SelectBtnDelegate <NSObject>
@optional
- (void)onclickedBtn:(SelectBtn*)btn;
@end

@interface SelectBtn: UIButton
@property (nonatomic, copy) NSString *title;
@property (nonatomic, weak) id<SelectBtnDelegate> delegate;
- (void)cancelBtnSelected;
@end
