//
//  CellBaseModel.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "CellBaseModel.h"

@implementation CellBaseModel

- (instancetype)initWithText:(NSString *)text detailText:(NSString *)detailText img:(UIImage *)iconImg modelType:(NSString*)modelType {
    if (self==[super init]) {
        _text = [text copy];
        _detailText = [detailText copy];
        _iconImg = iconImg?:nil;
        _modelType = [modelType copy];
    }
    return self;
}

+ (instancetype)baseModelWithText:(NSString *)text detailText:(NSString *)detailText img:(UIImage *)iconImg modelType:(NSString*)modelType {
    return [[self alloc] initWithText:text detailText:detailText img:iconImg modelType:modelType];
}
@end
