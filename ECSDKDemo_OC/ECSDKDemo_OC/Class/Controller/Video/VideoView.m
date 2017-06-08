/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.yuntongxun.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
#import "VideoView.h"
#import <QuartzCore/QuartzCore.h>
@interface VideoView()


@end

@implementation VideoView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    // Initialization code
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    UIView* viewbg = [[UIView alloc] init];
    viewbg.backgroundColor = [UIColor clearColor];
    viewbg.contentMode = UIViewContentModeScaleAspectFill;
    self.bgView = viewbg;
    [self addSubview: self.bgView];
    viewbg.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bgView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bgView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_bgView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bgView)]];
    
    UILabel* lb2 = [[UILabel alloc] init];
    lb2.backgroundColor = [UIColor clearColor];
    lb2.font = [UIFont systemFontOfSize:18];
    lb2.textAlignment = NSTextAlignmentCenter;
    lb2.textColor = [UIColor whiteColor];
    lb2.text = @"";
    self.videoLabel = lb2;
    [self addSubview:self.videoLabel];
    _videoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_videoLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_videoLabel)]];
    
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.3;
    self.footView = view;
    [self addSubview:self.footView];
    _footView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_footView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_footView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_videoLabel(==30)]-1-[_footView(==22)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_footView,_videoLabel)]];

    
    UILabel* lb1 = [[UILabel alloc] init];
    lb1.backgroundColor = [UIColor clearColor];
    lb1.textAlignment = NSTextAlignmentLeft;
    lb1.font = [UIFont systemFontOfSize:16];
    lb1.textColor = [UIColor whiteColor];
    self.voipLabel = lb1;
    [self addSubview:self.voipLabel];
    _voipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-6-[_voipLabel]-6-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_voipLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_voipLabel(==22)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_voipLabel)]];
    
    UIImage* image = [UIImage imageNamed:@"videoConf43.png"];
    UIImageView* iv = [[UIImageView alloc] init];
    iv.image = image;
    [self addSubview:iv];
    self.icon = iv;
    iv.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_icon(==2)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_icon)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_icon(==10)]-6-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_icon)]];
    
    UIImage* imgChoose = [UIImage imageNamed:@"videoConf27.png"];
    UIImageView* imgViewChoose = [[UIImageView alloc] init];
    imgViewChoose.image = imgChoose;
    [self addSubview:imgViewChoose];
    self.ivChoose = imgViewChoose;
    _ivChoose.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_ivChoose]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_ivChoose)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_ivChoose]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_ivChoose)]];
    
    self.backgroundColor = [UIColor grayColor];
    self.clipsToBounds = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.strVoip)
    {
        if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(onChooseIndex:andVoipAccount:)]) {
            [self.myDelegate onChooseIndex:self.tag andVoipAccount:self.strVoip];
        }
    }
}

- (void)setBgViewImagePath:(NSString*)imgPath
{
    if (imgPath.length > 0)
    {
        if (self.imagePath.length > 0)
        {
            if ([imgPath isEqualToString:self.imagePath]) {
                return;
            } else {
                [[NSFileManager defaultManager] removeItemAtPath:self.imagePath error:nil];
            }
        }        
        
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imgPath];
        if (image)
        {
            self.bgView.layer.contents = (id) image.CGImage;
            self.bgView.layer.backgroundColor = [UIColor clearColor].CGColor;
        }
    }
    self.imagePath = imgPath;
}
@end

@implementation MultiVideoView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.remoteRatioHehgth = 4.0f;
        self.remoteRatioWidth = 3.0f;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.bgView.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.footView.translatesAutoresizingMaskIntoConstraints = NO;
    self.voipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.icon.translatesAutoresizingMaskIntoConstraints = NO;
    self.ivChoose.translatesAutoresizingMaskIntoConstraints = NO;

    if (frame.size.width>0 && frame.origin.x!=_originFrame.origin.x) {
        self.bgView.translatesAutoresizingMaskIntoConstraints = YES;
        self.videoLabel.translatesAutoresizingMaskIntoConstraints = YES;
        self.footView.translatesAutoresizingMaskIntoConstraints = YES;
        self.voipLabel.translatesAutoresizingMaskIntoConstraints = YES;
        self.icon.translatesAutoresizingMaskIntoConstraints = YES;
        self.ivChoose.translatesAutoresizingMaskIntoConstraints = YES;
        
        CGRect bgframe = CGRectMake(0, 0, frame.size.width, (frame.size.width / 3)*4);
        if(_remoteRatioHehgth/_remoteRatioWidth > bgframe.size.height/bgframe.size.width)
        {
            bgframe.size.width = (_remoteRatioWidth/_remoteRatioHehgth)*bgframe.size.height;
        } else {
            bgframe.size.height = (_remoteRatioHehgth/_remoteRatioWidth)*bgframe.size.width;
        }
        self.bgView.frame = bgframe;
        self.videoLabel.frame = CGRectMake(0 , frame.size.height/2-6, frame.size.width, 30);
        self.footView.frame = CGRectMake(0, frame.size.height-22, frame.size.width, 22);
        self.voipLabel.frame = CGRectMake(6, frame.size.height-22, frame.size.width-12, 22);
        self.icon.frame = CGRectMake(frame.size.width - 6 - 2, frame.size.height - 6 - 10, 2, 10);
        self.ivChoose.frame = bgframe;
    }
}

-(void)setVideoRatioChangedWithHeight:(CGFloat)height withWidth:(CGFloat)width
{
    NSLog(@"采用自动布局方式，如果需要按比例显示（需再此添加bgview的约束），demo默认采用view的模式UIViewContentModeScaleAspectFill");
}
@end
