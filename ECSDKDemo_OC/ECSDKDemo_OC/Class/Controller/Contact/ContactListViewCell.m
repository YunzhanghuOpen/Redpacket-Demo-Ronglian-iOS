//
//  ContactListViewCell.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ContactListViewCell.h"

@implementation ContactListViewCell

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
    
    _nameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_nameLabel];
    
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.font = [UIFont systemFontOfSize:13.0f];
    _numberLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_numberLabel];
    
    _portraitImg.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    NSDictionary *metricsH = @{@"leftMargin":@20,@"imageSize":@45};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-leftMargin-[_portraitImg(==imageSize)]-[_nameLabel]-|" options:0 metrics:metricsH views:NSDictionaryOfVariableBindings(_portraitImg,_nameLabel,_numberLabel)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_portraitImg]-[_numberLabel]-|" options:0 metrics:metricsH views:NSDictionaryOfVariableBindings(_portraitImg,_nameLabel,_numberLabel)]];
    
    NSDictionary *metricsV = @{@"topMargin":@10,@"imageSize":@45,@"nameH":@25,@"numberH":@15};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[_portraitImg(==imageSize)]" options:0 metrics:metricsV views:NSDictionaryOfVariableBindings(_portraitImg,_nameLabel,_numberLabel)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[_nameLabel(==nameH)][_numberLabel(==numberH)]" options:0 metrics:metricsV views:NSDictionaryOfVariableBindings(_portraitImg,_nameLabel,_numberLabel)]];
}

@end
