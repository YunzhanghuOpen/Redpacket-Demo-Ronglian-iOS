//
//  GroupListViewCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "GroupListViewCell.h"

@implementation GroupListViewCell
{
    UIImageView *_headImage;
    UILabel *_nameLabel;
    UILabel *_numberLabel;
    UILabel *_joinLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self prepareCellUI];
    }
    return self;
}

-(void)prepareCellUI {
    
    _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 10.0f, 45.0f, 45.0f)];
    _headImage.translatesAutoresizingMaskIntoConstraints = NO;
    _headImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_headImage];
    _headImage.image = [UIImage imageNamed:@"group_head"];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_headImage(==45)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_headImage)]];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 10.0f, self.frame.size.width-70.0f-60.0f, 25.0f)];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:_nameLabel];
    
    _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y+_nameLabel.frame.size.height, _nameLabel.frame.size.width, 15.0f)];
    _numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _numberLabel.font = [UIFont systemFontOfSize:13.0f];
    _numberLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _numberLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_numberLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_nameLabel(==25)][_numberLabel(==15)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel,_numberLabel)]];
    
    
    _joinLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-60.0f, 17.5f, 60.0f, 30.0f)];
    _joinLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _joinLabel.text = @"已创建";
    _joinLabel.textAlignment = NSTextAlignmentCenter;
    _joinLabel.textColor = [UIColor colorWithRed:0.04f green:0.75f blue:0.40f alpha:1.00f];
    _joinLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_joinLabel];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-17.5-[_joinLabel(==30)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_joinLabel)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_nameLabel(==25)][_numberLabel(==15)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel,_numberLabel)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_headImage(==45)]-[_nameLabel]-[_joinLabel(==60)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_headImage,_nameLabel,_joinLabel)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_headImage]-[_numberLabel(_nameLabel)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_headImage,_nameLabel,_numberLabel)]];
}

-(void)setTableViewCellNameLabel:(NSString *)name andNumberLabel:(NSString *)number andIsJoin:(BOOL)isJoin andMemberNumber:(NSInteger)memberNum
{
    _nameLabel.text = name;
    if (_isDiscuss == NO) {
        _numberLabel.text = [NSString stringWithFormat:@"群组id:%@",number];
    } else {
        _numberLabel.text = [NSString stringWithFormat:@"讨论组id:%@",number];
    }
    _joinLabel.hidden = !isJoin;
    if (memberNum > 1) {
        _joinLabel.text = [NSString stringWithFormat:@"已加入"];
    }
}

@end
