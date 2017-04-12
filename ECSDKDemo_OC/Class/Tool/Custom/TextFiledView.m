//
//  TextFiledView.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/8/3.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "TextFiledView.h"

#define roteH 0.7
#define roteW 0.8

@interface TextFiledView ()
@property (nonatomic, strong) UILabel *backgroundLabel;
@property (nonatomic, strong) UILabel *footLabel;
@end

@implementation TextFiledView

- (instancetype)init {
    if (self == [super init]) {
        _placeholder = @"输入占位符";
        _footColor = [UIColor greenColor];
        _footText = @"输入角标";
        _isHiddenFootText = NO;
        [self buildUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self==[super initWithFrame:frame]) {
        _placeholder = @"输入占位符";
        _footColor = [UIColor greenColor];
        _footText = @"输入角标";
        _isHiddenFootText = NO;
        [self buildUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _textField.placeholder = _placeholder;
    _backgroundLabel.backgroundColor = _footColor;
    if (!_isHiddenFootText) {
        _footLabel.text = _footText;
        if (_footLabel.text.length>4) {
            CGSize size = [_footLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height*(1-roteH)-2) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]} context:nil].size;
            CGRect frame =  _footLabel.frame;
            frame.size.width = size.width;
            frame.origin.x= self.frame.size.width - size.width;
            _footLabel.frame = frame;
        }
    } else {
        [_footLabel removeFromSuperview];
    }
}

- (void)configText:(NSString *)placeholder footText:(NSString *)footText footColor:(UIColor *)footColor {
    _placeholder = [placeholder copy];
    _footText = [footText copy];
    _footColor = footColor;
}

- (void)buildUI {
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*roteH)];
    textField.placeholder = _placeholder;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    textField.textAlignment = UITextBorderStyleRoundedRect;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addSubview:textField];
    _textField = textField;
    
    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(textField.frame), self.frame.size.width, 1)];
    backgroundLabel.backgroundColor = _footColor;
    [self addSubview:backgroundLabel];
    _backgroundLabel = backgroundLabel;
    
    UILabel *footLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*roteW, CGRectGetMaxY(backgroundLabel.frame)+1, self.frame.size.width*(1-roteW), self.frame.size.height*(1-roteH)-2)];
    footLabel.text = _footText;
    footLabel.textAlignment = NSTextAlignmentRight;
    footLabel.textColor = [UIColor redColor];
    footLabel.font = [UIFont systemFontOfSize:12.0f];
    [self addSubview:footLabel];
    _footLabel = footLabel;
}
@end
