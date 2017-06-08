//
//  KeyboardView.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/8/11.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeyboardView;
@protocol KeyboardViewDelegate <NSObject>
@optional
- (void)onclickedBtn:(UIButton*)btn;
@end

@interface KeyboardView : UIView
@property (nonatomic, weak) id<KeyboardViewDelegate> delegate;
@end
