//
//  TextFiledView.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/8/3.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFiledView : UIView
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *footText;
@property (nonatomic, strong) UIColor *footColor;

@property (nonatomic, assign) BOOL isHiddenFootText;

- (void)configText:(NSString *)placeholder footText:(NSString*)footText footColor:(UIColor*)footColor;
@end
