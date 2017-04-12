//
//  CellBaseModel.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellBaseModel : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *detailText;
@property (nonatomic, strong) UIImage *iconImg;
@property (nonatomic, copy) NSString *modelType;

- (instancetype)initWithText:(NSString*)text detailText:(NSString*)detailText img:(UIImage*)iconImg modelType:(NSString*)modelType;

+ (instancetype)baseModelWithText:(NSString*)text detailText:(NSString*)detailText img:(UIImage*)iconImg modelType:(NSString*)modelType;
@end
