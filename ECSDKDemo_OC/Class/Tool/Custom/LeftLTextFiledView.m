//
//  LeftLTextFiledView.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/8/10.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "LeftLTextFiledView.h"

@implementation LeftLTextFiledView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepareUI];
    }
    return self;
}

- (void)prepareUI {
    _leftLabel = [[UILabel alloc] init];
    _leftLabel.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:_leftLabel];
    _leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftLabel)]];
    _textField = [[UITextField alloc] init];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_textField];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textField]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_textField)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_leftLabel]-2-[_textField(==_textFieldW@700)]|" options:0 metrics:@{@"_textFieldW":@(KscreenW)} views:NSDictionaryOfVariableBindings(_textField,_leftLabel)]];
}
@end
