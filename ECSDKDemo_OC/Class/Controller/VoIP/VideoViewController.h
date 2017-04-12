//
//  VideoViewController.h
//  ytxVoIPDemo
//
//  Created by jzy on 15/3/10.
//  Copyright (c) 2015年 jzy. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface VideoViewController : UIViewController
{
    int hhInt;
    int mmInt;
    int ssInt;
    NSTimer *timer;
    NSInteger callStatus; //0:呼出视频 1:视频呼入 2:视频中
}

@property (nonatomic, copy) NSString *callID;
@property (nonatomic, copy) NSString *callerName;
@property (nonatomic, copy) NSString *voipNo;

//挂断电话
@property (nonatomic, strong) UIButton *hangUpButton;
//接听
@property (nonatomic, strong) UIButton *acceptButton;
@property (nonatomic, strong) UILabel *netStatusLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UILabel *p2pStatusLabel;

/*name:被叫人的姓名，用于界面的显示(自己选择)
 voipNop:被叫人的voip账号，用于网络免费电话(也可用于界面的显示,自己选择)
 type:视频类型
 */
- (instancetype)initWithCallerName:(NSString *)name andVoipNo:(NSString *)voipNo andCallstatus:(NSInteger)type;
@end
