//
//  UIButton
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/8/10.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "SelectBtn.h"

@implementation SelectBtn
{
    BOOL _sel;
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prpareUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setTitle:_title forState:UIControlStateNormal];
    [self setAttributedTitle:[[NSAttributedString alloc] initWithString:self.currentTitle attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0],NSForegroundColorAttributeName:[UIColor blackColor]}] forState:UIControlStateNormal];
}

- (void)prpareUI {
    [self setImage:[UIImage imageNamed:@"select_account_list_unchecked"] forState:UIControlStateNormal];
    [self setTitle:@"title设置" forState:UIControlStateNormal];
    self.selected = YES;
    [self setAttributedTitle:[[NSAttributedString alloc] initWithString:self.currentTitle attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0],NSForegroundColorAttributeName:[UIColor blackColor]}] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(chageModeBtn) forControlEvents:UIControlEventTouchUpInside];
}

- (void)chageModeBtn {
    BOOL sel = !_sel;
    self.selected = sel;;
    _sel = sel;
    self.selected?[self setImage:[UIImage imageNamed:@"select_account_list_checked"] forState:UIControlStateNormal]:[self setImage:[UIImage imageNamed:@"select_account_list_unchecked"] forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onclickedBtn:)]) {
        [self.delegate onclickedBtn:self];
    }
}

- (void)cancelBtnSelected {
    _sel = NO;
    self.selected = NO;
    [self setImage:[UIImage imageNamed:@"select_account_list_unchecked"] forState:UIControlStateNormal];
}
@end
