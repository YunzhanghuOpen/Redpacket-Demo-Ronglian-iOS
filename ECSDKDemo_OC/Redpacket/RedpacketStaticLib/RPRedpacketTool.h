//
//  RPRedpacketTool.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/7/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YZHRedpacketBridge.h"

typedef void(^RedpacketSuccessBlock)(void);


UIKIT_EXTERN NSString *const RedpacketSDKVersion;


/*---------------------------------------
 *  Defines
 ---------------------------------------*/

#define rpWeakSelf __weak typeof(self) weakSelf = self

#define rpURL(...) [NSURL URLWithString:__VA_ARGS__]
#define rpString(...) [NSString stringWithFormat:__VA_ARGS__]
#define rpRedpacketBundleResource(__resource__) rpString(@"RedPacketResource.bundle/%@", __resource__)

#define rpImageNamed(__image__)  [UIImage imageNamed:__image__]
#define rpRedpacketBundleImage(__image__) rpImageNamed(rpRedpacketBundleResource(__image__))

#define rpResourceAtBundle(__bundle__, __resource__) rpString(__bundle__ stringByAppendingPathComponent:__resource__)

#define RPDebugOpen  [YZHRedpacketBridge sharedBridge].isDebug

#define RPDebug(...)  if(RPDebugOpen) {\
    NSLog(__VA_ARGS__);\
}\

/*---------------------------------------
 *  Const
 ---------------------------------------*/

/**
 *  红包字体颜色
 */
static uint const rp_textColorGray = 0x9e9e9e;

/**
 *  背景颜色
 */
static uint const rp_backGroundColorGray = 0xe3e3e3;


UIKIT_STATIC_INLINE UIImage * rp_redpacketImageWithName(NSString *name)
{
    NSString *imageName = [@"RedpacketCellResource.bundle/" stringByAppendingString:name];
    return [UIImage imageNamed:imageName];
}

UIKIT_STATIC_INLINE UIColor * rp_hexColor(uint color)
{
    float r = (color&0xFF0000) >> 16;
    float g = (color&0xFF00) >> 8;
    float b = (color&0xFF);
    
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
}

UIKIT_STATIC_INLINE BOOL rp_isEmpty(id thing) {
    return thing == nil || [thing isEqual:[NSNull null]]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

UIImage *imageWithColor(UIColor *color);

/**
 *  网络请求，请求头, 是否需要添加token。【Token请求不需要添加Token】
 */
NSDictionary *getRequestHeaderNeedToken(BOOL need);

@interface RPRedpacketTool : NSObject



@end
