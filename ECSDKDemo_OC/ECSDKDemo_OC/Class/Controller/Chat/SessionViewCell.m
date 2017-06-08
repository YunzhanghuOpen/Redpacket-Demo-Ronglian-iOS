//
//  SessionViewCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "SessionViewCell.h"

@interface SessionViewCell ()
@property (nonatomic, strong, readonly) UIImageView *portraitImg;
@property (nonatomic, strong, readonly) UILabel *contentLabel;
@property (nonatomic, strong, readonly) UILabel *unReadLabel;
@property (nonatomic, strong, readonly) UILabel *dateLabel;
@property (nonatomic, strong, readonly) UIImageView *noPushImg;
@property (nonatomic, strong) UIButton *unReadMsgRed;
@property (nonatomic, strong, readonly) UILabel *atLabel;
@property (nonatomic, strong) NSLayoutConstraint *constraint;
@end

@implementation SessionViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self prepareCellUI];
    }
    return self;
}

-(void)prepareCellUI {
    
    _portraitImg = [[UIImageView alloc] init];
    _portraitImg.contentMode = UIViewContentModeScaleAspectFit;
    _portraitImg.image = [UIImage imageNamed:@"personal_portrait"];
    [self.contentView addSubview:_portraitImg];
    
    _unReadMsgRed = [UIButton buttonWithType:UIButtonTypeCustom];
    [_unReadMsgRed setBackgroundImage:[UIImage imageNamed:@"UN_ReadMsg"] forState:UIControlStateNormal];
    _unReadMsgRed.userInteractionEnabled = NO;
    [_unReadMsgRed sizeToFit];
    _unReadMsgRed.center = CGPointMake(CGRectGetMaxX(_portraitImg.frame),10.0f);
    [self.contentView addSubview:_unReadMsgRed];
    
    _dateLabel = [[UILabel alloc]init];
    _dateLabel.textColor = [UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.00f];
    _dateLabel.font = [UIFont systemFontOfSize:13.0f];
    _dateLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_dateLabel];
    
    _atLabel = [[UILabel alloc] init];
    _atLabel.textColor = [UIColor redColor];
    _atLabel.text = @"[有人@我]";
    _atLabel.backgroundColor = [UIColor clearColor];
    _atLabel.font = [UIFont systemFontOfSize:13.0f];
    _atLabel.textAlignment = NSTextAlignmentCenter;
    _atLabel.hidden = YES;
    [_atLabel sizeToFit];
    [self.contentView addSubview:_atLabel];
    
    _unReadLabel = [[UILabel alloc] init];
    _unReadLabel.backgroundColor = [UIColor redColor];
    _unReadLabel.textColor = [UIColor whiteColor];
    _unReadLabel.font = [UIFont systemFontOfSize:13];
    _unReadLabel.layer.cornerRadius =10;
    _unReadLabel.layer.masksToBounds = YES;
    
    _unReadLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_unReadLabel];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:_nameLabel];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:13.0f];
    _contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _contentLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_contentLabel];
    
    _noPushImg = [[UIImageView alloc] init];
    _noPushImg.image = [UIImage imageNamed:@"chat_group_notpush"];
    [self.contentView addSubview:_noPushImg];
    
    _portraitImg.translatesAutoresizingMaskIntoConstraints = NO;
    _unReadMsgRed.translatesAutoresizingMaskIntoConstraints = NO;
    _dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _atLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _unReadLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _noPushImg.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_portraitImg(==45)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_portraitImg)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_dateLabel(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_dateLabel)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_nameLabel(==25)][_atLabel(==15)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel,_atLabel)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nameLabel][_contentLabel(==_atLabel)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel,_contentLabel,_atLabel)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-35-[_unReadLabel(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_unReadLabel)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-37-[_noPushImg(==15)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_noPushImg)]];
    
    NSDictionary *metricsH = @{@"leftMargin":@20,@"imageSize":@45,@"dateLabelW":@100};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-leftMargin-[_portraitImg(==imageSize)]-[_nameLabel]-[_dateLabel(==dateLabelW)]-8-|" options:0 metrics:metricsH views:NSDictionaryOfVariableBindings(_portraitImg,_nameLabel,_dateLabel)]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_unReadMsgRed
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_portraitImg
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_unReadMsgRed
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_portraitImg
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:0]];
    
    self.constraint = [NSLayoutConstraint constraintWithItem:_atLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[_atLabel intrinsicContentSize].width];
    [self.contentView addConstraint:self.constraint];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_portraitImg]-[_atLabel][_contentLabel]-[_unReadLabel(==25)][_noPushImg(==15)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_portraitImg,_atLabel,_contentLabel,_unReadLabel,_noPushImg)]];
}

-(void)updateCellUI {
    
    if (self.session.type == 100) {
        _nameLabel.text = self.session.sessionId;
        _portraitImg.image = [UIImage imageNamed:@"logo80x80"];
    } else {
        
        _nameLabel.text = [[DemoGlobalClass sharedInstance] getOtherNameWithPhone:self.session.sessionId];
        _portraitImg.image = [[DemoGlobalClass sharedInstance] getOtherImageWithPhone:self.session.sessionId];
    }
    
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [self.session.text stringByTrimmingCharactersInSet:ws];
    _contentLabel.text = trimmed;
    
    _dateLabel.text = [self getDateDisplayString:self.session.dateTime];
    
    BOOL isNotice = YES;
    if ([self.session.sessionId hasPrefix:@"g"]) {
        isNotice = [[IMMsgDBAccess sharedInstance] isNoticeOfGroupId:self.session.sessionId];
        _noPushImg.hidden = isNotice;
    } else {
        _noPushImg.hidden = YES;
    }
    
    if (isNotice) {
        _unReadMsgRed.hidden = YES;
        if (self.session.unreadCount == 0) {
            _unReadLabel.hidden = YES;
        } else {
            _unReadLabel.text = [NSString stringWithFormat:@"%d",(int)self.session.unreadCount];
            _unReadLabel.hidden = NO;
        }
        _contentLabel.text = trimmed;
    } else {
        _unReadLabel.hidden = YES;
        _unReadMsgRed.hidden = YES;
        if (self.session.unreadCount > 0) {
            _unReadMsgRed.hidden = NO;
            _contentLabel.text = [NSString stringWithFormat:@"[%d条]%@",(int)self.session.unreadCount,trimmed];
        }
    }
    
    self.backgroundColor = self.session.isTop?[UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1]:[UIColor clearColor];
    
    [self.contentView removeConstraint:self.constraint];
    if (self.session.isAt) {
        _atLabel.text = @"[有人@我]";
        _atLabel.hidden = NO;
    } else {
        _atLabel.text = nil;
        [_atLabel setHidden:YES];
    }
    self.constraint = [NSLayoutConstraint constraintWithItem:_atLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[_atLabel intrinsicContentSize].width];
    [self.contentView addConstraint:self.constraint];
    [self.contentView updateConstraints];
}

//时间显示内容
-(NSString *)getDateDisplayString:(long long) miliSeconds{
    
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    } else {
        if (nowCmps.day==myCmps.day) {
            dateFmt.dateFormat = @"今天 HH:mm:ss";
        } else if((nowCmps.day-myCmps.day)==1) {
            dateFmt.dateFormat = @"昨天 HH:mm:ss";
        } else {
            dateFmt.dateFormat = @"MM-dd HH:mm:ss";
        }
    }
    return [dateFmt stringFromDate:myDate];
}
@end
