//
//  KeyboardView.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/8/11.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "KeyboardView.h"

@implementation KeyboardView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self prpareUI];
    }
    return self;
}

- (void)prpareUI {
    for (NSInteger i = 0; i<4; i++) {
        for (NSInteger j = 0; j<3; j++) {
            //Button alloc
            UIButton* numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
            numberButton.frame = CGRectMake(86.0f*j, 46.0f*i, 86.0f, 46.0f);            
            [numberButton addTarget:self action:@selector(dtmfNumber:) forControlEvents:UIControlEventTouchUpInside];
            //设置数字图片
            NSInteger numberNum = i*3+j+1;
            if (numberNum == 11) {
                numberNum = 0;
            } else if (numberNum == 12) {
                numberNum = 11;
            }
            NSString * numberImgName = [NSString stringWithFormat:@"keyboard_%0.2ld.png",(long)numberNum];
            NSString * numberImgOnName = [NSString stringWithFormat:@"keyboard_%0.2ld_on.png",(long)numberNum];
            numberButton.tag = 1000 + numberNum;
            
            [numberButton setImage:[UIImage imageNamed:numberImgName] forState:UIControlStateNormal];
            [numberButton setImage:[UIImage imageNamed:numberImgOnName] forState:UIControlStateHighlighted];
            
            [self addSubview:numberButton];
        }
    }
}

- (void)dtmfNumber:(UIButton*)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onclickedBtn:)]) {
        [self.delegate onclickedBtn:sender];
    }
}
@end
